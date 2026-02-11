.winid "atmos_Assim_AC"
.title "AC Scheme"
.wintype entry

.panel

  .invisible (ATMOS_SR(18)!="0A")&&(AAS_AC=="Y")
   .text "\"Analysis Correction\" assimilation scheme is activated." L
  .invisend
  .invisible (ATMOS_SR(18)=="0A")||(AAS_AC=="N")
   .text "\"Analysis Correction\" assimilation scheme is not activated." L
  .invisend
  
    
  .case (ATMOS_SR(18)!="0A")&&(AAS_AC=="Y")
    .text "How many minutes after basis time is the:" L
    .block 1
      .entry "Start of AC" L ACSTART
      .entry "End of AC" L ACEND
    .blockend
    .text "Select observation types to be assimilated" L
    .block 1
      .check "MOPS cloud profiles" L ASACMOPS Y N
      .check "MOPS precipitation rates" L ASACPREC Y N
      .check "Tropical Convective Rainfall (TCR)" L ASACTCR Y N
    .blockend
    .check "Using MESOSCALE assimilation parameters" L LASMS Y N
    .check "With written diagnostics from the AC code" L ASDIAG Y N
    .gap
    .table nacp "Your additions to assimilation control namelist &ACP" top h 10 5 NONE
        .elementautonum "line" 1 10 5
        .element "Your own NAMELIST items, no leading space" AASNLACP 10 73 in
    .tableend
    .table nacd "Your additions to assimilation diagnostic namelist &ADIAG" top h 10 5 NONE
        .elementautonum "line" 1 10 5
        .element "Your own NAMELIST items, no leading space" AASNLADIAG 10 73 in
    .tableend
    .colour red GEN_SUITE==1
    .invisible GEN_SUITE==1
      .textw "Suite jobs may specify EXTERNAL if observation file supplied externally." L
    .invisend
    .colourend
    .table obs "Specify directory names for observation files" top h 5 5 INCR
      .elementautonum "No." 1 5 5
        .colour red  GEN_SUITE==1 
          .element "Full path name only without file names, leave no gaps " ACOBSFL 5 73  in
        .colourend
    .tableend
  .caseend
.panend
 


