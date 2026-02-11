"""Job CRUD endpoints."""

from __future__ import annotations

from fastapi import APIRouter
from umui_core.ops import jobs as job_ops

from umui_api.dependencies import Fs, Paths  # noqa: TC001
from umui_api.schemas import (
    CopyJobRequest,
    CreateJobRequest,
    JobListResponse,
    JobResponse,
    UpdateJobRequest,
)

router = APIRouter(tags=["jobs"])


@router.get(
    "/experiments/{exp_id}/jobs",
    response_model=JobListResponse,
)
def list_jobs(exp_id: str, fs: Fs, paths: Paths) -> JobListResponse:
    jobs = job_ops.list_jobs(fs, paths, exp_id)
    return JobListResponse(jobs=[JobResponse.from_model(j) for j in jobs])


@router.get(
    "/experiments/{exp_id}/jobs/{job_id}",
    response_model=JobResponse,
)
def get_job(exp_id: str, job_id: str, fs: Fs, paths: Paths) -> JobResponse:
    job = job_ops.get_job(fs, paths, exp_id, job_id)
    return JobResponse.from_model(job)


@router.post(
    "/experiments/{exp_id}/jobs",
    response_model=JobResponse,
    status_code=201,
)
def create_job(
    exp_id: str,
    body: CreateJobRequest,
    fs: Fs,
    paths: Paths,
) -> JobResponse:
    job = job_ops.create_job(
        fs, paths, exp_id, body.job_id, body.description, body.version,
    )
    return JobResponse.from_model(job)


@router.patch(
    "/experiments/{exp_id}/jobs/{job_id}",
    response_model=JobResponse,
)
def update_job(
    exp_id: str,
    job_id: str,
    body: UpdateJobRequest,
    fs: Fs,
    paths: Paths,
) -> JobResponse:
    job = job_ops.update_job(fs, paths, exp_id, job_id, body.to_updates())
    return JobResponse.from_model(job)


@router.delete(
    "/experiments/{exp_id}/jobs/{job_id}",
    status_code=204,
)
def delete_job(exp_id: str, job_id: str, fs: Fs, paths: Paths) -> None:
    job_ops.delete_job(fs, paths, exp_id, job_id)


@router.post(
    "/experiments/{exp_id}/jobs/{job_id}/copy",
    response_model=JobResponse,
    status_code=201,
)
def copy_job(
    exp_id: str,
    job_id: str,
    body: CopyJobRequest,
    fs: Fs,
    paths: Paths,
) -> JobResponse:
    job = job_ops.copy_job(
        fs,
        paths,
        exp_id,
        job_id,
        body.dest_exp_id,
        body.dest_job_id,
        body.description,
    )
    return JobResponse.from_model(job)
