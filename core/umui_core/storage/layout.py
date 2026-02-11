"""Storage layout and path construction for the UMUI database.

Database layout:
    <db_root>/
        <exp_id>.exp          - Experiment metadata (pairs format)
        <exp_id>/             - Experiment directory
            <job_id>.job      - Job metadata (pairs format)
            <job_id>          - Basis file (plain text)
            <job_id>.gz       - Basis file (gzip compressed)
        log                   - Server activity log

Experiment IDs:
    4-letter base-26 IDs (aaaa-zzzz). The 5-character "run ID" seen
    in UM output is experiment (4 chars) + job (1 char), e.g. xqjca
    = experiment xqjc, job a.
"""

from __future__ import annotations

import re
from pathlib import Path
from typing import Protocol

# Experiment ID: exactly 4 lowercase letters
EXP_ID_PATTERN = re.compile(r"^[a-z]{4}$")

# Job ID: exactly 1 lowercase letter
JOB_ID_PATTERN = re.compile(r"^[a-z]$")


class InvalidIdError(Exception):
    """Raised when an experiment or job ID is invalid."""


def validate_exp_id(exp_id: str) -> str:
    """Validate an experiment ID (4 lowercase letters).

    Args:
        exp_id: The experiment ID to validate.

    Returns:
        The validated ID.

    Raises:
        InvalidIdError: If the ID is not valid.
    """
    if not EXP_ID_PATTERN.match(exp_id):
        raise InvalidIdError(
            f"Invalid experiment ID '{exp_id}': "
            "must be 4 lowercase letters"
        )
    return exp_id


def validate_job_id(job_id: str) -> str:
    """Validate a job ID (1 lowercase letter).

    Args:
        job_id: The job ID to validate.

    Returns:
        The validated ID.

    Raises:
        InvalidIdError: If the ID is not valid.
    """
    if not JOB_ID_PATTERN.match(job_id):
        raise InvalidIdError(
            f"Invalid job ID '{job_id}': must be exactly 1 lowercase letter"
        )
    return job_id


def numerate_exp_id(exp_id: str) -> int:
    """Convert an experiment ID to a numeric value (base-26).

    Args:
        exp_id: 4 letter lowercase experiment ID.

    Returns:
        Integer representation in base-26.
    """
    validate_exp_id(exp_id)
    result = 0
    for ch in exp_id:
        result = result * 26 + (ord(ch) - 97)
    return result


def literate_exp_id(num: int, length: int = 4) -> str:
    """Convert a numeric value back to an experiment ID.

    Args:
        num: Non-negative integer.
        length: Number of characters (4 or 5).

    Returns:
        Lowercase experiment ID of the specified length.

    Raises:
        ValueError: If num is out of valid range for the length.
    """
    max_val = 26**length - 1
    if num < 0 or num > max_val:
        raise ValueError(
            f"Experiment ID number {num} out of range [0, {max_val}] "
            f"for length {length}"
        )
    chars: list[str] = []
    remaining = num
    for _ in range(length):
        chars.append(chr((remaining % 26) + 97))
        remaining //= 26
    return "".join(reversed(chars))


def next_exp_id(
    initial: str,
    existing_ids: frozenset[str],
    *,
    length: int = 4,
) -> str:
    """Find the next free experiment ID for a given initial letter.

    Port of the legacy Tcl `next_exp_id` function.
    Scans through the sorted existing IDs to find the lowest free ID
    starting with the given initial letter.

    Args:
        initial: Single lowercase letter for the first character.
        existing_ids: Set of all existing experiment IDs.
        length: ID length to generate (default 4).

    Returns:
        The next available experiment ID.

    Raises:
        InvalidIdError: If initial is not a single lowercase letter.
        ValueError: If no free IDs remain for the given initial.
    """
    if not re.match(r"^[a-z]$", initial):
        raise InvalidIdError(
            f"Bad initial letter '{initial}': must be a-z"
        )

    pad = "a" * (length - 1)
    end = "z" * (length - 1)
    free = numerate_exp_id(f"{initial}{pad}")
    last = numerate_exp_id(f"{initial}{end}")

    # Sort and scan existing IDs of matching length
    for exp_id in sorted(existing_ids):
        if len(exp_id) != length:
            continue
        this = numerate_exp_id(exp_id)
        if this > last:
            break
        if this >= free:
            free = this + 1
            if free > last:
                raise ValueError(
                    f"No more experiment IDs free for initial letter "
                    f"'{initial}' (length={length})"
                )

    return literate_exp_id(free, length=length)


class FileSystem(Protocol):
    """Abstract filesystem interface for storage operations.

    This protocol allows swapping between local filesystem and SSH
    backends without changing the core logic.
    """

    def read_bytes(self, path: str) -> bytes:
        """Read file contents as bytes."""
        ...

    def write_bytes(self, path: str, data: bytes) -> None:
        """Write bytes to a file (atomic: temp + rename)."""
        ...

    def read_text(self, path: str) -> str:
        """Read file contents as text."""
        ...

    def write_text(self, path: str, text: str) -> None:
        """Write text to a file (atomic: temp + rename)."""
        ...

    def exists(self, path: str) -> bool:
        """Check if a path exists."""
        ...

    def mkdir(self, path: str) -> bool:
        """Create a directory. Returns True if created, False if exists."""
        ...

    def rmdir(self, path: str) -> None:
        """Remove a directory."""
        ...

    def delete(self, path: str) -> None:
        """Delete a file."""
        ...

    def list_dir(self, path: str) -> list[str]:
        """List entries in a directory."""
        ...

    def glob(self, path: str, pattern: str) -> list[str]:
        """Find files matching a glob pattern."""
        ...


class LocalFileSystem:
    """Local filesystem implementation of the FileSystem protocol."""

    def read_bytes(self, path: str) -> bytes:
        return Path(path).read_bytes()

    def write_bytes(self, path: str, data: bytes) -> None:
        p = Path(path)
        tmp = p.with_suffix(".tmp")
        try:
            tmp.write_bytes(data)
            tmp.rename(p)
        except OSError:
            tmp.unlink(missing_ok=True)
            raise

    def read_text(self, path: str) -> str:
        return Path(path).read_text()

    def write_text(self, path: str, text: str) -> None:
        p = Path(path)
        tmp = p.with_suffix(".tmp")
        try:
            tmp.write_text(text)
            tmp.rename(p)
        except OSError:
            tmp.unlink(missing_ok=True)
            raise

    def exists(self, path: str) -> bool:
        return Path(path).exists()

    def mkdir(self, path: str) -> bool:
        p = Path(path)
        try:
            p.mkdir(parents=False, exist_ok=False)
            return True
        except FileExistsError:
            return False

    def rmdir(self, path: str) -> None:
        Path(path).rmdir()

    def delete(self, path: str) -> None:
        Path(path).unlink(missing_ok=True)

    def list_dir(self, path: str) -> list[str]:
        return [entry.name for entry in Path(path).iterdir()]

    def glob(self, path: str, pattern: str) -> list[str]:
        return [str(p) for p in Path(path).glob(pattern)]


class DatabasePaths:
    """Helper for constructing paths within the UMUI database layout."""

    def __init__(self, db_root: str) -> None:
        self._root = db_root

    @property
    def root(self) -> str:
        return self._root

    def exp_file(self, exp_id: str) -> str:
        """Path to the .exp metadata file."""
        validate_exp_id(exp_id)
        return f"{self._root}/{exp_id}.exp"

    def exp_dir(self, exp_id: str) -> str:
        """Path to the experiment directory."""
        validate_exp_id(exp_id)
        return f"{self._root}/{exp_id}"

    def job_file(self, exp_id: str, job_id: str) -> str:
        """Path to the .job metadata file."""
        validate_exp_id(exp_id)
        validate_job_id(job_id)
        return f"{self._root}/{exp_id}/{job_id}.job"

    def basis_file(self, exp_id: str, job_id: str) -> str:
        """Path to the basis file (without .gz extension)."""
        validate_exp_id(exp_id)
        validate_job_id(job_id)
        return f"{self._root}/{exp_id}/{job_id}"

    def lock_dir(self, exp_id: str, job_id: str) -> str:
        """Path to the mkdir-based lock directory."""
        validate_exp_id(exp_id)
        validate_job_id(job_id)
        return f"{self._root}/{exp_id}/{job_id}.lock"

    def log_file(self) -> str:
        """Path to the server log file."""
        return f"{self._root}/log"
