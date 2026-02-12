"""Submit a processed job to a remote HPC system via SSH.

Copies processed files to the remote machine, sets permissions, and
executes the SUBMIT script.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from umui_connectors.ssh_fs import SshFileSystem


class SubmitError(Exception):
    """Raised when job submission fails."""


@dataclass(frozen=True)
class SubmitRequest:
    """Input for submit operation."""

    exp_id: str
    job_id: str
    target_host: str
    target_user: str
    processed_files: dict[str, str]


@dataclass(frozen=True)
class SubmitResult:
    """Result of submit operation."""

    submit_id: str
    remote_dir: str
    submit_stdout: str
    submit_stderr: str
    exit_status: int
    success: bool


def submit_job(
    ssh_fs: SshFileSystem,
    request: SubmitRequest,
) -> SubmitResult:
    """Submit a processed job to remote HPC system.

    Workflow:
        1. Generate submit ID (timestamp: DDDHHMMSS format).
        2. Create remote directory ~/umui_runs/<runid>-<submitid>.
        3. Write all processed files via SFTP.
        4. Substitute :::submitid::: placeholder in file contents.
        5. Make SUBMIT executable (chmod 755).
        6. Execute SUBMIT script remotely.
        7. Return result with stdout/stderr.

    Args:
        ssh_fs: SSH filesystem with run_command capability.
        request: Submit request with files and target info.

    Returns:
        SubmitResult with remote execution output.

    Raises:
        SubmitError: If critical submission steps fail.
    """
    submit_id = _generate_submit_id()
    run_id = request.exp_id + request.job_id
    remote_dir = f"~/umui_runs/{run_id}-{submit_id}"

    # Create remote directory tree
    try:
        ssh_fs.run_command(f"mkdir -p {remote_dir}", check=True)
    except RuntimeError as exc:
        raise SubmitError(f"Failed to create remote directory: {exc}") from exc

    # Write all processed files
    for filename, content in request.processed_files.items():
        # Substitute :::submitid::: placeholder if present
        if ":::submitid:::" in content:
            content = content.replace(":::submitid:::", submit_id)

        ssh_fs.write_text(f"{remote_dir}/{filename}", content)

    # Make SUBMIT executable if present
    if "SUBMIT" in request.processed_files:
        try:
            ssh_fs.run_command(f"chmod 755 {remote_dir}/SUBMIT", check=True)
        except RuntimeError as exc:
            raise SubmitError(
                f"Failed to set SUBMIT permissions: {exc}"
            ) from exc

    # Execute SUBMIT script
    if "SUBMIT" in request.processed_files:
        stdout, stderr, exit_status = ssh_fs.run_command(
            f"{remote_dir}/SUBMIT",
            check=False,
        )
    else:
        stdout = ""
        stderr = "No SUBMIT script found in processed files"
        exit_status = 1

    return SubmitResult(
        submit_id=submit_id,
        remote_dir=remote_dir,
        submit_stdout=stdout,
        submit_stderr=stderr,
        exit_status=exit_status,
        success=(exit_status == 0),
    )


def _generate_submit_id() -> str:
    """Generate submit ID in legacy format (DDDHHMMSS).

    DDD = day of year (001-366)
    HHMMSS = time

    Example: 03614523 = day 36, 14:52:03
    """
    now = datetime.now()
    day_of_year = now.timetuple().tm_yday
    return f"{day_of_year:03d}{now:%H%M%S}"
