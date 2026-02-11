.winid "atmos_STASH_Time"
.title "STASH Time profiles."
.loop PROFILE 1 NTPROF_A
.wintype entry

.comment ======================================================================
.comment  When adding/removing profile variables, remember to change the
.comment  list in stash.tcl that perform functions to copy/remove profiles.
.comment ======================================================================

.panel
  .include gen_STASH_Time A %PROFILE
.panend
