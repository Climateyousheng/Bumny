.winid "atmos_Science_Section_Energy"
.title "Section 14 : Energy Adjustment"
.wintype entry

.panel
  .basrad "Choose the relevant section release" L 2 v ATMOS_SR(14)
          "Energy adjustment not included" 0A
          "<1B> Standard energy adjustment included" 1B
  .case ATMOS_SR(14)!="0A"
    .entry "Number of hours between successive calls" L ENGTS
    .check "Including dry mass correction" L LMASS_CORR T F
    .check "Including additional diagnostic printout" L LEMQ_PRINT T F
  .caseend
.panend


