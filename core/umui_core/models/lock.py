"""Domain model for UMUI locks."""

from __future__ import annotations

import time
from dataclasses import dataclass, field


@dataclass(frozen=True)
class Lock:
    """Represents a lock on a job.

    Supports both the legacy field-based locking (opened field in .job)
    and the new mkdir-based distributed locking.
    """

    exp_id: str
    job_id: str
    owner: str
    timestamp: float = field(default_factory=time.time)
    client_id: str = ""

    @property
    def key(self) -> str:
        """Unique identifier for this lock."""
        return f"{self.exp_id}/{self.job_id}"


@dataclass(frozen=True)
class LockResult:
    """Result of a lock acquisition attempt."""

    success: bool
    owner: str
    message: str
    forced: bool = False
