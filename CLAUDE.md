# UMUI Next

Modern rebuild of the legacy UMUI/GHUI Tcl/Tk tool for managing Unified Model experiments and jobs on HPC systems.

## Architecture

- `core/` - Domain model, file format parsers, storage layout, locking, CRUD ops
- `connectors/` - SSH/SFTP and local filesystem backends
- `api/` - FastAPI REST API (15 endpoints, `X-UMUI-User` header for auth)
- `ui/` - React 19 + TypeScript frontend (Vite, shadcn/ui, TanStack Query)
- `fixtures/` - App pack and sample data from legacy UMUI
- `tools/` - Bridge scripts, migration helpers

## Dev commands

```bash
# Python backend
uv sync
uv run pytest                    # Run all tests
uv run pytest core/tests/        # Run core tests only
uv run ruff check .              # Lint
uv run mypy --strict core/       # Type check

# API server (local fixtures)
uv run python -m umui_api --db-path ./fixtures/samples

# React frontend
cd ui
npm install
npm run dev                      # Dev server (port 5173, proxies to :8000)
npm run typecheck                # tsc --noEmit
npm run lint                     # eslint src/
npm run test                     # vitest run
npm run test:coverage            # vitest with coverage
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
