"""FastAPI application factory."""

from __future__ import annotations

from contextlib import asynccontextmanager
from typing import TYPE_CHECKING, Any

from fastapi import FastAPI
from umui_core.storage.app_pack import AppPackPaths
from umui_core.storage.layout import DatabasePaths, FileSystem, LocalFileSystem

from umui_api.errors import register_error_handlers
from umui_api.routers import bridge, experiments, jobs, locks, process, submit

if TYPE_CHECKING:
    from collections.abc import AsyncGenerator


@asynccontextmanager
async def _lifespan(app: FastAPI) -> AsyncGenerator[None, None]:
    yield
    fs: Any = getattr(app.state, "fs", None)
    if fs is not None and hasattr(fs, "close"):
        fs.close()


def create_app(
    *,
    fs: FileSystem | None = None,
    db_path: str | None = None,
    app_pack_path: str | None = None,
) -> FastAPI:
    """Create and configure the FastAPI application.

    Provide *either* an existing ``fs`` (e.g. SshFileSystem) *or* a local
    ``db_path``.  When ``db_path`` is given a :class:`LocalFileSystem` is
    created automatically.
    """
    if fs is None and db_path is None:
        msg = "Provide either fs or db_path"
        raise ValueError(msg)

    if fs is None:
        fs = LocalFileSystem()

    app = FastAPI(title="UMUI API", version="0.1.0", lifespan=_lifespan)
    app.state.fs = fs
    app.state.paths = DatabasePaths(db_path or "")
    app.state.app_pack = AppPackPaths(app_pack_path or "")

    register_error_handlers(app)

    app.include_router(experiments.router)
    app.include_router(jobs.router)
    app.include_router(locks.router)
    app.include_router(bridge.router)
    app.include_router(process.router)
    app.include_router(submit.router)

    return app
