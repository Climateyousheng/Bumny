"""Pydantic schemas for bridge editor API endpoints."""

from __future__ import annotations

from typing import Any

from pydantic import BaseModel, ConfigDict

# ---------------------------------------------------------------------------
# Navigation
# ---------------------------------------------------------------------------


class NavNodeResponse(BaseModel):
    model_config = ConfigDict(frozen=True)

    name: str
    label: str
    node_type: str
    children: list[NavNodeResponse]


# ---------------------------------------------------------------------------
# Window
# ---------------------------------------------------------------------------


class WindowResponse(BaseModel):
    model_config = ConfigDict(frozen=True)

    win_id: str
    title: str
    win_type: str
    components: list[dict[str, Any]]


# ---------------------------------------------------------------------------
# Variable register
# ---------------------------------------------------------------------------


class VariableRegistrationResponse(BaseModel):
    model_config = ConfigDict(frozen=True)

    name: str
    default: str
    dim1_start: str
    dim1_end: str
    dim2_start: str
    var_type: str
    width: int
    format_spec: str
    window: str
    partition: str
    condition: str
    validation_type: str
    validation_args: list[str]


# ---------------------------------------------------------------------------
# Partition
# ---------------------------------------------------------------------------


class PartitionResponse(BaseModel):
    model_config = ConfigDict(frozen=True)

    key: str
    identifier: str
    conditions: list[str]


# ---------------------------------------------------------------------------
# Variables
# ---------------------------------------------------------------------------


class VariablesResponse(BaseModel):
    model_config = ConfigDict(frozen=True)

    variables: dict[str, str | list[str]]


class UpdateVariablesRequest(BaseModel):
    model_config = ConfigDict(frozen=True)

    variables: dict[str, str | list[str]]


# ---------------------------------------------------------------------------
# Help
# ---------------------------------------------------------------------------


class HelpResponse(BaseModel):
    model_config = ConfigDict(frozen=True)

    win_id: str
    text: str
