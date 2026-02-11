"""Parse and write UMUI .exp/.job files.

Legacy format: alternating lines of field name and field value.
Empty values are represented as empty lines.
Field order must be preserved for round-trip fidelity.

Example:
    owner
    nd20983
    description
    Test experiment
    version
    8.6
"""

from __future__ import annotations

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from collections.abc import Sequence

# Type alias: ordered sequence of (field, value) pairs
Pairs = tuple[tuple[str, str], ...]


class PairsParseError(Exception):
    """Raised when a pairs file cannot be parsed."""


def parse_pairs(text: str) -> Pairs:
    """Parse alternating field/value lines into ordered pairs.

    Args:
        text: Raw file content with alternating field/value lines.

    Returns:
        Ordered tuple of (field, value) pairs.

    Raises:
        PairsParseError: If file has odd number of non-empty trailing lines.
    """
    lines = text.split("\n")

    # Remove single trailing empty line (from final newline)
    if lines and lines[-1] == "":
        lines = lines[:-1]

    if len(lines) % 2 != 0:
        raise PairsParseError(
            f"Expected even number of lines, got {len(lines)}"
        )

    entries: list[tuple[str, str]] = []
    for i in range(0, len(lines), 2):
        field = lines[i]
        value = lines[i + 1]
        entries.append((field, value))

    return tuple(entries)


def write_pairs(pairs: Pairs | Sequence[tuple[str, str]]) -> str:
    """Write ordered pairs back to the alternating field/value format.

    Each pair becomes two lines: field then value.
    The output ends with a trailing newline.

    Args:
        pairs: Ordered sequence of (field, value) tuples.

    Returns:
        String in the pairs file format.
    """
    lines: list[str] = []
    for field, value in pairs:
        lines.append(field)
        lines.append(value)
    return "\n".join(lines) + "\n"


def pairs_to_dict(pairs: Pairs) -> dict[str, str]:
    """Convert pairs to a dictionary.

    Note: If duplicate fields exist, the last value wins.

    Args:
        pairs: Ordered pairs.

    Returns:
        Dictionary mapping field names to values.
    """
    return {field: value for field, value in pairs}


def dict_to_pairs(
    data: dict[str, str],
    field_order: Sequence[str],
) -> Pairs:
    """Convert a dictionary to ordered pairs using a field order.

    Fields not in field_order are appended at the end.
    Fields in field_order but not in data get empty string values.

    Args:
        data: Field name to value mapping.
        field_order: Desired field ordering.

    Returns:
        Ordered pairs following the specified order.
    """
    entries: list[tuple[str, str]] = []
    seen: set[str] = set()

    for field in field_order:
        value = data.get(field, "")
        entries.append((field, value))
        seen.add(field)

    # Append any extra fields not in the ordering
    for field, value in data.items():
        if field not in seen:
            entries.append((field, value))

    return tuple(entries)


def update_pairs(
    pairs: Pairs,
    updates: dict[str, str],
) -> Pairs:
    """Create new pairs with updated values (immutable).

    Preserves the original field order. New fields in updates
    that don't exist in pairs are appended.

    Args:
        pairs: Original ordered pairs.
        updates: Fields to update with new values.

    Returns:
        New pairs tuple with updates applied.
    """
    entries: list[tuple[str, str]] = []
    remaining = dict(updates)

    for field, value in pairs:
        if field in remaining:
            entries.append((field, remaining.pop(field)))
        else:
            entries.append((field, value))

    # Append any new fields
    for field, value in remaining.items():
        entries.append((field, value))

    return tuple(entries)
