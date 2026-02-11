.winid "atmos_STASH_Macros_Test"
.title "Production of standard test diagnostics"
.wintype entry

.panel
  .text "Specify the macro for standard test diagnostics" L
  .basrad "Choose mode" L 3 v OCBIT
	  "No Macro" 0
	  "Standard Macro" 1
	  "Development Macro" 2
  .gap
  .textw "These diagnostics are for use in testing the diagnostic system" L
  .textw "They come out on unit 62 and can be used to test post processing" L
  .textw "packages. Fields with values calculated from each point's latitude" L
  .textw "and longitude position and vertical level are produced in accordance" L
  .textw "with UMDP D7." L
.panend


