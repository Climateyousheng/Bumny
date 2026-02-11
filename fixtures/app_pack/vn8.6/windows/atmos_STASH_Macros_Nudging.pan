.winid "atmos_STASH_Macros_Nudging"
.title "Nudging Macro"
.wintype entry

.panel
  .invisible ATMOS_SR(39)=="0A"
    .textw "NOTE: Nudging code is not in use.  This macro is NOT required" L
  .invisend
  .invisible ATMOS_SR(39)!="0A"
    .textw "NOTE: Nudging code is in use.  This macro is required" L
  .invisend
   .block 1
    .text "Specify the macro for Nudging:" L
    .block 2
      .basrad "Choose mode" L 2 v INDG
	  "No Macro" N
	  "Nudging Macro" Y
      .blockend
    .blockend
.panend
