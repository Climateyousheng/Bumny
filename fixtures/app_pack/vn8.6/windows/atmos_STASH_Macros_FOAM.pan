.winid "atmos_STASH_Macros_FOAM"
.title "FOAM Driving Macro"
.wintype entry

.panel
  .text "Specify the FOAM driving Macro." L
  .basrad "Choose mode" L 3 v OCBFOAM
	  "No Macro" 0
	  "Standard Macro" 1
	  "Development Macro" 2
  .case OCBFOAM!=0
    .block 1
       .gap
       .text "Specify times from the start of the run in hours" L
       .entry "Fields every  " L IFOAMF
       .entry "Starting (rainfall accumulations only)" L IFOAMS_R
       .entry "Starting (all other diagnostics) " L IFOAMS
       .entry "Ending        " L IFOAME
    .blockend
  .caseend
.panend


