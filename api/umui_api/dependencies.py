"""FastAPI dependency injection helpers."""

from __future__ import annotations

from typing import Annotated

from fastapi import Depends, Header, HTTPException, Request
from umui_core.storage.app_pack import AppPackPaths
from umui_core.storage.layout import DatabasePaths, FileSystem


def get_fs(request: Request) -> FileSystem:
    """Retrieve the FileSystem from application state."""
    fs: FileSystem = request.app.state.fs
    return fs


def get_paths(request: Request) -> DatabasePaths:
    """Retrieve DatabasePaths from application state."""
    paths: DatabasePaths = request.app.state.paths
    return paths


def get_user(
    x_umui_user: Annotated[str | None, Header()] = None,
) -> str:
    """Extract the username from the X-UMUI-User header."""
    if not x_umui_user:
        raise HTTPException(status_code=400, detail="X-UMUI-User header is required")
    return x_umui_user


def get_app_pack(request: Request) -> AppPackPaths:
    """Retrieve AppPackPaths from application state."""
    app_pack: AppPackPaths = request.app.state.app_pack
    return app_pack


Fs = Annotated[FileSystem, Depends(get_fs)]
Paths = Annotated[DatabasePaths, Depends(get_paths)]
User = Annotated[str, Depends(get_user)]
AppPack = Annotated[AppPackPaths, Depends(get_app_pack)]
