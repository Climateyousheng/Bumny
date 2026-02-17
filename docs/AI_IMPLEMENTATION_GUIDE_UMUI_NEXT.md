# UMUI Next — AI Implementation Guide

This document is a **step-by-step playbook** for an AI coding agent to design and implement “UMUI Next”: a modern rebuild of UMUI with long-term portability across HPC systems.

---

## 0) Context: what the legacy system does (functional model)

UMUI (legacy) provides:

1. **Experiment browser**
   - List/filter experiments from `<db>/<exp_id>.exp`.
   - Each experiment has a directory `<db>/<exp_id>/` containing jobs.

2. **Job browser**
   - List/filter jobs from `<db>/<exp_id>/<job_id>.job`.

3. **CRUD operations**
   - Create/copy/delete experiments and jobs.
   - Change description/owner/privacy/access lists.

4. **Multi-user locking**
   - Prevent concurrent edits of the same job.

5. **Job editor**
   - Loads a job “basis file” from the server, parses variables and registries.
   - Renders a navigation tree + dynamic panels defined by window-definition files.
   - Saves the basis file back and releases locks.

6. **Optional primary/backup mirroring**
   - Writes mirrored to both.

The legacy is Tcl/Tk + socket RPC + a file-backed “database”. The fastest durable replacement is to **keep the on-disk formats** and replace UI + transport.

---

## 1) Target outcomes and constraints

### 1.1 Product outcomes
- A modern UI (web-based) that runs locally on a user laptop.
- Works across multiple HPC sites via SSH.
- Keeps data compatible with existing UMUI databases.
- Multi-user safe (locking), with audit logs.

### 1.2 Operational constraints (HPC reality)
- No sudo; users can only install into `$HOME` or use modules.
- Inbound network ports are often blocked.
- X11 forwarding is fragile and slow.

### 1.3 Chosen approach
**Local UI + local API + SSH connector**.
- UI runs on laptop: browser.
- Local API: FastAPI (or equivalent) serving UI.
- Remote operations performed via SSH/SFTP.
- Optional: a tiny remote helper CLI invoked through SSH (no daemon).

---

## 2) Architecture (UMUI Next)

### 2.1 High level

```
+--------------------+        SSH/SFTP        +-------------------------+
| Local browser UI   | <--------------------> | Remote filesystem (HPC) |
+--------------------+                         +-------------------------+
         ^
         | HTTP (localhost)
         v
+--------------------+
| Local API (FastAPI)|
+--------------------+
         ^
         |
         v
+--------------------+
| Core library        |
| - parsers            |
| - locking            |
| - rules/validation   |
+--------------------+
```

### 2.2 Key design decisions

**A. Keep file formats**
- `.exp` and `.job` are alternating `field` / `value` lines.
- Database layout remains identical.

**B. Replace RPC server**
- Do not keep the Tcl socket RPC.
- Implement operations in `core` and execute on remote FS via SSH.

**C. Locking model (distributed via FS)**
- Use atomic remote operations to create lock directories:
  - `mkdir <db>/<exp>/<job>.lock/` is atomic on POSIX.
  - Store `owner`, `timestamp`, and `client_id` inside the lock dir.
  - Release lock by removing lock dir.
- Provide admin override for stale locks.

**D. Job editor strategy**
- Phase 1: “bridge mode” (reuse legacy parsing/export via Tcl + extensions).
- Phase 2: native parsing + native schema-to-UI pipeline.

---

## 3) Phase plan (deliver value early)

### Phase 0 — Inventory & extraction
**Goal:** obtain the missing “application pack” that defines UM panels, skeletons, and variable registers.

Tasks:
1. Identify the UMUI application directory on the canonical host (e.g. `/home/.../umui2.0/`).
2. Copy out (read-only) these directories:
   - `vn*/windows/` (`*.pan`, `*.inc`, `nav.spec`, `nav.buttons`)
   - `vn*/skeletons/` (`*.skel`)
   - `vn*/variables/` (`*.register`, `*.database`)
   - `vn*/help/` (`*.help`)
   - `apps/*.def`
3. Add them to a **private repo** `umui-app-pack/` (licensed content).
4. Create 2–3 “golden” job basis files for regression tests.

Deliverables:
- `app_pack/` directory with versioned content.
- `fixtures/` containing sample `.exp`, `.job`, and basis files.

### Phase 1 — Core CRUD + browsing
**Goal:** ship a usable replacement for the entry browser.

Features:
- List experiments, list jobs.
- Create/copy/delete experiment/job.
- Edit experiment/job metadata fields.
- Basic filtering and search.
- Lock acquisition/release for job open.

### Phase 2 — UI for browsing (web)
**Goal:** user-friendly interface without X11.

Features:
- Experiments table, jobs table.
- Filters (owner, access, substring/exact).
- Actions toolbar (new/copy/delete/open).

### Phase 3 — Job editing via bridge mode
**Goal:** enable editing without reimplementing the full legacy parser.

Approach:
- Bundle a minimal `tclsh` runtime + the `ghuiDatabase`/`GHUI_process` extensions (if licensing allows) OR rely on the existing installation.
- Implement a “bridge” command:
  - `umui-bridge export-json <basisfile> -> JSON`
  - `umui-bridge apply-json <basisfile> <JSON> -> new basisfile`
- UI edits JSON (typed forms) and the bridge writes back.

### Phase 4 — Native job editing
**Goal:** remove Tcl dependency.

Approach:
- Reimplement:
  - register/database parser
  - basis parser
  - expression evaluator (if required)
  - linking rules
- Convert window definitions (`*.pan`, `*.inc`, `*.skel`) into a JSON schema.

### Phase 5 — Hardening & migration
- Audit logs
- Backup/mirroring
- Packaging

---

## 4) Core data formats (spec)

### 4.1 `.exp` and `.job`
- Text files.
- Repeated pairs:
  - line 1: field name (string)
  - line 2: field value (string; may include spaces)

Parser requirements:
- Preserve unknown fields.
- Round-trip: write back exactly with `\n` line endings.

### 4.2 Database layout

```
<db>/
  <exp_id>.exp
  <exp_id>/
    <job_id>.job
    <job_id>            # basis file OR
    <job_id>.gz         # compressed basis file
```

### 4.3 Lock layout (UMUI Next)

```
<db>/<exp_id>/<job_id>.lock/
  owner.txt
  created_utc.txt
  client_id.txt
```

Atomicity:
- Acquire: `mkdir` lock dir; fail if exists.
- Release: remove files then `rmdir`.

Stale lock policy:
- If lock older than configurable threshold, allow admin override.

---

## 5) Implementation: packages and interfaces

### 5.1 `umui_core`
Modules:
- `formats/exp_job.py` — parse/write `.exp` and `.job`.
- `storage/layout.py` — path helpers, validation.
- `locking/locks.py` — lock acquire/release/stale detection.
- `ops/experiments.py` — CRUD.
- `ops/jobs.py` — CRUD.
- `auth/identity.py` — determine username (local) and remote user mapping.
- `audit/log.py` — append-only JSONL audit log.

### 5.2 `umui_connectors`
- `localfs.py` — operate on local filesystem (for tests).
- `sshfs.py` — SSH connector:
  - SFTP read/write
  - remote `mkdir`, `rm`, `mv` via `ssh` command execution when atomicity is required.

Important: implement **atomic remote write**:
1. Upload to `<path>.tmp.<uuid>`
2. `mv` to final path.

### 5.3 `umui_api` (local only)
- FastAPI endpoints:
  - `GET /targets` (configured HPCs)
  - `GET /experiments`
  - `GET /experiments/{exp}/jobs`
  - `POST /experiments` / `POST /jobs`
  - `PATCH /experiments/{exp}` / `PATCH /jobs/{exp}/{job}`
  - `POST /jobs/{exp}/{job}/lock`
  - `DELETE /jobs/{exp}/{job}/lock`
  - `GET /jobs/{exp}/{job}/basis` (download)
  - `PUT /jobs/{exp}/{job}/basis` (upload)

### 5.4 `umui_web`
- React + TypeScript.
- Use a table/grid component.
- Views:
  - Targets (HPC selection)
  - Experiments list
  - Jobs list
  - Job edit (Phase 3+)

---

## 6) Detailed step-by-step build instructions

### Step 1: Create repo skeleton
1. Initialise git repo.
2. Add `pyproject.toml` for `uv` and `ruff`.
3. Add `pnpm-workspace.yaml` + `ui/`.
4. Add CI (GitHub Actions) for tests + type-check.

### Step 2: Implement `.exp/.job` parsing + tests
1. Implement `parse_pairs_file(path) -> dict[str,str]`.
2. Implement `write_pairs_file(path, mapping)` preserving stable ordering.
3. Add tests:
   - empty file
   - missing value line error
   - round-trip with spaces

### Step 3: Implement storage layout
1. Implement helpers:
   - `exp_path(db, exp_id)`
   - `job_dir(db, exp_id)`
   - `job_meta_path(db, exp_id, job_id)`
   - `basis_path_candidates(db, exp_id, job_id)`
2. Validate `exp_id` and `job_id` against allowed patterns.

### Step 4: Implement SSH connector
1. Choose library (`asyncssh` recommended; fallback `paramiko`).
2. Implement:
   - `read_text(path)`
   - `write_text_atomic(path, content)`
   - `mkdir_atomic(path)`
   - `rm_tree(path)`
3. Add integration tests using a local temp dir backend.

### Step 5: Implement locking
1. `acquire_lock(exp, job, owner)`:
   - remote mkdir lockdir
   - write metadata files
2. `release_lock(exp, job, owner)`:
   - verify owner unless admin
   - delete lockdir
3. `get_lock_status(exp, job)`
4. Tests for concurrent lock attempts (simulate with localfs).

### Step 6: Implement CRUD operations
Experiments:
- `list_experiments` = glob `*.exp`, parse, sort.
- `create_experiment` = create `.exp` and directory, set permissions.
- `copy_experiment` = copy `.exp` + directory tree.
- `delete_experiment` = delete directory + `.exp`.

Jobs:
- `list_jobs` = glob `*.job`, parse.
- `create_job` = create `.job` + basis file from template.
- `copy_job` = copy `.job` + basis.
- `delete_job` = delete `.job` + basis.

### Step 7: Build API
- Implement endpoints mapping 1:1 to `core` ops.
- Add OpenAPI models and error handling.

### Step 8: Build UI (browse + CRUD)
- Implement target selection.
- Implement experiments table.
- Implement jobs table.
- Add dialogs for create/copy/delete.

### Step 9: Bridge-mode job editor
1. Implement a local wrapper that:
   - downloads basis file
   - runs `tclsh` script to export JSON (bridge)
   - UI edits JSON
   - runs `tclsh` script to apply JSON
   - uploads updated basis file
2. Start with minimal editing:
   - show raw key/value table of variables
   - allow change of scalar values

### Step 10: Native job editor
- Port parsers.
- Convert `*.pan` into JSON schema.
- Implement dynamic forms.

---

## 7) Testing & verification

### Golden tests
- Pick a set of real basis files.
- Export JSON via legacy bridge.
- Apply no-op import.
- Verify byte-identical output.

### Property tests
- Random `.exp/.job` mappings should round-trip.

### Concurrency tests
- Two lock attempts: one must fail.

---

## 8) Migration plan

1. Read-only pilot: browsing + list.
2. Enable CRUD.
3. Enable job open lock + download.
4. Enable bridge-mode edits for a small group.
5. Expand.
6. Replace legacy parser incrementally.

---

## 9) Acceptance criteria (definition of done)

Phase 1 done when:
- Can list experiments/jobs from an existing UMUI db.
- Can create/copy/delete exp/job.
- Locking prevents concurrent writes.

Bridge-mode done when:
- Can edit a job variable and save back without corrupting the basis file.

Native editor done when:
- Can edit the same set of panels/variables as legacy for vn1.4.
