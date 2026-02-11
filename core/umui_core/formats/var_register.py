"""Parse the UMUI variable register (var.register).

Each non-comment line defines one variable with whitespace-separated columns:

    NAME DEFAULT DIM1_START DIM1_END DIM2_START TYPE WIDTH FORMAT
        WINDOW PARTITION CONDITION VALIDATION_TYPE VALIDATION_ARGS...

The condition field may contain spaces when parenthesised, and validation
args are everything after the validation type to end of line.
"""

from __future__ import annotations

import re

from umui_core.models.variable import ValidationType, VariableRegistration, VarType

_VALID_TYPES: frozenset[str] = frozenset({"INT", "REAL", "STRING", "LOGIC"})
_VALID_VALIDATIONS: frozenset[str] = frozenset(
    {"RANGE", "LIST", "FUNCTION", "FILE", "NONE"}
)


class VarRegisterParseError(Exception):
    """Raised when var.register cannot be parsed."""


def parse_var_register(text: str) -> tuple[VariableRegistration, ...]:
    """Parse a var.register file.

    Args:
        text: Raw content of the var.register file.

    Returns:
        Tuple of VariableRegistration objects.

    Raises:
        VarRegisterParseError: If the format is invalid.
    """
    registrations: list[VariableRegistration] = []

    for line_num, line in enumerate(text.split("\n"), start=1):
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue

        try:
            reg = _parse_line(stripped)
        except (ValueError, IndexError) as e:
            raise VarRegisterParseError(
                f"Failed to parse line {line_num}: {stripped!r}: {e}"
            ) from e

        registrations.append(reg)

    return tuple(registrations)


def _parse_line(line: str) -> VariableRegistration:
    """Parse a single var.register line into a VariableRegistration."""
    # Split into tokens, but we need to handle the condition field
    # specially since it can contain spaces in parenthesised expressions.
    # Strategy: parse known fixed-position fields from left, then handle
    # the condition + validation tail.

    tokens = line.split()

    name = tokens[0]
    default = tokens[1]
    dim1_start = tokens[2]
    dim1_end = tokens[3]
    dim2_start = tokens[4]
    var_type_str = tokens[5]

    if var_type_str not in _VALID_TYPES:
        raise ValueError(f"Invalid var type: {var_type_str}")

    var_type: VarType = var_type_str  # type: ignore[assignment]
    width = int(tokens[6])
    format_spec = tokens[7]

    # After format_spec: window, partition, condition,
    # validation_type, validation_args
    # The condition can contain spaces (e.g. "(A==1)||(B==2)")
    # We need to find the window and partition first, then parse the rest.

    # Reconstruct the remainder after the first 8 tokens
    # Find position of the 8th token in the line
    pos = 0
    for i in range(8):
        pos = line.index(tokens[i], pos) + len(tokens[i])

    remainder = line[pos:].strip()

    # Window and partition are the next two tokens
    rest_tokens = remainder.split()
    window = rest_tokens[0]
    partition = rest_tokens[1]

    # Find position after partition in remainder
    pos2 = 0
    for i in range(2):
        pos2 = remainder.index(rest_tokens[i], pos2) + len(rest_tokens[i])

    tail = remainder[pos2:].strip()

    # Now we need to extract condition and validation from the tail.
    # The validation type is one of: RANGE, LIST, FUNCTION, FILE, NONE
    # Find the last occurrence of a validation type keyword.
    condition, validation_type, validation_args = _parse_condition_and_validation(tail)

    return VariableRegistration(
        name=name,
        default=default,
        dim1_start=dim1_start,
        dim1_end=dim1_end,
        dim2_start=dim2_start,
        var_type=var_type,
        width=width,
        format_spec=format_spec,
        window=window,
        partition=partition,
        condition=condition,
        validation_type=validation_type,
        validation_args=validation_args,
    )


def _parse_condition_and_validation(
    tail: str,
) -> tuple[str, ValidationType, tuple[str, ...]]:
    """Extract condition, validation type, and validation args from tail.

    The tail is the portion of the line after window and partition.
    The validation keyword (RANGE, LIST, FUNCTION, FILE, NONE) separates
    the condition from the validation args.
    """
    # Find the rightmost validation keyword
    best_pos = -1
    best_keyword = ""

    for keyword in _VALID_VALIDATIONS:
        # Search for keyword as a whole word from right
        pattern = rf"\b{keyword}\b"
        for match in re.finditer(pattern, tail):
            if match.start() > best_pos:
                best_pos = match.start()
                best_keyword = keyword

    if best_pos == -1:
        # No validation keyword found - treat entire tail as condition
        return tail.strip(), "NONE", ()

    condition = tail[:best_pos].strip()
    after_keyword = tail[best_pos + len(best_keyword):].strip()

    validation_type: ValidationType = best_keyword  # type: ignore[assignment]
    validation_args = tuple(after_keyword.split()) if after_keyword else ()

    return condition, validation_type, validation_args
