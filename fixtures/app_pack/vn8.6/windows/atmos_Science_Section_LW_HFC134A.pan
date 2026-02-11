.winid "atmos_Science_Section_LW_HFC134A"
.title "HFC134A Absorption"
.wintype entry

.panel
  .textw "This window is only active if using generalised 2-stream LW radiation."  L
  .invisible ES_RAD==2||ES_RAD==3
    .gap
    .basrad "Define specification of HFC134A absorption." L 3 v LW2HFC134AABS
            "Excluded. " N
            "Included. Use a constant value." Y
            "Included. Use the complex method of specification." C
   
    .case  LW2HFC134AABS=="Y" 
      .block 1
        .entry "Specify mass mixing ratio of HFC134A" L LW2HFC134AMIX
      .blockend 
    .caseend

    .case  LW2HFC134AABS=="C" 
      .text "Define the time variation of the mass mixing ratio of HFC134A"     L 
      .text "You can define up to 50 years to use as turning points in the calculation. See help." L
      .entry "Number of designated years for linear interpolation. 1 minimum." L HFC134ANGASL
      .table gvals6 "Years and HFC134A Mass Mixing Ratios for linear interp." top h HFC134ANGASL 5 INCR 
        .elementautonum "No." 1 HFC134ANGASL 3
        .element "Years in ascending order." HFC134AYGASL 5 35 in
        .element "HFC134A MRs at those years." HFC134AVGASL 5 35 in
      .tableend
      .entry "Number of designated years for subsequent exponential increase. See help." L HFC134ANGASR
      .table grate6 "Years and % compound growth of HFC134A MR pa in subsequent years." top h HFC134ANGASR 5 INCR 
         .elementautonum "No." 1 HFC134ANGASR 3
         .element "Years in ascending order." HFC134AYGASR 5 35 in
         .element "HFC134A MR % compound growth pa from this year." HFC134ARGASR 5 35 in
      .tableend
      .gap
    .caseend
   
  .invisend
  .text "Push LWG2 for general 2-stream LW radiation window.  Push METH for the next minor gas." L
  .pushnext "LWG2" atmos_Science_Section_LWGen2
  .pushnext "METH" atmos_Science_Section_LW_Meth
.panend





