"""Process endpoint: expand templates with basis variables."""

from __future__ import annotations

from fastapi import APIRouter
from umui_core.ops.process import ProcessRequest, process_job

from umui_api.dependencies import AppPack, Fs, Paths  # noqa: TC001
from umui_api.schemas_process import ProcessResponse

router = APIRouter(tags=["process"])


@router.post(
    "/process/{exp_id}/{job_id}",
    response_model=ProcessResponse,
)
def process(
    exp_id: str,
    job_id: str,
    fs: Fs,
    paths: Paths,
    app_pack: AppPack,
) -> ProcessResponse:
    """Process a job by expanding templates with basis variables."""
    request = ProcessRequest(exp_id=exp_id, job_id=job_id)
    result = process_job(fs, paths, app_pack, request)
    return ProcessResponse(files=result.files, warnings=result.warnings)
