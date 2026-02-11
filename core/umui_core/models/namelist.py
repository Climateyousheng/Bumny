"""Domain model for Fortran namelist groups."""

from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class NamelistGroup:
    """A single Fortran namelist group (&name ... &END).

    Values are stored as raw strings exactly as they appear in the file.
    Array values are stored as tuples of strings.
    """

    name: str
    values: tuple[tuple[str, str | tuple[str, ...]], ...]
