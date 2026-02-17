# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

UMUI (Unified Model User Interface) is a Tcl/Tk client-server application built on the GHUI (Generic Hierarchical User Interface) framework. It manages climate model experiments and jobs for the UK Met Office Unified Model. Deployed on ARCHER2's puma2 server, running on wish8.3 (Tcl/Tk 8.3).

## Running

```bash
# Launch UMUI client (on puma2)
ghui umui                    # or just: umui

# Launch admin interface
ghui_admin umui

# Server management
ghui_server <base_dir> <database_dir> <type> <application>
ghui_startserver             # automated startup
ghui_haltserver              # graceful shutdown
```

There are no tests, linting, or build steps. The Install/Configure script handles initial setup via interactive prompts and template substitution.

## Architecture

Client-server over RPC sockets (port 8407):
- **Entry Client** (`tcl/entry.tcl` via `bin/ghui`) -- wish GUI for browsing experiments/jobs
- **Job Editor** (`vn1.X/tcl/edit_job.tcl`) -- separate wish process per open job, version-mapped
- **Database Server** (`tcl/server.tcl` via `bin/ghui_server`) -- tclsh daemon, dual primary/backup
- **Admin Client** (`tcl/admin.tcl` via `bin/ghui_admin`) -- wish GUI for server management

### Startup Chain

`bin/ghui` -> `wish8.3` -> `entry.tcl` -> `source.tcl` (auto-sources all `tcl/*.tcl`) -> `read_appdef.tcl` (parses `apps/umui.def`) -> `entry_appearance.tcl` (evals `~/.ghui_appearance`) -> `entry_interface.tcl` (draws UI)

### Key Separation

- `tcl/` -- Core GHUI framework (entry system, RPC, database, admin). 44 files, ~8,000 lines.
- `vn1.X/` -- Version-specific job editor code. `vn1.4/` is current (UM 6.1-8.6), 65 files, ~12,000 lines.
- `pkg/` -- RPC client/server package (`GHUIserver 1.0`). Protocol: `[byte_length]\n[command_string]`.
- `apps/*.def` -- Application definitions controlling columns, versions, dimensions.
- `tcl.orig/` -- Backup of original tcl/ before Bristol customizations (filter exact mode, group-based experiment letters).

### Data Storage

Text-based `.exp` and `.job` files in a database directory. No SQL. Server manages locking via `jobs($id,opened)` tracking which user has a job open.

### Dual-Server Pattern

Writes go to both primary and backup via `OnBothServers`. Reads go to primary only via `OnPrimaryServer`. Server states: EMPTY -> PAUSED -> ACTIVE.

## Key Files

| File | Role |
|------|------|
| `tcl/server_commands.tcl` (1428 lines) | All RPC handlers -- the core business logic |
| `tcl/entry_menu.tcl` (719 lines) | Menu callbacks for experiment/job operations |
| `tcl/entry_appearance.tcl` | Appearance config; evals `~/.ghui_appearance` as raw Tcl |
| `tcl/read_appdef.tcl` | Parses `apps/*.def`; sets `relative_width`, `line_height`, `number_of_lines` |
| `tcl/entry_interface.tcl` | Main window; width = `screenwidth * relative_width` |
| `pkg/rpc_client.tcl` | Client-side RPC socket management |
| `pkg/run_on_servers.tcl` | `OnBothServers`/`OnPrimaryServer` dual-server orchestration |
| `vn1.4/tcl/navigation.tcl` (1605 lines) | Job editor tree UI with dual canvas |
| `apps/umui.def` | Column layout, UM version-to-editor mapping, window dimensions |

## Application Definition Format (`apps/*.def`)

```
<app_name> <app_base_dir>
ghui <ghui_base_dir>
Versions
<um_version> <vn_directory>    # e.g. "8.6 vn1.4"
END
Dimensions
RELATIVE_WIDTH .8
LINE_HEIGHT 32
NUMBER_OF_LINES 20
END
Columns
<name> <type> <title> <relx> <function> <filter_on> <default> [options...]
END
GHUI_Columns
<name> <type> <title> <relx> <function> <filter_on> <default> <max_width>
END
```

## User Configuration

`~/.ghui_appearance` on puma2 -- each line is `eval`'d as raw Tcl at startup. Key overrides:

```tcl
global relative_width
set relative_width 0.42    # window width fraction (default 0.8)
set fonts(lines) "helvetica 11"
set colours(select_bg) lightblue
```

## Deployment

Runs on puma2 (ARCHER2). Connection path: `local -> ssh bp14 -> tmux -> ssh -X archer2 -> ssh puma2 -> umui &`. X11 forwarding required. Source lives at `/home/n02/n02/umui/umui/ghui2.0/` on puma2.
