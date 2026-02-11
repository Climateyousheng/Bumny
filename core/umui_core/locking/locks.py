"""Multi-user locking for UMUI jobs.

Supports two locking strategies:
1. Legacy field-based: 'opened' field in .job file (for interop with legacy UMUI)
2. New mkdir-based: atomic directory creation for distributed safety

The legacy strategy reads/writes the 'opened' field in .job metadata.
The new strategy uses POSIX mkdir atomicity to prevent races.
"""

from __future__ import annotations

import json
import time
from typing import TYPE_CHECKING

from umui_core.formats.pairs import parse_pairs, update_pairs, write_pairs
from umui_core.models.lock import Lock, LockResult

if TYPE_CHECKING:
    from umui_core.storage.layout import DatabasePaths, FileSystem


class LockError(Exception):
    """Raised when a locking operation fails."""


def acquire_lock_legacy(
    fs: FileSystem,
    paths: DatabasePaths,
    exp_id: str,
    job_id: str,
    user: str,
    *,
    force: bool = False,
) -> LockResult:
    """Acquire a lock using the legacy field-based mechanism.

    Reads the .job file, checks the 'opened' field, and updates it.
    Matches the legacy Tcl `sc_lock_job` behavior.

    Args:
        fs: Filesystem interface.
        paths: Database path helper.
        exp_id: Experiment ID.
        job_id: Job ID.
        user: Username requesting the lock.
        force: Force lock even if held by another user.

    Returns:
        LockResult indicating success/failure.
    """
    job_path = paths.job_file(exp_id, job_id)

    if not fs.exists(job_path):
        return LockResult(
            success=False,
            owner="",
            message=f"Job file not found: {exp_id}/{job_id}",
        )

    text = fs.read_text(job_path)
    pairs = parse_pairs(text)
    fields = {f: v for f, v in pairs}
    opened = fields.get("opened", "N")

    if opened == "N" or opened == "":
        # Not locked - acquire it
        new_pairs = update_pairs(pairs, {"opened": user})
        fs.write_text(job_path, write_pairs(new_pairs))
        return LockResult(success=True, owner=user, message="")

    if opened == user:
        # Already locked by this user
        return LockResult(
            success=False,
            owner=user,
            message="Already locked by you",
        )

    # Locked by someone else
    if force:
        new_pairs = update_pairs(pairs, {"opened": user})
        fs.write_text(job_path, write_pairs(new_pairs))
        return LockResult(
            success=True,
            owner=user,
            message=f"Forced lock from {opened}",
            forced=True,
        )

    return LockResult(
        success=False,
        owner=opened,
        message=f"Locked by user {opened}",
    )


def release_lock_legacy(
    fs: FileSystem,
    paths: DatabasePaths,
    exp_id: str,
    job_id: str,
    user: str,
    *,
    force: bool = False,
) -> LockResult:
    """Release a lock using the legacy field-based mechanism.

    Matches the legacy Tcl `sc_unlock_job` behavior.

    Args:
        fs: Filesystem interface.
        paths: Database path helper.
        exp_id: Experiment ID.
        job_id: Job ID.
        user: Username releasing the lock.
        force: Force release even if held by another user.

    Returns:
        LockResult indicating success/failure.
    """
    job_path = paths.job_file(exp_id, job_id)

    if not fs.exists(job_path):
        return LockResult(
            success=False,
            owner="",
            message=f"Job file not found: {exp_id}/{job_id}",
        )

    text = fs.read_text(job_path)
    pairs = parse_pairs(text)
    fields = {f: v for f, v in pairs}
    opened = fields.get("opened", "N")

    if opened == "N" or opened == "":
        return LockResult(
            success=False,
            owner="",
            message="Job is not locked",
        )

    if opened != user and not force:
        return LockResult(
            success=False,
            owner=opened,
            message=f"Locked by user {opened}, not you",
        )

    new_pairs = update_pairs(pairs, {"opened": "N"})
    fs.write_text(job_path, write_pairs(new_pairs))

    forced = opened != user
    return LockResult(
        success=True,
        owner=user,
        message=f"Force released from {opened}" if forced else "",
        forced=forced,
    )


def check_lock_legacy(
    fs: FileSystem,
    paths: DatabasePaths,
    exp_id: str,
    job_id: str,
) -> str | None:
    """Check who holds the legacy lock on a job.

    Args:
        fs: Filesystem interface.
        paths: Database path helper.
        exp_id: Experiment ID.
        job_id: Job ID.

    Returns:
        Username of lock holder, or None if unlocked.
    """
    job_path = paths.job_file(exp_id, job_id)

    if not fs.exists(job_path):
        return None

    text = fs.read_text(job_path)
    pairs = parse_pairs(text)
    fields = {f: v for f, v in pairs}
    opened = fields.get("opened", "N")

    if opened == "N" or opened == "":
        return None
    return opened


def acquire_lock_mkdir(
    fs: FileSystem,
    paths: DatabasePaths,
    exp_id: str,
    job_id: str,
    user: str,
) -> LockResult:
    """Acquire a lock using atomic mkdir.

    Creates a lock directory and writes owner info inside it.
    POSIX mkdir is atomic, preventing race conditions.

    Args:
        fs: Filesystem interface.
        paths: Database path helper.
        exp_id: Experiment ID.
        job_id: Job ID.
        user: Username requesting the lock.

    Returns:
        LockResult indicating success/failure.
    """
    lock_path = paths.lock_dir(exp_id, job_id)

    if fs.mkdir(lock_path):
        # Successfully created lock directory
        lock = Lock(
            exp_id=exp_id,
            job_id=job_id,
            owner=user,
            timestamp=time.time(),
        )
        info_path = f"{lock_path}/info.json"
        fs.write_text(
            info_path,
            json.dumps({
                "owner": lock.owner,
                "timestamp": lock.timestamp,
                "exp_id": lock.exp_id,
                "job_id": lock.job_id,
            }),
        )
        return LockResult(success=True, owner=user, message="")

    # Lock directory already exists - read owner info
    info_path = f"{lock_path}/info.json"
    try:
        info = json.loads(fs.read_text(info_path))
        existing_owner: str = info["owner"]
    except (OSError, KeyError, json.JSONDecodeError):
        existing_owner = "unknown"

    if existing_owner == user:
        return LockResult(
            success=False,
            owner=user,
            message="Already locked by you",
        )

    return LockResult(
        success=False,
        owner=existing_owner,
        message=f"Locked by user {existing_owner}",
    )


def release_lock_mkdir(
    fs: FileSystem,
    paths: DatabasePaths,
    exp_id: str,
    job_id: str,
    user: str,
    *,
    force: bool = False,
) -> LockResult:
    """Release a mkdir-based lock.

    Args:
        fs: Filesystem interface.
        paths: Database path helper.
        exp_id: Experiment ID.
        job_id: Job ID.
        user: Username releasing the lock.
        force: Force release even if held by another user.

    Returns:
        LockResult indicating success/failure.
    """
    lock_path = paths.lock_dir(exp_id, job_id)

    if not fs.exists(lock_path):
        return LockResult(
            success=False,
            owner="",
            message="Job is not locked",
        )

    info_path = f"{lock_path}/info.json"
    try:
        info = json.loads(fs.read_text(info_path))
        existing_owner: str = info["owner"]
    except (OSError, KeyError, json.JSONDecodeError):
        existing_owner = "unknown"

    if existing_owner != user and not force:
        return LockResult(
            success=False,
            owner=existing_owner,
            message=f"Locked by user {existing_owner}, not you",
        )

    # Remove lock directory contents and directory
    fs.delete(info_path)
    fs.rmdir(lock_path)

    forced = existing_owner != user
    return LockResult(
        success=True,
        owner=user,
        message=f"Force released from {existing_owner}" if forced else "",
        forced=forced,
    )
