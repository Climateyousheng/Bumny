"""Domain models for UMUI window definitions (.pan files)."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Literal

# ---------------------------------------------------------------------------
# PanComponent hierarchy — discriminated union on `kind`
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class TextComponent:
    """Static text display (.text / .textw)."""

    kind: Literal["text"]
    text: str
    justify: str


@dataclass(frozen=True)
class EntryComponent:
    """Text input field (.entry)."""

    kind: Literal["entry"]
    label: str
    justify: str
    variable: str
    width: int = 0


@dataclass(frozen=True)
class CheckComponent:
    """Checkbox field (.check)."""

    kind: Literal["check"]
    label: str
    justify: str
    variable: str
    on_value: str
    off_value: str


@dataclass(frozen=True)
class BasradComponent:
    """Radio button group (.basrad)."""

    kind: Literal["basrad"]
    label: str
    justify: str
    count: int
    orientation: str
    variable: str
    options: tuple[tuple[str, str], ...]


@dataclass(frozen=True)
class GapComponent:
    """Vertical spacer (.gap)."""

    kind: Literal["gap"]


@dataclass(frozen=True)
class BlockComponent:
    """Indented group (.block .. .blockend)."""

    kind: Literal["block"]
    indent: int
    children: tuple[PanComponent, ...]


@dataclass(frozen=True)
class CaseComponent:
    """Conditional grey-out region (.case .. .caseend)."""

    kind: Literal["case"]
    expression: str
    children: tuple[PanComponent, ...]


@dataclass(frozen=True)
class InvisibleComponent:
    """Conditional hide region (.invisible .. .invisend)."""

    kind: Literal["invisible"]
    expression: str
    children: tuple[PanComponent, ...]


@dataclass(frozen=True)
class PushNextComponent:
    """Navigation button (.pushnext)."""

    kind: Literal["pushnext"]
    label: str
    target_window: str


@dataclass(frozen=True)
class TableElementComponent:
    """A column definition inside a table (.element)."""

    kind: Literal["element"]
    label: str
    variable: str
    rows: str
    width: int
    mode: str


@dataclass(frozen=True)
class TableAutoNumComponent:
    """Auto-numbered column inside a table (.elementautonum)."""

    kind: Literal["elementautonum"]
    label: str
    start: str
    end: str
    width: int


@dataclass(frozen=True)
class TableComponent:
    """Multi-row table (.table .. .tableend)."""

    kind: Literal["table"]
    name: str
    header: str
    orientation: str
    justify: str
    rows: str
    width: int
    validation: str
    children: tuple[PanComponent, ...]


# Union type for all pan components
PanComponent = (
    TextComponent
    | EntryComponent
    | CheckComponent
    | BasradComponent
    | GapComponent
    | BlockComponent
    | CaseComponent
    | InvisibleComponent
    | PushNextComponent
    | TableComponent
    | TableElementComponent
    | TableAutoNumComponent
)


# ---------------------------------------------------------------------------
# Window
# ---------------------------------------------------------------------------

WinType = Literal["entry", "dummy"]


@dataclass(frozen=True)
class Window:
    """A parsed window definition from a .pan file."""

    win_id: str
    title: str
    win_type: WinType
    components: tuple[PanComponent, ...] = ()
