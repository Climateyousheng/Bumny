"""Read and write UMUI basis files (job configuration data).

Basis files are stored either as plain text or gzip-compressed.
The file format is opaque to this layer - we preserve bytes exactly.
"""

from __future__ import annotations

import gzip
from pathlib import Path


class BasisFileError(Exception):
    """Raised when a basis file operation fails."""


def read_basis(path: Path) -> bytes:
    """Read a basis file, handling both plain and gzip formats.

    Checks for .gz version first, then plain.

    Args:
        path: Base path without .gz extension.

    Returns:
        Raw basis file contents as bytes.

    Raises:
        BasisFileError: If neither plain nor .gz file exists.
    """
    gz_path = path.with_suffix(path.suffix + ".gz") if path.suffix else Path(
        str(path) + ".gz"
    )

    if gz_path.exists():
        try:
            return gzip.decompress(gz_path.read_bytes())
        except (gzip.BadGzipFile, OSError) as e:
            raise BasisFileError(
                f"Failed to decompress {gz_path}: {e}"
            ) from e

    if path.exists():
        return path.read_bytes()

    raise BasisFileError(
        f"Basis file not found: neither {path} nor {gz_path} exists"
    )


def write_basis(path: Path, content: bytes, *, compress: bool = True) -> Path:
    """Write a basis file, optionally compressing with gzip.

    Uses atomic write: writes to temp file then renames.

    Args:
        path: Base path without .gz extension.
        content: Raw basis file contents.
        compress: Whether to gzip the output.

    Returns:
        The actual path written (may have .gz suffix).
    """
    gz_path = path.with_suffix(path.suffix + ".gz") if path.suffix else Path(
        str(path) + ".gz"
    )

    # Remove any existing version (plain or gz)
    _cleanup_existing(path, gz_path)

    if compress:
        tmp_path = gz_path.with_suffix(".tmp")
        try:
            tmp_path.write_bytes(gzip.compress(content))
            tmp_path.rename(gz_path)
        except OSError:
            tmp_path.unlink(missing_ok=True)
            raise
        return gz_path

    tmp_path = path.with_suffix(".tmp")
    try:
        tmp_path.write_bytes(content)
        tmp_path.rename(path)
    except OSError:
        tmp_path.unlink(missing_ok=True)
        raise
    return path


def basis_exists(path: Path) -> bool:
    """Check if a basis file exists (plain or gzip).

    Args:
        path: Base path without .gz extension.

    Returns:
        True if either plain or .gz version exists.
    """
    gz_path = path.with_suffix(path.suffix + ".gz") if path.suffix else Path(
        str(path) + ".gz"
    )
    return path.exists() or gz_path.exists()


def _cleanup_existing(path: Path, gz_path: Path) -> None:
    """Remove existing plain and gz versions."""
    if gz_path.exists():
        gz_path.unlink()
    if path.exists():
        path.unlink()
