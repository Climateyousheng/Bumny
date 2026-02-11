.winid "atmos_STASH_Usage"
.title "STASH Usage profile."
.loop PROFILE 1 NUPROF_A
.wintype entry

.comment ======================================================================
.comment  When adding/removing profile variables, remember to change the
.comment  list in stash.tcl that perform functions to copy/remove profiles.
.comment ======================================================================

.panel
   .include gen_STASH_Usage A %PROFILE 1
.panend



