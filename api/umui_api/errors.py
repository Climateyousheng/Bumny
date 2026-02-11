"""Core exception to HTTP status mapping."""

from __future__ import annotations

from typing import TYPE_CHECKING

from fastapi.responses import JSONResponse
from umui_core.locking.locks import LockError
from umui_core.ops.experiments import (
    ExperimentExistsError,
    ExperimentNotFoundError,
    PermissionDeniedError,
)
from umui_core.ops.jobs import JobExistsError, JobLockedError, JobNotFoundError
from umui_core.storage.layout import InvalidIdError

if TYPE_CHECKING:
    from fastapi import FastAPI, Request

_EXCEPTION_STATUS: list[tuple[type[Exception], int]] = [
    (ExperimentNotFoundError, 404),
    (JobNotFoundError, 404),
    (ExperimentExistsError, 409),
    (JobExistsError, 409),
    (PermissionDeniedError, 403),
    (JobLockedError, 423),
    (InvalidIdError, 422),
    (LockError, 409),
]


def register_error_handlers(app: FastAPI) -> None:
    """Register exception handlers that map core errors to HTTP responses."""
    for exc_type, status in _EXCEPTION_STATUS:
        _add_handler(app, exc_type, status)


def _add_handler(app: FastAPI, exc_type: type[Exception], status: int) -> None:
    @app.exception_handler(exc_type)
    async def _handler(
        _request: Request,
        exc: Exception,
    ) -> JSONResponse:
        return JSONResponse(
            status_code=status,
            content={"detail": str(exc)},
        )
