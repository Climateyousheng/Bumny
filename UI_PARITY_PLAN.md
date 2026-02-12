# UI Parity Plan (Legacy UMUI → UMUI Next)

This document captures **what users miss** when moving from legacy UMUI/GHUI (Tcl/Tk) to UMUI Next (web UI), and provides a **practical implementation plan** to close the gaps without derailing Phase 4c (editable Bridge).

## 1) What legacy UMUI exposed (user-visible “facilities”)

### 1.1 Entry screen menus (experiment/job browser)

Defined in `ghui2.0/tcl/entry_appearance.tcl`:

- **File**: Open read-only, Open read-write, Quit
- **Search**: Filter…, Reload
- **Experiment**: New…, Copy…, Delete, Download, Change description…, Make operational, Change ownership, Change privacy…, Access list…
- **Job**: New…, Copy…, Delete…, Force Close…, Change description…, Change identifier…, Upgrade version…, Difference
- **Help**: Introduction, General, File menu, Search menu, Experiment menu, Job menu, Changing fonts

### 1.2 Job editor navigation actions (bottom bar / help menu)

Driven by `windows/nav.buttons` in the application pack (example in this repo: `fixtures/app_pack/vn8.6/windows/nav.buttons`). Key actions:

- Check Setup
- Save
- Process (generate control files into `~/umui_jobs/<run-id>/`)
- Submit
- Import / Export
- Edit History
- Quit
- Help / Keyboard shortcuts

These are *not just UI decorations* — they are the completion path from “edited values” → “runnable UM job”.

## 2) What UMUI Next UI currently provides

Current routes (see `ui/src/router.tsx`):

- `/` experiments table (create/copy/delete)
- `/experiments/:expId` experiment detail + jobs table (create/copy/delete)
- `/experiments/:expId/jobs/:jobId` job detail (edit metadata, lock acquire/release)
- `/experiments/:expId/jobs/:jobId/bridge` Bridge editor (read-only window rendering)

Notable differences:

- No global **menubar**; actions are distributed across pages + “…” row menus.
- No single-screen “Explorer” (experiments with expandable jobs).
- Bridge lacks the legacy **action toolbar** (Check Setup, Save, Process, Submit, Import/Export, …).
- Bridge components are **read-only** (Phase 4b).
- Filtering is basic (client-side substring search) and only on experiments.

## 3) Gap analysis (why it “feels” missing)

### 3.1 Discoverability and workflow shape

Legacy users expect:

1) Open/read-only vs open/read-write is **explicit**.
2) There is always an obvious **next action** (Check Setup → Save → Process → Submit).
3) Bulk operations exist (selection + menu action).

UMUI Next currently requires deeper navigation and hides actions in per-row dropdowns. Even when the functionality exists (e.g., lock acquire), it is not located where the legacy mental model expects.

### 3.2 Missing parity primitives

Some legacy “facilities” are not implemented at all yet (end-to-end), e.g. Process/Submit/Jobsheet. Other items are partially present but not surfaced (force lock acquire).

### 3.3 A concrete bug that hurts trust

In `ui/src/components/jobs/job-table.tsx`, `job.opened` is a **string** but is treated as boolean. This makes “Locked/Available” misleading. Fixing this is a fast, high-impact improvement.

## 4) Recommended improvements (prioritized)

### P0 — Unblock Phase 4c and restore the legacy “shape”

1) **Bridge toolbar + edit mode**
   - Add top toolbar: Lock status, Acquire/Release (including “force acquire”), Edit toggle, Save, Reset, Help.
   - Make entry/check/basrad/table components editable only when in edit mode.
   - Save uses `PATCH /bridge/variables/{exp}/{job}`.

2) **Global menubar (or command palette)**
   - Implement `File/Search/Experiment/Job/Help` menus in the Header.
   - First pass can route to existing dialogs/pages and show “Not implemented yet” for missing features.

3) **Fix and improve job lock display**
   - Show `Opened by <user>` when `opened` is non-empty.
   - Add “Acquire lock” and “Open Bridge” actions directly from job rows.

### P1 — Reduce click depth / make browsing feel like UMUI

4) **Explorer view**
   - Add an optional single-page view with expandable experiments → jobs.
   - Support row selection (checkboxes) and bulk actions.

5) **Filtering (legacy-style)**
   - Add a filter drawer with structured filters (owner/version/privacy/description, plus job fields).
   - Start with client-side filtering; later move to server-side query params if needed.

### P2 — Restore “power user” capabilities

6) **Diff viewer**
   - Select two jobs → show structured diff of `.job` fields and basis variables.

7) **Hand-edit mode**
   - Raw basis file editor (read-only initially) + upload on save.

8) **Process / Submit integration**
   - Implement as HPC-side operations via SSH connector (Phase 5).
   - UI can already expose disabled buttons to mirror legacy workflows.

## 5) Implementation plan (step-by-step for an AI coding agent)

### Step 0 — Establish UI parity acceptance criteria

- Users can discover the same top-level action categories as legacy (menus or command palette).
- In Bridge: user can acquire lock, toggle edit mode, modify values, and save.
- After saving, the UI re-evaluates show/hide/disable logic (server-side eval) and updates rendering.
- Job table correctly reports lock owner.

### Step 1 — Fix job “locked” status display

Files:

- `ui/src/components/jobs/job-table.tsx`

Tasks:

- Treat `job.opened` as string: `const isLocked = job.opened.trim().length > 0`.
- Display badge text `Locked by <opened>`.
- Add a small “Acquire lock” button in row actions.

### Step 2 — Add a global menubar

Files:

- `ui/src/components/layout/header.tsx`
- New: `ui/src/components/layout/menu-bar.tsx`

Tasks:

- Implement `File/Search/Experiment/Job/Help` dropdown menus.
- Wire existing actions:
  - File → Reload: invalidate TanStack Query caches
  - Experiment → New: open create experiment dialog
  - Job → New: open create job dialog (contextual: only enabled on experiment page)
  - Help → About: open modal with links to RUNBOOK

For missing actions (download/make operational/upgrade version):

- Show disabled menu items with tooltip “Planned (Phase 5+)”.

### Step 3 — Bridge toolbar and edit mode (Phase 4c)

Files:

- `ui/src/components/bridge/window-panel.tsx`
- New: `ui/src/components/bridge/bridge-toolbar.tsx`
- `ui/src/components/bridge/component-renderer.tsx` and component implementations
- `ui/src/lib/api-client.ts` (add update variables)
- New hooks: `ui/src/hooks/use-bridge-mutations.ts` or extend `use-bridge.ts`

Tasks:

1) Implement `api.patchBridgeVariables(expId, jobId, updates)` that calls:
   - `PATCH /bridge/variables/{expId}/{jobId}` with body `{ updates: { VAR: "value", ... } }` (match API schema).
2) Build draft state:
   - Track edits locally (diff map) so Save is explicit (legacy semantics).
3) Add lock gating:
   - Show lock status in toolbar.
   - Allow “Force acquire” if lock owned by someone else.
4) Convert display components → editable variants:
   - Entry: `<Input>` editable with debounced draft update
   - Check: toggle variable to `on_value` / `off_value` (extend schema if needed)
   - Basrad: radio selection sets variable value
   - Table: for `element` columns, render per-cell input updating an array element
5) Save flow:
   - On Save: call patch endpoint with diff.
   - On success: clear diff; invalidate relevant queries:
     - `bridge.windowVariables(exp, job, win)`
     - `bridge.window(win, exp, job)` (to refresh active logic)
     - optionally `jobs` and `lock` queries

### Step 4 — Filtering + Explorer view

Files:

- New page: `ui/src/components/explorer/explorer-page.tsx`
- Router: add `/explorer` route, and optionally set as index.

Tasks:

- Expand/collapse experiments to show nested jobs.
- Add search + filter drawer.
- Add row selection + bulk actions.

### Step 5 — Tests

- Add unit tests (Vitest) for:
  - Job locked badge renders owner
  - Menubar enables/disables items based on route/context
- Add Playwright E2E for:
  - Create experiment → create job → open bridge → edit value → save

## 6) Notes for design

- Prefer **command palette** + menus for discoverability and speed.
- Keep Bridge layout visually close to legacy: nav tree on left, window on right, action bar at top/bottom.
- Always represent lock/ownership prominently; it is a core safety constraint.
