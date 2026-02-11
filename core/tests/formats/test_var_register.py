"""Tests for var.register parser."""

from __future__ import annotations

from typing import TYPE_CHECKING

from umui_core.formats.var_register import parse_var_register

if TYPE_CHECKING:
    from pathlib import Path


class TestParseVarRegister:
    """Tests for parse_var_register."""

    def test_simple_list_validation(self) -> None:
        line = (
            "AAS_AC        0  1  0  0 STRING  1 0"
            "     atmos_Assim_General"
            '               a2312   ATMOS_SR(18)=="0A"'
            "   LIST Y N"
        )
        result = parse_var_register(line)
        assert len(result) == 1
        reg = result[0]
        assert reg.name == "AAS_AC"
        assert reg.default == "0"
        assert reg.var_type == "STRING"
        assert reg.width == 1
        assert reg.window == "atmos_Assim_General"
        assert reg.partition == "a2312"
        assert reg.condition == 'ATMOS_SR(18)=="0A"'
        assert reg.validation_type == "LIST"
        assert reg.validation_args == ("Y", "N")

    def test_range_validation(self) -> None:
        line = (
            "AASMDEF      -1  1  0  0 INT     1 0"
            "     atmos_Assim_General"
            "               a2312"
            '   (ATMOS_SR(18)=="0A")'
            '||(AAS_AC=="N"&&AAS_IAU=="N")'
            "           RANGE 0 14400"
        )
        result = parse_var_register(line)
        reg = result[0]
        assert reg.name == "AASMDEF"
        assert reg.var_type == "INT"
        assert reg.validation_type == "RANGE"
        assert reg.validation_args == ("0", "14400")

    def test_function_validation(self) -> None:
        line = (
            "ASM_IAUINC    0  1  0  0 STRING 80 0"
            "     atmos_Assim_IAU"
            "                   a2312"
            '   (ATMOS_SR(18)=="0A")||(AAS_IAU=="N")'
            "      FUNCTION path_ext NOTOPT"
        )
        result = parse_var_register(line)
        reg = result[0]
        assert reg.validation_type == "FUNCTION"
        assert reg.validation_args == ("path_ext", "NOTOPT")

    def test_never_condition(self) -> None:
        line = (
            "FLOOR         0  1  0  0 STRING  1 0"
            "     atmos_Config_Mode"
            "                 a2313"
            "   NEVER                LIST  Y N"
        )
        result = parse_var_register(line)
        reg = result[0]
        assert reg.condition == "NEVER"

    def test_none_validation(self) -> None:
        line = (
            "AASNLACP      0  1 10  0 STRING 80 0"
            "     atmos_Assim_AC"
            "                    a2312"
            '   (ATMOS_SR(18)=="0A")||(AAS_AC=="N")'
            "      NONE OPT"
        )
        result = parse_var_register(line)
        reg = result[0]
        assert reg.validation_type == "NONE"

    def test_comments_ignored(self) -> None:
        text = (
            "# Comment line\n"
            "AAS_AC        0  1  0  0 STRING  1 0"
            "     atmos_Assim_General"
            '               a2312   ATMOS_SR(18)=="0A"'
            "   LIST Y N\n"
            "# Another comment\n"
        )
        result = parse_var_register(text)
        assert len(result) == 1

    def test_empty_input(self) -> None:
        result = parse_var_register("")
        assert result == ()

    def test_real_var_register(self, fixtures_dir: Path) -> None:
        """Parse the real var.register fixture file."""
        path = fixtures_dir / "app_pack" / "vn8.6" / "variables" / "var.register"
        text = path.read_text()
        result = parse_var_register(text)

        # Should have many registrations
        assert len(result) > 1000

        # All should have a name and valid type
        for reg in result:
            assert reg.name
            assert reg.var_type in ("INT", "REAL", "STRING", "LOGIC")
            assert reg.validation_type in (
                "RANGE", "LIST", "FUNCTION", "FILE", "NONE"
            )

    def test_file_validation(self) -> None:
        line = (
            "UMCOMP_OP  ZZZZ  1 NMODS 0 STRING 80 0"
            "   subindep_Compile_User"
            '             i2326   LUM_OVR=="N"'
            "        FILE OPT PATH"
        )
        result = parse_var_register(line)
        reg = result[0]
        assert reg.validation_type == "FILE"
        assert reg.validation_args == ("OPT", "PATH")

    def test_real_format_spec(self) -> None:
        line = (
            "ASM_IAULCP   -1  1  0  0 REAL  1 10.5e"
            "   atmos_Assim_IAU"
            "                   a2312"
            '   (ATMOS_SR(18)=="0A")'
            '||(AAS_IAU=="N")'
            '||(LIAU_SPCFILT=="N")'
            '||(ASM_IAUFILT!="3")'
            "    RANGE 0.0 1.0e9"
        )
        result = parse_var_register(line)
        reg = result[0]
        assert reg.var_type == "REAL"
        assert reg.format_spec == "10.5e"
        assert reg.validation_type == "RANGE"
