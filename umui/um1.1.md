# UMUI Project Notes

## Project Overview

UMUI = Unified Model User Interface. Tcl/Tk client-server app on puma2 (ARCHER2).
Repo: `/Users/nd20983/Library/CloudStorage/OneDrive-UniversityofBristol/Documents/Github/umui`
Live source on puma2: `/home/n02/n02/umui/umui/`

## Active UM Version

User works primarily with **UM 4.5** → job editor **vn1.1**.
Job `xqfqh` confirmed: `VN=4.5`, created by UMUI 4.5.1.
The vn1.4 (UM 6.1-8.6) documentation is present but NOT what user works with day-to-day.

## Repository Structure

```
ghui2.0/          ← this repo (GHUI framework only)
  tcl/            ← core framework (entry, RPC, server, admin) ~8,000 lines
  vn1.1/          ← job editor for UM 4.0-5.0 (USER'S PRIMARY)
  vn1.4/          ← job editor for UM 6.1-8.6 (less relevant to user)
  apps/umui.def   ← column/version/dimension config
  pkg/            ← GHUIserver RPC package
```

Panel files (.pan) are NOT in this repo. They live on puma2:
- `umui2.0/vn4.5/windows/` — UM 4.5 panels (confirmed path)
- `umui2.0/` — contains vn4.0.1 through vn8.6

## Remote Access

tmux session on bp14: session named `puma2`
Connection chain: local → ssh bp14 → tmux → ssh archer2 → ssh puma2
To run commands on puma2: `ssh bp14 "tmux send-keys -t puma2 'COMMAND' Enter"`

## vn1.1 Architecture

Job editor flow:
`edit_job.tcl` → `source.tcl` → `get_basis_file()` → `load_variables()` → `partition_info()` → `navigation()`

Key files in `vn1.1/tcl/`:
- `navigation.tcl` (1597 lines) — dual canvas tree UI
- `parse_window.tcl` (411 lines) — parses .pan files
- `handle_case.tcl` (534 lines) — .case/.colour/.invisible
- `partitions.tcl` (149 lines) — partition.database management
- `pkg/mplb.tcl` (2607 lines) — PLB table widget

## Submodels (umui.def Columns)

| Name | Type | Options |
|------|------|---------|
| atmosphere | multi-option | Global, Limited Area, Single Column |
| ocean | multi-option | Global, Limited Area, NEMO |
| slab | binary Y/N | slab ocean on/off |
| mesoscale | binary Y/N | mesoscale on/off |

## nav.spec Structure (UM 4.5)

Top-level tree nodes:
1. Model Selection
   - User Information & Target Machine
   - Sub-Model Independent (compile, sections, postproc, job submission)
   - Sub-Model Configurations & Coupling (smcc)
   - Atmosphere (domain, science, ancils, STASH, control)
   - Ocean GCM (domain, science, ancils, STASH, control)
   - Slab Ocean
   - Wave Model

Panel naming convention: `{submodel}_{Category}_{Subcategory}[_{Detail}].pan`
e.g. `atmos_Science_Section_BLay.pan`, `ocean_InFiles_PAncil_SstSss.pan`

## See Also

- `umui_overview.md` — broad architecture overview
- `CLAUDE.md` — project instructions (focused on vn1.4, less relevant)
- `eocene_feasibility.md` — feasibility study for eocene runs
