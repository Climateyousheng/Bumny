"""Submit endpoint: deploy processed files to remote HPC."""

from __future__ import annotations

from fastapi import APIRouter, HTTPException
from umui_connectors.ssh_fs import SshFileSystem
from umui_core.ops.submit import SubmitRequest, submit_job

from umui_api.dependencies import Fs  # noqa: TC001
from umui_api.schemas_process import SubmitRequestBody, SubmitResponse

router = APIRouter(tags=["submit"])


@router.post(
    "/submit/{exp_id}/{job_id}",
    response_model=SubmitResponse,
)
def submit(
    exp_id: str,
    job_id: str,
    body: SubmitRequestBody,
    fs: Fs,
) -> SubmitResponse:
    """Submit a processed job to remote HPC system.

    Requires SSH backend (SshFileSystem). Returns 400 if
    the backend is a local filesystem.
    """
    if not isinstance(fs, SshFileSystem):
        raise HTTPException(
            status_code=400,
            detail="Submit requires SSH backend (not local filesystem)",
        )

    request = SubmitRequest(
        exp_id=exp_id,
        job_id=job_id,
        target_host=body.target_host,
        target_user=body.target_user,
        processed_files=body.processed_files,
    )

    result = submit_job(fs, request)
    return SubmitResponse(
        submit_id=result.submit_id,
        remote_dir=result.remote_dir,
        stdout=result.submit_stdout,
        stderr=result.submit_stderr,
        exit_status=result.exit_status,
        success=result.success,
    )
