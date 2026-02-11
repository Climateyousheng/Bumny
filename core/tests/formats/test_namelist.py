"""Tests for Fortran namelist parser (UMUI basis format)."""

from __future__ import annotations

import gzip
from typing import TYPE_CHECKING

import pytest
from umui_core.formats.namelist import (
    NamelistParseError,
    namelist_to_dict,
    parse_namelist,
    update_namelist,
    write_namelist,
)
from umui_core.models.namelist import NamelistGroup

if TYPE_CHECKING:
    from pathlib import Path


class TestParseNamelist:
    """Tests for parse_namelist."""

    def test_single_group_scalar(self) -> None:
        text = " &mygroup\n SCALAR=42\n &END\n"
        result = parse_namelist(text)
        assert len(result) == 1
        assert result[0].name == "mygroup"
        assert result[0].values == (("SCALAR", "42"),)

    def test_single_group_string(self) -> None:
        text = " &g1\n NAME='hello'\n &END\n"
        result = parse_namelist(text)
        assert result[0].values == (("NAME", "'hello'"),)

    def test_array_value(self) -> None:
        text = " &g1\n ARR=1,\n 2,\n 3\n &END\n"
        result = parse_namelist(text)
        assert result[0].values == (("ARR", ("1", "2", "3")),)

    def test_string_array(self) -> None:
        text = " &g1\n SA='A',\n 'B',\n 'C'\n &END\n"
        result = parse_namelist(text)
        assert result[0].values == (("SA", ("'A'", "'B'", "'C'")),)

    def test_multiple_groups(self) -> None:
        text = " &g1\n A=1\n &END\n &g2\n B=2\n &END\n"
        result = parse_namelist(text)
        assert len(result) == 2
        assert result[0].name == "g1"
        assert result[1].name == "g2"

    def test_mixed_scalars_and_arrays(self) -> None:
        text = (
            " &mixed\n"
            " S=42\n"
            " A=1,\n 2,\n 3\n"
            " T='hello'\n"
            " &END\n"
        )
        result = parse_namelist(text)
        assert result[0].values == (
            ("S", "42"),
            ("A", ("1", "2", "3")),
            ("T", "'hello'"),
        )

    def test_empty_group(self) -> None:
        text = " &empty\n &END\n"
        result = parse_namelist(text)
        assert len(result) == 1
        assert result[0].values == ()

    def test_missing_end_raises(self) -> None:
        text = " &g1\n A=1\n"
        with pytest.raises(NamelistParseError, match="missing &END"):
            parse_namelist(text)

    def test_unexpected_end_raises(self) -> None:
        text = " &END\n"
        with pytest.raises(NamelistParseError, match="Unexpected &END"):
            parse_namelist(text)

    def test_blank_lines_between_groups(self) -> None:
        text = " &g1\n A=1\n &END\n\n &g2\n B=2\n &END\n"
        result = parse_namelist(text)
        assert len(result) == 2

    def test_logical_values(self) -> None:
        text = " &g1\n FLAG=T\n OTHER=F\n &END\n"
        result = parse_namelist(text)
        assert result[0].values == (("FLAG", "T"), ("OTHER", "F"))

    def test_real_values(self) -> None:
        text = " &g1\n X=2.000000e+03\n &END\n"
        result = parse_namelist(text)
        assert result[0].values == (("X", "2.000000e+03"),)

    def test_empty_input(self) -> None:
        result = parse_namelist("")
        assert result == ()

    def test_single_element_array(self) -> None:
        """A value ending in comma with no continuation is still an array."""
        text = " &g1\n A=1,\n B=2\n &END\n"
        result = parse_namelist(text)
        assert result[0].values == (("A", ("1",)), ("B", "2"))


class TestWriteNamelist:
    """Tests for write_namelist."""

    def test_single_scalar(self) -> None:
        groups = (NamelistGroup(name="g1", values=(("A", "1"),)),)
        result = write_namelist(groups)
        assert result == " &g1\n A=1\n &END\n"

    def test_array(self) -> None:
        groups = (
            NamelistGroup(name="g1", values=(("A", ("1", "2", "3")),)),
        )
        result = write_namelist(groups)
        assert result == " &g1\n A=1,\n 2,\n 3\n &END\n"

    def test_multiple_groups(self) -> None:
        groups = (
            NamelistGroup(name="g1", values=(("A", "1"),)),
            NamelistGroup(name="g2", values=(("B", "2"),)),
        )
        result = write_namelist(groups)
        assert " &g1\n" in result
        assert " &g2\n" in result

    def test_single_element_array(self) -> None:
        groups = (NamelistGroup(name="g1", values=(("A", ("1",)),)),)
        result = write_namelist(groups)
        assert result == " &g1\n A=1\n &END\n"


class TestRoundTrip:
    """Round-trip tests: parse -> write -> parse."""

    def test_simple_roundtrip(self) -> None:
        text = " &g1\n S=42\n A=1,\n 2,\n 3\n &END\n"
        groups = parse_namelist(text)
        written = write_namelist(groups)
        reparsed = parse_namelist(written)
        assert groups == reparsed

    def test_real_basis_file(self, fixtures_dir: Path) -> None:
        """Parse the real xqgt/a.gz basis file and round-trip it."""
        gz_path = fixtures_dir / "samples" / "xqgt" / "a.gz"
        raw = gzip.decompress(gz_path.read_bytes())
        text = raw.decode("utf-8", errors="replace")

        groups = parse_namelist(text)
        assert len(groups) == 33

        # All groups should have a name and at least some values
        for g in groups:
            assert g.name

        # Verify round-trip: parse -> write -> parse gives same result
        written = write_namelist(groups)
        reparsed = parse_namelist(written)
        assert len(reparsed) == len(groups)

        for orig, rt in zip(groups, reparsed, strict=True):
            assert orig.name == rt.name
            assert len(orig.values) == len(rt.values)
            for (ok, ov), (rk, rv) in zip(
                orig.values, rt.values, strict=True
            ):
                assert ok == rk
                assert ov == rv


class TestNamelistToDict:
    """Tests for namelist_to_dict."""

    def test_flattens_groups(self) -> None:
        groups = (
            NamelistGroup(name="g1", values=(("A", "1"),)),
            NamelistGroup(name="g2", values=(("B", "2"),)),
        )
        result = namelist_to_dict(groups)
        assert result == {"A": "1", "B": "2"}

    def test_preserves_arrays(self) -> None:
        groups = (
            NamelistGroup(name="g1", values=(("ARR", ("1", "2")),)),
        )
        result = namelist_to_dict(groups)
        assert result == {"ARR": ("1", "2")}


class TestUpdateNamelist:
    """Tests for update_namelist."""

    def test_update_scalar(self) -> None:
        groups = (NamelistGroup(name="g1", values=(("A", "1"), ("B", "2"))),)
        updated = update_namelist(groups, {"A": "99"})
        assert updated[0].values == (("A", "99"), ("B", "2"))

    def test_update_preserves_structure(self) -> None:
        groups = (
            NamelistGroup(name="g1", values=(("A", "1"),)),
            NamelistGroup(name="g2", values=(("B", "2"),)),
        )
        updated = update_namelist(groups, {"B": "99"})
        assert updated[0].values == (("A", "1"),)
        assert updated[1].values == (("B", "99"),)

    def test_update_array(self) -> None:
        groups = (
            NamelistGroup(name="g1", values=(("ARR", ("1", "2")),)),
        )
        updated = update_namelist(groups, {"ARR": ("10", "20", "30")})
        assert updated[0].values == (("ARR", ("10", "20", "30")),)
