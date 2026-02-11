"""Tests for job CRUD operations."""

from __future__ import annotations

from typing import TYPE_CHECKING

import pytest
from umui_core.ops.jobs import (
    JobExistsError,
    JobNotFoundError,
    copy_job,
    create_job,
    delete_job,
    get_job,
    list_jobs,
    update_job,
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


def _setup_exp_dir(tmp_path: Path, exp_id: str) -> None:
    """Create experiment directory."""
    (tmp_path / exp_id).mkdir(exist_ok=True)


class TestListJobs:
    def test_empty_experiment(
        self, fs: LocalFileSystem, db: DatabasePaths, tmp_path: Path
    ) -> None:
        _setup_exp_dir(tmp_path, "xqjc")
        result = list_jobs(fs, db, "xqjc")
        assert result == []

    def test_nonexistent_experiment(
        self, fs: LocalFileSystem, db: DatabasePaths
    ) -> None:
        result = list_jobs(fs, db, "xqjc")
        assert result == []

    def test_lists_from_fixtures(
        self, fs: LocalFileSystem, fixtures_dir: Path
    ) -> None:
        db = DatabasePaths(str(fixtures_dir / "samples"))
        result = list_jobs(fs, db, "xqgt")
        assert len(result) == 8
        ids = [j.job_id for j in result]
        assert "a" in ids
        assert "b" in ids
        assert "z" in ids

    def test_sorted_alphabetically(
        self, fs: LocalFileSystem, fixtures_dir: Path
    ) -> None:
        db = DatabasePaths(str(fixtures_dir / "samples"))
        result = list_jobs(fs, db, "xqgt")
        ids = [j.job_id for j in result]
        assert ids == sorted(ids)


class TestGetJob:
    def test_get_existing(
        self, fs: LocalFileSystem, fixtures_dir: Path
    ) -> None:
        db = DatabasePaths(str(fixtures_dir / "samples"))
        job = get_job(fs, db, "xqjc", "a")
        assert job.job_id == "a"
        assert job.exp_id == "xqjc"
        assert job.version == "4.5.1"

    def test_get_locked_job(
        self, fs: LocalFileSystem, fixtures_dir: Path
    ) -> None:
        db = DatabasePaths(str(fixtures_dir / "samples"))
        job = get_job(fs, db, "xqjc", "a")
        assert job.is_locked() is True
        assert job.locked_by() == "nd20983"

    def test_get_nonexistent(
        self, fs: LocalFileSystem, db: DatabasePaths, tmp_path: Path
    ) -> None:
        _setup_exp_dir(tmp_path, "xqjc")
        with pytest.raises(JobNotFoundError):
            get_job(fs, db, "xqjc", "z")


class TestCreateJob:
    def test_create(
        self, fs: LocalFileSystem, db: DatabasePaths, tmp_path: Path
    ) -> None:
        _setup_exp_dir(tmp_path, "xqjc")
        job = create_job(fs, db, "xqjc", "a", "Test job", "8.6")
        assert job.job_id == "a"
        assert job.exp_id == "xqjc"
        assert job.description == "Test job"
        assert job.opened == "N"

    def test_creates_files(
        self, fs: LocalFileSystem, db: DatabasePaths, tmp_path: Path
    ) -> None:
        _setup_exp_dir(tmp_path, "xqjc")
        create_job(fs, db, "xqjc", "a")
        assert (tmp_path / "xqjc" / "a.job").exists()
        assert (tmp_path / "xqjc" / "a").exists()

    def test_creates_exp_dir_if_missing(
        self, fs: LocalFileSystem, db: DatabasePaths, tmp_path: Path
    ) -> None:
        create_job(fs, db, "xqjc", "a")
        assert (tmp_path / "xqjc").is_dir()

    def test_duplicate_raises(
        self, fs: LocalFileSystem, db: DatabasePaths, tmp_path: Path
    ) -> None:
        _setup_exp_dir(tmp_path, "xqjc")
        create_job(fs, db, "xqjc", "a")
        with pytest.raises(JobExistsError):
            create_job(fs, db, "xqjc", "a")

    def test_roundtrip(
        self, fs: LocalFileSystem, db: DatabasePaths, tmp_path: Path
    ) -> None:
        _setup_exp_dir(tmp_path, "xqjc")
        created = create_job(fs, db, "xqjc", "a", "Test", "8.6")
        loaded = get_job(fs, db, "xqjc", "a")
        assert loaded.description == created.description
        assert loaded.version == created.version


class TestUpdateJob:
    def test_update_description(
        self, fs: LocalFileSystem, db: DatabasePaths, tmp_path: Path
    ) -> None:
        _setup_exp_dir(tmp_path, "xqjc")
        create_job(fs, db, "xqjc", "a", "Original")
        updated = update_job(
            fs, db, "xqjc", "a", {"description": "Updated"}
        )
        assert updated.description == "Updated"

    def test_persists(
        self, fs: LocalFileSystem, db: DatabasePaths, tmp_path: Path
    ) -> None:
        _setup_exp_dir(tmp_path, "xqjc")
        create_job(fs, db, "xqjc", "a")
        update_job(fs, db, "xqjc", "a", {"description": "Updated"})
        loaded = get_job(fs, db, "xqjc", "a")
        assert loaded.description == "Updated"

    def test_nonexistent_raises(
        self, fs: LocalFileSystem, db: DatabasePaths
    ) -> None:
        with pytest.raises(JobNotFoundError):
            update_job(fs, db, "xqjc", "a", {"description": "x"})


class TestDeleteJob:
    def test_delete(
        self, fs: LocalFileSystem, db: DatabasePaths, tmp_path: Path
    ) -> None:
        _setup_exp_dir(tmp_path, "xqjc")
        create_job(fs, db, "xqjc", "a")
        delete_job(fs, db, "xqjc", "a")
        assert not (tmp_path / "xqjc" / "a.job").exists()
        assert not (tmp_path / "xqjc" / "a").exists()

    def test_deletes_gz_basis(
        self, fs: LocalFileSystem, db: DatabasePaths, tmp_path: Path
    ) -> None:
        _setup_exp_dir(tmp_path, "xqjc")
        create_job(fs, db, "xqjc", "a")
        # Replace with gz
        (tmp_path / "xqjc" / "a").unlink()
        (tmp_path / "xqjc" / "a.gz").write_bytes(b"compressed")
        delete_job(fs, db, "xqjc", "a")
        assert not (tmp_path / "xqjc" / "a.gz").exists()

    def test_nonexistent_raises(
        self, fs: LocalFileSystem, db: DatabasePaths
    ) -> None:
        with pytest.raises(JobNotFoundError):
            delete_job(fs, db, "xqjc", "a")


class TestCopyJob:
    def test_copy(
        self, fs: LocalFileSystem, db: DatabasePaths, tmp_path: Path
    ) -> None:
        _setup_exp_dir(tmp_path, "xqjc")
        _setup_exp_dir(tmp_path, "xqgt")
        create_job(fs, db, "xqjc", "a", "Original", "8.6")
        copied = copy_job(
            fs, db, "xqjc", "a", "xqgt", "b", "Copy of original"
        )
        assert copied.job_id == "b"
        assert copied.exp_id == "xqgt"
        assert copied.description == "Copy of original"
        assert copied.version == "8.6"
        assert copied.opened == "N"

    def test_copies_basis_file(
        self, fs: LocalFileSystem, db: DatabasePaths, tmp_path: Path
    ) -> None:
        _setup_exp_dir(tmp_path, "xqjc")
        _setup_exp_dir(tmp_path, "xqgt")
        create_job(fs, db, "xqjc", "a")
        (tmp_path / "xqjc" / "a").write_bytes(b"basis content")
        copy_job(fs, db, "xqjc", "a", "xqgt", "b")
        assert (tmp_path / "xqgt" / "b").read_bytes() == b"basis content"

    def test_copies_gz_basis(
        self, fs: LocalFileSystem, db: DatabasePaths, tmp_path: Path
    ) -> None:
        _setup_exp_dir(tmp_path, "xqjc")
        _setup_exp_dir(tmp_path, "xqgt")
        create_job(fs, db, "xqjc", "a")
        (tmp_path / "xqjc" / "a").unlink()
        (tmp_path / "xqjc" / "a.gz").write_bytes(b"compressed basis")
        copy_job(fs, db, "xqjc", "a", "xqgt", "b")
        assert (tmp_path / "xqgt" / "b.gz").read_bytes() == b"compressed basis"

    def test_source_not_found_raises(
        self, fs: LocalFileSystem, db: DatabasePaths
    ) -> None:
        with pytest.raises(JobNotFoundError):
            copy_job(fs, db, "xqjc", "a", "xqgt", "b")

    def test_dest_exists_raises(
        self, fs: LocalFileSystem, db: DatabasePaths, tmp_path: Path
    ) -> None:
        _setup_exp_dir(tmp_path, "xqjc")
        create_job(fs, db, "xqjc", "a")
        create_job(fs, db, "xqjc", "b")
        with pytest.raises(JobExistsError):
            copy_job(fs, db, "xqjc", "a", "xqjc", "b")
