.winid "atmos_Science_Section_River"
.title "Section 26 : River Routing"
.wintype entry
.panel
	.gap
	.basrad "Choose version" L 3 v ATMOS_SR(26)
	  "<0A> Not Used" 0A
	  "<1A> Global Model"  1A
	  "<2A> Limited Area Model" 2A
	.gap  
	.case ATMOS_SR(26)=="1A"
      .check "Re-routing inland basin water back to soil moisture" L LINLAND Y N
      .gap 
      .block 1
	  .entry "River Routing Timestep  ( sec )"   L ATMOS_RV_DAYS 12
	  .entry "Effective Velocity      ( m/sec )" L ATMOS_RV_EVEL 12
	  .entry "Meander Ratio                    " L ATMOS_RV_MRAT 12
	  .blockend
	.caseend
	.gap
	.textw "Push ANC_1A to specify 'Ancil River' files for <1A> scheme" L
    .textw "Push ANC_2A to specify 'Ancil River' files for <2A> scheme" L
	.pushnext "ANC-1A" atmos_InFiles_PAncil_RivRout
    .pushnext "ANC-2A" atmos_InFiles_PAncil_RivLoc
.panend

