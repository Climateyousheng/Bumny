"""Evaluate UMUI conditional expressions used in .case and .invisible.

Expressions appear in .pan files and var.register:
- ``OCAAA==1``
- ``ATMOS_SR(12)!="0A"``
- ``OCAAA==2||OCAAA==3||OCAAA==4``
- ``(USE_TCA=="Y")&&(ATMOS_SR(36)=="1A")&&(OCAAA==2)``
- ``NEVER`` (always false) / ``ALWAYS`` (always true)

Grammar (recursive-descent)::

    expr     -> or_expr
    or_expr  -> and_expr ('||' and_expr)*
    and_expr -> not_expr ('&&' not_expr)*
    not_expr -> '!' not_expr | primary
    primary  -> '(' expr ')' | comparison | 'NEVER' | 'ALWAYS'
    comparison -> value ('==' | '!=') value
    value    -> IDENTIFIER | IDENTIFIER '(' INDEX ')' | LITERAL
"""

from __future__ import annotations


class ExpressionError(Exception):
    """Raised when an expression cannot be evaluated."""


def evaluate(
    expression: str,
    variables: dict[str, str | tuple[str, ...]],
) -> bool:
    """Evaluate a UMUI conditional expression.

    Args:
        expression: The expression string.
        variables: Current variable values for lookups.

    Returns:
        True if the condition is met.
    """
    expr = expression.strip()
    if not expr:
        return True

    parser = _Parser(expr, variables)
    result = parser.parse_expr()

    if parser.pos < len(parser.text):
        remaining = parser.text[parser.pos:].strip()
        if remaining:
            raise ExpressionError(
                f"Unexpected trailing text: {remaining!r} in {expression!r}"
            )

    return result


class _Parser:
    """Recursive-descent parser for UMUI expressions."""

    def __init__(
        self,
        text: str,
        variables: dict[str, str | tuple[str, ...]],
    ) -> None:
        self.text = text
        self.variables = variables
        self.pos = 0

    def _skip_spaces(self) -> None:
        while self.pos < len(self.text) and self.text[self.pos] == " ":
            self.pos += 1

    def _peek(self, n: int = 1) -> str:
        return self.text[self.pos : self.pos + n]

    def _at_end(self) -> bool:
        self._skip_spaces()
        return self.pos >= len(self.text)

    def parse_expr(self) -> bool:
        return self._or_expr()

    def _or_expr(self) -> bool:
        left = self._and_expr()
        while self._match("||"):
            right = self._and_expr()
            left = left or right
        return left

    def _and_expr(self) -> bool:
        left = self._not_expr()
        while self._match("&&"):
            right = self._not_expr()
            left = left and right
        return left

    def _not_expr(self) -> bool:
        self._skip_spaces()
        if (
            self.pos < len(self.text)
            and self.text[self.pos] == "!"
            and self.pos + 1 < len(self.text)
            and self.text[self.pos + 1] != "="
        ):
            self.pos += 1
            return not self._not_expr()
        return self._primary()

    def _primary(self) -> bool:
        self._skip_spaces()

        if self._at_end():
            raise ExpressionError("Unexpected end of expression")

        # Parenthesised sub-expression
        if self.text[self.pos] == "(":
            self.pos += 1
            result = self._or_expr()
            self._skip_spaces()
            if self.pos >= len(self.text) or self.text[self.pos] != ")":
                raise ExpressionError("Missing closing parenthesis")
            self.pos += 1
            return result

        # Check for NEVER / ALWAYS keywords
        for keyword, value in (("NEVER", False), ("ALWAYS", True)):
            if self.text[self.pos :].startswith(keyword):
                end = self.pos + len(keyword)
                if end >= len(self.text) or not self.text[end].isalnum():
                    self.pos = end
                    return value

        # Must be a comparison: value op value
        return self._comparison()

    def _comparison(self) -> bool:
        left = self._value()
        self._skip_spaces()

        if self._match("=="):
            right = self._value()
            return left == right
        elif self._match("!="):
            right = self._value()
            return left != right
        else:
            raise ExpressionError(
                f"Expected == or != at position {self.pos} "
                f"in {self.text!r}"
            )

    def _match(self, token: str) -> bool:
        self._skip_spaces()
        if self.text[self.pos : self.pos + len(token)] == token:
            self.pos += len(token)
            return True
        return False

    def _value(self) -> str:
        self._skip_spaces()

        if self._at_end():
            raise ExpressionError("Unexpected end of expression in value")

        ch = self.text[self.pos]

        # Quoted string
        if ch in ("'", '"'):
            return self._quoted_string()

        # Number (possibly negative)
        if ch.isdigit() or (
            ch == "-"
            and self.pos + 1 < len(self.text)
            and self.text[self.pos + 1].isdigit()
        ):
            return self._number()

        # Identifier (possibly with subscript)
        if ch.isalpha() or ch == "_":
            return self._identifier()

        raise ExpressionError(
            f"Unexpected character {ch!r} at position {self.pos} "
            f"in {self.text!r}"
        )

    def _quoted_string(self) -> str:
        quote = self.text[self.pos]
        self.pos += 1
        start = self.pos
        while self.pos < len(self.text) and self.text[self.pos] != quote:
            self.pos += 1
        if self.pos >= len(self.text):
            raise ExpressionError("Unterminated string")
        value = self.text[start : self.pos]
        self.pos += 1  # skip closing quote
        return value

    def _number(self) -> str:
        start = self.pos
        if self.text[self.pos] == "-":
            self.pos += 1
        while self.pos < len(self.text) and (
            self.text[self.pos].isdigit() or self.text[self.pos] == "."
        ):
            self.pos += 1
        return self.text[start : self.pos]

    def _identifier(self) -> str:
        start = self.pos
        while self.pos < len(self.text) and (
            self.text[self.pos].isalnum() or self.text[self.pos] == "_"
        ):
            self.pos += 1

        name = self.text[start : self.pos]
        self._skip_spaces()

        # Check for subscript: NAME(index)
        if self.pos < len(self.text) and self.text[self.pos] == "(":
            self.pos += 1
            idx_start = self.pos
            while self.pos < len(self.text) and self.text[self.pos] != ")":
                self.pos += 1
            if self.pos >= len(self.text):
                raise ExpressionError(f"Unterminated subscript for {name}")
            index_str = self.text[idx_start : self.pos]
            self.pos += 1  # skip ')'
            return self._resolve_subscript(name, index_str)

        return self._resolve(name)

    def _resolve(self, name: str) -> str:
        val = self.variables.get(name, "")
        if isinstance(val, tuple):
            return val[0] if val else ""
        return val

    def _resolve_subscript(self, name: str, index_str: str) -> str:
        val = self.variables.get(name, "")
        if isinstance(val, tuple):
            try:
                idx = int(index_str) - 1  # 1-based to 0-based
                if 0 <= idx < len(val):
                    return val[idx]
                return ""
            except ValueError:
                return ""
        # If scalar, just return the value regardless of subscript
        if isinstance(val, str):
            return val
        return ""
