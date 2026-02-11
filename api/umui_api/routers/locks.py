"""Legacy lock endpoints."""

from __future__ import annotations

from fastapi import APIRouter
from umui_core.locking.locks import (
    acquire_lock_legacy,
    check_lock_legacy,
    release_lock_legacy,
)

from umui_api.dependencies import Fs, Paths, User  # noqa: TC001
from umui_api.schemas import AcquireLockRequest, LockResultResponse, LockStatusResponse

router = APIRouter(tags=["locks"])


@router.get(
    "/experiments/{exp_id}/jobs/{job_id}/lock",
    response_model=LockStatusResponse,
)
def check_lock(
    exp_id: str,
    job_id: str,
    fs: Fs,
    paths: Paths,
) -> LockStatusResponse:
    owner = check_lock_legacy(fs, paths, exp_id, job_id)
    return LockStatusResponse(locked=owner is not None, owner=owner)


@router.post(
    "/experiments/{exp_id}/jobs/{job_id}/lock",
    response_model=LockResultResponse,
)
def acquire_lock(
    exp_id: str,
    job_id: str,
    fs: Fs,
    paths: Paths,
    user: User,
    body: AcquireLockRequest | None = None,
) -> LockResultResponse:
    force = body.force if body else False
    result = acquire_lock_legacy(fs, paths, exp_id, job_id, user, force=force)
    return LockResultResponse.from_model(result)


@router.delete(
    "/experiments/{exp_id}/jobs/{job_id}/lock",
    response_model=LockResultResponse,
)
def release_lock(
    exp_id: str,
    job_id: str,
    fs: Fs,
    paths: Paths,
    user: User,
) -> LockResultResponse:
    result = release_lock_legacy(fs, paths, exp_id, job_id, user)
    return LockResultResponse.from_model(result)
