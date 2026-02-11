"""Parse and write Fortran namelist files (UMUI basis format).

UMUI basis files use a non-standard Fortran namelist format:
- Groups start with `` &name`` (space-prefixed) on their own line.
- Groups end with `` &END`` on their own line.
- Assignments are `` KEY=value`` with a leading space.
- Array values use continuation lines: the first line has a trailing
  comma, and subsequent lines are just the value (space-prefixed),
  each also with a trailing comma except the last.
- String values are single-quoted: ``'text'``.

Example::

     &mygroup
     SCALAR=42
     ARRAY=1,
     2,
     3
     NAME='hello'
     &END
"""

from __future__ import annotations

import re

from umui_core.models.namelist import NamelistGroup


class NamelistParseError(Exception):
    """Raised when a namelist file cannot be parsed."""


def parse_namelist(text: str) -> tuple[NamelistGroup, ...]:
    """Parse a UMUI basis file into a sequence of namelist groups.

    Args:
        text: Raw file content.

    Returns:
        Ordered tuple of NamelistGroup objects.

    Raises:
        NamelistParseError: If the file structure is invalid.
    """
    lines = text.split("\n")
    groups: list[NamelistGroup] = []
    i = 0

    while i < len(lines):
        line = lines[i]
        stripped = line.strip()

        # Skip blank lines between groups
        if not stripped:
            i += 1
            continue

        # Look for group start: &name
        match = re.match(r"\s*&(\w+)\s*$", stripped)
        if match:
            group_name = match.group(1)
            if group_name.upper() == "END":
                raise NamelistParseError(
                    f"Unexpected &END at line {i + 1} outside a group"
                )
            i += 1
            entries: list[tuple[str, str | tuple[str, ...]]] = []
            i = _parse_group_body(lines, i, entries)
            groups.append(
                NamelistGroup(name=group_name, values=tuple(entries))
            )
        else:
            raise NamelistParseError(
                f"Expected group start (&name), got: {line!r} at line {i + 1}"
            )

    return tuple(groups)


def _parse_group_body(
    lines: list[str],
    start: int,
    entries: list[tuple[str, str | tuple[str, ...]]],
) -> int:
    """Parse the body of a namelist group.

    Returns the line index after the &END line.
    """
    i = start

    while i < len(lines):
        line = lines[i]
        stripped = line.strip()

        # Group end
        if stripped.upper() == "&END":
            return i + 1

        # Skip blank lines within group
        if not stripped:
            i += 1
            continue

        # Assignment: KEY=value
        eq_match = re.match(r"\s*(\S+?)=(.*)", line)
        if not eq_match:
            raise NamelistParseError(
                f"Expected KEY=value or &END, got: {line!r} at line {i + 1}"
            )

        key = eq_match.group(1)
        first_val = eq_match.group(2)
        i += 1

        # Check if this is an array (trailing comma)
        if first_val.rstrip().endswith(","):
            # Collect array values
            vals = [first_val.rstrip().rstrip(",")]
            while i < len(lines):
                cont = lines[i]
                cont_stripped = cont.strip()
                if not cont_stripped:
                    i += 1
                    continue
                # If next line looks like a new assignment or &END, stop
                if cont_stripped.upper() == "&END" or re.match(
                    r"\s*\S+?=", cont
                ):
                    break
                # Continuation value
                val = cont_stripped.rstrip(",")
                vals.append(val)
                i += 1
                # If this line didn't end with comma, array is done
                if not cont_stripped.endswith(","):
                    break
            entries.append((key, tuple(vals)))
        else:
            entries.append((key, first_val))

    raise NamelistParseError("Unexpected end of file: missing &END")


def write_namelist(groups: tuple[NamelistGroup, ...] | list[NamelistGroup]) -> str:
    """Write namelist groups back to UMUI basis file format.

    Args:
        groups: Sequence of NamelistGroup objects.

    Returns:
        String in the basis file format.
    """
    parts: list[str] = []

    for group in groups:
        parts.append(f" &{group.name}")
        for key, value in group.values:
            if isinstance(value, tuple):
                # Array value
                for j, v in enumerate(value):
                    if j == 0:
                        if len(value) == 1:
                            parts.append(f" {key}={v}")
                        else:
                            parts.append(f" {key}={v},")
                    elif j == len(value) - 1:
                        parts.append(f" {v}")
                    else:
                        parts.append(f" {v},")
            else:
                parts.append(f" {key}={value}")
        parts.append(" &END")

    return "\n".join(parts) + "\n"


def namelist_to_dict(
    groups: tuple[NamelistGroup, ...],
) -> dict[str, str | tuple[str, ...]]:
    """Flatten all namelist groups into a single variable dict.

    Namelist group names become prefixed where needed to avoid collisions.
    In practice, UMUI variable names are unique across groups.

    Args:
        groups: Sequence of NamelistGroup objects.

    Returns:
        Dict mapping variable names to their values.
    """
    result: dict[str, str | tuple[str, ...]] = {}
    for group in groups:
        for key, value in group.values:
            result[key] = value
    return result


def update_namelist(
    groups: tuple[NamelistGroup, ...],
    updates: dict[str, str | tuple[str, ...]],
) -> tuple[NamelistGroup, ...]:
    """Create new namelist groups with updated values (immutable).

    Searches all groups for matching keys and returns updated copies.

    Args:
        groups: Original groups.
        updates: Variable names to new values.

    Returns:
        New tuple of groups with updates applied.
    """
    remaining = dict(updates)
    new_groups: list[NamelistGroup] = []

    for group in groups:
        new_entries: list[tuple[str, str | tuple[str, ...]]] = []
        for key, value in group.values:
            if key in remaining:
                new_entries.append((key, remaining.pop(key)))
            else:
                new_entries.append((key, value))
        new_groups.append(
            NamelistGroup(name=group.name, values=tuple(new_entries))
        )

    return tuple(new_groups)
