.winid "jules_Science_Section_Snow"
.title "JULES Section 3: Snow"
.wintype entry

.panel
  .gap
  .case JULES=="T"
    .block 1
      .entry "Maximum number of layers in the snowpack" L NSMAX 15
      .case BLCANOPY == "4"
        .check "Use the equivalent canopy snow depth in surface calculations" L JL_SNOWDEPS Y N
      .caseend
    .gap
    .blockend
  .caseend
.panend
