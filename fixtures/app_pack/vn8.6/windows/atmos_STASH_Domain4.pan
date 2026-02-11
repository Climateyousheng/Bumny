.winid "atmos_STASH_Domain4"
.title "Domain Profile Specification (Timeseries)"
.wintype entry
.comment ======================================================================
.comment  When adding/removing profile variables, remember to change the
.comment  list in stash.tcl that perform functions to copy/remove profiles.
.comment ======================================================================

.panel
  .include gen_STASH_Domain4 A
  .pushnext "LEVS" atmos_STASH_Domain
  .pushnext "PSEUDO" atmos_STASH_Domain2
  .pushnext "HORIZ" atmos_STASH_Domain3
.panend


