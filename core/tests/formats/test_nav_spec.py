"""Tests for nav.spec parser."""

from __future__ import annotations

from typing import TYPE_CHECKING

import pytest
from umui_core.formats.nav_spec import NavSpecParseError, parse_nav_spec

if TYPE_CHECKING:
    from pathlib import Path


class TestParseNavSpec:
    """Tests for parse_nav_spec."""

    def test_single_node(self) -> None:
        text = '.n modsel "Model Selection"\n'
        result = parse_nav_spec(text)
        assert len(result) == 1
        assert result[0].name == "modsel"
        assert result[0].label == "Model Selection"
        assert result[0].node_type == "node"
        assert result[0].children == ()

    def test_node_with_panel(self) -> None:
        text = (
            '.n modsel "Model Selection"\n'
            '..p personal_gen "General details"\n'
        )
        result = parse_nav_spec(text)
        assert len(result) == 1
        node = result[0]
        assert node.name == "modsel"
        assert len(node.children) == 1
        assert node.children[0].name == "personal_gen"
        assert node.children[0].node_type == "panel"

    def test_nested_nodes(self) -> None:
        text = (
            '.n top "Top"\n'
            '..n mid "Middle"\n'
            '...p leaf "Leaf"\n'
        )
        result = parse_nav_spec(text)
        assert len(result) == 1
        assert result[0].children[0].children[0].name == "leaf"

    def test_multiple_roots(self) -> None:
        text = (
            '.n a "Node A"\n'
            '.n b "Node B"\n'
        )
        result = parse_nav_spec(text)
        assert len(result) == 2

    def test_shared_panel(self) -> None:
        text = '.n top "Top"\n..s shared_win "Shared"\n'
        result = parse_nav_spec(text)
        child = result[0].children[0]
        assert child.node_type == "shared"
        assert child.name == "shared_win"

    def test_repeated_node(self) -> None:
        text = '.n top "Top"\n..t rep "Repeated"\n'
        result = parse_nav_spec(text)
        child = result[0].children[0]
        assert child.node_type == "repeated"

    def test_follow_on(self) -> None:
        text = '.n top "Top"\n..> follow "Follow On"\n'
        result = parse_nav_spec(text)
        child = result[0].children[0]
        assert child.node_type == "follow_on"

    def test_comments_and_blanks_ignored(self) -> None:
        text = (
            "# Comment\n"
            "\n"
            '.n top "Top"\n'
            "# Another comment\n"
            '..p child "Child"\n'
        )
        result = parse_nav_spec(text)
        assert len(result) == 1
        assert len(result[0].children) == 1

    def test_empty_input(self) -> None:
        result = parse_nav_spec("")
        assert result == ()

    def test_invalid_line_raises(self) -> None:
        with pytest.raises(NavSpecParseError, match="Cannot parse"):
            parse_nav_spec("garbage line\n")

    def test_siblings_at_same_level(self) -> None:
        text = (
            '.n top "Top"\n'
            '..p a "A"\n'
            '..p b "B"\n'
            '..n sub "Sub"\n'
            '...p c "C"\n'
        )
        result = parse_nav_spec(text)
        top = result[0]
        assert len(top.children) == 3
        assert top.children[0].name == "a"
        assert top.children[1].name == "b"
        assert top.children[2].name == "sub"
        assert len(top.children[2].children) == 1

    def test_real_nav_spec(self, fixtures_dir: Path) -> None:
        """Parse the real nav.spec fixture file."""
        path = fixtures_dir / "app_pack" / "vn8.6" / "windows" / "nav.spec"
        text = path.read_text()
        result = parse_nav_spec(text)

        # Should have top-level nodes
        assert len(result) >= 1
        # First top-level node should be "modsel"
        assert result[0].name == "modsel"
        assert result[0].label == "Model Selection"

        # Count total nodes recursively
        count = _count_nodes(result)
        assert count > 200  # nav.spec has 249 entries

    def test_depth_decrease_skipping(self) -> None:
        """Test jumping from deep to shallow level."""
        text = (
            '.n a "A"\n'
            '..n b "B"\n'
            '...p deep "Deep"\n'
            '.n c "C"\n'  # Jump back to depth 1
        )
        result = parse_nav_spec(text)
        assert len(result) == 2
        assert result[0].name == "a"
        assert result[1].name == "c"


def _count_nodes(nodes: tuple[object, ...]) -> int:
    """Recursively count all nodes."""
    total = 0
    for node in nodes:
        total += 1
        if hasattr(node, "children"):
            total += _count_nodes(node.children)  # type: ignore[attr-defined]
    return total
