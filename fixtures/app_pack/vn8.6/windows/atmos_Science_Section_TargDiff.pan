.winid "atmos_Science_Section_TargDiff"
.title "Section 13 : Targeted Diffusion of moisture"
.wintype entry

.panel
   .invisible ATMOS_SR(13)!="0A"
     .textw "When Targeted Diffusion is enabled, set the variables." L
   .invisend 
   .invisible ATMOS_SR(13)=="0A"
     .textw "Targeted Diffusion is not enabled." L
   .invisend 
   .gap
   .case ATMOS_SR(13)!="0A"
     .check "Targeted diffusion of moisture" L TDIFFOPT T F
	 .block 1
	 .case TDIFFOPT=="T"
	   .entry "Targeted diffusion factor" L TDFFACTOR
	   .entry "Targeted diffusion vertical velocity test value" L TDFCONVLIM
	   .entry "Targeted diffusion test start level" L TDFTESTSTART
	   .entry "Targeted diffusion apply start level" L TDFAPPSTART
	   .entry "Targeted diffusion apply end level" L TDFAPPEND
       .entry "Horizontal level to switch off steep slope diffusion" L TDHORIZ
	 .caseend  
	 .blockend  
	 .gap
   .caseend   
   .textw "Push DIAG_PRN to specify diagnostic print" L
   .textw "Push DIFF to go to the Diffusion & Filtering main window" L
   .pushsequence "DIAG_PRN" atmos_Science_Section_DiagPrn
   .pushnext "DIFF" atmos_Science_Section_DiffFilt
.panend
