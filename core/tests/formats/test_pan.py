"""Tests for .pan window parser."""

from __future__ import annotations

from typing import TYPE_CHECKING

import pytest
from umui_core.formats.pan import parse_pan
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
)

if TYPE_CHECKING:
    from pathlib import Path


class TestParseHeader:
    """Tests for window header parsing."""

    def test_winid_and_title(self) -> None:
        text = '.winid "test_win"\n.title "Test Window"\n.wintype entry\n'
        win = parse_pan(text)
        assert win.win_id == "test_win"
        assert win.title == "Test Window"
        assert win.win_type == "entry"

    def test_dummy_wintype(self) -> None:
        text = '.winid "dummy"\n.title "Dummy"\n.wintype dummy\n'
        win = parse_pan(text)
        assert win.win_type == "dummy"

    def test_empty_components_without_panel(self) -> None:
        text = '.winid "test"\n.title "T"\n.wintype entry\n'
        win = parse_pan(text)
        assert win.components == ()


class TestParseComponents:
    """Tests for individual component parsing."""

    def test_gap(self) -> None:
        text = (
            '.winid "t"\n.title "T"\n.wintype entry\n'
            ".panel\n   .gap\n.panend\n"
        )
        win = parse_pan(text)
        assert len(win.components) == 1
        assert isinstance(win.components[0], GapComponent)

    def test_text(self) -> None:
        text = (
            '.winid "t"\n.title "T"\n.wintype entry\n'
            '.panel\n   .text "Hello world" L\n.panend\n'
        )
        win = parse_pan(text)
        assert len(win.components) == 1
        comp = win.components[0]
        assert isinstance(comp, TextComponent)
        assert comp.text == "Hello world"
        assert comp.justify == "L"

    def test_textw(self) -> None:
        text = (
            '.winid "t"\n.title "T"\n.wintype entry\n'
            '.panel\n   .textw "Bold text" L\n.panend\n'
        )
        win = parse_pan(text)
        comp = win.components[0]
        assert isinstance(comp, TextComponent)
        assert comp.text == "Bold text"

    def test_entry(self) -> None:
        text = (
            '.winid "t"\n.title "T"\n.wintype entry\n'
            '.panel\n   .entry "Number of Columns" L NCOLSAG 15\n.panend\n'
        )
        win = parse_pan(text)
        comp = win.components[0]
        assert isinstance(comp, EntryComponent)
        assert comp.label == "Number of Columns"
        assert comp.variable == "NCOLSAG"
        assert comp.width == 15

    def test_entry_no_width(self) -> None:
        text = (
            '.winid "t"\n.title "T"\n.wintype entry\n'
            '.panel\n   .entry "Directory:" L PATHVARGRD\n.panend\n'
        )
        win = parse_pan(text)
        comp = win.components[0]
        assert isinstance(comp, EntryComponent)
        assert comp.width == 0

    def test_check(self) -> None:
        text = (
            '.winid "t"\n.title "T"\n.wintype entry\n'
            '.panel\n   .check "Variable resolution" L LVARGRID Y N\n.panend\n'
        )
        win = parse_pan(text)
        comp = win.components[0]
        assert isinstance(comp, CheckComponent)
        assert comp.label == "Variable resolution"
        assert comp.variable == "LVARGRID"
        assert comp.on_value == "Y"
        assert comp.off_value == "N"

    def test_pushnext(self) -> None:
        text = (
            '.winid "t"\n.title "T"\n.wintype entry\n'
            '.panel\n   .pushnext "ANCIL" atmos_InFiles\n.panend\n'
        )
        win = parse_pan(text)
        comp = win.components[0]
        assert isinstance(comp, PushNextComponent)
        assert comp.label == "ANCIL"
        assert comp.target_window == "atmos_InFiles"


class TestParseBasrad:
    """Tests for basrad (radio button) parsing."""

    def test_simple_basrad(self) -> None:
        text = (
            '.winid "t"\n.title "T"\n.wintype entry\n'
            ".panel\n"
            '   .basrad "Select Option" L 2 v MYVAR\n'
            '            "Option A" 1\n'
            '            "Option B" 2\n'
            ".panend\n"
        )
        win = parse_pan(text)
        comp = win.components[0]
        assert isinstance(comp, BasradComponent)
        assert comp.label == "Select Option"
        assert comp.count == 2
        assert comp.variable == "MYVAR"
        assert len(comp.options) == 2
        assert comp.options[0] == ("Option A", "1")
        assert comp.options[1] == ("Option B", "2")


class TestParseContainers:
    """Tests for block, case, invisible containers."""

    def test_block(self) -> None:
        text = (
            '.winid "t"\n.title "T"\n.wintype entry\n'
            ".panel\n"
            "   .block 1\n"
            '      .entry "X" L VAR_X\n'
            "   .blockend\n"
            ".panend\n"
        )
        win = parse_pan(text)
        comp = win.components[0]
        assert isinstance(comp, BlockComponent)
        assert comp.indent == 1
        assert len(comp.children) == 1
        assert isinstance(comp.children[0], EntryComponent)

    def test_case(self) -> None:
        text = (
            '.winid "t"\n.title "T"\n.wintype entry\n'
            ".panel\n"
            "   .case OCAAA==1\n"
            '      .text "Global Model" L\n'
            "   .caseend\n"
            ".panend\n"
        )
        win = parse_pan(text)
        comp = win.components[0]
        assert isinstance(comp, CaseComponent)
        assert comp.expression == "OCAAA==1"
        assert len(comp.children) == 1

    def test_invisible(self) -> None:
        text = (
            '.winid "t"\n.title "T"\n.wintype entry\n'
            ".panel\n"
            '   .invisible LVARGRID=="Y"\n'
            '      .entry "Path" L PATH\n'
            "   .invisend\n"
            ".panend\n"
        )
        win = parse_pan(text)
        comp = win.components[0]
        assert isinstance(comp, InvisibleComponent)
        assert comp.expression == 'LVARGRID=="Y"'
        assert len(comp.children) == 1

    def test_nested_containers(self) -> None:
        text = (
            '.winid "t"\n.title "T"\n.wintype entry\n'
            ".panel\n"
            "   .case OCAAA==1\n"
            "      .block 1\n"
            '         .entry "X" L VAR_X\n'
            "      .blockend\n"
            "   .caseend\n"
            ".panend\n"
        )
        win = parse_pan(text)
        case_comp = win.components[0]
        assert isinstance(case_comp, CaseComponent)
        block_comp = case_comp.children[0]
        assert isinstance(block_comp, BlockComponent)
        entry_comp = block_comp.children[0]
        assert isinstance(entry_comp, EntryComponent)


class TestParseTable:
    """Tests for table parsing."""

    def test_simple_table(self) -> None:
        text = (
            '.winid "t"\n.title "T"\n.wintype entry\n'
            ".panel\n"
            '   .table mytable "My Table" top h 10 5 NONE\n'
            '      .element "Column A" VAR_A 10 20 in\n'
            "   .tableend\n"
            ".panend\n"
        )
        win = parse_pan(text)
        comp = win.components[0]
        assert isinstance(comp, TableComponent)
        assert comp.name == "mytable"
        assert comp.header == "My Table"
        assert len(comp.children) == 1
        elem = comp.children[0]
        assert isinstance(elem, TableElementComponent)
        assert elem.variable == "VAR_A"

    def test_table_with_autonum(self) -> None:
        text = (
            '.winid "t"\n.title "T"\n.wintype entry\n'
            ".panel\n"
            '   .table t "Table" top h 10 5 INCR\n'
            '      .elementautonum "Level" 1 10 5\n'
            '      .element "Values" VALS 10 25 in\n'
            "   .tableend\n"
            ".panend\n"
        )
        win = parse_pan(text)
        comp = win.components[0]
        assert isinstance(comp, TableComponent)
        assert len(comp.children) == 2
        assert isinstance(comp.children[0], TableAutoNumComponent)
        assert isinstance(comp.children[1], TableElementComponent)


class TestParseRealFiles:
    """Tests with real .pan fixture files."""

    def test_atmos_domain_horiz(self, fixtures_dir: Path) -> None:
        """Parse the canonical test fixture."""
        path = (
            fixtures_dir / "app_pack" / "vn8.6" / "windows"
            / "atmos_Domain_Horiz.pan"
        )
        text = path.read_text()
        win = parse_pan(text)

        assert win.win_id == "atmos_Domain_Horiz"
        assert win.title == "Horizontal"
        assert win.win_type == "entry"
        assert len(win.components) > 0

        # First component should be a basrad
        first = win.components[0]
        assert isinstance(first, BasradComponent)
        assert first.variable == "OCAAA"
        assert first.count == 6

    def test_atmos_domain_vert(self, fixtures_dir: Path) -> None:
        """Parse a file with tables."""
        path = (
            fixtures_dir / "app_pack" / "vn8.6" / "windows"
            / "atmos_Domain_Vert.pan"
        )
        text = path.read_text()
        win = parse_pan(text)
        assert win.win_id == "atmos_Domain_Vert"

        # Should contain a table component somewhere
        tables = [c for c in _flatten(win.components)
                  if isinstance(c, TableComponent)]
        assert len(tables) >= 1

    def test_dummy_window(self, fixtures_dir: Path) -> None:
        """Parse the STASH dummy window."""
        path = (
            fixtures_dir / "app_pack" / "vn8.6" / "windows"
            / "atmos_STASH_tcl.pan"
        )
        text = path.read_text()
        win = parse_pan(text)
        assert win.win_id == "atmos_STASH"
        assert win.win_type == "dummy"

    def test_all_pan_files(self, fixtures_dir: Path) -> None:
        """Parse ALL 206 .pan files without error."""
        windows_dir = fixtures_dir / "app_pack" / "vn8.6" / "windows"
        pan_files = sorted(windows_dir.glob("*.pan"))
        assert len(pan_files) >= 200

        errors: list[str] = []
        for pan_file in pan_files:
            try:
                win = parse_pan(pan_file.read_text())
                assert win.win_id, f"Missing win_id in {pan_file.name}"
            except Exception as e:
                errors.append(f"{pan_file.name}: {e}")

        if errors:
            pytest.fail(
                f"{len(errors)} .pan files failed to parse:\n"
                + "\n".join(errors[:10])
            )


def _flatten(components: tuple[PanComponent, ...]) -> list[PanComponent]:
    """Recursively flatten all components."""
    result: list[PanComponent] = []
    for comp in components:
        result.append(comp)
        if hasattr(comp, "children"):
            result.extend(_flatten(comp.children))  # type: ignore[attr-defined]
    return result
