"""Tests for the locking system."""

from __future__ import annotations

from typing import TYPE_CHECKING

import pytest
from umui_core.formats.pairs import write_pairs
from umui_core.locking.locks import (
    acquire_lock_legacy,
    acquire_lock_mkdir,
    check_lock_legacy,
    release_lock_legacy,
    release_lock_mkdir,
)
from umui_core.storage.layout import DatabasePaths, LocalFileSystem

if TYPE_CHECKING:
    from pathlib import Path


@pytest.fixture
def fs() -> LocalFileSystem:
    return LocalFileSystem()


@pytest.fixture
def db(tmp_path: Path) -> DatabasePaths:
    return DatabasePaths(str(tmp_path))


def _create_job_file(
    tmp_path: Path,
    exp_id: str,
    job_id: str,
    opened: str = "N",
) -> None:
    """Create a minimal .job file for testing."""
    exp_dir = tmp_path / exp_id
    exp_dir.mkdir(exist_ok=True)
    pairs = (
        ("version", "8.6"),
        ("description", "Test job"),
        ("opened", opened),
    )
    (exp_dir / f"{job_id}.job").write_text(write_pairs(pairs))


class TestAcquireLockLegacy:
    def test_acquire_unlocked(
        self, fs: LocalFileSystem, db: DatabasePaths, tmp_path: Path
    ) -> None:
        _create_job_file(tmp_path, "xqjc", "a")
        result = acquire_lock_legacy(fs, db, "xqjc", "a", "nd20983")
        assert result.success is True
        assert result.owner == "nd20983"

    def test_lock_persisted_in_file(
        self, fs: LocalFileSystem, db: DatabasePaths, tmp_path: Path
    ) -> None:
        _create_job_file(tmp_path, "xqjc", "a")
        acquire_lock_legacy(fs, db, "xqjc", "a", "nd20983")
        # Verify the file was updated
        owner = check_lock_legacy(fs, db, "xqjc", "a")
        assert owner == "nd20983"

    def test_already_locked_by_self(
        self, fs: LocalFileSystem, db: DatabasePaths, tmp_path: Path
    ) -> None:
        _create_job_file(tmp_path, "xqjc", "a", opened="nd20983")
        result = acquire_lock_legacy(fs, db, "xqjc", "a", "nd20983")
        assert result.success is False
        assert "Already locked by you" in result.message

    def test_locked_by_other(
        self, fs: LocalFileSystem, db: DatabasePaths, tmp_path: Path
    ) -> None:
        _create_job_file(tmp_path, "xqjc", "a", opened="other_user")
        result = acquire_lock_legacy(fs, db, "xqjc", "a", "nd20983")
        assert result.success is False
        assert result.owner == "other_user"

    def test_force_lock(
        self, fs: LocalFileSystem, db: DatabasePaths, tmp_path: Path
    ) -> None:
        _create_job_file(tmp_path, "xqjc", "a", opened="other_user")
        result = acquire_lock_legacy(
            fs, db, "xqjc", "a", "nd20983", force=True
        )
        assert result.success is True
        assert result.forced is True

    def test_missing_job_file(
        self, fs: LocalFileSystem, db: DatabasePaths
    ) -> None:
        result = acquire_lock_legacy(fs, db, "xqjc", "a", "nd20983")
        assert result.success is False
        assert "not found" in result.message


class TestReleaseLockLegacy:
    def test_release_own_lock(
        self, fs: LocalFileSystem, db: DatabasePaths, tmp_path: Path
    ) -> None:
        _create_job_file(tmp_path, "xqjc", "a", opened="nd20983")
        result = release_lock_legacy(fs, db, "xqjc", "a", "nd20983")
        assert result.success is True
        assert check_lock_legacy(fs, db, "xqjc", "a") is None

    def test_cannot_release_others_lock(
        self, fs: LocalFileSystem, db: DatabasePaths, tmp_path: Path
    ) -> None:
        _create_job_file(tmp_path, "xqjc", "a", opened="other_user")
        result = release_lock_legacy(fs, db, "xqjc", "a", "nd20983")
        assert result.success is False
        assert result.owner == "other_user"

    def test_force_release(
        self, fs: LocalFileSystem, db: DatabasePaths, tmp_path: Path
    ) -> None:
        _create_job_file(tmp_path, "xqjc", "a", opened="other_user")
        result = release_lock_legacy(
            fs, db, "xqjc", "a", "nd20983", force=True
        )
        assert result.success is True
        assert result.forced is True

    def test_release_unlocked(
        self, fs: LocalFileSystem, db: DatabasePaths, tmp_path: Path
    ) -> None:
        _create_job_file(tmp_path, "xqjc", "a")
        result = release_lock_legacy(fs, db, "xqjc", "a", "nd20983")
        assert result.success is False
        assert "not locked" in result.message

    def test_missing_job_file(
        self, fs: LocalFileSystem, db: DatabasePaths
    ) -> None:
        result = release_lock_legacy(fs, db, "xqjc", "a", "nd20983")
        assert result.success is False


class TestCheckLockLegacy:
    def test_unlocked(
        self, fs: LocalFileSystem, db: DatabasePaths, tmp_path: Path
    ) -> None:
        _create_job_file(tmp_path, "xqjc", "a")
        assert check_lock_legacy(fs, db, "xqjc", "a") is None

    def test_locked(
        self, fs: LocalFileSystem, db: DatabasePaths, tmp_path: Path
    ) -> None:
        _create_job_file(tmp_path, "xqjc", "a", opened="nd20983")
        assert check_lock_legacy(fs, db, "xqjc", "a") == "nd20983"

    def test_missing_file(
        self, fs: LocalFileSystem, db: DatabasePaths
    ) -> None:
        assert check_lock_legacy(fs, db, "xqjc", "a") is None


class TestAcquireLockMkdir:
    def test_acquire(
        self, fs: LocalFileSystem, db: DatabasePaths, tmp_path: Path
    ) -> None:
        (tmp_path / "xqjc").mkdir()
        result = acquire_lock_mkdir(fs, db, "xqjc", "a", "nd20983")
        assert result.success is True
        assert result.owner == "nd20983"

    def test_lock_dir_created(
        self, fs: LocalFileSystem, db: DatabasePaths, tmp_path: Path
    ) -> None:
        (tmp_path / "xqjc").mkdir()
        acquire_lock_mkdir(fs, db, "xqjc", "a", "nd20983")
        assert (tmp_path / "xqjc" / "a.lock").is_dir()
        assert (tmp_path / "xqjc" / "a.lock" / "info.json").exists()

    def test_already_locked_by_self(
        self, fs: LocalFileSystem, db: DatabasePaths, tmp_path: Path
    ) -> None:
        (tmp_path / "xqjc").mkdir()
        acquire_lock_mkdir(fs, db, "xqjc", "a", "nd20983")
        result = acquire_lock_mkdir(fs, db, "xqjc", "a", "nd20983")
        assert result.success is False
        assert "Already locked by you" in result.message

    def test_locked_by_other(
        self, fs: LocalFileSystem, db: DatabasePaths, tmp_path: Path
    ) -> None:
        (tmp_path / "xqjc").mkdir()
        acquire_lock_mkdir(fs, db, "xqjc", "a", "other_user")
        result = acquire_lock_mkdir(fs, db, "xqjc", "a", "nd20983")
        assert result.success is False
        assert result.owner == "other_user"


class TestReleaseLockMkdir:
    def test_release_own(
        self, fs: LocalFileSystem, db: DatabasePaths, tmp_path: Path
    ) -> None:
        (tmp_path / "xqjc").mkdir()
        acquire_lock_mkdir(fs, db, "xqjc", "a", "nd20983")
        result = release_lock_mkdir(fs, db, "xqjc", "a", "nd20983")
        assert result.success is True
        assert not (tmp_path / "xqjc" / "a.lock").exists()

    def test_cannot_release_others(
        self, fs: LocalFileSystem, db: DatabasePaths, tmp_path: Path
    ) -> None:
        (tmp_path / "xqjc").mkdir()
        acquire_lock_mkdir(fs, db, "xqjc", "a", "other_user")
        result = release_lock_mkdir(fs, db, "xqjc", "a", "nd20983")
        assert result.success is False

    def test_force_release(
        self, fs: LocalFileSystem, db: DatabasePaths, tmp_path: Path
    ) -> None:
        (tmp_path / "xqjc").mkdir()
        acquire_lock_mkdir(fs, db, "xqjc", "a", "other_user")
        result = release_lock_mkdir(
            fs, db, "xqjc", "a", "nd20983", force=True
        )
        assert result.success is True
        assert result.forced is True

    def test_release_unlocked(
        self, fs: LocalFileSystem, db: DatabasePaths, tmp_path: Path
    ) -> None:
        result = release_lock_mkdir(fs, db, "xqjc", "a", "nd20983")
        assert result.success is False
        assert "not locked" in result.message
