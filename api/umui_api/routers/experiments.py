"""Experiment CRUD endpoints."""

from __future__ import annotations

from fastapi import APIRouter
from umui_core.ops import experiments as exp_ops

from umui_api.dependencies import Fs, Paths, User  # noqa: TC001
from umui_api.schemas import (
    CopyExperimentRequest,
    CreateExperimentRequest,
    ExperimentListResponse,
    ExperimentResponse,
    UpdateExperimentRequest,
)

router = APIRouter(tags=["experiments"])


@router.get("/experiments", response_model=ExperimentListResponse)
def list_experiments(fs: Fs, paths: Paths) -> ExperimentListResponse:
    exps = exp_ops.list_experiments(fs, paths)
    return ExperimentListResponse(
        experiments=[ExperimentResponse.from_model(e) for e in exps],
    )


@router.get("/experiments/{exp_id}", response_model=ExperimentResponse)
def get_experiment(exp_id: str, fs: Fs, paths: Paths) -> ExperimentResponse:
    exp = exp_ops.get_experiment(fs, paths, exp_id)
    return ExperimentResponse.from_model(exp)


@router.post("/experiments", response_model=ExperimentResponse, status_code=201)
def create_experiment(
    body: CreateExperimentRequest,
    fs: Fs,
    paths: Paths,
    user: User,
) -> ExperimentResponse:
    exp = exp_ops.create_experiment(
        fs, paths, user, body.initial, body.description, body.privacy,
    )
    return ExperimentResponse.from_model(exp)


@router.patch("/experiments/{exp_id}", response_model=ExperimentResponse)
def update_experiment(
    exp_id: str,
    body: UpdateExperimentRequest,
    fs: Fs,
    paths: Paths,
    user: User,
) -> ExperimentResponse:
    exp = exp_ops.update_experiment(fs, paths, exp_id, user, body.to_updates())
    return ExperimentResponse.from_model(exp)


@router.delete("/experiments/{exp_id}", status_code=204)
def delete_experiment(exp_id: str, fs: Fs, paths: Paths, user: User) -> None:
    exp_ops.delete_experiment(fs, paths, exp_id, user)


@router.post(
    "/experiments/{exp_id}/copy",
    response_model=ExperimentResponse,
    status_code=201,
)
def copy_experiment(
    exp_id: str,
    body: CopyExperimentRequest,
    fs: Fs,
    paths: Paths,
    user: User,
) -> ExperimentResponse:
    exp = exp_ops.copy_experiment(
        fs, paths, exp_id, user, body.initial, body.description,
    )
    return ExperimentResponse.from_model(exp)
