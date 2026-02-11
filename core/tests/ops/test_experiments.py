"""Tests for experiment CRUD operations."""

from __future__ import annotations

from typing import TYPE_CHECKING

import pytest
from umui_core.ops.experiments import (
    ExperimentNotFoundError,
    PermissionDeniedError,
    copy_experiment,
    create_experiment,
    delete_experiment,
    get_experiment,
    list_experiments,
    update_experiment,
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


class TestListExperiments:
    def test_empty_database(
        self, fs: LocalFileSystem, db: DatabasePaths
    ) -> None:
        result = list_experiments(fs, db)
        assert result == []

    def test_lists_from_fixtures(
        self, fs: LocalFileSystem, fixtures_dir: Path
    ) -> None:
        db = DatabasePaths(str(fixtures_dir / "samples"))
        result = list_experiments(fs, db)
        assert len(result) == 3
        ids = [e.id for e in result]
        assert "xqjc" in ids
        assert "xqgt" in ids
        assert "aaaa" in ids

    def test_sorted_alphabetically(
        self, fs: LocalFileSystem, fixtures_dir: Path
    ) -> None:
        db = DatabasePaths(str(fixtures_dir / "samples"))
        result = list_experiments(fs, db)
        ids = [e.id for e in result]
        assert ids == sorted(ids)


class TestGetExperiment:
    def test_get_existing(
        self, fs: LocalFileSystem, fixtures_dir: Path
    ) -> None:
        db = DatabasePaths(str(fixtures_dir / "samples"))
        exp = get_experiment(fs, db, "xqjc")
        assert exp.id == "xqjc"
        assert exp.owner == "nd20983"
        assert exp.version == "4.5.1"

    def test_get_nonexistent(
        self, fs: LocalFileSystem, db: DatabasePaths
    ) -> None:
        with pytest.raises(ExperimentNotFoundError):
            get_experiment(fs, db, "xaaa")


class TestCreateExperiment:
    def test_create(
        self, fs: LocalFileSystem, db: DatabasePaths
    ) -> None:
        exp = create_experiment(fs, db, "nd20983", "x", "Test experiment")
        assert exp.id == "xaaa"
        assert exp.owner == "nd20983"
        assert exp.description == "Test experiment"
        assert exp.privacy == "N"

    def test_creates_files(
        self, fs: LocalFileSystem, db: DatabasePaths, tmp_path: Path
    ) -> None:
        create_experiment(fs, db, "nd20983", "x", "Test")
        assert (tmp_path / "xaaa.exp").exists()
        assert (tmp_path / "xaaa").is_dir()

    def test_sequential_ids(
        self, fs: LocalFileSystem, db: DatabasePaths
    ) -> None:
        e1 = create_experiment(fs, db, "nd20983", "x", "First")
        e2 = create_experiment(fs, db, "nd20983", "x", "Second")
        assert e1.id == "xaaa"
        assert e2.id == "xaab"

    def test_roundtrip(
        self, fs: LocalFileSystem, db: DatabasePaths
    ) -> None:
        created = create_experiment(
            fs, db, "nd20983", "x", "Test", "Y"
        )
        loaded = get_experiment(fs, db, created.id)
        assert loaded.owner == created.owner
        assert loaded.description == created.description
        assert loaded.privacy == created.privacy


class TestUpdateExperiment:
    def test_update_description(
        self, fs: LocalFileSystem, db: DatabasePaths
    ) -> None:
        create_experiment(fs, db, "nd20983", "x", "Original")
        updated = update_experiment(
            fs, db, "xaaa", "nd20983", {"description": "Updated"}
        )
        assert updated.description == "Updated"

    def test_persists(
        self, fs: LocalFileSystem, db: DatabasePaths
    ) -> None:
        create_experiment(fs, db, "nd20983", "x", "Original")
        update_experiment(
            fs, db, "xaaa", "nd20983", {"description": "Updated"}
        )
        loaded = get_experiment(fs, db, "xaaa")
        assert loaded.description == "Updated"

    def test_nonexistent_raises(
        self, fs: LocalFileSystem, db: DatabasePaths
    ) -> None:
        with pytest.raises(ExperimentNotFoundError):
            update_experiment(fs, db, "xaaa", "user", {"description": "x"})

    def test_no_permission_raises(
        self, fs: LocalFileSystem, db: DatabasePaths
    ) -> None:
        create_experiment(fs, db, "nd20983", "x", "Test")
        with pytest.raises(PermissionDeniedError):
            update_experiment(
                fs, db, "xaaa", "stranger", {"description": "hack"}
            )

    def test_access_list_user_can_update(
        self, fs: LocalFileSystem, db: DatabasePaths
    ) -> None:
        create_experiment(fs, db, "nd20983", "x", "Test")
        update_experiment(
            fs, db, "xaaa", "nd20983",
            {"access_list": "colleague"},
        )
        updated = update_experiment(
            fs, db, "xaaa", "colleague", {"description": "By colleague"}
        )
        assert updated.description == "By colleague"


class TestDeleteExperiment:
    def test_delete(
        self, fs: LocalFileSystem, db: DatabasePaths, tmp_path: Path
    ) -> None:
        create_experiment(fs, db, "nd20983", "x", "To delete")
        delete_experiment(fs, db, "xaaa", "nd20983")
        assert not (tmp_path / "xaaa.exp").exists()
        assert not (tmp_path / "xaaa").exists()

    def test_nonexistent_raises(
        self, fs: LocalFileSystem, db: DatabasePaths
    ) -> None:
        with pytest.raises(ExperimentNotFoundError):
            delete_experiment(fs, db, "xaaa", "user")

    def test_no_permission_raises(
        self, fs: LocalFileSystem, db: DatabasePaths
    ) -> None:
        create_experiment(fs, db, "nd20983", "x", "Test")
        with pytest.raises(PermissionDeniedError):
            delete_experiment(fs, db, "xaaa", "stranger")


class TestCopyExperiment:
    def test_copy(
        self, fs: LocalFileSystem, db: DatabasePaths, tmp_path: Path
    ) -> None:
        create_experiment(fs, db, "nd20983", "x", "Original")
        # Add a job file manually
        (tmp_path / "xaaa" / "a.job").write_text(
            "version\n8.6\ndescription\nTest job\nopened\nN\n"
        )
        copied = copy_experiment(
            fs, db, "xaaa", "nd20983", "y", "Copied experiment"
        )
        assert copied.id == "yaaa"
        assert copied.description == "Copied experiment"
        # Job file should be copied
        assert (tmp_path / "yaaa" / "a.job").exists()

    def test_nonexistent_source_raises(
        self, fs: LocalFileSystem, db: DatabasePaths
    ) -> None:
        with pytest.raises(ExperimentNotFoundError):
            copy_experiment(fs, db, "xaaa", "user", "y", "Copy")
