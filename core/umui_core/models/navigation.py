"""Domain model for UMUI navigation tree."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Literal

NodeType = Literal["node", "panel", "shared", "repeated", "follow_on"]


@dataclass(frozen=True)
class NavNode:
    """A node in the UMUI navigation tree.

    The tree is defined in nav.spec and drives the sidebar of the Bridge
    editor.  Leaf nodes (panels, shared, follow_on) reference a window
    by name; branch nodes group children.
    """

    name: str
    label: str
    node_type: NodeType
    children: tuple[NavNode, ...] = ()
