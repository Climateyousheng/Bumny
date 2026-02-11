.winid "atmos_STASH_Macros_River"
.title "River Flow Model Macro"
.wintype entry

.panel
  .text "Specify the macro for the driving CEH's River Flow Model externally" L
  .basrad "Choose mode" L 2 v IRIVER
	  "No Macro" 0
	  "Standard Macro" 1
  .case IRIVER=="1"
    .textw "Specify meaning period and output times from the start of the run in timesteps:" L
    .block 1
      .entry "Meaning Period (RFM timestep):" L IRIVMEAN 15
      .entry "Output starting:" L IRIVSTRT 15
      .entry "Output ending:" L IRIVEND 15
    .blockend
  .caseend
.panend


