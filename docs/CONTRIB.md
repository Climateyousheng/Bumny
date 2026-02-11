# Contributing Guide

## Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| Python | >= 3.12 | Backend runtime |
| [uv](https://docs.astral.sh/uv/) | latest | Python package manager (workspace) |
| Node.js | >= 20 | Frontend runtime |
| npm | >= 10 | Frontend package manager |

## Environment Setup

```bash
# Clone and enter repo
git clone <repo-url>
cd umui-next

# Install Python dependencies (all workspace packages)
uv sync

# Install frontend dependencies
cd ui && npm install && cd ..
```

### SSH targets (optional)

To connect to the production UMUI database on puma2, create `~/.config/umui/targets.toml`:

```toml
[targets.puma2]
final_host = "puma2"
db_path = "/home/n02/n02/umui/umui/umui2.0/DBSE"
jump_hosts = ["bp14", "archer2"]
connect_timeout = 30.0
```

## Workspace Layout

This is a uv workspace with three Python packages and one npm package:

| Package | Type | Dependencies |
|---------|------|-------------|
| `core/` (`umui-core`) | Python | None |
| `connectors/` (`umui-connectors`) | Python | umui-core, asyncssh |
| `api/` (`umui-api`) | Python | umui-core, umui-connectors, fastapi, uvicorn |
| `ui/` (`umui-ui`) | npm | react, react-router-dom, @tanstack/react-query, shadcn/ui |

## Available Scripts

### Python (run from project root)

| Command | Description |
|---------|-------------|
| `uv sync` | Install/update all Python dependencies |
| `uv run pytest` | Run all Python tests (core + connectors + api) |
| `uv run pytest core/tests/` | Run core tests only |
| `uv run pytest connectors/tests/` | Run connectors tests only |
| `uv run pytest api/tests/` | Run API tests only |
| `uv run ruff check .` | Lint all Python code |
| `uv run ruff check . --fix` | Lint and auto-fix |
| `uv run mypy --strict core/` | Type check core package |
| `uv run mypy --strict connectors/` | Type check connectors package |
| `uv run mypy --strict api/` | Type check API package |
| `uv run python -m umui_api --db-path ./fixtures/samples` | Start API with local fixture data |
| `uv run python -m umui_api --target puma2` | Start API with SSH to puma2 |

### Frontend (run from `ui/`)

| Command | Description |
|---------|-------------|
| `npm run dev` | Start Vite dev server (port 5173, proxies `/experiments` to `:8000`) |
| `npm run build` | TypeScript build + Vite production bundle |
| `npm run preview` | Preview production build |
| `npm run typecheck` | `tsc --noEmit` |
| `npm run lint` | `eslint src/` |
| `npm run test` | `vitest run` (single run) |
| `npm run test:watch` | `vitest` (watch mode) |
| `npm run test:coverage` | `vitest run --coverage` (v8 provider, target >= 80%) |

## Development Workflow

### Running the full stack

```bash
# Terminal 1: API server
uv run python -m umui_api --db-path ./fixtures/samples

# Terminal 2: Frontend dev server
cd ui && npm run dev
# Open http://localhost:5173
```

The Vite dev server proxies all requests to `/experiments` to the API at `http://127.0.0.1:8000`.

### Making changes

1. **Backend (Python)**: Edit files in `core/`, `connectors/`, or `api/`. Run `uv run pytest` to verify.
2. **Frontend (React)**: Edit files in `ui/src/`. The Vite dev server hot-reloads automatically.
3. **API contract changes**: Update `api/umui_api/schemas.py` first, then sync `ui/src/types/` to match.

### Code quality checks

```bash
# Python
uv run ruff check .
uv run mypy --strict core/ connectors/ api/
uv run pytest

# Frontend
cd ui
npm run typecheck
npm run lint
npm run test:coverage
```

## Testing

### Python tests

- **Framework**: pytest
- **Coverage**: pytest-cov (per-package reports)
- **Test paths**: `core/tests/`, `connectors/tests/`, `api/tests/`
- **API tests** use httpx `TestClient` with `LocalFileSystem` + temp dirs

### Frontend tests

- **Framework**: vitest + @testing-library/react
- **Mocking**: MSW v2 (network-level, tests the full fetch path)
- **Coverage**: @vitest/coverage-v8 (target >= 80%)
- **Test structure**:
  - `tests/lib/` -- API client, user store
  - `tests/hooks/` -- TanStack Query hooks, UserContext
  - `tests/components/` -- Component rendering + interactions
  - `tests/integration/` -- Multi-page CRUD flows
  - `tests/mocks/` -- MSW handlers, server, fixtures

### Test fixtures

The `fixtures/samples/` directory contains real experiment data from puma2 (3 experiments: `aaaa`, `xqgt`, `xqjc`). The API server can use these directly via `--db-path ./fixtures/samples`.

## Configuration

### Python tooling

| Tool | Config location | Purpose |
|------|----------------|---------|
| ruff | `pyproject.toml [tool.ruff]` | Linting (E, F, W, I, N, UP, B, A, SIM, TCH, RUF) |
| mypy | `pyproject.toml [tool.mypy]` | Type checking (strict mode) |
| pytest | `pyproject.toml [tool.pytest]` | Test runner |

### Frontend tooling

| Tool | Config file | Purpose |
|------|------------|---------|
| TypeScript | `ui/tsconfig.json` | Strict mode, path aliases (`@/` -> `src/`) |
| Vite | `ui/vite.config.ts` | Bundler, dev proxy |
| Vitest | `ui/vitest.config.ts` | Test runner (jsdom, MSW setup) |
| Tailwind | `ui/tailwind.config.js` | CSS utility classes |
| ESLint | `ui/eslint.config.js` | Linting (react-hooks, react-refresh) |
| shadcn/ui | `ui/components.json` | Component generator config |

## API Authentication

The API uses a simple `X-UMUI-User` header for identity (no password). The frontend stores the username in localStorage and sends it with every mutating request. Read-only endpoints (GET) do not require the header.
