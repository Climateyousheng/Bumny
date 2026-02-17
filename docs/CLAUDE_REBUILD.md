# CLAUDE.md

## What this repo is
UMUI Next is a modern rebuild of the legacy UMUI/GHUI Tcl/Tk tool used to manage Unified Model (UM) experiments and jobs.

Legacy UMUI characteristics (compatibility targets):
- Metadata as text files: `<db>/<exp_id>.exp` and `<db>/<exp_id>/<job_id>.job` (alternating `field` / `value` lines).
- Job configuration as a text “basis file” (preserve byte-for-byte unless edited).
- Multi-user locking to prevent concurrent edits of the same job.
- Optional mirroring of writes to a backup location.

UMUI Next must keep the on-disk layout compatible, while removing hard dependencies on Tcl/Tk 8.3 and X11.

## Design principles
- Compatibility first: never invent a new DB format unless you also ship a lossless migrator.
- SSH as transport + authentication: no inbound ports; use existing cluster SSH.
- Strict separation:
  - `core/` = file formats, locking, validation, rules.
  - `connectors/` = local FS + SSH FS backends.
  - `api/` = local HTTP API (OpenAPI).
  - `ui/` = web frontend.
- Incremental replacement: ship browse/list/CRUD early; job editor later.
- Testable and reproducible: typed code, unit tests, golden fixtures, deterministic behaviour.

## Repository layout (target)
```
.
├── core/                 # Domain model, formats, locking, rules
│   ├── umui_core/
│   └── tests/
├── connectors/           # SSH + local filesystem backends
│   └── umui_connectors/
├── api/                  # FastAPI + OpenAPI
│   └── umui_api/
├── ui/                   # React/TypeScript web UI
│   └── umui_web/
├── tools/                # One-off migration/inspection scripts
└── docs/                 # Architecture, ops, contributor docs
```

## Local dev commands
Python (use `uv`):
- `uv sync`
- `uv run ruff check .`
- `uv run mypy .`
- `uv run pytest`
- `uv run python -m umui_api`  (start API)

Frontend:
- `pnpm install`
- `pnpm dev`
- `pnpm lint`
- `pnpm test`

## Coding standards
- Python: `ruff` formatting/linting, `mypy` type checking, `pytest` tests.
- Prefer small, pure functions. Keep I/O at the edges.
- All remote writes must be atomic (write temp, fsync if possible, then rename).
- All remote paths must be treated as untrusted input.

## Behavioural invariants to preserve
- `.exp` / `.job` parsing and writing must preserve ordering when possible and must not drop unknown fields.
- Locking must be safe under multiple clients (use atomic remote primitives like `mkdir`).
- Operations must be idempotent where practical (e.g., “create if missing” should be safe to retry).
- Never `eval` user configuration. Config is `TOML`/`YAML` only.

## Security
- Do not execute arbitrary remote shell. Prefer SFTP for file ops.
- If remote command execution is unavoidable, use a fixed command list and strict quoting.
- Log all state-changing operations (who/host/what/when).

## Non-goals
- Reimplement UM itself.
- Replace site-specific job-submission wrappers (optional helpers are fine).
- Require root/admin installation on any HPC.
