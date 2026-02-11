.winid "atmos_Science_Section_UKCA_LBC"
.title "Section 37 : UKCA LBCs"
.wintype entry
.panel
	.gap
	.invisible OCAAA==1
	  .textw "Note: LBC tracers cannot be used because the global model is currently in use" L
	.invisend
	.basrad "Choose version" L 2 v ATMOS_SR(37)
	  "<0A> Not Used" 0A
	  "<1A> UKCA LBCs"  1A
	.gap  
	.textw "Push UKCA_LBCs to specify UKCA LBC Tracers" L
        .textw "Push UKCA to go to the parent window" L
    .pushnext "UKCA_LBCs" atmos_Config_Tracer_UKCA
    .pushnext "UKCA" atmos_Science_Section_UKCA
.panend

