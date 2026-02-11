"""Tests for expression evaluator."""

from __future__ import annotations

from umui_core.formats.expressions import evaluate


class TestEvaluateBasic:
    """Tests for basic expression evaluation."""

    def test_equal_true(self) -> None:
        assert evaluate('OCAAA==1', {"OCAAA": "1"}) is True

    def test_equal_false(self) -> None:
        assert evaluate('OCAAA==1', {"OCAAA": "2"}) is False

    def test_not_equal_true(self) -> None:
        assert evaluate('OCAAA!=1', {"OCAAA": "2"}) is True

    def test_not_equal_false(self) -> None:
        assert evaluate('OCAAA!=1', {"OCAAA": "1"}) is False

    def test_string_comparison(self) -> None:
        assert evaluate('USE_TCA=="Y"', {"USE_TCA": "Y"}) is True

    def test_string_comparison_false(self) -> None:
        assert evaluate('USE_TCA=="Y"', {"USE_TCA": "N"}) is False

    def test_missing_variable_empty(self) -> None:
        assert evaluate('X==1', {}) is False
        assert evaluate('X==""', {}) is True


class TestEvaluateLogical:
    """Tests for logical operators."""

    def test_or_true(self) -> None:
        assert evaluate('A==1||B==2', {"A": "1", "B": "0"}) is True

    def test_or_false(self) -> None:
        assert evaluate('A==1||B==2', {"A": "0", "B": "0"}) is False

    def test_and_true(self) -> None:
        assert evaluate('A==1&&B==2', {"A": "1", "B": "2"}) is True

    def test_and_false(self) -> None:
        assert evaluate('A==1&&B==2', {"A": "1", "B": "0"}) is False

    def test_chained_or(self) -> None:
        assert evaluate(
            'OCAAA==2||OCAAA==3||OCAAA==4', {"OCAAA": "3"}
        ) is True

    def test_parenthesised(self) -> None:
        assert evaluate(
            '(USE_TCA=="Y")&&(OCAAA==2)',
            {"USE_TCA": "Y", "OCAAA": "2"},
        ) is True

    def test_negation(self) -> None:
        assert evaluate('!(A==1)', {"A": "2"}) is True
        assert evaluate('!(A==1)', {"A": "1"}) is False

    def test_complex_expression(self) -> None:
        expr = '(ATMOS_SR(18)=="0A")||(AAS_AC=="N"&&AAS_IAU=="N")'
        vars_ = {"ATMOS_SR": ("x", "y"), "AAS_AC": "N", "AAS_IAU": "N"}
        # ATMOS_SR(18) resolves to "" (out of bounds), so "0A" comparison is false
        # But AAS_AC=="N" && AAS_IAU=="N" is true
        assert evaluate(expr, vars_) is True


class TestEvaluateKeywords:
    """Tests for NEVER and ALWAYS keywords."""

    def test_never(self) -> None:
        assert evaluate("NEVER", {}) is False

    def test_always(self) -> None:
        assert evaluate("ALWAYS", {}) is True


class TestEvaluateSubscripts:
    """Tests for array subscript access."""

    def test_subscript_access(self) -> None:
        vars_ = {"ATMOS_SR": ("0A", "1A", "0A")}
        assert evaluate('ATMOS_SR(1)=="0A"', vars_) is True
        assert evaluate('ATMOS_SR(2)=="1A"', vars_) is True

    def test_subscript_out_of_range(self) -> None:
        vars_ = {"ATMOS_SR": ("0A",)}
        assert evaluate('ATMOS_SR(99)=="0A"', vars_) is False

    def test_subscript_on_scalar(self) -> None:
        vars_ = {"X": "hello"}
        assert evaluate('X(1)=="hello"', vars_) is True


class TestEvaluateEdgeCases:
    """Edge case tests."""

    def test_empty_expression(self) -> None:
        assert evaluate("", {}) is True

    def test_whitespace_handling(self) -> None:
        assert evaluate(' A == 1 ', {"A": "1"}) is True

    def test_quoted_with_spaces(self) -> None:
        assert evaluate('X=="0A"', {"X": "0A"}) is True

    def test_not_equal_string(self) -> None:
        assert evaluate(
            'ATMOS_SR(12)!="0A"',
            {"ATMOS_SR": tuple(["0A"] * 12)},
        ) is False

    def test_double_quoted_string(self) -> None:
        assert evaluate('X=="hello"', {"X": "hello"}) is True

    def test_numeric_comparison(self) -> None:
        # Values are strings, comparison is string-based
        assert evaluate("X==42", {"X": "42"}) is True
