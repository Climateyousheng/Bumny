.winid "subindep_Control"
.title "Control"
.wintype entry

.panel
   .check "Use 360 day calendar" L CAL360 Y N
   .gap
   .invisible INDEP_SR(97)=="4A"
      .textw "Timer diagnostic section is not chosen. Diagnostics not possible" L
   .invisend
   .invisible INDEP_SR(97)!="4A"
      .textw "Timer diagnostic section is chosen. Diagnostics are possible" L
   .invisend
   .case INDEP_SR(97)!="4A"
     .check "Subroutine timer diagnostics" L TIMER Y N
   .caseend
   .gap
   .check "Using your own STASHmaster directory on the target machine." L L_SMDIR Y N
   .case L_SMDIR=="Y"
     .block 1
       .entry "Define the directory holding a full set of STASHmaster files"   L SMDIR
     .blockend
   .caseend
   .gap
.panend




