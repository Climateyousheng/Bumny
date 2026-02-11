"""Pydantic request/response models for the UMUI REST API."""

from __future__ import annotations

from dataclasses import asdict
from typing import TYPE_CHECKING

from pydantic import BaseModel, ConfigDict

if TYPE_CHECKING:
    from umui_core.models.experiment import Experiment
    from umui_core.models.job import Job
    from umui_core.models.lock import LockResult

# ---------------------------------------------------------------------------
# Experiment schemas
# ---------------------------------------------------------------------------


class CreateExperimentRequest(BaseModel):
    model_config = ConfigDict(frozen=True)

    initial: str
    description: str
    privacy: str = "N"


class UpdateExperimentRequest(BaseModel):
    model_config = ConfigDict(frozen=True)

    description: str | None = None
    version: str | None = None
    atmosphere: str | None = None
    mesoscale: str | None = None
    ocean: str | None = None
    slab: str | None = None
    access_list: str | None = None
    privacy: str | None = None

    def to_updates(self) -> dict[str, str]:
        """Return only the fields that were explicitly set."""
        return {k: v for k, v in self.model_dump().items() if v is not None}


class CopyExperimentRequest(BaseModel):
    model_config = ConfigDict(frozen=True)

    initial: str
    description: str


class ExperimentResponse(BaseModel):
    model_config = ConfigDict(frozen=True)

    id: str
    owner: str
    description: str
    version: str
    access_list: str
    privacy: str
    atmosphere: str
    ocean: str
    slab: str
    mesoscale: str

    @staticmethod
    def from_model(exp: Experiment) -> ExperimentResponse:
        d = asdict(exp)
        d.pop("opened", None)
        return ExperimentResponse(**d)


class ExperimentListResponse(BaseModel):
    model_config = ConfigDict(frozen=True)

    experiments: list[ExperimentResponse]


# ---------------------------------------------------------------------------
# Job schemas
# ---------------------------------------------------------------------------


class CreateJobRequest(BaseModel):
    model_config = ConfigDict(frozen=True)

    job_id: str
    description: str = ""
    version: str = ""


class UpdateJobRequest(BaseModel):
    model_config = ConfigDict(frozen=True)

    description: str | None = None
    version: str | None = None
    atmosphere: str | None = None
    ocean: str | None = None
    slab: str | None = None
    mesoscale: str | None = None

    def to_updates(self) -> dict[str, str]:
        """Return only the fields that were explicitly set."""
        return {k: v for k, v in self.model_dump().items() if v is not None}


class CopyJobRequest(BaseModel):
    model_config = ConfigDict(frozen=True)

    dest_exp_id: str
    dest_job_id: str
    description: str = ""


class JobResponse(BaseModel):
    model_config = ConfigDict(frozen=True)

    job_id: str
    exp_id: str
    version: str
    description: str
    opened: str
    atmosphere: str
    ocean: str
    slab: str
    mesoscale: str

    @staticmethod
    def from_model(job: Job) -> JobResponse:
        return JobResponse(**asdict(job))


class JobListResponse(BaseModel):
    model_config = ConfigDict(frozen=True)

    jobs: list[JobResponse]


# ---------------------------------------------------------------------------
# Lock schemas
# ---------------------------------------------------------------------------


class AcquireLockRequest(BaseModel):
    model_config = ConfigDict(frozen=True)

    force: bool = False


class LockStatusResponse(BaseModel):
    model_config = ConfigDict(frozen=True)

    locked: bool
    owner: str | None


class LockResultResponse(BaseModel):
    model_config = ConfigDict(frozen=True)

    success: bool
    owner: str
    message: str
    forced: bool = False

    @staticmethod
    def from_model(result: LockResult) -> LockResultResponse:
        return LockResultResponse(**asdict(result))
