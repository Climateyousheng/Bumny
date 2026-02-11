.winid "atmos_Assim_General"
.title "Assimilation General"
.wintype entry

.panel
  .basrad "Choose the relevant section release" L 2 v ATMOS_SR(18)
	  "No data assimilation or temporal filtering" 0A
	  "<2A> Data assimilation or temporal filtering included" 2A
    
  .case ATMOS_SR(18)!="0A"
    .text "Select scheme(s):" L
    .block 1
      .check "Run Analysis-Correction (AC) scheme" L AAS_AC Y N
      .check "Run Incremental Analysis Update (IAU) scheme" L AAS_IAU Y N
    .blockend
    .case (AAS_AC=="Y")||(AAS_IAU=="Y")
    .entry "Nominal analysis time from start of run (in minutes)" L AASMDEF
  .caseend
.panend
 


