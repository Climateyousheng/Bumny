# UMUI Next

Modern rebuild of the legacy UMUI/GHUI Tcl/Tk tool for managing Unified Model experiments and jobs on HPC systems.

## Architecture

- `core/` - Domain model, file format parsers, storage layout, locking, CRUD ops
- `connectors/` - SSH/SFTP and local filesystem backends
- `api/` - FastAPI REST API (23 endpoints: experiments, jobs, locks, bridge; `X-UMUI-User` header for auth)
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

# API server (local fixtures + app pack for bridge)
uv run python -m umui_api --db-path ./fixtures/samples --app-pack-path ./fixtures/app_pack/vn8.6

# React frontend
cd ui
npm install
npm run dev                      # Dev server (port 5173, proxies /experiments + /bridge to :8000)
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

## Frontend parity goals (legacy UMUI)

Legacy UMUI exposed most operations via:

1) **Entry screen menus**: `File`, `Search`, `Experiment`, `Job`, `Help` (see `umui/ghui2.0/tcl/entry_appearance.tcl`).
2) **Job editor action buttons** (bottom bar / help menu) driven by `nav.buttons` in the application pack.

UMUI Next intentionally started with a smaller surface area, but for usability the UI should converge on the legacy workflow:

- Provide a **global menubar / command palette** that exposes the legacy actions (even if some are temporarily disabled).
- Provide a **single-screen “Explorer” view** (experiments with expandable jobs) and **bulk selection** + bulk actions.
- Bridge editor must support **read-only** and **read-write** modes. Read-write mode requires acquiring a legacy lock.
- Bridge editor should include a top toolbar with at least: **Lock status**, **Edit mode**, **Save**, **Reset**, **Help**.
- Bridge should eventually surface legacy actions: **Check Setup**, **Process**, **Submit**, **Import/Export**, **Edit History**.

Key UI files:

- `ui/src/components/layout/header.tsx` (global nav / menubar)
- `ui/src/components/experiments/*` (experiment explorer/table)
- `ui/src/components/jobs/*` (job table + actions)
- `ui/src/components/bridge/*` (bridge editor, toolbar, editable components)

Key legacy references (for parity):

- `umui/ghui2.0/tcl/entry_appearance.tcl` (menu titles/items)
- `fixtures/app_pack/*/windows/nav.buttons` (job editor action buttons, accelerators)
