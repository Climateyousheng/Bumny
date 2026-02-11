# UMUI Next

Modern rebuild of the legacy UMUI/GHUI Tcl/Tk tool for managing Unified Model experiments and jobs on HPC systems.

## Architecture

- `core/` - Domain model, file format parsers, storage layout, locking, CRUD ops
- `connectors/` - SSH/SFTP and local filesystem backends
- `api/` - FastAPI REST API (local-only)
- `ui/` - React/TypeScript web frontend
- `fixtures/` - App pack and sample data from legacy UMUI
- `tools/` - Bridge scripts, migration helpers

## Dev commands

```bash
# Python
uv sync
uv run pytest                    # Run all tests
uv run pytest core/tests/        # Run core tests only
uv run ruff check .              # Lint
uv run mypy --strict core/       # Type check
```

## Key file formats

- `.exp` / `.job` files: Alternating field/value lines (pairs format)
- Basis files: Job configuration data (plain text or gzip)
- Database layout: `<db>/<exp_id>.exp` + `<db>/<exp_id>/<job_id>.job`

## Design principles

- Keep legacy file format compatibility (byte-identical round-trips)
- SSH as transport (no inbound ports needed on HPC)
- FileSystem protocol abstraction (local + SSH backends)
- Atomic writes (temp file + rename)
- mkdir-based distributed locking
