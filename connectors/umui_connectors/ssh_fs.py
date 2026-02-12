"""SSH/SFTP implementation of the FileSystem protocol.

Provides ``SshFileSystem`` — a drop-in replacement for ``LocalFileSystem``
that operates over an SSH tunnel chain. Designed for the 3-hop path
local -> bp14 -> archer2 -> puma2.

Key design points:
- Background daemon thread running an asyncio event loop.
- Lazy connection: first filesystem operation triggers connect.
- Context manager: ``with SshFileSystem(target) as fs: ...``
- Multi-hop tunnel using asyncssh ``connect_ssh()`` chain.
- Atomic writes via temp file + rename.
- Single automatic reconnect attempt on connection loss.
"""

from __future__ import annotations

import asyncio
import contextlib
import fnmatch
import threading
import uuid
from posixpath import dirname, join
from typing import TYPE_CHECKING, TypeVar

import asyncssh

if TYPE_CHECKING:
    from collections.abc import Callable, Coroutine

    from umui_connectors.config import SshTarget

_T = TypeVar("_T")

# Errors that indicate the connection is broken and worth retrying.
_CONNECTION_ERRORS = (
    asyncssh.ConnectionLost,
    asyncssh.DisconnectError,
    ConnectionError,
    TimeoutError,
)

# Mapped errors raised intentionally by our SFTP methods — never retry these.
_MAPPED_ERRORS = (FileNotFoundError, PermissionError)


class SshConnectionError(Exception):
    """Raised when SSH connection cannot be established or is lost."""


class SshFileSystem:
    """SFTP-based filesystem implementing the ``FileSystem`` protocol.

    Usage::

        target = SshTarget(name='puma2', final_host='puma2', ...)
        with SshFileSystem(target) as fs:
            data = fs.read_bytes('/path/to/file')

    The class manages a background asyncio event loop on a daemon thread.
    All public methods are synchronous, bridging to async SFTP operations
    via ``run_coroutine_threadsafe``.
    """

    def __init__(self, target: SshTarget) -> None:
        self._target = target
        self._loop: asyncio.AbstractEventLoop | None = None
        self._thread: threading.Thread | None = None
        self._conn: asyncssh.SSHClientConnection | None = None
        self._sftp: asyncssh.SFTPClient | None = None
        self._tunnel_conns: list[asyncssh.SSHClientConnection] = []
        self._lock = threading.Lock()
        self._closed = False

    # -- Context manager --------------------------------------------------

    def __enter__(self) -> SshFileSystem:
        self._start_loop()
        return self

    def __exit__(
        self,
        exc_type: type[BaseException] | None,
        exc_val: BaseException | None,
        exc_tb: object,
    ) -> None:
        self.close()

    # -- Lifecycle --------------------------------------------------------

    def _start_loop(self) -> None:
        """Start the background event loop thread if not already running."""
        if self._loop is not None:
            return
        loop = asyncio.new_event_loop()
        self._loop = loop
        thread = threading.Thread(
            target=loop.run_forever, daemon=True, name="ssh-fs-loop"
        )
        thread.start()
        self._thread = thread

    def _run(
        self,
        make_coro: Callable[[], Coroutine[object, object, _T]],
    ) -> _T:
        """Run an async operation with lazy connect and single-retry.

        Args:
            make_coro: A zero-arg callable that returns a fresh coroutine
                       each time (needed because coroutines can't be re-awaited).
        """
        self._start_loop()
        assert self._loop is not None
        try:
            return self._run_once(make_coro)
        except _MAPPED_ERRORS:
            raise
        except _CONNECTION_ERRORS:
            self._reset_connection()
            try:
                return self._run_once(make_coro)
            except _CONNECTION_ERRORS as exc:
                raise SshConnectionError(
                    f"Lost connection to {self._target.final_host}: {exc}"
                ) from exc

    def _run_once(
        self,
        make_coro: Callable[[], Coroutine[object, object, _T]],
    ) -> _T:
        """Run a single coroutine, connecting first if needed."""
        assert self._loop is not None

        async def _with_connect() -> _T:
            await self._ensure_connected()
            return await make_coro()

        future = asyncio.run_coroutine_threadsafe(_with_connect(), self._loop)
        return future.result(timeout=self._target.connect_timeout + 60)

    async def _ensure_connected(self) -> None:
        """Establish the SSH tunnel chain and open SFTP if not connected."""
        if self._sftp is not None:
            return
        await self._connect()

    async def _connect(self) -> None:
        """Build multi-hop SSH tunnel and open SFTP session."""
        timeout = self._target.connect_timeout
        kwargs: dict[str, object] = {
            "known_hosts": None,
            "login_timeout": timeout,
        }
        if self._target.username:
            kwargs["username"] = self._target.username

        all_hosts = [*self._target.jump_hosts, self._target.final_host]
        conn: asyncssh.SSHClientConnection | None = None
        tunnel_conns: list[asyncssh.SSHClientConnection] = []

        try:
            for host in all_hosts:
                if conn is None:
                    conn = await asyncssh.connect(host, **kwargs)
                else:
                    new_conn = await conn.connect_ssh(host, **kwargs)

                    tunnel_conns.append(conn)
                    conn = new_conn

            assert conn is not None
            sftp = await conn.start_sftp_client()
        except Exception as exc:
            for c in reversed(tunnel_conns):
                c.close()
            if conn is not None:
                conn.close()
            raise SshConnectionError(
                f"Failed to connect to {self._target.final_host}: {exc}"
            ) from exc

        self._conn = conn
        self._sftp = sftp
        self._tunnel_conns = tunnel_conns

    def _reset_connection(self) -> None:
        """Close current connections to allow reconnect."""
        if self._sftp is not None:
            self._sftp.exit()
            self._sftp = None
        if self._conn is not None:
            self._conn.close()
            self._conn = None
        for c in reversed(self._tunnel_conns):
            c.close()
        self._tunnel_conns = []

    def close(self) -> None:
        """Close SSH connections and stop the background event loop."""
        if self._closed:
            return
        self._closed = True
        self._reset_connection()
        if self._loop is not None:
            self._loop.call_soon_threadsafe(self._loop.stop)
            if self._thread is not None:
                self._thread.join(timeout=5)
            self._loop.close()
            self._loop = None
            self._thread = None

    # -- FileSystem protocol methods --------------------------------------

    def read_bytes(self, path: str) -> bytes:
        """Read file contents as bytes over SFTP."""

        async def _read() -> bytes:
            assert self._sftp is not None
            async with self._sftp.open(path, "rb") as f:
                data: bytes = await f.read()
            return data

        return self._run(_read)

    def write_bytes(self, path: str, data: bytes) -> None:
        """Write bytes to a file atomically (temp + rename) over SFTP."""

        async def _write() -> None:
            assert self._sftp is not None
            tmp = join(dirname(path), f".tmp.{uuid.uuid4().hex[:8]}")
            try:
                async with self._sftp.open(tmp, "wb") as f:
                    await f.write(data)
                await self._sftp.rename(tmp, path)
            except Exception:
                with contextlib.suppress(asyncssh.SFTPNoSuchFile):
                    await self._sftp.remove(tmp)
                raise

        self._run(_write)

    def read_text(self, path: str) -> str:
        """Read file contents as UTF-8 text over SFTP."""
        return self.read_bytes(path).decode("utf-8")

    def write_text(self, path: str, text: str) -> None:
        """Write UTF-8 text to a file atomically over SFTP."""
        self.write_bytes(path, text.encode("utf-8"))

    def exists(self, path: str) -> bool:
        """Check if a remote path exists."""

        async def _exists() -> bool:
            assert self._sftp is not None
            try:
                await self._sftp.stat(path)
                return True
            except asyncssh.SFTPNoSuchFile:
                return False

        return self._run(_exists)

    def mkdir(self, path: str) -> bool:
        """Create a remote directory.

        Returns True if created, False if already exists.
        Uses SFTP mkdir which is atomic on POSIX systems.
        """

        async def _mkdir() -> bool:
            assert self._sftp is not None
            try:
                await self._sftp.mkdir(path)
                return True
            except asyncssh.SFTPFailure:
                return False

        return self._run(_mkdir)

    def rmdir(self, path: str) -> None:
        """Remove a remote directory."""

        async def _rmdir() -> None:
            assert self._sftp is not None
            try:
                await self._sftp.rmdir(path)
            except asyncssh.SFTPNoSuchFile as exc:
                raise FileNotFoundError(path) from exc
            except asyncssh.SFTPPermissionDenied as exc:
                raise PermissionError(path) from exc

        self._run(_rmdir)

    def delete(self, path: str) -> None:
        """Delete a remote file (missing_ok)."""

        async def _delete() -> None:
            assert self._sftp is not None
            with contextlib.suppress(asyncssh.SFTPNoSuchFile):
                await self._sftp.remove(path)

        self._run(_delete)

    def list_dir(self, path: str) -> list[str]:
        """List entries in a remote directory."""

        async def _list_dir() -> list[str]:
            assert self._sftp is not None
            try:
                names = list(await self._sftp.listdir(path))
                return sorted(names)
            except asyncssh.SFTPNoSuchFile as exc:
                raise FileNotFoundError(path) from exc

        return self._run(_list_dir)

    def glob(self, path: str, pattern: str) -> list[str]:
        """Find files matching a glob pattern in a remote directory."""

        async def _glob() -> list[str]:
            assert self._sftp is not None
            try:
                names = list(await self._sftp.listdir(path))
            except asyncssh.SFTPNoSuchFile as exc:
                raise FileNotFoundError(path) from exc
            return [
                join(path, name)
                for name in sorted(names)
                if fnmatch.fnmatch(name, pattern)
            ]

        return self._run(_glob)

    # -- SSH command execution (not part of FileSystem protocol) -----------

    def run_command(
        self,
        command: str,
        *,
        check: bool = False,
        env: dict[str, str] | None = None,
    ) -> tuple[str, str, int]:
        """Execute a remote command via SSH.

        Args:
            command: Shell command to execute.
            check: Raise RuntimeError if command exits non-zero.
            env: Optional environment variables for the command.

        Returns:
            Tuple of (stdout, stderr, exit_status).

        Raises:
            SshConnectionError: If SSH connection fails.
            RuntimeError: If check=True and command exits non-zero.
        """

        async def _run_command() -> tuple[str, str, int]:
            assert self._conn is not None
            result = await self._conn.run(command, check=False, env=env)
            raw_stdout = result.stdout or ""
            raw_stderr = result.stderr or ""
            stdout = (
                raw_stdout.decode("utf-8")
                if isinstance(raw_stdout, bytes)
                else str(raw_stdout)
            )
            stderr = (
                raw_stderr.decode("utf-8")
                if isinstance(raw_stderr, bytes)
                else str(raw_stderr)
            )
            exit_status: int = result.exit_status or 0

            if check and exit_status != 0:
                raise RuntimeError(
                    f"Command failed (exit {exit_status}): {command}\n"
                    f"stderr: {stderr}"
                )

            return (stdout, stderr, exit_status)

        return self._run(_run_command)
