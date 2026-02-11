"""Tests for SshFileSystem with mocked asyncssh."""

from __future__ import annotations

import asyncio
from typing import Any
from unittest.mock import AsyncMock, MagicMock, patch

import asyncssh
import pytest
from umui_connectors.config import SshTarget
from umui_connectors.ssh_fs import SshConnectionError, SshFileSystem


@pytest.fixture()
def target() -> SshTarget:
    """Simple single-hop target for unit tests."""
    return SshTarget(
        name="test",
        final_host="test.example.com",
        db_path="/data/db",
        connect_timeout=5.0,
    )


@pytest.fixture()
def multi_hop_target() -> SshTarget:
    """Multi-hop target matching puma2 chain."""
    return SshTarget(
        name="puma2",
        final_host="puma2",
        db_path="/data/DBSE",
        jump_hosts=("bp14", "archer2"),
        connect_timeout=5.0,
    )


@pytest.fixture()
def mock_sftp() -> AsyncMock:
    """A mock SFTP client with standard async methods."""
    sftp = AsyncMock()
    sftp.listdir = AsyncMock(return_value=["a.txt", "b.txt", "c.dat"])
    sftp.stat = AsyncMock()
    sftp.mkdir = AsyncMock()
    sftp.rmdir = AsyncMock()
    sftp.remove = AsyncMock()
    sftp.rename = AsyncMock()

    # Mock the file context manager for read/write
    mock_file = AsyncMock()
    mock_file.read = AsyncMock(return_value=b"hello world")
    mock_file.write = AsyncMock()
    mock_file.__aenter__ = AsyncMock(return_value=mock_file)
    mock_file.__aexit__ = AsyncMock(return_value=False)
    sftp.open = MagicMock(return_value=mock_file)

    # exit() is sync on AsyncMock, just make it a no-op
    sftp.exit = MagicMock()

    return sftp


@pytest.fixture()
def mock_conn(mock_sftp: AsyncMock) -> AsyncMock:
    """A mock SSH connection that returns our mock SFTP."""
    conn = AsyncMock()
    conn.start_sftp_client = AsyncMock(return_value=mock_sftp)
    conn.connect_ssh = AsyncMock()
    conn.close = MagicMock()
    return conn


def _patch_connect(
    mock_conn: AsyncMock,
) -> Any:
    """Return a patch context for asyncssh.connect."""
    return patch(
        "umui_connectors.ssh_fs.asyncssh.connect",
        new_callable=lambda: lambda *a, **kw: _async_return(mock_conn),
    )


async def _async_return(val: Any) -> Any:
    return val


def _make_fs_connected(
    fs: SshFileSystem,
    mock_conn: AsyncMock,
    mock_sftp: AsyncMock,
) -> None:
    """Inject mock connection state into an SshFileSystem."""
    fs._start_loop()
    fs._conn = mock_conn
    fs._sftp = mock_sftp
    fs._tunnel_conns = []


class TestSshFileSystemLifecycle:
    """Tests for connection lifecycle and context manager."""

    def test_context_manager_starts_and_stops_loop(
        self, target: SshTarget
    ) -> None:
        fs = SshFileSystem(target)
        assert fs._loop is None
        fs._start_loop()
        assert fs._loop is not None
        assert fs._thread is not None
        assert fs._thread.is_alive()
        fs.close()
        assert fs._loop is None

    def test_close_is_idempotent(self, target: SshTarget) -> None:
        fs = SshFileSystem(target)
        fs._start_loop()
        fs.close()
        fs.close()  # Should not raise

    def test_context_manager_protocol(
        self,
        target: SshTarget,
        mock_conn: AsyncMock,
        mock_sftp: AsyncMock,
    ) -> None:
        with SshFileSystem(target) as fs:
            assert fs._loop is not None
            _make_fs_connected(fs, mock_conn, mock_sftp)
        assert fs._loop is None


class TestSshFileSystemConnect:
    """Tests for SSH connection establishment."""

    def test_single_hop_connect(
        self,
        target: SshTarget,
        mock_conn: AsyncMock,
        mock_sftp: AsyncMock,
    ) -> None:
        with patch(
            "umui_connectors.ssh_fs.asyncssh.connect",
            new=AsyncMock(return_value=mock_conn),
        ):
            fs = SshFileSystem(target)
            fs._start_loop()
            assert fs._loop is not None
            future = asyncio.run_coroutine_threadsafe(
                fs._connect(), fs._loop
            )
            future.result(timeout=5)
            assert fs._sftp is mock_sftp
            assert fs._conn is mock_conn
            assert fs._tunnel_conns == []
            fs.close()

    def test_multi_hop_connect(
        self,
        multi_hop_target: SshTarget,
        mock_sftp: AsyncMock,
    ) -> None:
        # Build chain: connect -> bp14_conn, bp14 -> archer2_conn, archer2 -> puma2_conn
        puma2_conn = AsyncMock()
        puma2_conn.start_sftp_client = AsyncMock(return_value=mock_sftp)
        puma2_conn.close = MagicMock()

        archer2_conn = AsyncMock()
        archer2_conn.connect_ssh = AsyncMock(return_value=puma2_conn)
        archer2_conn.close = MagicMock()

        bp14_conn = AsyncMock()
        bp14_conn.connect_ssh = AsyncMock(return_value=archer2_conn)
        bp14_conn.close = MagicMock()

        with patch(
            "umui_connectors.ssh_fs.asyncssh.connect",
            new=AsyncMock(return_value=bp14_conn),
        ):
            fs = SshFileSystem(multi_hop_target)
            fs._start_loop()
            assert fs._loop is not None
            future = asyncio.run_coroutine_threadsafe(
                fs._connect(), fs._loop
            )
            future.result(timeout=5)
            assert fs._conn is puma2_conn
            assert fs._tunnel_conns == [bp14_conn, archer2_conn]
            fs.close()


class TestReadOperations:
    """Tests for read_bytes, read_text, exists, list_dir, glob."""

    def test_read_bytes(
        self,
        target: SshTarget,
        mock_conn: AsyncMock,
        mock_sftp: AsyncMock,
    ) -> None:
        with SshFileSystem(target) as fs:
            _make_fs_connected(fs, mock_conn, mock_sftp)
            result = fs.read_bytes("/data/file.bin")

        assert result == b"hello world"
        mock_sftp.open.assert_called_once_with("/data/file.bin", "rb")

    def test_read_text(
        self,
        target: SshTarget,
        mock_conn: AsyncMock,
        mock_sftp: AsyncMock,
    ) -> None:
        with SshFileSystem(target) as fs:
            _make_fs_connected(fs, mock_conn, mock_sftp)
            result = fs.read_text("/data/file.txt")

        assert result == "hello world"

    def test_exists_true(
        self,
        target: SshTarget,
        mock_conn: AsyncMock,
        mock_sftp: AsyncMock,
    ) -> None:
        with SshFileSystem(target) as fs:
            _make_fs_connected(fs, mock_conn, mock_sftp)
            assert fs.exists("/data/file.txt") is True

    def test_exists_false(
        self,
        target: SshTarget,
        mock_conn: AsyncMock,
        mock_sftp: AsyncMock,
    ) -> None:
        mock_sftp.stat = AsyncMock(
            side_effect=asyncssh.SFTPNoSuchFile("not found")
        )
        with SshFileSystem(target) as fs:
            _make_fs_connected(fs, mock_conn, mock_sftp)
            assert fs.exists("/data/missing.txt") is False

    def test_list_dir(
        self,
        target: SshTarget,
        mock_conn: AsyncMock,
        mock_sftp: AsyncMock,
    ) -> None:
        with SshFileSystem(target) as fs:
            _make_fs_connected(fs, mock_conn, mock_sftp)
            result = fs.list_dir("/data")

        assert result == ["a.txt", "b.txt", "c.dat"]

    def test_list_dir_not_found(
        self,
        target: SshTarget,
        mock_conn: AsyncMock,
        mock_sftp: AsyncMock,
    ) -> None:
        mock_sftp.listdir = AsyncMock(
            side_effect=asyncssh.SFTPNoSuchFile("not found")
        )
        with SshFileSystem(target) as fs:
            _make_fs_connected(fs, mock_conn, mock_sftp)
            with pytest.raises(FileNotFoundError):
                fs.list_dir("/missing")

    def test_glob_pattern(
        self,
        target: SshTarget,
        mock_conn: AsyncMock,
        mock_sftp: AsyncMock,
    ) -> None:
        with SshFileSystem(target) as fs:
            _make_fs_connected(fs, mock_conn, mock_sftp)
            result = fs.glob("/data", "*.txt")

        assert result == ["/data/a.txt", "/data/b.txt"]

    def test_glob_no_match(
        self,
        target: SshTarget,
        mock_conn: AsyncMock,
        mock_sftp: AsyncMock,
    ) -> None:
        with SshFileSystem(target) as fs:
            _make_fs_connected(fs, mock_conn, mock_sftp)
            result = fs.glob("/data", "*.xyz")

        assert result == []

    def test_glob_star(
        self,
        target: SshTarget,
        mock_conn: AsyncMock,
        mock_sftp: AsyncMock,
    ) -> None:
        with SshFileSystem(target) as fs:
            _make_fs_connected(fs, mock_conn, mock_sftp)
            result = fs.glob("/data", "*")

        assert result == ["/data/a.txt", "/data/b.txt", "/data/c.dat"]


class TestWriteOperations:
    """Tests for write_bytes, write_text (atomic pattern)."""

    def test_write_bytes_atomic(
        self,
        target: SshTarget,
        mock_conn: AsyncMock,
        mock_sftp: AsyncMock,
    ) -> None:
        with SshFileSystem(target) as fs:
            _make_fs_connected(fs, mock_conn, mock_sftp)
            fs.write_bytes("/data/out.bin", b"binary data")

        # Verify temp file was written then renamed
        mock_sftp.open.assert_called_once()
        call_args = mock_sftp.open.call_args
        tmp_path = call_args[0][0]
        assert tmp_path.startswith("/data/.tmp.")
        assert call_args[0][1] == "wb"
        mock_sftp.rename.assert_called_once()
        rename_args = mock_sftp.rename.call_args[0]
        assert rename_args[0] == tmp_path
        assert rename_args[1] == "/data/out.bin"

    def test_write_text_atomic(
        self,
        target: SshTarget,
        mock_conn: AsyncMock,
        mock_sftp: AsyncMock,
    ) -> None:
        with SshFileSystem(target) as fs:
            _make_fs_connected(fs, mock_conn, mock_sftp)
            fs.write_text("/data/out.txt", "hello")

        mock_sftp.open.assert_called_once()
        mock_sftp.rename.assert_called_once()

    def test_write_bytes_cleanup_on_failure(
        self,
        target: SshTarget,
        mock_conn: AsyncMock,
        mock_sftp: AsyncMock,
    ) -> None:
        mock_sftp.rename = AsyncMock(side_effect=OSError("rename failed"))
        with SshFileSystem(target) as fs:
            _make_fs_connected(fs, mock_conn, mock_sftp)
            with pytest.raises(OSError, match="rename failed"):
                fs.write_bytes("/data/out.bin", b"data")

        # Temp file should have been cleaned up
        mock_sftp.remove.assert_called_once()


class TestDirectoryOperations:
    """Tests for mkdir, rmdir, delete."""

    def test_mkdir_success(
        self,
        target: SshTarget,
        mock_conn: AsyncMock,
        mock_sftp: AsyncMock,
    ) -> None:
        with SshFileSystem(target) as fs:
            _make_fs_connected(fs, mock_conn, mock_sftp)
            assert fs.mkdir("/data/newdir") is True

        mock_sftp.mkdir.assert_called_once_with("/data/newdir")

    def test_mkdir_already_exists(
        self,
        target: SshTarget,
        mock_conn: AsyncMock,
        mock_sftp: AsyncMock,
    ) -> None:
        mock_sftp.mkdir = AsyncMock(
            side_effect=asyncssh.SFTPFailure("exists")
        )
        with SshFileSystem(target) as fs:
            _make_fs_connected(fs, mock_conn, mock_sftp)
            assert fs.mkdir("/data/existing") is False

    def test_rmdir(
        self,
        target: SshTarget,
        mock_conn: AsyncMock,
        mock_sftp: AsyncMock,
    ) -> None:
        with SshFileSystem(target) as fs:
            _make_fs_connected(fs, mock_conn, mock_sftp)
            fs.rmdir("/data/olddir")

        mock_sftp.rmdir.assert_called_once_with("/data/olddir")

    def test_rmdir_not_found(
        self,
        target: SshTarget,
        mock_conn: AsyncMock,
        mock_sftp: AsyncMock,
    ) -> None:
        mock_sftp.rmdir = AsyncMock(
            side_effect=asyncssh.SFTPNoSuchFile("not found")
        )
        with SshFileSystem(target) as fs:
            _make_fs_connected(fs, mock_conn, mock_sftp)
            with pytest.raises(FileNotFoundError):
                fs.rmdir("/data/missing")

    def test_rmdir_permission_denied(
        self,
        target: SshTarget,
        mock_conn: AsyncMock,
        mock_sftp: AsyncMock,
    ) -> None:
        mock_sftp.rmdir = AsyncMock(
            side_effect=asyncssh.SFTPPermissionDenied("denied")
        )
        with SshFileSystem(target) as fs:
            _make_fs_connected(fs, mock_conn, mock_sftp)
            with pytest.raises(PermissionError):
                fs.rmdir("/data/protected")

    def test_delete(
        self,
        target: SshTarget,
        mock_conn: AsyncMock,
        mock_sftp: AsyncMock,
    ) -> None:
        with SshFileSystem(target) as fs:
            _make_fs_connected(fs, mock_conn, mock_sftp)
            fs.delete("/data/file.txt")

        mock_sftp.remove.assert_called_once_with("/data/file.txt")

    def test_delete_missing_ok(
        self,
        target: SshTarget,
        mock_conn: AsyncMock,
        mock_sftp: AsyncMock,
    ) -> None:
        mock_sftp.remove = AsyncMock(
            side_effect=asyncssh.SFTPNoSuchFile("not found")
        )
        with SshFileSystem(target) as fs:
            _make_fs_connected(fs, mock_conn, mock_sftp)
            fs.delete("/data/already-gone.txt")  # Should not raise


class TestErrorHandling:
    """Tests for error mapping and reconnect behavior."""

    def test_connection_error_on_connect_failure(
        self,
        target: SshTarget,
    ) -> None:
        with (
            patch(
                "umui_connectors.ssh_fs.asyncssh.connect",
                new=AsyncMock(side_effect=OSError("connection refused")),
            ),
            SshFileSystem(target) as fs,
            pytest.raises(SshConnectionError, match="connection refused"),
        ):
            fs.exists("/data/file.txt")

    def test_reconnect_on_connection_lost(
        self,
        target: SshTarget,
        mock_conn: AsyncMock,
        mock_sftp: AsyncMock,
    ) -> None:
        call_count = 0

        async def _stat_with_one_failure(path: str) -> MagicMock:
            nonlocal call_count
            call_count += 1
            if call_count == 1:
                raise asyncssh.ConnectionLost("lost")
            return MagicMock()

        mock_sftp.stat = _stat_with_one_failure

        # After reconnect, the fs needs a new SFTP; patch connect
        new_sftp = AsyncMock()
        new_sftp.stat = AsyncMock(return_value=MagicMock())
        new_sftp.exit = MagicMock()
        new_conn = AsyncMock()
        new_conn.start_sftp_client = AsyncMock(return_value=new_sftp)
        new_conn.close = MagicMock()

        with patch(
            "umui_connectors.ssh_fs.asyncssh.connect",
            new=AsyncMock(return_value=new_conn),
        ), SshFileSystem(target) as fs:
            _make_fs_connected(fs, mock_conn, mock_sftp)
            result = fs.exists("/data/file.txt")
            assert result is True
