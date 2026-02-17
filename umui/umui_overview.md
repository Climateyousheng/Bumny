# UMUI/GHUI Codebase Overview

## What is UMUI?

UMUI (Unified Model User Interface) is built on **GHUI** (Generic Hierarchical User Interface), a Tcl/Tk client-server framework for managing climate model experiments and jobs. Written in the early 2000s, it runs on **wish8.3** (Tcl/Tk 8.3) and is deployed on ARCHER2's puma2 server.

**Total codebase:** ~450 files, 3.9MB, ~8,000 lines of core Tcl in `tcl/`, plus version-specific job editor code in `vn1.X/`.

---

## Directory Structure

```
ghui2.0/
├── apps/          # Application definition files (umui.def, varui.def, etc.)
├── bin/           # Launcher scripts (ghui, ghui_admin, ghui_server, etc.)
├── doc/           # Documentation (.tex, .html)
├── help/          # Help files (.help)
├── icons/         # X11 bitmap icons (.xbm)
├── Install/       # Installation system and templates
├── pkg/           # Tcl packages (RPC client/server)
├── tcl/           # Core GHUI source (44 files, ~8,009 lines)
├── tcl.orig/      # Backup of original tcl/
├── vn1.1/         # Job editor for UM versions 4.0-4.5
├── vn1.2/         # Job editor for UM version 5.4
└── vn1.4/         # Job editor for UM versions 6.1-8.6 (latest)
```

---

## Architecture

### Client-Server Model

```
┌─────────────────────────────────────────────────┐
│                                                 │
│  ┌──────────────┐       ┌──────────────┐       │
│  │ Entry Client │       │ Admin Client │       │
│  │  (wish)      │       │   (wish)     │       │
│  │ entry.tcl    │       │ admin.tcl    │       │
│  └──────┬───────┘       └──────┬───────┘       │
│         │    RPC over sockets  │               │
│         │      (port 8407)     │               │
│  ┌──────▼──────────────────────▼──────┐        │
│  │    Database Server (tclsh)         │        │
│  │      server.tcl                    │        │
│  │  ┌──────────┐   ┌──────────────┐  │        │
│  │  │ Primary  │◄─►│   Backup     │  │        │
│  │  │ (ACTIVE) │   │   (PAUSED)   │  │        │
│  │  └──────────┘   └──────────────┘  │        │
│  └────────────────────────────────────┘        │
│                                                 │
│  ┌────────────────────────────────┐            │
│  │ Job Editor Clients (wish)      │            │
│  │   edit_job.tcl + navigation    │            │
│  │   One per open job             │            │
│  └────────────┬───────────────────┘            │
│               │ Read/Write basis files         │
│               ▼                                │
│  ┌────────────────────────────────┐            │
│  │   Database Directory           │            │
│  │   /{exp_id}.exp                │            │
│  │   /{exp_id}/{job_id}.job       │            │
│  │   /{exp_id}/{job_id}[.gz]      │            │
│  └────────────────────────────────┘            │
└─────────────────────────────────────────────────┘
```

### Startup Flow

1. **`bin/ghui`** -- Shell launcher, invokes `wish8.3` with `entry.tcl`
2. **`entry.tcl`** -- Parses args, sets user/group, calls `source_and_setup`
3. **`source.tcl`** -- Auto-sources every `*.tcl` in `tcl/` directory
4. **`read_appdef.tcl`** -- Reads `apps/umui.def` for columns, directories, dimensions
5. **`entry_appearance.tcl`** -- Sets colours, fonts, icons, menus; evals `~/.ghui_appearance`
6. **`entry_interface.tcl`** -- Draws main window: `width = screenwidth * relative_width`

---

## Core Source Files (`tcl/`)

### Entry System (Main GUI)

| File | Lines | Purpose |
|------|-------|---------|
| `entry.tcl` | 60 | Entry point -- sets user, sources code, draws UI |
| `entry_interface.tcl` | 109 | Main window layout, menu bar |
| `entry_menu.tcl` | 719 | Menu callbacks -- new/copy/delete experiments & jobs, diff |
| `entry_appearance.tcl` | 108 | Visual config -- colours, fonts, icons, user overrides |
| `entry_filter.tcl` | 148 | Filter dialog |
| `draw_list.tcl` | 351 | Renders experiment/job list, selection handling |

### Server Components

| File | Lines | Purpose |
|------|-------|---------|
| `server.tcl` | -- | Server main loop, RPC init, `vwait forever` |
| `server_commands.tcl` | 1428 | All RPC handlers -- CRUD for experiments/jobs, filtering, locking |
| `server_log.tcl` | -- | Timestamped logging |

### Database Operations

| File | Purpose |
|------|---------|
| `gather_details.tcl` | Read experiments/jobs from database files |
| `save_details.tcl` | Write experiments/jobs, permission checks |
| `job.tcl` | Job object constructor/destructor |
| `open_job.tcl` | Spawns job editor (separate wish process) |

### Configuration & Utilities

| File | Purpose |
|------|---------|
| `source.tcl` | Bootstrap loader -- sources all tcl files |
| `read_appdef.tcl` | Parses `apps/*.def` files, sets defaults |
| `shared_globals.tcl` | Global config (port number) |
| `small_dialogs.tcl` | Info boxes, confirmations, text input dialogs |
| `small_utils.tcl` | String manipulation, file path utilities |
| `dialog.tcl` | Generic dialog box framework |
| `scroll_win.tcl` | Scrollable window widget |
| `filter_window.tcl` | Filter UI components |
| `show_help.tcl` | Help file viewer |

### Admin Interface

| File | Purpose |
|------|---------|
| `admin_interface.tcl` | Admin GUI layout |
| `admin_commands.tcl` | Server management, database copy, status toggle |
| `admin_dialogs.tcl` | Admin-specific dialogs |

---

## RPC Protocol (`pkg/`)

### Message Format

```
Client -> Server:  [byte_length]\n[command_string]
Server -> Client:  [byte_length]\n[result_data]
                   or [-1]\n[error_message]  (error)
```

### Available RPC Commands

**Experiment operations:** `send_experiment_list`, `create_new_experiment`, `delete_experiment`, `copy_experiment`, `change_experiment_description`, `changeExperimentOwner`, `change_experiment_privacy`, `change_access_list`, `make_experiment_operational`

**Job operations:** `send_job_list`, `create_new_job`, `delete_job`, `copy_job`, `change_job_description`, `change_job_id`, `load_job`, `save_job`, `close_job`, `force_close_job`

**Server management:** `server_set_type`, `server_get_type`, `server_set_status`, `server_get_status`, `halt_server`, `reload_all`, `clear_log`, `list_open_jobs`, `tail_log`

### Dual-Server Write Pattern

```tcl
proc OnBothServers {command args} {
  # Execute on primary, then mirror to backup
  set result [RPC $primary $command $vals]
  if {$backup != "NONE"} { RPC $backup $command $vals }
  return $result
}
```

---

## Application Definition (`apps/umui.def`)

Defines the UMUI-specific configuration:

```
Versions:  UM 4.0->vn1.1, 5.4->vn1.2, 6.1-8.6->vn1.4
Dimensions: RELATIVE_WIDTH=0.8, LINE_HEIGHT=32, NUMBER_OF_LINES=20
Columns:   id, owner, description, version, atmosphere, ocean, access_list
```

Column types: `string` (text filter) or `option` (radio button filter).

---

## Version Directories (`vn1.1/`, `vn1.2/`, `vn1.4/`)

Each contains the **job editor** UI code for specific UM versions. The job editor is a separate wish process spawned when a user opens a job.

### Key Job Editor Files (`vn1.4/tcl/`)

| File | Lines | Purpose |
|------|-------|---------|
| `navigation.tcl` | 1605 | Hierarchical tree with dual canvas (left=tree, right=panels) |
| `edit_job.tcl` | 111 | Job editor entry point |
| `window_end.tcl` | 523 | Close/Next/Quit buttons, save logic |
| `simple_components.tcl` | 375 | Basic UI widgets (text, entry, checkbox, radio) |
| `parseWindow.tcl` | 514 | Parses window definition files |
| `handle_case.tcl` | 534 | Conditional show/hide of fields |
| `print_window.tcl` | 578 | Export job config to text |
| `compare_jobs.tcl` | 415 | Side-by-side job comparison |

---

## Data Model

### Experiments

```tcl
experiments(list)                    # All experiment IDs
experiments($id,owner)               # Username
experiments($id,description)         # Text description
experiments($id,privacy)             # Y/N
experiments($id,access_list)         # Allowed users
experiments($id,joblist)             # List of job IDs
```

### Jobs

```tcl
jobs($expid$jobid,version)           # UM version (e.g. "8.6")
jobs($expid$jobid,description)       # Text description
jobs($expid$jobid,opened)            # "N" or username (lock)
```

### Job Variables (basis file)

```
EXPT_ID xqjca
JOB_ID a
ATMOS_TIMESTEP 1800
...
```

---

## User Configuration

### `~/.ghui_appearance` (on puma2)

Lines are raw `eval`'d by Tcl at startup. Can override any appearance variable:

```tcl
# Fonts
option add *font "helvetica 12"
set fonts(lines) "helvetica 11"

# Window width (default 0.7 from umui.def's 0.8, overridden to 0.42)
global relative_width
set relative_width 0.42
```

### Key Overridable Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `relative_width` | 0.8 (umui.def) | Window width as fraction of screen |
| `line_height` | 32 | Pixel height per row |
| `number_of_lines` | 20 | Initial visible rows |
| `maxlines` | 25 | Maximum visible rows |
| `colours(*)` | Various | UI colour scheme |
| `fonts(*)` | Lucida/Helvetica | Font specifications |

### Environment Variables

| Variable | Purpose |
|----------|---------|
| `UMUI_FILTER_EXACT` | `1`=exact match, `0`=substring (default) |

---

## Key Design Patterns

1. **Client-server with RPC** -- GUI clients talk to database server over sockets. Server manages state and locking.
2. **Dual-server replication** -- Primary + backup. All writes mirrored. Admin can switch roles.
3. **Job locking** -- Server tracks who has a job open read/write. Prevents concurrent edits.
4. **Privacy & access control** -- Experiments can be private with explicit access lists.
5. **Grid-based UI** -- Experiments rendered as rows of labels with `place -relx`. No tree/table widgets.
6. **Eval-based user config** -- `~/.ghui_appearance` lines executed as raw Tcl. Powerful but unsandboxed.
7. **Version-mapped job editors** -- Different UM versions get different editor UIs via `vn1.X/` directories.
8. **Text-based database** -- Simple `.exp` and `.job` files. No SQL or binary formats.

---

## Server States

| State | Description |
|-------|-------------|
| EMPTY | Started, database not loaded |
| PAUSED | Database loaded, not accepting changes |
| ACTIVE | Accepting client connections |
| RELOAD | Re-reading database from disk |

---

## Data Flow: Opening a Job

```
User selects job -> menu_open_rw()
  -> find_selections() gets selected job ID
  -> start_job_edit() spawns new wish process
    -> edit_job.tcl sources code, calls navigation()
    -> RPC load_job to server
      -> Server checks lock, sets opened=$user
      -> Returns basis file contents
    -> Job editor parses variables, builds tree UI
    -> User edits variables in form windows
    -> On close: RPC save_job to server
      -> Server writes basis file, releases lock
```

---

## File Locations on puma2

| Purpose | Path |
|---------|------|
| GHUI base | `/home/n02/n02/umui/umui/ghui2.0/` |
| UMUI app | `/home/n02/n02/umui/umui/umui2.0/` |
| wish interpreter | `/home/n02/n02/umui/bin/wish8.3` |
| Launcher | `/home/n02/n02/p2local/bin/umui` |
| User config | `~/.ghui_appearance` |
