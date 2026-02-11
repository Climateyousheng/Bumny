"""Tests for the basis file format reader/writer."""

from __future__ import annotations

import gzip
from typing import TYPE_CHECKING

import pytest
from umui_core.formats.basis import (
    BasisFileError,
    basis_exists,
    read_basis,
    write_basis,
)

if TYPE_CHECKING:
    from pathlib import Path


class TestReadBasis:
    def test_read_plain(self, tmp_path: Path) -> None:
        path = tmp_path / "a"
        path.write_bytes(b"plain content")
        assert read_basis(path) == b"plain content"

    def test_read_gzip(self, tmp_path: Path) -> None:
        path = tmp_path / "a"
        gz_path = tmp_path / "a.gz"
        gz_path.write_bytes(gzip.compress(b"compressed content"))
        assert read_basis(path) == b"compressed content"

    def test_gzip_preferred_over_plain(self, tmp_path: Path) -> None:
        path = tmp_path / "a"
        path.write_bytes(b"plain")
        gz_path = tmp_path / "a.gz"
        gz_path.write_bytes(gzip.compress(b"compressed"))
        # gz should be preferred
        assert read_basis(path) == b"compressed"

    def test_missing_file_raises(self, tmp_path: Path) -> None:
        path = tmp_path / "nonexistent"
        with pytest.raises(BasisFileError, match="not found"):
            read_basis(path)

    def test_corrupt_gzip_raises(self, tmp_path: Path) -> None:
        path = tmp_path / "a"
        gz_path = tmp_path / "a.gz"
        gz_path.write_bytes(b"not a valid gzip file")
        with pytest.raises(BasisFileError, match="decompress"):
            read_basis(path)

    def test_read_fixture_gz(self, fixtures_dir: Path) -> None:
        gz_path = fixtures_dir / "samples" / "xqjc" / "a.gz"
        if gz_path.exists():
            path = fixtures_dir / "samples" / "xqjc" / "a"
            content = read_basis(path)
            assert len(content) > 0


class TestWriteBasis:
    def test_write_plain(self, tmp_path: Path) -> None:
        path = tmp_path / "a"
        result = write_basis(path, b"content", compress=False)
        assert result == path
        assert path.read_bytes() == b"content"

    def test_write_compressed(self, tmp_path: Path) -> None:
        path = tmp_path / "a"
        result = write_basis(path, b"content", compress=True)
        gz_path = tmp_path / "a.gz"
        assert result == gz_path
        assert gzip.decompress(gz_path.read_bytes()) == b"content"

    def test_write_removes_existing_plain(self, tmp_path: Path) -> None:
        path = tmp_path / "a"
        path.write_bytes(b"old")
        write_basis(path, b"new", compress=True)
        assert not path.exists()
        assert (tmp_path / "a.gz").exists()

    def test_write_removes_existing_gz(self, tmp_path: Path) -> None:
        path = tmp_path / "a"
        gz_path = tmp_path / "a.gz"
        gz_path.write_bytes(gzip.compress(b"old"))
        write_basis(path, b"new", compress=False)
        assert not gz_path.exists()
        assert path.exists()

    def test_no_temp_file_left_on_success(self, tmp_path: Path) -> None:
        path = tmp_path / "a"
        write_basis(path, b"content", compress=False)
        tmp_files = list(tmp_path.glob("*.tmp"))
        assert len(tmp_files) == 0


class TestRoundTrip:
    def test_roundtrip_plain(self, tmp_path: Path) -> None:
        path = tmp_path / "a"
        original = b"test content with\nlines\n"
        write_basis(path, original, compress=False)
        assert read_basis(path) == original

    def test_roundtrip_compressed(self, tmp_path: Path) -> None:
        path = tmp_path / "a"
        original = b"test content with\nlines\n"
        write_basis(path, original, compress=True)
        assert read_basis(path) == original

    def test_roundtrip_empty(self, tmp_path: Path) -> None:
        path = tmp_path / "a"
        write_basis(path, b"", compress=False)
        assert read_basis(path) == b""

    def test_roundtrip_binary(self, tmp_path: Path) -> None:
        path = tmp_path / "a"
        original = bytes(range(256))
        write_basis(path, original, compress=True)
        assert read_basis(path) == original


class TestBasisExists:
    def test_exists_plain(self, tmp_path: Path) -> None:
        path = tmp_path / "a"
        path.write_bytes(b"content")
        assert basis_exists(path) is True

    def test_exists_gz(self, tmp_path: Path) -> None:
        path = tmp_path / "a"
        gz_path = tmp_path / "a.gz"
        gz_path.write_bytes(gzip.compress(b"content"))
        assert basis_exists(path) is True

    def test_not_exists(self, tmp_path: Path) -> None:
        path = tmp_path / "nonexistent"
        assert basis_exists(path) is False
