# UMUI Next

Modern rebuild of the legacy UMUI/GHUI Tcl/Tk tool for managing Unified Model experiments and jobs on HPC systems.

## Architecture

```
core/          Domain model, file format parsers, storage layout, locking, CRUD ops
connectors/    SSH/SFTP and local filesystem backends
api/           FastAPI REST API (planned)
ui/            React/TypeScript web frontend (planned)
fixtures/      App pack and sample data from legacy UMUI on puma2
tools/         Bridge scripts, migration helpers (planned)
```

## Quick start

```bash
# Install dependencies
uv sync

# Run all tests
uv run pytest

# Run by package
uv run pytest core/tests/
uv run pytest connectors/tests/

# Lint and type check
uv run ruff check .
uv run mypy --strict core/
uv run mypy --strict connectors/
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
| 2 | Planned | REST API (FastAPI) |
| 3 | Planned | Web UI (React/TypeScript) |
| 4 | Planned | Bridge editor |

## Requirements

- Python >= 3.12
- [uv](https://docs.astral.sh/uv/) package manager
