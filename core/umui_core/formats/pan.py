"""Parse UMUI window definition (.pan) files.

A ``.pan`` file defines the layout of a single window in the Bridge
editor.  It has a header section (winid, title, wintype, procs, etc.)
followed by a ``.panel`` / ``.panend`` block containing UI components.

Components are parsed recursively: ``.block``, ``.case``, ``.invisible``,
``.table``, ``.colour``, and ``.super`` all contain nested children.
"""

from __future__ import annotations

import re
import shlex

from umui_core.models.window import (
    BasradComponent,
    BlockComponent,
    CaseComponent,
    CheckComponent,
    EntryComponent,
    GapComponent,
    InvisibleComponent,
    PanComponent,
    PushNextComponent,
    TableAutoNumComponent,
    TableComponent,
    TableElementComponent,
    TextComponent,
    Window,
    WinType,
)


class PanParseError(Exception):
    """Raised when a .pan file cannot be parsed."""


def parse_pan(text: str) -> Window:
    """Parse a .pan file into a Window object.

    Args:
        text: Raw content of a .pan file.

    Returns:
        Window object with parsed components.

    Raises:
        PanParseError: If the file structure is invalid.
    """
    lines = text.split("\n")
    win_id = ""
    title = ""
    win_type: WinType = "entry"
    components: tuple[PanComponent, ...] = ()

    i = 0
    while i < len(lines):
        line = lines[i].strip()
        i += 1

        if not line or line.startswith(".comment") or line.startswith("#"):
            continue

        if line.startswith(".winid"):
            win_id = _extract_quoted(line, ".winid")
        elif line.startswith(".title"):
            title = _extract_quoted(line, ".title")
        elif line.startswith(".wintype"):
            wt = line.split(None, 1)[1].strip()
            if wt in ("entry", "dummy"):
                win_type = wt  # type: ignore[assignment]
        elif line.startswith(".panel"):
            components, i = _parse_panel(lines, i)
        elif line.startswith(".panend"):
            break
        # Skip: .procs, .function, .set_on_closure, .loop, etc.

    return Window(
        win_id=win_id,
        title=title,
        win_type=win_type,
        components=components,
    )


def _extract_quoted(line: str, directive: str) -> str:
    """Extract a quoted string from a line like `.winid "foo"`."""
    rest = line[len(directive):].strip()
    if rest.startswith('"') and rest.endswith('"'):
        return rest[1:-1]
    return rest


def _parse_panel(
    lines: list[str],
    start: int,
) -> tuple[tuple[PanComponent, ...], int]:
    """Parse the body of a .panel block.

    Returns (components, next_line_index).
    """
    components: list[PanComponent] = []
    i = start

    while i < len(lines):
        line = lines[i].strip()

        if not line or line.startswith(".comment") or line.startswith("#"):
            i += 1
            continue

        if line.startswith(".panend"):
            return tuple(components), i + 1

        comp, next_i = _parse_component(lines, i)
        if comp is not None:
            components.append(comp)
        # Ensure we always advance
        i = next_i if next_i > i else i + 1

    return tuple(components), i


_END_MARKERS = frozenset((
    ".blockend", ".caseend", ".invisend", ".tableend",
    ".panend", ".colourend", ".superend",
))

_SKIP_PREFIXES = (
    ".colour", ".colourend", ".super", ".superend",
    ".set_on_closure", ".procs", ".function", ".loop",
    ".include", ".comment",
)


def _parse_component(
    lines: list[str],
    start: int,
) -> tuple[PanComponent | None, int]:
    """Parse a single component starting at the given line.

    Returns (component_or_None, next_line_index).
    All paths must return next_line_index > start.
    """
    line = lines[start].strip()

    # .gap
    if line.startswith(".gap"):
        return GapComponent(kind="gap"), start + 1

    # .text / .textw / .textj
    if line.startswith(".text"):
        return _parse_text(line), start + 1

    # .entry
    if line.startswith(".entry"):
        return _parse_entry(line), start + 1

    # .check
    if line.startswith(".check"):
        return _parse_check(line), start + 1

    # .basrad — may span multiple lines
    if line.startswith(".basrad"):
        return _parse_basrad(lines, start)

    # .block .. .blockend
    if line.startswith(".block"):
        return _parse_block(lines, start)

    # .case .. .caseend
    if line.startswith(".case ") or line == ".case":
        return _parse_case(lines, start)

    # .invisible .. .invisend
    if line.startswith(".invisible"):
        return _parse_invisible(lines, start)

    # .pushnext / .pushsequence
    if line.startswith(".pushnext") or line.startswith(".pushsequence"):
        return _parse_pushnext(line), start + 1

    # .table .. .tableend
    if line.startswith(".table "):
        return _parse_table(lines, start)

    # .element (inside table, but handle gracefully)
    if line.startswith(".element ") and not line.startswith(".elementautonum"):
        return _parse_table_element(line), start + 1

    # .elementautonum
    if line.startswith(".elementautonum"):
        return _parse_table_autonum(line), start + 1

    # End markers — don't advance, let parent consume
    if line in _END_MARKERS:
        return None, start

    # Skip directives we don't render
    if any(line.startswith(s) for s in _SKIP_PREFIXES):
        return None, start + 1

    # Unknown: skip
    return None, start + 1


def _parse_text(line: str) -> TextComponent:
    """Parse .text, .textw, or .textj."""
    tokens = _tokenize_line(line)
    text = tokens[1] if len(tokens) > 1 else ""
    justify = tokens[2] if len(tokens) > 2 else "L"
    return TextComponent(kind="text", text=text, justify=justify)


def _parse_entry(line: str) -> EntryComponent:
    """Parse .entry "label" justify variable [width]."""
    tokens = _tokenize_line(line)
    label = tokens[1] if len(tokens) > 1 else ""
    justify = tokens[2] if len(tokens) > 2 else "L"
    variable = tokens[3] if len(tokens) > 3 else ""
    width = int(tokens[4]) if len(tokens) > 4 else 0
    return EntryComponent(
        kind="entry", label=label, justify=justify,
        variable=variable, width=width,
    )


def _parse_check(line: str) -> CheckComponent:
    """Parse .check "label" justify variable on_value off_value."""
    tokens = _tokenize_line(line)
    label = tokens[1] if len(tokens) > 1 else ""
    justify = tokens[2] if len(tokens) > 2 else "L"
    variable = tokens[3] if len(tokens) > 3 else ""
    on_value = tokens[4] if len(tokens) > 4 else "Y"
    off_value = tokens[5] if len(tokens) > 5 else "N"
    return CheckComponent(
        kind="check", label=label, justify=justify,
        variable=variable, on_value=on_value, off_value=off_value,
    )


def _parse_basrad(
    lines: list[str], start: int,
) -> tuple[BasradComponent, int]:
    """Parse .basrad which may span multiple lines.

    Format: .basrad "label" justify count orientation variable
               "option1" value1
               "option2" value2
    """
    all_text = lines[start].strip()
    i = start + 1

    while i < len(lines):
        next_line = lines[i].strip()
        if not next_line:
            i += 1
            continue
        # If the line starts with a dot directive, stop
        if next_line.startswith("."):
            break
        # Continuation line (option label/value)
        all_text += " " + next_line
        i += 1

    tokens = _tokenize_line(all_text)
    label = tokens[1] if len(tokens) > 1 else ""
    justify = tokens[2] if len(tokens) > 2 else "L"
    count = int(tokens[3]) if len(tokens) > 3 else 0
    orientation = tokens[4] if len(tokens) > 4 else "v"
    variable = tokens[5] if len(tokens) > 5 else ""

    options: list[tuple[str, str]] = []
    idx = 6
    while idx + 1 < len(tokens):
        options.append((tokens[idx], tokens[idx + 1]))
        idx += 2

    return BasradComponent(
        kind="basrad", label=label, justify=justify,
        count=count, orientation=orientation, variable=variable,
        options=tuple(options),
    ), i


def _parse_children(
    lines: list[str],
    start: int,
    end_marker: str,
) -> tuple[tuple[PanComponent, ...], int]:
    """Parse child components until end_marker is found."""
    children: list[PanComponent] = []
    i = start

    while i < len(lines):
        cline = lines[i].strip()
        if not cline or cline.startswith(".comment") or cline.startswith("#"):
            i += 1
            continue
        if cline.startswith(end_marker):
            return tuple(children), i + 1

        comp, next_i = _parse_component(lines, i)
        if comp is not None:
            children.append(comp)
        i = next_i if next_i > i else i + 1

    return tuple(children), i


def _parse_block(
    lines: list[str], start: int,
) -> tuple[BlockComponent, int]:
    """Parse .block indent ... .blockend."""
    line = lines[start].strip()
    tokens = line.split()
    indent = int(tokens[1]) if len(tokens) > 1 else 1
    children, next_i = _parse_children(lines, start + 1, ".blockend")
    return BlockComponent(
        kind="block", indent=indent, children=children,
    ), next_i


def _parse_case(
    lines: list[str], start: int,
) -> tuple[CaseComponent, int]:
    """Parse .case expression ... .caseend."""
    line = lines[start].strip()
    expression = line[len(".case"):].strip()
    children, next_i = _parse_children(lines, start + 1, ".caseend")
    return CaseComponent(
        kind="case", expression=expression, children=children,
    ), next_i


def _parse_invisible(
    lines: list[str], start: int,
) -> tuple[InvisibleComponent, int]:
    """Parse .invisible expression ... .invisend."""
    line = lines[start].strip()
    expression = line[len(".invisible"):].strip()
    children, next_i = _parse_children(lines, start + 1, ".invisend")
    return InvisibleComponent(
        kind="invisible", expression=expression, children=children,
    ), next_i


def _parse_pushnext(line: str) -> PushNextComponent:
    """Parse .pushnext "label" target_window."""
    tokens = _tokenize_line(line)
    label = tokens[1] if len(tokens) > 1 else ""
    target = tokens[2] if len(tokens) > 2 else ""
    return PushNextComponent(
        kind="pushnext", label=label, target_window=target,
    )


def _parse_table(
    lines: list[str], start: int,
) -> tuple[TableComponent, int]:
    """Parse .table name "header" orientation justify rows width validation."""
    line = lines[start].strip()
    tokens = _tokenize_line(line)
    name = tokens[1] if len(tokens) > 1 else ""
    header = tokens[2] if len(tokens) > 2 else ""
    orientation = tokens[3] if len(tokens) > 3 else "top"
    justify = tokens[4] if len(tokens) > 4 else "h"
    rows = tokens[5] if len(tokens) > 5 else "0"
    width = int(tokens[6]) if len(tokens) > 6 else 0
    validation = tokens[7] if len(tokens) > 7 else "NONE"

    children, next_i = _parse_children(lines, start + 1, ".tableend")

    return TableComponent(
        kind="table", name=name, header=header, orientation=orientation,
        justify=justify, rows=rows, width=width, validation=validation,
        children=children,
    ), next_i


def _parse_table_element(line: str) -> TableElementComponent:
    """Parse .element "label" variable rows width mode."""
    tokens = _tokenize_line(line)
    label = tokens[1] if len(tokens) > 1 else ""
    variable = tokens[2] if len(tokens) > 2 else ""
    rows = tokens[3] if len(tokens) > 3 else "0"
    width = int(tokens[4]) if len(tokens) > 4 else 0
    mode = tokens[5] if len(tokens) > 5 else "in"
    return TableElementComponent(
        kind="element", label=label, variable=variable,
        rows=rows, width=width, mode=mode,
    )


def _parse_table_autonum(line: str) -> TableAutoNumComponent:
    """Parse .elementautonum "label" start end width."""
    tokens = _tokenize_line(line)
    label = tokens[1] if len(tokens) > 1 else ""
    start_val = tokens[2] if len(tokens) > 2 else "1"
    end_val = tokens[3] if len(tokens) > 3 else "1"
    width = int(tokens[4]) if len(tokens) > 4 else 0
    return TableAutoNumComponent(
        kind="elementautonum", label=label, start=start_val,
        end=end_val, width=width,
    )


def _tokenize_line(line: str) -> list[str]:
    """Split a .pan directive line respecting quoted strings."""
    try:
        return shlex.split(line)
    except ValueError:
        return _fallback_tokenize(line)


def _fallback_tokenize(line: str) -> list[str]:
    """Tokenize with regex when shlex fails."""
    tokens: list[str] = []
    for match in re.finditer(r'"[^"]*"|\'[^\']*\'|\S+', line):
        token = match.group()
        if (
            token.startswith('"') and token.endswith('"')
        ) or (
            token.startswith("'") and token.endswith("'")
        ):
            token = token[1:-1]
        tokens.append(token)
    return tokens
