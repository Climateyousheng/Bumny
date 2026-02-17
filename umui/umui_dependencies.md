# UMUI Dependencies & Installation Analysis

## Dependency Matrix

| Dependency | Required | On puma2 (RHEL 8.10) | On BP14 (Rocky 8.9) | Status |
|-----------|----------|-------------------|--------------------|--------|
| **Tcl** | 8.0+ (uses 8.3) | 8.3 custom + 8.6 system | 8.6 system | OK |
| **Tk** | 8.0+ (uses 8.3) | 8.3 custom + 8.6 system | **Not installed** | Issue on BP14 |
| **wish** | wish8.3 | Custom `/home/n02/n02/umui/bin/wish8.3` | **Not available** | Issue on BP14 |
| **ksh** | Korn shell (Configure script) | ksh93u+ | ksh93u+ | OK |
| **X11/libX11** | For GUI display | Installed | Installed | OK |
| **ANSI C compiler** | For building .sl extensions | gcc available | gcc available | OK |
| **libtcl8.3.so / libtk8.3.so** | Custom shared libs | Bundled in `/home/n02/n02/umui/lib/` | Not present | Bundled |
| **Ghuidatabase.sl / GHUI_process.sl** | C extension shared libs | Compiled, statically linked | Same binaries | OK (x86-64) |

## Current Deployment on puma2

UMUI ships its own self-contained Tcl/Tk 8.3 stack:

```
/home/n02/n02/umui/
├── bin/
│   ├── wish8.3          # Custom wish binary (ELF 64-bit x86-64)
│   ├── tclsh8.3         # Custom tclsh binary
│   └── expect, expectk  # Expect automation tools
├── lib/
│   ├── libtcl8.3.so     # Tcl 8.3 shared library
│   ├── libtk8.3.so      # Tk 8.3 shared library
│   ├── libexpect5.43.so
│   ├── tcl8.3/          # Tcl standard library
│   └── tk8.3/           # Tk standard library
└── umui/ghui2.0/        # GHUI source and config
```

wish8.3 runtime dependencies (from `ldd`):
- `libtk8.3.so` (bundled)
- `libtcl8.3.so` (bundled)
- `libX11.so.6` (system)
- `libdl.so.2` (system)
- `libm.so.6` (system)
- `libc.so.6` (system)

The .sl C extensions (`Ghuidatabase.sl`, `GHUI_process.sl`) are statically linked — no external dependencies beyond libc. Old versions from 2022/2023 are kept as backups with `.old-puma-2023` suffix.

## Compatibility Testing Results (2026-02-11)

### Tcl 8.6 Source Compatibility

**All UMUI Tcl source files parse without errors on Tcl 8.6.** Tested by launching with `/usr/bin/wish8.6` on puma2 — it sourced all `tcl/*.tcl` files and reached `entry_appearance` before failing on the expected X11 display issue (no DISPLAY set), not a Tcl syntax error.

### C Extension (.sl) Loading

**Both .sl libraries load successfully on Tcl 8.6:**
```
$ tclsh (8.6.8)
% load /path/to/Ghuidatabase.sl   → OK
% load /path/to/GHUI_process.sl   → OK (statically linked, no deps)
```

### Font Compatibility

**Tcl 8.6 accepts the XLFD font strings used throughout UMUI.** The font fix in `~/.ghui_appearance` (sourcing `~/ghuiFontsTcl8.5/dialog.tcl`) already handles Tcl 8.5+ font rendering differences by replacing XLFD strings with named fonts.

## Could UMUI Run on Modern Tcl 8.6?

**Likely yes**, with minor changes. The main risks are subtle API behaviour differences between 8.3 and 8.6 (string handling, encoding, trace command changes).

### Steps to Install on a New HPC System

1. **Install system Tcl/Tk** — `dnf install tcl tk` (provides wish8.6, tclsh8.6)
2. **Recompile the 2 .sl C extensions** against system Tcl headers (`tcl.h` from `tcl-devel` package)
3. **Update launcher** — change `bin/ghui` to point to system `wish` instead of custom `wish8.3`
4. **Apply font fix** — ensure `~/.ghui_appearance` uses named fonts instead of XLFD strings
5. **Test for 8.3 -> 8.6 behavioural differences** — key areas:
   - `string` command changes (8.4+ UTF-8 default)
   - `trace` command syntax (renamed in 8.4)
   - `package` command enhancements
   - `encoding` system differences
   - `regexp` Unicode support changes
6. **Verify X11 forwarding** — ensure libX11, libXft are available

### Why the Current Approach Works

The self-contained Tcl/Tk 8.3 bundle is robust because:
- No dependency on system Tcl/Tk version
- Won't break when OS upgrades
- Consistent behaviour across different HPC environments
- Only depends on standard system libs (libc, libX11, libdl, libm)

The tradeoff is running a 25+ year old Tcl/Tk interpreter with known font rendering issues on modern systems (hence the font fix workarounds).

## System Versions Reference

| System | OS | Tcl (system) | Tk (system) | Tcl (custom) |
|--------|-----|-------------|-------------|--------------|
| puma2 (ARCHER2) | RHEL 8.10 | 8.6.8 | 8.6.8 | 8.3.0 |
| BP14 | Rocky 8.9 | 8.6.8 | **Not installed** | N/A |
