"""Tests for storage layout, ID generation, and filesystem abstraction."""

from __future__ import annotations

from typing import TYPE_CHECKING

import pytest
from umui_core.storage.layout import (
    DatabasePaths,
    InvalidIdError,
    LocalFileSystem,
    literate_exp_id,
    next_exp_id,
    numerate_exp_id,
    validate_exp_id,
    validate_job_id,
)

if TYPE_CHECKING:
    from pathlib import Path


class TestValidateExpId:
    def test_valid_4char(self) -> None:
        assert validate_exp_id("xqjc") == "xqjc"
        assert validate_exp_id("aaaa") == "aaaa"
        assert validate_exp_id("zzzz") == "zzzz"

    def test_too_short(self) -> None:
        with pytest.raises(InvalidIdError):
            validate_exp_id("abc")

    def test_too_long_5char(self) -> None:
        with pytest.raises(InvalidIdError):
            validate_exp_id("abcde")

    def test_too_long_6char(self) -> None:
        with pytest.raises(InvalidIdError):
            validate_exp_id("abcdef")

    def test_uppercase(self) -> None:
        with pytest.raises(InvalidIdError):
            validate_exp_id("ABCD")

    def test_numbers(self) -> None:
        with pytest.raises(InvalidIdError):
            validate_exp_id("ab1d")

    def test_empty(self) -> None:
        with pytest.raises(InvalidIdError):
            validate_exp_id("")


class TestValidateJobId:
    def test_valid_ids(self) -> None:
        assert validate_job_id("a") == "a"
        assert validate_job_id("z") == "z"

    def test_too_long(self) -> None:
        with pytest.raises(InvalidIdError):
            validate_job_id("ab")

    def test_uppercase(self) -> None:
        with pytest.raises(InvalidIdError):
            validate_job_id("A")

    def test_number(self) -> None:
        with pytest.raises(InvalidIdError):
            validate_job_id("1")

    def test_empty(self) -> None:
        with pytest.raises(InvalidIdError):
            validate_job_id("")


class TestNumerateExpId:
    def test_aaaa_is_zero(self) -> None:
        assert numerate_exp_id("aaaa") == 0

    def test_aaab_is_one(self) -> None:
        assert numerate_exp_id("aaab") == 1

    def test_aaba_is_26(self) -> None:
        assert numerate_exp_id("aaba") == 26

    def test_abaa_is_676(self) -> None:
        assert numerate_exp_id("abaa") == 676

    def test_baaa_is_17576(self) -> None:
        assert numerate_exp_id("baaa") == 17576

    def test_zzzz(self) -> None:
        assert numerate_exp_id("zzzz") == 26**4 - 1

    def test_xqjc(self) -> None:
        # x=23, q=16, j=9, c=2
        expected = 23 * 26**3 + 16 * 26**2 + 9 * 26 + 2
        assert numerate_exp_id("xqjc") == expected


class TestLiterateExpId:
    def test_zero_is_aaaa(self) -> None:
        assert literate_exp_id(0) == "aaaa"

    def test_one_is_aaab(self) -> None:
        assert literate_exp_id(1) == "aaab"

    def test_max(self) -> None:
        assert literate_exp_id(26**4 - 1) == "zzzz"

    def test_negative_raises(self) -> None:
        with pytest.raises(ValueError, match="out of range"):
            literate_exp_id(-1)

    def test_too_large_raises(self) -> None:
        with pytest.raises(ValueError, match="out of range"):
            literate_exp_id(26**4)


class TestNumerateLiterateRoundTrip:
    def test_all_initials(self) -> None:
        for ch in "abcdefghijklmnopqrstuvwxyz":
            exp_id = f"{ch}aaa"
            num = numerate_exp_id(exp_id)
            assert literate_exp_id(num) == exp_id

    def test_known_ids(self) -> None:
        known = ["xqjc", "qaab", "raaa", "zzzz"]
        for exp_id in known:
            num = numerate_exp_id(exp_id)
            assert literate_exp_id(num) == exp_id

    def test_sequential_ids_sorted(self) -> None:
        ids = [literate_exp_id(i) for i in range(100)]
        assert ids == sorted(ids)


class TestNextExpId:
    def test_first_in_empty_db(self) -> None:
        result = next_exp_id("x", frozenset())
        assert result == "xaaa"

    def test_skips_existing(self) -> None:
        result = next_exp_id("x", frozenset({"xaaa"}))
        assert result == "xaab"

    def test_advances_past_all_existing(self) -> None:
        # Legacy behavior: doesn't find gaps, advances past all existing
        existing = frozenset({"xaaa", "xaab", "xaad"})
        result = next_exp_id("x", existing)
        assert result == "xaae"

    def test_after_all_existing(self) -> None:
        existing = frozenset({"xaaa", "xaab", "xaac"})
        result = next_exp_id("x", existing)
        assert result == "xaad"

    def test_ignores_other_initials(self) -> None:
        existing = frozenset({"aaaa", "baaa", "xaaa"})
        result = next_exp_id("x", existing)
        assert result == "xaab"

    def test_bad_initial_raises(self) -> None:
        with pytest.raises(InvalidIdError, match="Bad initial"):
            next_exp_id("1", frozenset())

    def test_uppercase_initial_raises(self) -> None:
        with pytest.raises(InvalidIdError, match="Bad initial"):
            next_exp_id("X", frozenset())

    def test_full_range_raises(self) -> None:
        # Fill all 4-char IDs for letter 'z'
        start = numerate_exp_id("zaaa")
        end = numerate_exp_id("zzzz")
        all_z = frozenset(
            literate_exp_id(i)
            for i in range(start, end + 1)
        )
        with pytest.raises(ValueError, match="No more"):
            next_exp_id("z", all_z)


class TestDatabasePaths:
    def test_exp_file(self) -> None:
        paths = DatabasePaths("/data/umui_db")
        assert paths.exp_file("xqjc") == "/data/umui_db/xqjc.exp"

    def test_exp_dir(self) -> None:
        paths = DatabasePaths("/data/umui_db")
        assert paths.exp_dir("xqjc") == "/data/umui_db/xqjc"

    def test_job_file(self) -> None:
        paths = DatabasePaths("/data/umui_db")
        assert paths.job_file("xqjc", "a") == "/data/umui_db/xqjc/a.job"

    def test_basis_file(self) -> None:
        paths = DatabasePaths("/data/umui_db")
        assert paths.basis_file("xqjc", "a") == "/data/umui_db/xqjc/a"

    def test_lock_dir(self) -> None:
        paths = DatabasePaths("/data/umui_db")
        assert paths.lock_dir("xqjc", "a") == "/data/umui_db/xqjc/a.lock"

    def test_log_file(self) -> None:
        paths = DatabasePaths("/data/umui_db")
        assert paths.log_file() == "/data/umui_db/log"

    def test_invalid_exp_id_raises(self) -> None:
        paths = DatabasePaths("/data/umui_db")
        with pytest.raises(InvalidIdError):
            paths.exp_file("bad")

    def test_invalid_job_id_raises(self) -> None:
        paths = DatabasePaths("/data/umui_db")
        with pytest.raises(InvalidIdError):
            paths.job_file("xqjc", "bad")

    def test_root(self) -> None:
        paths = DatabasePaths("/data/umui_db")
        assert paths.root == "/data/umui_db"


class TestLocalFileSystem:
    def test_read_write_bytes(self, tmp_path: Path) -> None:
        fs = LocalFileSystem()
        path = str(tmp_path / "test.bin")
        fs.write_bytes(path, b"hello bytes")
        assert fs.read_bytes(path) == b"hello bytes"

    def test_read_write_text(self, tmp_path: Path) -> None:
        fs = LocalFileSystem()
        path = str(tmp_path / "test.txt")
        fs.write_text(path, "hello text")
        assert fs.read_text(path) == "hello text"

    def test_exists(self, tmp_path: Path) -> None:
        fs = LocalFileSystem()
        path = str(tmp_path / "test.txt")
        assert fs.exists(path) is False
        fs.write_text(path, "content")
        assert fs.exists(path) is True

    def test_mkdir(self, tmp_path: Path) -> None:
        fs = LocalFileSystem()
        path = str(tmp_path / "newdir")
        assert fs.mkdir(path) is True
        assert fs.exists(path) is True
        assert fs.mkdir(path) is False

    def test_rmdir(self, tmp_path: Path) -> None:
        fs = LocalFileSystem()
        path = str(tmp_path / "newdir")
        fs.mkdir(path)
        fs.rmdir(path)
        assert fs.exists(path) is False

    def test_delete(self, tmp_path: Path) -> None:
        fs = LocalFileSystem()
        path = str(tmp_path / "test.txt")
        fs.write_text(path, "content")
        fs.delete(path)
        assert fs.exists(path) is False

    def test_delete_missing_ok(self, tmp_path: Path) -> None:
        fs = LocalFileSystem()
        path = str(tmp_path / "nonexistent")
        fs.delete(path)

    def test_list_dir(self, tmp_path: Path) -> None:
        fs = LocalFileSystem()
        (tmp_path / "a.txt").write_text("a")
        (tmp_path / "b.txt").write_text("b")
        entries = fs.list_dir(str(tmp_path))
        assert sorted(entries) == ["a.txt", "b.txt"]

    def test_glob(self, tmp_path: Path) -> None:
        fs = LocalFileSystem()
        (tmp_path / "a.exp").write_text("a")
        (tmp_path / "b.exp").write_text("b")
        (tmp_path / "c.txt").write_text("c")
        matches = fs.glob(str(tmp_path), "*.exp")
        assert len(matches) == 2
        assert all(m.endswith(".exp") for m in matches)

    def test_atomic_write_no_temp_left(self, tmp_path: Path) -> None:
        fs = LocalFileSystem()
        path = str(tmp_path / "test.txt")
        fs.write_text(path, "content")
        tmp_files = list(tmp_path.glob("*.tmp"))
        assert len(tmp_files) == 0
