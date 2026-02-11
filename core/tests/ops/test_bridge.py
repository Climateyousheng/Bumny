"""Tests for bridge operations."""

from __future__ import annotations

import gzip
from typing import TYPE_CHECKING

import pytest
from umui_core.ops.bridge import (
    BasisNotFoundError,
    BridgeError,
    load_help,
    load_nav_tree,
    load_partitions,
    load_var_register,
    load_window,
    read_variables,
    write_variables,
)
from umui_core.storage.app_pack import AppPackPaths
from umui_core.storage.layout import DatabasePaths, LocalFileSystem

if TYPE_CHECKING:
    from pathlib import Path


@pytest.fixture
def fs() -> LocalFileSystem:
    return LocalFileSystem()


@pytest.fixture
def app_pack(fixtures_dir: Path) -> AppPackPaths:
    return AppPackPaths(str(fixtures_dir / "app_pack" / "vn8.6"))


@pytest.fixture
def db_paths(fixtures_dir: Path) -> DatabasePaths:
    return DatabasePaths(str(fixtures_dir / "samples"))


class TestLoadNavTree:
    def test_loads_tree(
        self, fs: LocalFileSystem, app_pack: AppPackPaths,
    ) -> None:
        tree = load_nav_tree(fs, app_pack)
        assert len(tree) >= 1
        assert tree[0].name == "modsel"

    def test_tree_has_children(
        self, fs: LocalFileSystem, app_pack: AppPackPaths,
    ) -> None:
        tree = load_nav_tree(fs, app_pack)
        # modsel should have children
        assert len(tree[0].children) > 0


class TestLoadWindow:
    def test_load_entry_window(
        self, fs: LocalFileSystem, app_pack: AppPackPaths,
    ) -> None:
        win = load_window(fs, app_pack, "atmos_Domain_Horiz")
        assert win.win_id == "atmos_Domain_Horiz"
        assert win.win_type == "entry"
        assert len(win.components) > 0

    def test_load_dummy_window(
        self, fs: LocalFileSystem, app_pack: AppPackPaths,
    ) -> None:
        win = load_window(fs, app_pack, "atmos_STASH_tcl")
        assert win.win_type == "dummy"

    def test_missing_window_raises(
        self, fs: LocalFileSystem, app_pack: AppPackPaths,
    ) -> None:
        with pytest.raises(BridgeError, match="not found"):
            load_window(fs, app_pack, "nonexistent_window")


class TestLoadHelp:
    def test_load_existing_help(
        self, fs: LocalFileSystem, app_pack: AppPackPaths,
    ) -> None:
        text = load_help(fs, app_pack, "atmos_Domain_Horiz")
        assert len(text) > 0

    def test_missing_help_returns_empty(
        self, fs: LocalFileSystem, app_pack: AppPackPaths,
    ) -> None:
        text = load_help(fs, app_pack, "nonexistent_window")
        assert text == ""


class TestLoadVarRegister:
    def test_loads_registrations(
        self, fs: LocalFileSystem, app_pack: AppPackPaths,
    ) -> None:
        regs = load_var_register(fs, app_pack)
        assert len(regs) > 1000


class TestLoadPartitions:
    def test_loads_partitions(
        self, fs: LocalFileSystem, app_pack: AppPackPaths,
    ) -> None:
        parts = load_partitions(fs, app_pack)
        assert len(parts) >= 10


class TestReadVariables:
    def test_read_from_gz(
        self,
        fs: LocalFileSystem,
        db_paths: DatabasePaths,
    ) -> None:
        """Read variables from the real xqgt/a.gz basis file."""
        vars_ = read_variables(fs, db_paths, "xqgt", "a")
        assert len(vars_) > 100

    def test_missing_basis_raises(
        self,
        fs: LocalFileSystem,
        db_paths: DatabasePaths,
    ) -> None:
        with pytest.raises(BasisNotFoundError):
            read_variables(fs, db_paths, "xqgt", "q")  # job q doesn't exist


class TestWriteVariables:
    def test_roundtrip(
        self,
        fs: LocalFileSystem,
        tmp_db: Path,
    ) -> None:
        """Write variables and read them back."""
        db = DatabasePaths(str(tmp_db))
        exp_dir = tmp_db / "test"
        exp_dir.mkdir()

        # Create a simple basis file
        content = " &g1\n MYVAR=42\n OTHER='hello'\n &END\n"
        gz_data = gzip.compress(content.encode())
        (exp_dir / "a.gz").write_bytes(gz_data)

        # Read, verify, update, verify
        vars_ = read_variables(fs, db, "test", "a")
        assert vars_["MYVAR"] == "42"

        write_variables(fs, db, "test", "a", {"MYVAR": "99"})

        vars2 = read_variables(fs, db, "test", "a")
        assert vars2["MYVAR"] == "99"
        assert vars2["OTHER"] == "'hello'"
