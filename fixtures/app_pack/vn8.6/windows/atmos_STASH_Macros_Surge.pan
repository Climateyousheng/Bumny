.winid "atmos_STASH_Macros_Surge"
.title "Driving an external surge model"
.wintype entry

.panel
  .text "Specify the macro for driving an external surge model" L
  .basrad "Choose mode" L 3 v OCBIS
	  "No Macro" 0
	  "Standard Macro" 1
	  "Development Macro" 2
  .case OCBIS!=0
    .block 1
       .gap
       .text "Specify times from the start of the run in hours" L
       .entry "Fields every  " L ISURF
       .entry "Starting      " L ISURS
       .entry "Ending        " L ISURE
       .entry "Splitting the file at  " L ISURA
    .blockend
  .caseend
.panend


