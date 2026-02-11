.winid "atmos_Science_Section_Tra_LBC"
.title "Section 36 : Tracer LBCs"
.wintype entry
.panel
	.gap
	.invisible OCAAA==1
	  .textw "Note: LBC tracers cannot be used because the global model is currently in use" L
	.invisend
	.basrad "Choose version" L 2 v ATMOS_SR(36)
	  "<0A> Not Used" 0A
	  "<1A> Lateral Boundary Condition"  1A
	.gap  
	.textw "Push TRA_LBCs to specify LBC Tracers" L
    .pushnext "TRA_LBCs" atmos_Config_Tracer
.panend

