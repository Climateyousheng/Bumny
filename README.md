# UMUI Next

Modern rebuild of the legacy UMUI/GHUI Tcl/Tk tool for managing Unified Model experiments and jobs on HPC systems.

## Architecture

```
core/          Domain model, file format parsers, storage layout, locking, CRUD ops
connectors/    SSH/SFTP and local filesystem backends
api/           FastAPI REST API (24 endpoints)
ui/            React/TypeScript web frontend (Vite + shadcn/ui)
fixtures/      App pack and sample data from legacy UMUI on puma2
tools/         Bridge scripts, migration helpers (planned)
docs/          Implementation guides, planning docs, science notes, contributing guide, runbook
umui/          Legacy UMUI/GHUI Tcl/Tk source (ghui2.0/) and reference docs (read-only reference)
```

## Quick start

### Prerequisites

- Python >= 3.12
- [uv](https://docs.astral.sh/uv/) package manager
- Node.js >= 20

### Backend (Python)

```bash
# Install all Python dependencies (core, connectors, api)
uv sync

# Run all Python tests
uv run pytest

# Run by package
uv run pytest core/tests/
uv run pytest connectors/tests/
uv run pytest api/tests/

# Lint and type check
uv run ruff check .
uv run mypy --strict core/
uv run mypy --strict connectors/
uv run mypy --strict api/
```

### Frontend (React)

```bash
cd ui

# Install dependencies
npm install

# Development server (proxies /experiments to localhost:8000)
npm run dev

# Type check, lint, test
npm run typecheck
npm run lint
npm run test
npm run test:coverage

# E2E tests (requires running API + dev server)
npm run test:e2e
```

### Running the full stack locally

```bash
# Terminal 1: Start API with fixture data + app pack (required for bridge editor)
uv run python -m umui_api --db-path ./fixtures/samples --app-pack-path ./fixtures/app_pack/vn8.6

# Terminal 2: Start UI dev server
cd ui && npm run dev

# Open http://localhost:5173
```

## Packages

### `umui-core`

Domain library with zero external dependencies. Provides:

- **Models** -- `Experiment`, `Job`, `Lock`, `LockResult` dataclasses
- **Formats** -- Pairs format parser (`.exp`/`.job` files), basis file reader
- **Storage** -- `FileSystem` protocol, `LocalFileSystem`, `DatabasePaths` helper
- **Locking** -- Legacy field-based and new mkdir-based lock strategies
- **Ops** -- CRUD operations for experiments and jobs

### `umui-connectors`

SSH/SFTP implementation of the `FileSystem` protocol for remote access to the UMUI database on puma2.

- **`SshTarget`** -- Frozen dataclass describing an SSH target (host, jump hosts, db path)
- **`load_targets()`** -- TOML config loader (`~/.config/umui/targets.toml`)
- **`SshFileSystem`** -- All 9 `FileSystem` methods over SFTP with:
  - Multi-hop tunneling (local -> bp14 -> archer2 -> puma2)
  - Background asyncio event loop on a daemon thread
  - Atomic writes (temp file + rename)
  - Automatic single-retry on connection loss

#### Example usage

```python
from umui_connectors import SshFileSystem, SshTarget
from umui_core.ops.experiments import list_experiments
from umui_core.storage.layout import DatabasePaths

target = SshTarget(
    name="puma2",
    final_host="puma2",
    jump_hosts=("bp14", "archer2"),
    db_path="/home/n02/n02/umui/umui/umui2.0/DBSE",
)
with SshFileSystem(target) as fs:
    db = DatabasePaths(target.db_path)
    for exp in list_experiments(fs, db)[:5]:
        print(f"{exp.id}: {exp.owner} - {exp.description}")
```

#### TOML config

```toml
# ~/.config/umui/targets.toml
[targets.puma2]
final_host = "puma2"
db_path = "/home/n02/n02/umui/umui/umui2.0/DBSE"
jump_hosts = ["bp14", "archer2"]
connect_timeout = 30.0
```

### `umui-api`

FastAPI REST API with 24 endpoints across four routers:

| Method | Path | Description |
|--------|------|-------------|
| GET | `/experiments` | List all experiments |
| GET | `/experiments/{exp_id}` | Get experiment details |
| POST | `/experiments` | Create experiment |
| PATCH | `/experiments/{exp_id}` | Update experiment |
| DELETE | `/experiments/{exp_id}` | Delete experiment |
| POST | `/experiments/{exp_id}/copy` | Copy experiment |
| GET | `/experiments/{exp_id}/jobs` | List jobs |
| GET | `/experiments/{exp_id}/jobs/{job_id}` | Get job details |
| POST | `/experiments/{exp_id}/jobs` | Create job |
| PATCH | `/experiments/{exp_id}/jobs/{job_id}` | Update job |
| DELETE | `/experiments/{exp_id}/jobs/{job_id}` | Delete job |
| POST | `/experiments/{exp_id}/jobs/{job_id}/copy` | Copy job |
| GET | `/experiments/{exp_id}/jobs/{job_id}/lock` | Check lock status |
| POST | `/experiments/{exp_id}/jobs/{job_id}/lock` | Acquire lock |
| DELETE | `/experiments/{exp_id}/jobs/{job_id}/lock` | Release lock |
| GET | `/bridge/nav` | Navigation tree |
| GET | `/bridge/windows/{win_id}` | Window definition + components |
| GET | `/bridge/windows/{win_id}/help` | Window help text |
| GET | `/bridge/register` | Variable registrations |
| GET | `/bridge/partitions` | Partition definitions |
| GET | `/bridge/variables/{exp_id}/{job_id}` | All variables for job |
| GET | `/bridge/variables/{exp_id}/{job_id}/{win_id}` | Variables scoped to window |
| PATCH | `/bridge/variables/{exp_id}/{job_id}` | Update variables |
| GET | `/bridge/basis/{exp_id}/{job_id}/raw` | Raw basis file content |

Mutating endpoints require the `X-UMUI-User` header for identity.

### `umui-ui`

React 19 web frontend built with Vite, TypeScript, Tailwind CSS, and shadcn/ui. Features:

- **Explorer view** -- expandable experiment rows with inline lazy-loaded jobs, structured filtering (search, owner, version, privacy), row selection with bulk delete
- **Experiment management** -- list, search, create, copy, edit, delete
- **Job management** -- list, create, copy, edit, delete per experiment
- **Lock management** -- view status, acquire/release/force-acquire locks with 30s polling
- **Global menubar** -- File/Search/Experiment/Job/Help menus matching legacy UMUI, with all dialog actions wired up
- **Bridge editor** -- read-write variable editing with lock-gated draft state, nav tree, expression-driven show/hide, server-side evaluation
- **Job diff viewer** -- side-by-side comparison of two jobs' metadata and variables, highlighting added/removed/changed entries
- **Raw basis viewer** -- read-only dialog showing the full Fortran namelist basis file (gzip decompressed) with copy-to-clipboard
- **Process/Submit** -- toolbar buttons present (disabled, pending Phase 6 SSH connector)
- **User identity** -- username prompted on first visit, stored in localStorage
- **262 tests** with 92% statement coverage (Vitest + MSW v2 + Playwright E2E)

## Key concepts

- **Experiment IDs** -- 4-letter base-26 (`aaaa`--`zzzz`). The 5-char "run ID" (e.g. `xqjca`) = experiment (`xqjc`) + job (`a`).
- **File formats** -- `.exp`/`.job` files use alternating field/value lines (pairs format). Byte-identical round-trips with legacy UMUI.
- **Locking** -- Legacy: `opened` field in `.job` file. New: atomic `mkdir`-based locks for distributed safety.
- **FileSystem protocol** -- 9-method abstraction (`read_bytes`, `write_bytes`, `read_text`, `write_text`, `exists`, `mkdir`, `rmdir`, `delete`, `list_dir`, `glob`) enabling local and SSH backends.

## Roadmap

| Phase | Status | Description |
|-------|--------|-------------|
| 0 | Done | Real app pack + fixtures from puma2 |
| 1 | Done | Core library (models, formats, storage, locking, ops) |
| 1.5 | Done | SSH connector (`SshFileSystem`) |
| 2 | Done | REST API (FastAPI, 24 endpoints) |
| 3 | Done | Web UI (React, Vite, shadcn/ui) |
| 4 | Done | Bridge editor (read-write, lock-gated, expression eval) |
| 4+ | Done | UI parity (explorer, menubar, filtering, 262 tests) |
| 5 | Done | Menubar actions, diff viewer, hand-edit mode, Process/Submit UI |
| 6 | Done | Process/Submit backend (template processing + SSH execution) |
