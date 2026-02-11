"""Bridge editor API endpoints."""

from __future__ import annotations

from dataclasses import asdict
from typing import Any

from fastapi import APIRouter
from umui_core.ops import bridge as bridge_ops

from umui_api.dependencies import AppPack, Fs, Paths, User  # noqa: TC001
from umui_api.schemas_bridge import (
    HelpResponse,
    NavNodeResponse,
    PartitionResponse,
    UpdateVariablesRequest,
    VariableRegistrationResponse,
    VariablesResponse,
    WindowResponse,
)

router = APIRouter(prefix="/bridge", tags=["bridge"])


# ---------------------------------------------------------------------------
# Navigation tree
# ---------------------------------------------------------------------------


@router.get("/nav", response_model=list[NavNodeResponse])
def get_nav_tree(fs: Fs, app_pack: AppPack) -> list[NavNodeResponse]:
    """Get the full navigation tree."""
    tree = bridge_ops.load_nav_tree(fs, app_pack)
    return [_nav_node_to_response(n) for n in tree]


def _nav_node_to_response(node: Any) -> NavNodeResponse:
    """Recursively convert NavNode to response model."""
    return NavNodeResponse(
        name=node.name,
        label=node.label,
        node_type=node.node_type,
        children=[_nav_node_to_response(c) for c in node.children],
    )


# ---------------------------------------------------------------------------
# Windows
# ---------------------------------------------------------------------------


@router.get("/windows/{win_id}", response_model=WindowResponse)
def get_window(win_id: str, fs: Fs, app_pack: AppPack) -> WindowResponse:
    """Get parsed window definition with components."""
    win = bridge_ops.load_window(fs, app_pack, win_id)
    return WindowResponse(
        win_id=win.win_id,
        title=win.title,
        win_type=win.win_type,
        components=[_component_to_dict(c) for c in win.components],
    )


def _component_to_dict(comp: Any) -> dict[str, Any]:
    """Convert a PanComponent to a serialisable dict."""
    d: dict[str, Any] = asdict(comp)
    # Recursively convert nested children
    if "children" in d:
        d["children"] = [_component_to_dict(c) for c in comp.children]
    return d


# ---------------------------------------------------------------------------
# Help
# ---------------------------------------------------------------------------


@router.get("/windows/{win_id}/help", response_model=HelpResponse)
def get_window_help(win_id: str, fs: Fs, app_pack: AppPack) -> HelpResponse:
    """Get help text for a window."""
    text = bridge_ops.load_help(fs, app_pack, win_id)
    return HelpResponse(win_id=win_id, text=text)


# ---------------------------------------------------------------------------
# Variable register
# ---------------------------------------------------------------------------


@router.get(
    "/register",
    response_model=list[VariableRegistrationResponse],
)
def get_register(
    fs: Fs,
    app_pack: AppPack,
) -> list[VariableRegistrationResponse]:
    """Get the full variable register."""
    regs = bridge_ops.load_var_register(fs, app_pack)
    return [
        VariableRegistrationResponse(
            name=r.name,
            default=r.default,
            dim1_start=r.dim1_start,
            dim1_end=r.dim1_end,
            dim2_start=r.dim2_start,
            var_type=r.var_type,
            width=r.width,
            format_spec=r.format_spec,
            window=r.window,
            partition=r.partition,
            condition=r.condition,
            validation_type=r.validation_type,
            validation_args=list(r.validation_args),
        )
        for r in regs
    ]


# ---------------------------------------------------------------------------
# Partitions
# ---------------------------------------------------------------------------


@router.get("/partitions", response_model=list[PartitionResponse])
def get_partitions(fs: Fs, app_pack: AppPack) -> list[PartitionResponse]:
    """Get partition definitions."""
    parts = bridge_ops.load_partitions(fs, app_pack)
    return [
        PartitionResponse(
            key=p.key,
            identifier=p.identifier,
            conditions=list(p.conditions),
        )
        for p in parts
    ]


# ---------------------------------------------------------------------------
# Variables (from basis file)
# ---------------------------------------------------------------------------


@router.get(
    "/variables/{exp_id}/{job_id}",
    response_model=VariablesResponse,
)
def get_variables(
    exp_id: str,
    job_id: str,
    fs: Fs,
    paths: Paths,
) -> VariablesResponse:
    """Get all variable values from a job's basis file."""
    vars_ = bridge_ops.read_variables(fs, paths, exp_id, job_id)
    return VariablesResponse(variables=_normalise_vars(vars_))


@router.get(
    "/variables/{exp_id}/{job_id}/{win_id}",
    response_model=VariablesResponse,
)
def get_variables_for_window(
    exp_id: str,
    job_id: str,
    win_id: str,
    fs: Fs,
    paths: Paths,
    app_pack: AppPack,
) -> VariablesResponse:
    """Get variable values scoped to a specific window."""
    vars_ = bridge_ops.read_variables_for_window(
        fs, paths, app_pack, exp_id, job_id, win_id,
    )
    return VariablesResponse(variables=_normalise_vars(vars_))


@router.patch(
    "/variables/{exp_id}/{job_id}",
    response_model=VariablesResponse,
)
def update_variables(
    exp_id: str,
    job_id: str,
    body: UpdateVariablesRequest,
    fs: Fs,
    paths: Paths,
    user: User,
) -> VariablesResponse:
    """Update variables in a job's basis file (requires lock)."""
    updates: dict[str, str | tuple[str, ...]] = {}
    for k, v in body.variables.items():
        if isinstance(v, list):
            updates[k] = tuple(v)
        else:
            updates[k] = v

    bridge_ops.write_variables(fs, paths, exp_id, job_id, updates)
    vars_ = bridge_ops.read_variables(fs, paths, exp_id, job_id)
    return VariablesResponse(variables=_normalise_vars(vars_))


def _normalise_vars(
    vars_: dict[str, str | tuple[str, ...]],
) -> dict[str, str | list[str]]:
    """Convert tuple values to lists for JSON serialization."""
    result: dict[str, str | list[str]] = {}
    for k, v in vars_.items():
        if isinstance(v, tuple):
            result[k] = list(v)
        else:
            result[k] = v
    return result
