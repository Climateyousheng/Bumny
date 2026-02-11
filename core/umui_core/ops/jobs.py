"""Job CRUD operations.

Implements create, read, list, update, copy, and delete for jobs.
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
from umui_core.models.job import Job
from umui_core.storage.layout import DatabasePaths, validate_job_id

if TYPE_CHECKING:
    from umui_core.storage.layout import FileSystem

# Standard job fields in canonical order (matches legacy)
JOB_FIELDS: tuple[str, ...] = (
    "version",
    "description",
    "opened",
    "atmosphere",
    "ocean",
    "slab",
    "mesoscale",
)


class JobNotFoundError(Exception):
    """Raised when a job does not exist."""


class JobExistsError(Exception):
    """Raised when a job already exists."""


class JobLockedError(Exception):
    """Raised when a job is locked and operation is not permitted."""


def _pairs_to_job(exp_id: str, job_id: str, pairs: Pairs) -> Job:
    """Convert parsed pairs to a Job model."""
    fields = pairs_to_dict(pairs)
    return Job(
        job_id=job_id,
        exp_id=exp_id,
        version=fields.get("version", ""),
        description=fields.get("description", ""),
        opened=fields.get("opened", "N"),
        atmosphere=fields.get("atmosphere", ""),
        ocean=fields.get("ocean", ""),
        slab=fields.get("slab", ""),
        mesoscale=fields.get("mesoscale", ""),
    )


def _job_to_pairs(job: Job) -> Pairs:
    """Convert a Job model to pairs for writing."""
    data = {
        "version": job.version,
        "description": job.description,
        "opened": job.opened,
        "atmosphere": job.atmosphere,
        "ocean": job.ocean,
        "slab": job.slab,
        "mesoscale": job.mesoscale,
    }
    return dict_to_pairs(data, JOB_FIELDS)


def list_jobs(
    fs: FileSystem,
    paths: DatabasePaths,
    exp_id: str,
) -> list[Job]:
    """List all jobs in an experiment.

    Args:
        fs: Filesystem interface.
        paths: Database path helper.
        exp_id: Experiment ID.

    Returns:
        Sorted list of Job models.
    """
    exp_dir = paths.exp_dir(exp_id)
    if not fs.exists(exp_dir):
        return []

    job_files = fs.glob(exp_dir, "*.job")
    jobs: list[Job] = []

    for filepath in sorted(job_files):
        filename = filepath.rsplit("/", 1)[-1]
        job_id = filename.removesuffix(".job")

        try:
            validate_job_id(job_id)
        except Exception:
            continue

        text = fs.read_text(filepath)
        pairs = parse_pairs(text)
        jobs.append(_pairs_to_job(exp_id, job_id, pairs))

    return jobs


def get_job(
    fs: FileSystem,
    paths: DatabasePaths,
    exp_id: str,
    job_id: str,
) -> Job:
    """Read a single job.

    Args:
        fs: Filesystem interface.
        paths: Database path helper.
        exp_id: Experiment ID.
        job_id: Job ID.

    Returns:
        Job model.

    Raises:
        JobNotFoundError: If job does not exist.
    """
    job_path = paths.job_file(exp_id, job_id)
    if not fs.exists(job_path):
        raise JobNotFoundError(
            f"Job {job_id} not found in experiment {exp_id}"
        )

    text = fs.read_text(job_path)
    pairs = parse_pairs(text)
    return _pairs_to_job(exp_id, job_id, pairs)


def create_job(
    fs: FileSystem,
    paths: DatabasePaths,
    exp_id: str,
    job_id: str,
    description: str = "",
    version: str = "",
) -> Job:
    """Create a new job in an experiment.

    Args:
        fs: Filesystem interface.
        paths: Database path helper.
        exp_id: Experiment ID.
        job_id: Job ID (single lowercase letter).
        description: Job description.
        version: UM version.

    Returns:
        The newly created Job.

    Raises:
        JobExistsError: If job already exists.
    """
    validate_job_id(job_id)

    job_path = paths.job_file(exp_id, job_id)
    if fs.exists(job_path):
        raise JobExistsError(
            f"Job {job_id} already exists in experiment {exp_id}"
        )

    # Ensure experiment directory exists
    exp_dir = paths.exp_dir(exp_id)
    if not fs.exists(exp_dir):
        fs.mkdir(exp_dir)

    job = Job(
        job_id=job_id,
        exp_id=exp_id,
        version=version,
        description=description,
        opened="N",
        atmosphere="",
        ocean="",
        slab="",
        mesoscale="",
    )

    _save_job(fs, paths, job)

    # Create empty basis file if none exists
    basis_path = paths.basis_file(exp_id, job_id)
    basis_gz = f"{basis_path}.gz"
    if not fs.exists(basis_path) and not fs.exists(basis_gz):
        fs.write_bytes(basis_path, b"")

    return job


def update_job(
    fs: FileSystem,
    paths: DatabasePaths,
    exp_id: str,
    job_id: str,
    updates: dict[str, str],
) -> Job:
    """Update job fields.

    Args:
        fs: Filesystem interface.
        paths: Database path helper.
        exp_id: Experiment ID.
        job_id: Job ID.
        updates: Dictionary of fields to update.

    Returns:
        Updated Job model.

    Raises:
        JobNotFoundError: If job doesn't exist.
    """
    job_path = paths.job_file(exp_id, job_id)
    if not fs.exists(job_path):
        raise JobNotFoundError(
            f"Job {job_id} not found in experiment {exp_id}"
        )

    text = fs.read_text(job_path)
    pairs = parse_pairs(text)
    new_pairs = update_pairs(pairs, updates)

    fs.write_text(job_path, write_pairs(new_pairs))
    return _pairs_to_job(exp_id, job_id, new_pairs)


def delete_job(
    fs: FileSystem,
    paths: DatabasePaths,
    exp_id: str,
    job_id: str,
) -> None:
    """Delete a job and its basis file.

    Args:
        fs: Filesystem interface.
        paths: Database path helper.
        exp_id: Experiment ID.
        job_id: Job ID.

    Raises:
        JobNotFoundError: If job doesn't exist.
    """
    job_path = paths.job_file(exp_id, job_id)
    if not fs.exists(job_path):
        raise JobNotFoundError(
            f"Job {job_id} not found in experiment {exp_id}"
        )

    # Delete job file
    fs.delete(job_path)

    # Delete basis file (plain or gz)
    basis_path = paths.basis_file(exp_id, job_id)
    basis_gz = f"{basis_path}.gz"
    fs.delete(basis_path)
    fs.delete(basis_gz)


def copy_job(
    fs: FileSystem,
    paths: DatabasePaths,
    source_exp_id: str,
    source_job_id: str,
    dest_exp_id: str,
    dest_job_id: str,
    description: str = "",
) -> Job:
    """Copy a job to a new location.

    Copies job metadata and basis file.

    Args:
        fs: Filesystem interface.
        paths: Database path helper.
        source_exp_id: Source experiment ID.
        source_job_id: Source job ID.
        dest_exp_id: Destination experiment ID.
        dest_job_id: Destination job ID.
        description: Override description (empty = copy from source).

    Returns:
        The newly created Job.

    Raises:
        JobNotFoundError: If source doesn't exist.
        JobExistsError: If destination already exists.
    """
    source = get_job(fs, paths, source_exp_id, source_job_id)

    dest_path = paths.job_file(dest_exp_id, dest_job_id)
    if fs.exists(dest_path):
        raise JobExistsError(
            f"Job {dest_job_id} already exists in experiment {dest_exp_id}"
        )

    # Ensure destination experiment directory exists
    dest_dir = paths.exp_dir(dest_exp_id)
    if not fs.exists(dest_dir):
        fs.mkdir(dest_dir)

    new_job = Job(
        job_id=dest_job_id,
        exp_id=dest_exp_id,
        version=source.version,
        description=description or source.description,
        opened="N",
        atmosphere=source.atmosphere,
        ocean=source.ocean,
        slab=source.slab,
        mesoscale=source.mesoscale,
    )

    _save_job(fs, paths, new_job)

    # Copy basis file
    src_basis = paths.basis_file(source_exp_id, source_job_id)
    dst_basis = paths.basis_file(dest_exp_id, dest_job_id)
    src_gz = f"{src_basis}.gz"
    dst_gz = f"{dst_basis}.gz"

    if fs.exists(src_gz):
        data = fs.read_bytes(src_gz)
        fs.write_bytes(dst_gz, data)
    elif fs.exists(src_basis):
        data = fs.read_bytes(src_basis)
        fs.write_bytes(dst_basis, data)

    return new_job


def _save_job(
    fs: FileSystem,
    paths: DatabasePaths,
    job: Job,
) -> None:
    """Write job to disk."""
    pairs = _job_to_pairs(job)
    fs.write_text(paths.job_file(job.exp_id, job.job_id), write_pairs(pairs))
