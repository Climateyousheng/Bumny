"""Process a job by expanding templates with basis variables.

Uses Python's built-in tkinter.Tcl() interpreter to execute legacy UMUI
processing templates. The templates use Tcl substitution syntax with custom
directives (%VAR, %I, %TCL...%ENDTCL, %OUTPUTFILE, etc.).

Template directive reference:
    %C text            - Comment line (ignored)
    %COMM ... %ENDCOMM - Multi-line comment block (ignored)
    %T code            - Single line of Tcl code
    %TCL ... %ENDTCL   - Block of Tcl code
    %I template_name   - Include another template file
    %OUTPUTFILE name   - Switch to a new output file
    %VAR / %{VAR}      - Variable substitution (in output text)
    %VAR(index)        - Array variable substitution
    %%                 - Literal percent sign

Requires tkinter (ships with most Python installations). If tkinter is
unavailable, process_job() raises ProcessError at call time.
"""

from __future__ import annotations

import contextlib
import re
from dataclasses import dataclass, field
from typing import TYPE_CHECKING, Any

from umui_core.ops.bridge import read_variables

if TYPE_CHECKING:
    from umui_core.storage.app_pack import AppPackPaths
    from umui_core.storage.layout import DatabasePaths, FileSystem

# Tcl availability check — deferred until process_job() is called.
_tcl_import_error: str | None = None
try:
    import tkinter as _tk
except ImportError as _exc:
    _tk = None  # type: ignore[assignment]
    _tcl_import_error = str(_exc)


class ProcessError(Exception):
    """Raised when template processing fails."""


@dataclass(frozen=True)
class ProcessRequest:
    """Input for process operation."""

    exp_id: str
    job_id: str
    job_dir: str | None = None


@dataclass(frozen=True)
class ProcessedJob:
    """Result of template processing."""

    files: dict[str, str]
    warnings: list[str]


# Pattern for %VAR, %{VAR}, %VAR(index) in output lines
_VAR_PATTERN = re.compile(
    r"%%"                         # escaped percent -> literal %
    r"|%\{(\w+)\}"               # %{VARNAME}
    r"|%(\w+)\(([^)]+)\)"        # %VAR(index)
    r"|%(\w+)"                    # %VAR
)


def process_job(
    fs: FileSystem,
    paths: DatabasePaths,
    app_pack: AppPackPaths,
    request: ProcessRequest,
) -> ProcessedJob:
    """Process a job by expanding templates with basis variables.

    Reads the basis file, injects variables into a Tcl interpreter,
    and executes the master template ("top") to generate output files.

    Args:
        fs: Filesystem abstraction.
        paths: Database path helper.
        app_pack: App pack path helper.
        request: Processing request with exp/job IDs.

    Returns:
        ProcessedJob with generated files and any warnings.

    Raises:
        ProcessError: If template processing fails or tkinter unavailable.
    """
    if _tk is None:
        raise ProcessError(
            f"tkinter is required for template processing: {_tcl_import_error}"
        )

    variables = read_variables(fs, paths, request.exp_id, request.job_id)

    # Flatten variables to str-only dict
    flat_vars: dict[str, str] = {}
    for key, value in variables.items():
        if isinstance(value, tuple):
            for i, v in enumerate(value, 1):
                flat_vars[f"{key}({i})"] = v
            flat_vars[key] = value[0] if value else ""
        else:
            flat_vars[key] = value

    # Add built-in variables
    run_id = request.exp_id + request.job_id
    flat_vars.setdefault("EXPT_ID", request.exp_id)
    flat_vars.setdefault("JOB_ID", request.job_id)
    flat_vars.setdefault("RUN_ID", run_id)

    ctx = _ProcessContext(
        fs=fs,
        template_dir=app_pack.processing_dir,
        variables=flat_vars,
        job_dir=request.job_dir or f"~/umui_jobs/{run_id}",
    )

    try:
        _execute_template(ctx, "top")
    except ProcessError:
        raise
    except Exception as exc:
        raise ProcessError(f"Template processing failed: {exc}") from exc

    files = {
        name: "\n".join(lines)
        for name, lines in ctx.output_files.items()
        if lines
    }

    return ProcessedJob(files=files, warnings=list(ctx.warnings))


@dataclass
class _ProcessContext:
    """Mutable state for template processing."""

    fs: Any  # FileSystem protocol
    template_dir: str
    variables: dict[str, str]
    job_dir: str
    output_files: dict[str, list[str]] = field(default_factory=dict)
    current_file: str = ""
    warnings: list[str] = field(default_factory=list)
    tcl: Any = field(default=None, repr=False)
    _included: set[str] = field(default_factory=set)

    def __post_init__(self) -> None:
        self.tcl = _create_tcl_interpreter(self.variables)


def _create_tcl_interpreter(variables: dict[str, str]) -> Any:
    """Create Tcl interpreter with basis variables and custom commands."""
    assert _tk is not None
    tcl = _tk.Tcl()

    # Inject all basis variables as Tcl variables
    for name, value in variables.items():
        with contextlib.suppress(Exception):
            tcl.setvar(name, value)

    # Define custom helper procs used by templates
    tcl.eval("""
        proc putl {arg} { return $arg }
        proc put {arg} { return $arg }
        proc pad {val {width 80}} {
            return [format "%-${width}s" $val]
        }
        proc replace {text old new} {
            regsub -all $old $text $new result
            return $result
        }
        proc if_active {name val default} {
            upvar #0 $name x
            if {[info exists x] && $x != ""} {
                return $val
            }
            return $default
        }
        proc inactive_var {name} {
            upvar #0 $name x
            if {[info exists x] && $x != "" && $x != 0} {
                return 0
            }
            return 1
        }
        proc dialog {w title msg args} {
            # No-op in batch processing mode
        }
    """)

    return tcl


def _tcl_error(*_args: object) -> type[Exception]:
    """Return the TclError exception class or a fallback."""
    if _tk is not None:
        return _tk.TclError
    return Exception


def _execute_template(ctx: _ProcessContext, template_name: str) -> None:
    """Execute a template file, processing all directives."""
    template_name = template_name.strip()

    path = f"{ctx.template_dir}/{template_name}"
    try:
        content = ctx.fs.read_text(path)
    except FileNotFoundError:
        ctx.warnings.append(f"Template not found: {template_name}")
        return

    lines = content.split("\n")
    i = 0

    while i < len(lines):
        line = lines[i]
        stripped = line.strip()

        # Empty line -> pass through to output
        if not stripped:
            _emit_line(ctx, "")
            i += 1
            continue

        # %C - comment
        if stripped.startswith("%C"):
            i += 1
            continue

        # %COMM ... %ENDCOMM - multi-line comment
        if stripped.startswith("%COMM"):
            i += 1
            while i < len(lines) and not lines[i].strip().startswith("%ENDCOMM"):
                i += 1
            i += 1  # skip %ENDCOMM
            continue

        # %TCL ... %ENDTCL - Tcl code block
        if stripped.startswith("%TCL"):
            tcl_lines: list[str] = []
            # Check if there's code on the same line as %TCL
            rest = stripped[4:].strip()
            if rest:
                tcl_lines.append(rest)
            i += 1
            while i < len(lines):
                tline = lines[i].strip()
                if tline.startswith("%ENDTCL"):
                    break
                tcl_lines.append(lines[i])
                i += 1
            i += 1  # skip %ENDTCL

            tcl_code = "\n".join(tcl_lines)
            tcl_code = _substitute_vars_in_tcl(tcl_code, ctx.variables)
            try:
                ctx.tcl.eval(tcl_code)
            except Exception as exc:
                ctx.warnings.append(
                    f"Tcl error in {template_name}: {exc}"
                )
            continue

        # %OUTPUTFILE name - switch output file
        if stripped.startswith("%OUTPUTFILE"):
            name = stripped[len("%OUTPUTFILE"):].strip()
            ctx.current_file = name
            if name not in ctx.output_files:
                ctx.output_files[name] = []
            i += 1
            continue

        # %I template_name - include
        if stripped.startswith("%I"):
            inc_name = stripped[2:].strip()
            _execute_template(ctx, inc_name)
            i += 1
            continue

        # %T - single line Tcl code
        if stripped.startswith("%T"):
            tcl_code = stripped[2:]
            if line.lstrip().startswith("%T"):
                idx = line.index("%T")
                tcl_code = line[idx + 2:]

            tcl_code = _substitute_vars_in_tcl(tcl_code, ctx.variables)
            try:
                result = ctx.tcl.eval(tcl_code)
                if result and _has_output_command(tcl_code):
                    _emit_line(ctx, result)
            except Exception as exc:
                ctx.warnings.append(
                    f"Tcl error in {template_name}: {exc}"
                )
            i += 1
            continue

        # Regular output line - substitute %VAR references
        output = _substitute_vars_in_output(line, ctx)
        _emit_line(ctx, output)
        i += 1


def _has_output_command(tcl_code: str) -> bool:
    """Check if Tcl code contains an output command (putl, put)."""
    return "putl" in tcl_code or "put " in tcl_code


def _substitute_vars_in_tcl(code: str, variables: dict[str, str]) -> str:
    """Replace %VAR references in Tcl code with $VAR or literal values."""

    def _replace(m: re.Match[str]) -> str:
        full = m.group(0)
        if full == "%%":
            return "%"
        if m.group(1):
            return f"${{{m.group(1)}}}"
        if m.group(2):
            var = m.group(2)
            idx = m.group(3)
            key = f"{var}({idx})"
            if key in variables:
                return variables[key]
            return f"${var}($idx)"
        if m.group(4):
            return f"${m.group(4)}"
        return full

    return _VAR_PATTERN.sub(_replace, code)


def _substitute_vars_in_output(line: str, ctx: _ProcessContext) -> str:
    """Replace %VAR references in output text with variable values.

    Handles inline %TCL...%ENDTCL blocks within output lines.
    """
    if "%TCL" in line and "%ENDTCL" in line:
        line = _expand_inline_tcl(line, ctx)

    if "%T " in line:
        line = _expand_inline_t(line, ctx)

    def _replace(m: re.Match[str]) -> str:
        full = m.group(0)
        if full == "%%":
            return "%"
        if m.group(1):
            return ctx.variables.get(m.group(1), full)
        if m.group(2):
            key = f"{m.group(2)}({m.group(3)})"
            return ctx.variables.get(key, full)
        if m.group(4):
            name = m.group(4)
            if name in ("OUTPUTFILE", "COMM", "ENDCOMM", "TCL", "ENDTCL"):
                return full
            return ctx.variables.get(name, full)
        return full

    return _VAR_PATTERN.sub(_replace, line)


def _expand_inline_tcl(line: str, ctx: _ProcessContext) -> str:
    """Expand inline %TCL...%ENDTCL within a line."""
    pattern = re.compile(r"%TCL\s*(.*?)\s*%ENDTCL")

    def _eval(m: re.Match[str]) -> str:
        tcl_code = _substitute_vars_in_tcl(m.group(1), ctx.variables)
        try:
            return str(ctx.tcl.eval(tcl_code))
        except Exception as exc:
            ctx.warnings.append(f"Inline Tcl error: {exc}")
            return ""

    return pattern.sub(_eval, line)


def _expand_inline_t(line: str, ctx: _ProcessContext) -> str:
    """Expand inline %T within a line (e.g. '%T putl value')."""
    pattern = re.compile(r"%T\s+(putl?\s+.+)")

    def _eval(m: re.Match[str]) -> str:
        tcl_code = _substitute_vars_in_tcl(m.group(1), ctx.variables)
        try:
            return str(ctx.tcl.eval(tcl_code))
        except Exception as exc:
            ctx.warnings.append(f"Inline %T error: {exc}")
            return ""

    return pattern.sub(_eval, line)


def _emit_line(ctx: _ProcessContext, line: str) -> None:
    """Append a line to the current output file."""
    if not ctx.current_file:
        return
    ctx.output_files.setdefault(ctx.current_file, []).append(line)
