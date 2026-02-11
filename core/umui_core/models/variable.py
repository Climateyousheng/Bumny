"""Domain models for UMUI variable registration and partitions."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Literal

ValidationType = Literal["RANGE", "LIST", "FUNCTION", "FILE", "NONE"]
VarType = Literal["INT", "REAL", "STRING", "LOGIC"]


@dataclass(frozen=True)
class VariableRegistration:
    """A variable registration from var.register.

    Each row in var.register defines a variable that can be edited in
    the Bridge and stored in the basis file.
    """

    name: str
    default: str
    dim1_start: str
    dim1_end: str
    dim2_start: str
    var_type: VarType
    width: int
    format_spec: str
    window: str
    partition: str
    condition: str
    validation_type: ValidationType
    validation_args: tuple[str, ...]


@dataclass(frozen=True)
class Partition:
    """A partition from partition.database.

    Partitions group variables by sub-model (atmosphere, ocean, etc.)
    and define conditions under which the partition is inactive.
    """

    key: str
    identifier: str
    conditions: tuple[str, ...]
