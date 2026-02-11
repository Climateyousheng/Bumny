.winid "atmos_STASH_Macros_Wave"
.title "Driving an external wave model"
.wintype entry

.panel
  .text "Specify the macro for driving an external wave model" L
  .basrad "Choose mode" L 3 v OCBIW
	  "No Macro" 0
	  "Standard Macro" 1
	  "Development Macro" 2
  .case OCBIW!=0
    .block 1
       .gap
       .text "Specify times from the start of the run in hours" L
       .entry "Fields every  " L IWAVF
       .entry "Starting      " L IWAVS
       .entry "Ending        " L IWAVE
       .entry "Splitting the file at  " L IWAVA
    .blockend
  .caseend
.panend


