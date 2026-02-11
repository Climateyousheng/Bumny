"""Experiment CRUD operations.

Implements create, read, list, update, copy, and delete for experiments.
All operations work through the FileSystem protocol for portability.
"""

from __future__ import annotations

from typing import TYPE_CHECKING

from umui_core.formats.pairs import (
    Pairs,
    dict_to_pairs,
    pairs_to_dict,
    parse_pairs,
    update_pairs,
    write_pairs,
)
from umui_core.models.experiment import Experiment
from umui_core.storage.layout import DatabasePaths, next_exp_id, validate_exp_id

if TYPE_CHECKING:
    from umui_core.storage.layout import FileSystem

# Standard experiment fields in canonical order (matches legacy .exp format)
# Note: 'id' is derived from the filename, not stored in the file.
# Note: 'opened' is a job-level field, not stored in .exp files.
EXP_FIELDS: tuple[str, ...] = (
    "owner",
    "description",
    "version",
    "atmosphere",
    "mesoscale",
    "ocean",
    "slab",
    "access_list",
    "privacy",
)


class ExperimentNotFoundError(Exception):
    """Raised when an experiment does not exist."""


class ExperimentExistsError(Exception):
    """Raised when an experiment already exists."""


class PermissionDeniedError(Exception):
    """Raised when a user lacks permission for an operation."""


def _pairs_to_experiment(exp_id: str, pairs: Pairs) -> Experiment:
    """Convert parsed pairs to an Experiment model."""
    fields = pairs_to_dict(pairs)
    return Experiment(
        id=fields.get("id", exp_id),
        owner=fields.get("owner", ""),
        description=fields.get("description", ""),
        version=fields.get("version", ""),
        access_list=fields.get("access_list", ""),
        privacy=fields.get("privacy", "N"),
        atmosphere=fields.get("atmosphere", ""),
        ocean=fields.get("ocean", ""),
        slab=fields.get("slab", ""),
        mesoscale=fields.get("mesoscale", ""),
        opened=fields.get("opened", "N"),
    )


def _experiment_to_pairs(exp: Experiment) -> Pairs:
    """Convert an Experiment model to pairs for writing.

    The 'id' is derived from the filename, not stored in the file.
    The 'opened' field is job-level, not stored in .exp files.
    """
    data = {
        "owner": exp.owner,
        "description": exp.description,
        "version": exp.version,
        "atmosphere": exp.atmosphere,
        "mesoscale": exp.mesoscale,
        "ocean": exp.ocean,
        "slab": exp.slab,
        "access_list": exp.access_list,
        "privacy": exp.privacy,
    }
    return dict_to_pairs(data, EXP_FIELDS)


def list_experiments(
    fs: FileSystem,
    paths: DatabasePaths,
) -> list[Experiment]:
    """List all experiments in the database.

    Args:
        fs: Filesystem interface.
        paths: Database path helper.

    Returns:
        Sorted list of Experiment models.
    """
    exp_files = fs.glob(paths.root, "*.exp")
    experiments: list[Experiment] = []

    for filepath in sorted(exp_files):
        # Extract exp_id from filename
        filename = filepath.rsplit("/", 1)[-1]
        exp_id = filename.removesuffix(".exp")

        try:
            validate_exp_id(exp_id)
        except Exception:
            continue

        text = fs.read_text(filepath)
        pairs = parse_pairs(text)
        experiments.append(_pairs_to_experiment(exp_id, pairs))

    return experiments


def get_experiment(
    fs: FileSystem,
    paths: DatabasePaths,
    exp_id: str,
) -> Experiment:
    """Read a single experiment.

    Args:
        fs: Filesystem interface.
        paths: Database path helper.
        exp_id: Experiment ID.

    Returns:
        Experiment model.

    Raises:
        ExperimentNotFoundError: If experiment does not exist.
    """
    exp_path = paths.exp_file(exp_id)
    if not fs.exists(exp_path):
        raise ExperimentNotFoundError(f"Experiment {exp_id} not found")

    text = fs.read_text(exp_path)
    pairs = parse_pairs(text)
    return _pairs_to_experiment(exp_id, pairs)


def create_experiment(
    fs: FileSystem,
    paths: DatabasePaths,
    owner: str,
    initial: str,
    description: str,
    privacy: str = "N",
    *,
    id_length: int = 4,
) -> Experiment:
    """Create a new experiment.

    Generates the next available ID for the given initial letter.

    Args:
        fs: Filesystem interface.
        paths: Database path helper.
        owner: Username of the experiment owner.
        initial: Initial letter for the experiment ID.
        description: Experiment description.
        privacy: Privacy setting (Y or N).
        id_length: Length of generated ID (default 4).

    Returns:
        The newly created Experiment.
    """
    existing = _get_existing_ids(fs, paths)
    exp_id = next_exp_id(initial, existing, length=id_length)

    exp = Experiment(
        id=exp_id,
        owner=owner,
        description=description,
        version="",
        access_list="",
        privacy=privacy,
        atmosphere="",
        ocean="",
        slab="",
        mesoscale="",
        opened="N",
    )

    _save_experiment(fs, paths, exp)

    # Create experiment directory
    exp_dir = paths.exp_dir(exp_id)
    if not fs.exists(exp_dir):
        fs.mkdir(exp_dir)

    return exp


def update_experiment(
    fs: FileSystem,
    paths: DatabasePaths,
    exp_id: str,
    user: str,
    updates: dict[str, str],
) -> Experiment:
    """Update experiment fields.

    Args:
        fs: Filesystem interface.
        paths: Database path helper.
        exp_id: Experiment ID.
        user: User performing the update.
        updates: Dictionary of fields to update.

    Returns:
        Updated Experiment model.

    Raises:
        ExperimentNotFoundError: If experiment doesn't exist.
        PermissionDeniedError: If user lacks permission.
    """
    exp = get_experiment(fs, paths, exp_id)

    if not exp.has_write_permission(user):
        raise PermissionDeniedError(
            f"User {user} does not have permission to alter experiment {exp_id}"
        )

    # Read raw pairs to preserve unknown fields
    text = fs.read_text(paths.exp_file(exp_id))
    pairs = parse_pairs(text)
    new_pairs = update_pairs(pairs, updates)

    fs.write_text(paths.exp_file(exp_id), write_pairs(new_pairs))
    return _pairs_to_experiment(exp_id, new_pairs)


def delete_experiment(
    fs: FileSystem,
    paths: DatabasePaths,
    exp_id: str,
    user: str,
) -> None:
    """Delete an experiment and all its jobs.

    Args:
        fs: Filesystem interface.
        paths: Database path helper.
        exp_id: Experiment ID.
        user: User performing the deletion.

    Raises:
        ExperimentNotFoundError: If experiment doesn't exist.
        PermissionDeniedError: If user lacks permission.
    """
    exp = get_experiment(fs, paths, exp_id)

    if not exp.has_write_permission(user):
        raise PermissionDeniedError(
            f"User {user} does not have permission to delete experiment {exp_id}"
        )

    # Delete experiment directory contents
    exp_dir = paths.exp_dir(exp_id)
    if fs.exists(exp_dir):
        for entry in fs.list_dir(exp_dir):
            fs.delete(f"{exp_dir}/{entry}")
        fs.rmdir(exp_dir)

    # Delete .exp file
    fs.delete(paths.exp_file(exp_id))


def copy_experiment(
    fs: FileSystem,
    paths: DatabasePaths,
    source_id: str,
    user: str,
    initial: str,
    description: str,
    *,
    id_length: int = 4,
) -> Experiment:
    """Copy an experiment to a new ID.

    Copies all jobs and basis files from the source experiment.

    Args:
        fs: Filesystem interface.
        paths: Database path helper.
        source_id: Source experiment ID.
        user: User performing the copy.
        initial: Initial letter for the new experiment ID.
        description: Description for the new experiment.
        id_length: Length of generated ID (default 4).

    Returns:
        The newly created Experiment.

    Raises:
        ExperimentNotFoundError: If source doesn't exist.
    """
    source = get_experiment(fs, paths, source_id)

    new_exp = create_experiment(
        fs, paths, user, initial, description, source.privacy,
        id_length=id_length,
    )

    # Copy all files from source directory
    source_dir = paths.exp_dir(source_id)
    dest_dir = paths.exp_dir(new_exp.id)

    if fs.exists(source_dir):
        for entry in fs.list_dir(source_dir):
            source_path = f"{source_dir}/{entry}"
            dest_path = f"{dest_dir}/{entry}"
            data = fs.read_bytes(source_path)
            fs.write_bytes(dest_path, data)

    return new_exp


def _save_experiment(
    fs: FileSystem,
    paths: DatabasePaths,
    exp: Experiment,
) -> None:
    """Write experiment to disk."""
    pairs = _experiment_to_pairs(exp)
    fs.write_text(paths.exp_file(exp.id), write_pairs(pairs))


def _get_existing_ids(
    fs: FileSystem,
    paths: DatabasePaths,
) -> frozenset[str]:
    """Get all existing experiment IDs."""
    exp_files = fs.glob(paths.root, "*.exp")
    ids: set[str] = set()
    for filepath in exp_files:
        filename = filepath.rsplit("/", 1)[-1]
        exp_id = filename.removesuffix(".exp")
        try:
            validate_exp_id(exp_id)
            ids.add(exp_id)
        except Exception:
            continue
    return frozenset(ids)
