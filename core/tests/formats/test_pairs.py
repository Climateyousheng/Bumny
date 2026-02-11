"""Tests for the pairs file format parser/writer."""

from __future__ import annotations

from typing import TYPE_CHECKING

import pytest
from umui_core.formats.pairs import (
    Pairs,
    PairsParseError,
    dict_to_pairs,
    pairs_to_dict,
    parse_pairs,
    update_pairs,
    write_pairs,
)

if TYPE_CHECKING:
    from pathlib import Path


class TestParsePairs:
    def test_simple_pairs(self) -> None:
        text = "owner\nnd20983\ndescription\nTest\n"
        result = parse_pairs(text)
        assert result == (("owner", "nd20983"), ("description", "Test"))

    def test_empty_value(self) -> None:
        text = "owner\nnd20983\naccess_list\n\n"
        result = parse_pairs(text)
        assert result == (("owner", "nd20983"), ("access_list", ""))

    def test_multiple_empty_values(self) -> None:
        text = "slab\n\nmesoscale\n\n"
        result = parse_pairs(text)
        assert result == (("slab", ""), ("mesoscale", ""))

    def test_odd_lines_raises(self) -> None:
        text = "owner\nnd20983\norphan\n"
        with pytest.raises(PairsParseError, match="even number"):
            parse_pairs(text)

    def test_empty_file(self) -> None:
        result = parse_pairs("")
        assert result == ()

    def test_single_pair(self) -> None:
        text = "version\n8.6\n"
        result = parse_pairs(text)
        assert result == (("version", "8.6"),)

    def test_preserves_field_order(self) -> None:
        text = "z_field\nzval\na_field\naval\nm_field\nmval\n"
        result = parse_pairs(text)
        fields = [f for f, _ in result]
        assert fields == ["z_field", "a_field", "m_field"]

    def test_values_with_spaces(self) -> None:
        text = "description\nHadCM3 Eocene soil sensitivity test\n"
        result = parse_pairs(text)
        assert result == (
            ("description", "HadCM3 Eocene soil sensitivity test"),
        )

    def test_access_list_with_multiple_users(self) -> None:
        text = "access_list\nnd20983 colleague1 colleague2\n"
        result = parse_pairs(text)
        assert result[0][1] == "nd20983 colleague1 colleague2"


class TestWritePairs:
    def test_simple_roundtrip(self) -> None:
        pairs: Pairs = (("owner", "nd20983"), ("version", "8.6"))
        text = write_pairs(pairs)
        assert text == "owner\nnd20983\nversion\n8.6\n"

    def test_empty_values_roundtrip(self) -> None:
        pairs: Pairs = (("slab", ""), ("mesoscale", ""))
        text = write_pairs(pairs)
        assert text == "slab\n\nmesoscale\n\n"

    def test_empty_pairs(self) -> None:
        text = write_pairs(())
        assert text == "\n"

    def test_trailing_newline(self) -> None:
        pairs: Pairs = (("field", "value"),)
        text = write_pairs(pairs)
        assert text.endswith("\n")


class TestRoundTrip:
    """Verify parse -> write -> parse produces identical results."""

    def test_roundtrip_simple(self) -> None:
        original = "owner\nnd20983\nversion\n8.6\n"
        pairs = parse_pairs(original)
        written = write_pairs(pairs)
        assert written == original

    def test_roundtrip_with_empty_values(self) -> None:
        original = "owner\nnd20983\naccess_list\n\nprivacy\nN\n"
        pairs = parse_pairs(original)
        written = write_pairs(pairs)
        assert written == original

    def test_roundtrip_fixture_files(self, fixtures_dir: Path) -> None:
        """Round-trip test against all fixture .exp and .job files."""
        samples = fixtures_dir / "samples"
        exp_files = list(samples.glob("*.exp"))
        job_files = list(samples.glob("*/*.job"))
        all_files = exp_files + job_files
        assert len(all_files) > 0, "No fixture files found"

        for filepath in all_files:
            original = filepath.read_text()
            pairs = parse_pairs(original)
            written = write_pairs(pairs)
            assert written == original, (
                f"Round-trip failed for {filepath.name}"
            )


class TestPairsToDict:
    def test_basic(self) -> None:
        pairs: Pairs = (("owner", "nd20983"), ("version", "8.6"))
        result = pairs_to_dict(pairs)
        assert result == {"owner": "nd20983", "version": "8.6"}

    def test_duplicate_last_wins(self) -> None:
        pairs: Pairs = (("field", "first"), ("field", "second"))
        result = pairs_to_dict(pairs)
        assert result == {"field": "second"}


class TestDictToPairs:
    def test_respects_field_order(self) -> None:
        data = {"version": "8.6", "owner": "nd20983"}
        order = ["owner", "version"]
        result = dict_to_pairs(data, order)
        assert result == (("owner", "nd20983"), ("version", "8.6"))

    def test_missing_fields_get_empty(self) -> None:
        data = {"owner": "nd20983"}
        order = ["owner", "version", "description"]
        result = dict_to_pairs(data, order)
        assert result == (
            ("owner", "nd20983"),
            ("version", ""),
            ("description", ""),
        )

    def test_extra_fields_appended(self) -> None:
        data = {"owner": "nd20983", "custom": "value"}
        order = ["owner"]
        result = dict_to_pairs(data, order)
        assert result == (("owner", "nd20983"), ("custom", "value"))


class TestUpdatePairs:
    def test_update_existing(self) -> None:
        pairs: Pairs = (("owner", "old"), ("version", "8.4"))
        result = update_pairs(pairs, {"owner": "new"})
        assert result == (("owner", "new"), ("version", "8.4"))

    def test_preserves_order(self) -> None:
        pairs: Pairs = (
            ("z_field", "z"),
            ("a_field", "a"),
            ("m_field", "m"),
        )
        result = update_pairs(pairs, {"a_field": "updated"})
        fields = [f for f, _ in result]
        assert fields == ["z_field", "a_field", "m_field"]

    def test_new_field_appended(self) -> None:
        pairs: Pairs = (("owner", "nd20983"),)
        result = update_pairs(pairs, {"new_field": "value"})
        assert result == (("owner", "nd20983"), ("new_field", "value"))

    def test_immutable(self) -> None:
        original: Pairs = (("owner", "nd20983"),)
        update_pairs(original, {"owner": "other"})
        assert original == (("owner", "nd20983"),)
