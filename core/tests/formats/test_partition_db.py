"""Tests for partition.database parser."""

from __future__ import annotations

from typing import TYPE_CHECKING

import pytest
from umui_core.formats.partition_db import PartitionDbParseError, parse_partition_db

if TYPE_CHECKING:
    from pathlib import Path


class TestParsePartitionDb:
    """Tests for parse_partition_db."""

    def test_simple_partition(self) -> None:
        text = 'a    atmos           ATMOS!="T"\n'
        result = parse_partition_db(text)
        assert len(result) == 1
        assert result[0].key == "a"
        assert result[0].identifier == "atmos"
        assert result[0].conditions == ('ATMOS!="T"',)

    def test_never_condition(self) -> None:
        text = "p    personal        NEVER\n"
        result = parse_partition_db(text)
        assert result[0].conditions == ("NEVER",)

    def test_multiple_conditions(self) -> None:
        text = "x    xsubmod         a         o         s        w\n"
        result = parse_partition_db(text)
        assert result[0].key == "x"
        assert result[0].identifier == "xsubmod"
        assert result[0].conditions == ("a", "o", "s", "w")

    def test_always_condition(self) -> None:
        text = "y    ysubmod         a         o         ALWAYS   w\n"
        result = parse_partition_db(text)
        assert "ALWAYS" in result[0].conditions

    def test_comments_and_blanks(self) -> None:
        text = (
            "# Comment\n"
            "\n"
            "a    atmos           NEVER\n"
            "# Another\n"
            "o    ocean           NEVER\n"
        )
        result = parse_partition_db(text)
        assert len(result) == 2

    def test_empty_input(self) -> None:
        result = parse_partition_db("")
        assert result == ()

    def test_too_few_columns_raises(self) -> None:
        with pytest.raises(PartitionDbParseError, match="at least 3 columns"):
            parse_partition_db("a atmos\n")

    def test_real_partition_db(self, fixtures_dir: Path) -> None:
        """Parse the real partition.database fixture."""
        path = (
            fixtures_dir / "app_pack" / "vn8.6" / "variables"
            / "partition.database"
        )
        text = path.read_text()
        result = parse_partition_db(text)
        assert len(result) >= 10

        # Check known partitions
        keys = {p.key for p in result}
        assert "a" in keys  # atmosphere
        assert "o" in keys  # ocean
        assert "p" in keys  # personal
