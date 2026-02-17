# UMUI Installation Feasibility on Eocene

## Eocene System Profile

| Component | Value |
|-----------|-------|
| Hostname | eocene.ggy.bris.ac.uk |
| OS | CentOS 6.10 (Final) |
| Kernel | 2.6.32-754.35.1.el6.x86_64 |
| glibc | 2.12 (max GLIBC_2.12) |
| Tcl (system) | 8.5.7 |
| Tk (system) | 8.5.7 |
| Tcl (Anaconda) | 8.6.8 (`/opt/bridge/CentOS6-64/python/anaconda-2019.10-3.7/bin/`) |
| wish | wish8.5 (system), wish8.6 (Anaconda) |
| ksh | ksh93u+ |
| gcc | 4.4.7 |
| tcl-devel | 8.5.7 (headers at `/usr/include/tcl.h`) |
| tk-devel | 8.5.7 |
| X11 | libX11-1.6.4, X11 forwarding works |
| Shared lib ext | `.so` |
| Home dir | `/home/bridge/nd20983` (writable, 41GB free) |

## Dependency Comparison

| Dependency | Puma2 (RHEL 8.10) | Eocene (CentOS 6.10) | Compatible? |
|-----------|-------------------|----------------------|-------------|
| glibc | 2.28 | 2.12 | **NO** -- puma2 binaries won't run |
| Tcl | 8.3 custom + 8.6 system | 8.5 system + 8.6 Anaconda | OK (Tcl code parses fine) |
| Tk | 8.3 custom + 8.6 system | 8.5 system + 8.6 Anaconda | OK |
| wish | wish8.3 custom | wish8.5 + wish8.6 | OK (need to update launcher) |
| ksh | ksh93u+ | ksh93u+ | OK |
| X11 | libX11-1.6.8 | libX11-1.6.4 | OK |
| Shared lib ext | `.sl` (HP-UX convention) | `.so` (Linux standard) | **NO** -- pkgIndex.tcl references `.sl` |
| C extensions (.sl) | Compiled for glibc 2.28 | Needs glibc 2.12 | **NO** -- must recompile |

## What Works Without Changes

The **pure Tcl components** would run on eocene's wish8.5 or Anaconda wish8.6:

- Entry system (experiment/job browser) -- `tcl/entry.tcl`
- Server -- `tcl/server.tcl`
- Admin client -- `tcl/admin.tcl`
- RPC client/server -- `pkg/rpc_client.tcl`, `pkg/rpc_server.tcl`
- All menu operations, filtering, dialogs
- User configuration via `~/.ghui_appearance`

These are ~8,000 lines of pure Tcl with no C dependencies.

## What Doesn't Work

The **job editor** (`vn1.4/`) requires two C extension shared libraries:

| Library | Purpose | Symbols |
|---------|---------|---------|
| `Ghuidatabase.sl` | Variable database parsing | `add_link`, `add_name`, `calc`, `decode_value`, `backup_variable`, `clear_databases`, etc. |
| `GHUI_process.sl` | Process management | `append_output`, `increase_output_size`, `Ghui_process_Init` |

These are loaded via `package require` in `vn1.4/pkg/pkgIndex.tcl`:
```tcl
package ifneeded GHUI_process 1.1 [list load [file join $dir GHUI_process.sl]]
package ifneeded ghuiDatabase 1.1 [list load [file join $dir Ghuidatabase.sl]]
```

### Why They Can't Be Copied From Puma2

1. **glibc 2.28 vs 2.12** -- the puma2 .sl binaries are linked against glibc 2.28, eocene only has 2.12. They would fail to load with symbol errors.
2. **`.sl` vs `.so` naming** -- eocene's Tcl expects `.so` extensions. The `pkgIndex.tcl` would need updating to reference `.so` files.

### Why They Can't Be Easily Recompiled

**The C source code is not included in the GHUI distribution.** The `vn1.4/src/` directory does not exist on puma2. Only pre-compiled binaries are distributed. The Tcl 8.3 source tree exists at `/home/n02/n02/umui/src/tcl8.3.0/` but that's the interpreter source, not the GHUI extensions.

## Installation Path (If Attempted)

### Minimal (Entry System Only)

1. Copy `ghui2.0/` to eocene
2. Edit `bin/ghui`:
   ```bash
   WISH_EXE=/usr/bin/wish8.5   # or Anaconda wish8.6
   TCLSH_EXE=/usr/bin/tclsh    # for server
   ```
3. The experiment browser, server, and admin client would work
4. Job editing would fail when it tries to load the C extensions

### Full (With Job Editor)

Everything above, plus:

4. Obtain the C source for `Ghuidatabase` and `GHUI_process` (ask the UMUI maintainers / Met Office)
5. Compile on eocene:
   ```bash
   gcc -shared -fPIC -o Ghuidatabase.so Ghuidatabase.c -I/usr/include -ltcl8.5
   gcc -shared -fPIC -o GHUI_process.so GHUI_process.c -I/usr/include -ltcl8.5
   ```
6. Update `vn1.4/pkg/pkgIndex.tcl` to reference `.so` instead of `.sl`
7. Apply font fix in `~/.ghui_appearance` for wish8.5/8.6

## Existing Infrastructure on Eocene

Eocene has BRIDGE group tools at `/home/bridge/swsvalde/`:
- `convsh`, `bin`, `dumps`, `ancil`
- CMIP5/6 data directories
- No existing UMUI or GHUI installation found

## Verdict

**Partially feasible.** The entry system and server would work out of the box with a wish path change. The job editor is blocked by missing C source code for two shared libraries. The OS is also very old (CentOS 6, EOL since 2020) which adds general risk.
