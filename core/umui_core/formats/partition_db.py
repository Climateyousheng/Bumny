"""Parse the UMUI partition database (partition.database).

Each non-comment line defines a partition:

    KEY IDENTIFIER CONDITION1 [CONDITION2 ...]

- KEY is a single character identifying the partition (first letter of
  the partition code in var.register).
- IDENTIFIER is a string used in window name matching.
- CONDITIONs define when the partition is inactive (NEVER, ALWAYS,
  or a Tcl/expression condition).  Multiple conditions are for
  cross-partition variables.
"""

from __future__ import annotations

from umui_core.models.variable import Partition


class PartitionDbParseError(Exception):
    """Raised when partition.database cannot be parsed."""


def parse_partition_db(text: str) -> tuple[Partition, ...]:
    """Parse a partition.database file.

    Args:
        text: Raw content of the partition.database file.

    Returns:
        Tuple of Partition objects.

    Raises:
        PartitionDbParseError: If the format is invalid.
    """
    partitions: list[Partition] = []

    for line_num, line in enumerate(text.split("\n"), start=1):
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue

        tokens = stripped.split()
        if len(tokens) < 3:
            raise PartitionDbParseError(
                f"Expected at least 3 columns at line {line_num}: {line!r}"
            )

        key = tokens[0]
        identifier = tokens[1]
        conditions = tuple(tokens[2:])

        partitions.append(
            Partition(key=key, identifier=identifier, conditions=conditions)
        )

    return tuple(partitions)
