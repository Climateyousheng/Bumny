"""Parse the UMUI navigation tree specification (nav.spec).

Format:
- Lines starting with ``#`` are comments.
- Dots define depth: ``.n`` = depth 1, ``..n`` = depth 2, etc.
- Type suffixes: ``n`` = node, ``p`` = panel, ``s`` = shared,
  ``t`` = repeated, ``>`` = follow-on.
- After the type suffix: name (no spaces) then label in quotes.

Example::

    .n modsel "Model Selection"
    ..p personal_gen "General details"
"""

from __future__ import annotations

import re

from umui_core.models.navigation import NavNode, NodeType

_TYPE_MAP: dict[str, NodeType] = {
    "n": "node",
    "p": "panel",
    "s": "shared",
    "t": "repeated",
    ">": "follow_on",
}

# Matches: dots + type-char + spaces + name + spaces + "label"
_LINE_RE = re.compile(
    r'^(\.+)([npst>])\s+(\S+)\s+"([^"]*)"'
)


class NavSpecParseError(Exception):
    """Raised when nav.spec cannot be parsed."""


def parse_nav_spec(text: str) -> tuple[NavNode, ...]:
    """Parse a nav.spec file into a tree of NavNode objects.

    Args:
        text: Raw content of a nav.spec file.

    Returns:
        Tuple of top-level NavNode objects.

    Raises:
        NavSpecParseError: If the file format is invalid.
    """
    entries: list[tuple[int, str, str, str]] = []

    for line_num, line in enumerate(text.split("\n"), start=1):
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue

        match = _LINE_RE.match(stripped)
        if not match:
            raise NavSpecParseError(
                f"Cannot parse line {line_num}: {line!r}"
            )

        dots = match.group(1)
        type_char = match.group(2)
        name = match.group(3)
        label = match.group(4)
        depth = len(dots)

        node_type = _TYPE_MAP[type_char]
        entries.append((depth, node_type, name, label))

    return _build_tree(entries)


def _build_tree(
    entries: list[tuple[int, str, str, str]],
) -> tuple[NavNode, ...]:
    """Build tree from flat (depth, type, name, label) entries."""
    if not entries:
        return ()

    roots: list[NavNode] = []
    # Stack of (depth, node, children_list)
    stack: list[tuple[int, str, str, str, list[NavNode]]] = []

    for depth, node_type, name, label in entries:
        # Pop entries from stack until we find our parent
        while stack and stack[-1][0] >= depth:
            _finalize_top(stack, roots)

        children: list[NavNode] = []
        stack.append((depth, node_type, name, label, children))

    # Finalize remaining stack
    while stack:
        _finalize_top(stack, roots)

    return tuple(roots)


def _finalize_top(
    stack: list[tuple[int, str, str, str, list[NavNode]]],
    roots: list[NavNode],
) -> None:
    """Pop the top of stack and attach as child or root."""
    _depth, node_type, name, label, children = stack.pop()
    node = NavNode(
        name=name,
        label=label,
        node_type=node_type,  # type: ignore[arg-type]
        children=tuple(children),
    )
    if stack:
        stack[-1][4].append(node)
    else:
        roots.append(node)
