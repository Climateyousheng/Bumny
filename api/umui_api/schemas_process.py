"""Pydantic schemas for process and submit endpoints."""

from __future__ import annotations

from pydantic import BaseModel, ConfigDict


class ProcessResponse(BaseModel):
    model_config = ConfigDict(frozen=True)

    files: dict[str, str]
    warnings: list[str]


class SubmitRequestBody(BaseModel):
    model_config = ConfigDict(frozen=True)

    target_host: str
    target_user: str
    processed_files: dict[str, str]


class SubmitResponse(BaseModel):
    model_config = ConfigDict(frozen=True)

    submit_id: str
    remote_dir: str
    stdout: str
    stderr: str
    exit_status: int
    success: bool
