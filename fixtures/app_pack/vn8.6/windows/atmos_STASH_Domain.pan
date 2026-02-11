.winid "atmos_STASH_Domain"
.title "Domain profile specification (Levels)"
.wintype entry
.loop PROFILE 1 NDPROF_A
.comment ======================================================================
.comment  When adding/removing profile variables, remember to change the
.comment  list in stash.tcl that perform functions to copy/remove profiles.
.comment ======================================================================

.panel
  .include atmos_STASH_Domain A %PROFILE
.panend




