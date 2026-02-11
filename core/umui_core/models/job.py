"""Domain model for UMUI jobs."""

from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class Job:
    """A job within an experiment in the UMUI database.

    Fields match the legacy .job file format (alternating field/value pairs).
    """

    job_id: str
    exp_id: str
    version: str
    description: str
    opened: str
    atmosphere: str
    ocean: str
    slab: str
    mesoscale: str

    def is_locked(self) -> bool:
        """Check if job is currently locked (opened) by someone."""
        return self.opened != "N" and self.opened != ""

    def locked_by(self) -> str | None:
        """Return the user who has this job locked, or None."""
        if self.is_locked():
            return self.opened
        return None
