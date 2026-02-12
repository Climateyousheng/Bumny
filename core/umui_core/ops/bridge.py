"""Bridge operations: load app pack, read/write basis file variables.

The bridge editor allows users to view and edit model configuration
variables.  This module provides the core operations:

- Load the app pack (nav tree, windows, variable register, partitions)
- Read variable values from a job's basis file
- Write updated variables back to the basis file
"""

from __future__ import annotations

import gzip
from typing import TYPE_CHECKING

from umui_core.formats.namelist import (
    NamelistParseError,
    namelist_to_dict,
    parse_namelist,
    update_namelist,
    write_namelist,
)
from umui_core.formats.nav_spec import parse_nav_spec
from umui_core.formats.pan import parse_pan
from umui_core.formats.partition_db import parse_partition_db
from umui_core.formats.var_register import parse_var_register

if TYPE_CHECKING:
    from umui_core.models.namelist import NamelistGroup
    from umui_core.models.navigation import NavNode
    from umui_core.models.variable import Partition, VariableRegistration
    from umui_core.models.window import Window
    from umui_core.storage.app_pack import AppPackPaths
    from umui_core.storage.layout import DatabasePaths, FileSystem


class BridgeError(Exception):
    """Raised when a bridge operation fails."""


class BasisNotFoundError(BridgeError):
    """Raised when a basis file cannot be found."""


def load_nav_tree(
    fs: FileSystem,
    app_pack: AppPackPaths,
) -> tuple[NavNode, ...]:
    """Load the navigation tree from the app pack.

    Args:
        fs: Filesystem abstraction.
        app_pack: App pack path helper.

    Returns:
        Tuple of root NavNode objects.
    """
    text = fs.read_text(app_pack.nav_spec)
    return parse_nav_spec(text)


def load_window(
    fs: FileSystem,
    app_pack: AppPackPaths,
    win_id: str,
) -> Window:
    """Load a single window definition.

    Args:
        fs: Filesystem abstraction.
        app_pack: App pack path helper.
        win_id: Window identifier (filename without .pan).

    Returns:
        Parsed Window object.

    Raises:
        BridgeError: If the window file cannot be read.
    """
    path = app_pack.window_file(win_id)
    try:
        text = fs.read_text(path)
    except (FileNotFoundError, OSError) as e:
        raise BridgeError(f"Window '{win_id}' not found: {e}") from e
    return parse_pan(text)


def load_help(
    fs: FileSystem,
    app_pack: AppPackPaths,
    win_id: str,
) -> str:
    """Load help text for a window.

    Args:
        fs: Filesystem abstraction.
        app_pack: App pack path helper.
        win_id: Window identifier.

    Returns:
        Help text content, or empty string if not found.
    """
    path = app_pack.help_file(win_id)
    try:
        return fs.read_text(path)
    except (FileNotFoundError, OSError):
        return ""


def load_var_register(
    fs: FileSystem,
    app_pack: AppPackPaths,
) -> tuple[VariableRegistration, ...]:
    """Load the variable register from the app pack.

    Args:
        fs: Filesystem abstraction.
        app_pack: App pack path helper.

    Returns:
        Tuple of VariableRegistration objects.
    """
    text = fs.read_text(app_pack.var_register)
    return parse_var_register(text)


def load_partitions(
    fs: FileSystem,
    app_pack: AppPackPaths,
) -> tuple[Partition, ...]:
    """Load partition definitions from the app pack.

    Args:
        fs: Filesystem abstraction.
        app_pack: App pack path helper.

    Returns:
        Tuple of Partition objects.
    """
    text = fs.read_text(app_pack.partition_database)
    return parse_partition_db(text)


def read_variables(
    fs: FileSystem,
    paths: DatabasePaths,
    exp_id: str,
    job_id: str,
) -> dict[str, str | tuple[str, ...]]:
    """Read all variable values from a job's basis file.

    Looks for the .gz version first, then plain text.

    Args:
        fs: Filesystem abstraction.
        paths: Database path helper.
        exp_id: Experiment ID.
        job_id: Job ID (single letter).

    Returns:
        Dict mapping variable names to their values.

    Raises:
        BasisNotFoundError: If no basis file exists.
    """
    groups = _read_basis_groups(fs, paths, exp_id, job_id)
    return namelist_to_dict(groups)


def read_variables_for_window(
    fs: FileSystem,
    paths: DatabasePaths,
    app_pack: AppPackPaths,
    exp_id: str,
    job_id: str,
    win_id: str,
) -> dict[str, str | tuple[str, ...]]:
    """Read variable values scoped to a specific window.

    Loads the full variable register to determine which variables
    belong to the given window, then filters the basis file values.

    Args:
        fs: Filesystem abstraction.
        paths: Database path helper.
        app_pack: App pack path helper.
        exp_id: Experiment ID.
        job_id: Job ID.
        win_id: Window identifier.

    Returns:
        Dict of variable values for the given window.
    """
    all_vars = read_variables(fs, paths, exp_id, job_id)
    register = load_var_register(fs, app_pack)

    # Find variables that belong to this window
    window_var_names = frozenset(
        reg.name for reg in register if reg.window == win_id
    )

    return {k: v for k, v in all_vars.items() if k in window_var_names}


def write_variables(
    fs: FileSystem,
    paths: DatabasePaths,
    exp_id: str,
    job_id: str,
    updates: dict[str, str | tuple[str, ...]],
) -> None:
    """Update variables in a job's basis file.

    Reads the existing basis file, applies updates, and writes
    back in compressed format.

    Args:
        fs: Filesystem abstraction.
        paths: Database path helper.
        exp_id: Experiment ID.
        job_id: Job ID.
        updates: Variable names to new values.

    Raises:
        BasisNotFoundError: If no basis file exists.
    """
    groups = _read_basis_groups(fs, paths, exp_id, job_id)
    new_groups = update_namelist(groups, updates)
    content = write_namelist(new_groups).encode("utf-8")
    compressed = gzip.compress(content)

    gz_path = paths.basis_file(exp_id, job_id) + ".gz"
    fs.write_bytes(gz_path, compressed)


def read_basis_raw(
    fs: FileSystem,
    paths: DatabasePaths,
    exp_id: str,
    job_id: str,
) -> str:
    """Read the raw text content of a job's basis file.

    Args:
        fs: Filesystem abstraction.
        paths: Database path helper.
        exp_id: Experiment ID.
        job_id: Job ID.

    Returns:
        Raw basis file content as UTF-8 text.

    Raises:
        BasisNotFoundError: If no basis file exists.
        BridgeError: If the file cannot be read or decompressed.
    """
    base_path = paths.basis_file(exp_id, job_id)
    gz_path = base_path + ".gz"

    if fs.exists(gz_path):
        try:
            raw = fs.read_bytes(gz_path)
            return gzip.decompress(raw).decode("utf-8", errors="replace")
        except (gzip.BadGzipFile, OSError) as e:
            raise BridgeError(
                f"Failed to read basis file {gz_path}: {e}"
            ) from e

    if fs.exists(base_path):
        return fs.read_text(base_path)

    raise BasisNotFoundError(
        f"Basis file not found for experiment {exp_id}, job {job_id}"
    )


def _read_basis_groups(
    fs: FileSystem,
    paths: DatabasePaths,
    exp_id: str,
    job_id: str,
) -> tuple[NamelistGroup, ...]:
    """Read and parse the basis file for a job."""
    base_path = paths.basis_file(exp_id, job_id)
    gz_path = base_path + ".gz"

    # Try compressed first
    if fs.exists(gz_path):
        try:
            raw = fs.read_bytes(gz_path)
            text = gzip.decompress(raw).decode("utf-8", errors="replace")
            return parse_namelist(text)
        except (gzip.BadGzipFile, OSError, NamelistParseError) as e:
            raise BridgeError(
                f"Failed to read basis file {gz_path}: {e}"
            ) from e

    # Try plain text
    if fs.exists(base_path):
        try:
            text = fs.read_text(base_path)
            return parse_namelist(text)
        except NamelistParseError as e:
            raise BridgeError(
                f"Failed to parse basis file {base_path}: {e}"
            ) from e

    raise BasisNotFoundError(
        f"Basis file not found for experiment {exp_id}, job {job_id}"
    )
