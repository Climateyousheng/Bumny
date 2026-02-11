"""Domain model for UMUI experiments."""

from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class Experiment:
    """An experiment in the UMUI database.

    Fields match the legacy .exp file format (alternating field/value pairs).
    The 'id' field is derived from the filename, not stored in the file itself
    in the legacy system, but is included in the data for convenience.
    """

    id: str
    owner: str
    description: str
    version: str
    access_list: str
    privacy: str
    atmosphere: str
    ocean: str
    slab: str
    mesoscale: str
    opened: str

    def is_public(self) -> bool:
        """Check if experiment is publicly viewable."""
        return self.privacy in ("N", "Unset", "")

    def has_access(self, user: str) -> bool:
        """Check if a user has access to this experiment."""
        if self.is_public():
            return True
        if self.owner == user:
            return True
        return user in self.access_list.split()

    def has_write_permission(self, user: str) -> bool:
        """Check if a user has write permission."""
        if self.owner == user:
            return True
        return user in self.access_list.split()
