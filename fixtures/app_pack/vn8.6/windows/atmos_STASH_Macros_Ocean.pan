.winid "atmos_STASH_Macros_Ocean"
.title "Driving an external ocean model"
.wintype entry

.panel
   .text "Specify the macro for driving an external ocean model" L
  .basrad "Choose mode" L 3 v OCBIO
	  "No Macro" 0
	  "Standard Macro" 1
	  "Development Macro" 2
  .case OCBIO!=0
    .block 1
       .gap
       .text "Specify times from the start of the run in hours" L
       .entry "Fields every  " L IOCNF
       .entry "Starting      " L IOCNS
       .entry "Ending        " L IOCNE
    .blockend
  .caseend
.panend


