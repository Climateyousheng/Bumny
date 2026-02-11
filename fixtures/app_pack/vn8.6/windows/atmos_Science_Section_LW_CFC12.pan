.winid "atmos_Science_Section_LW_CFC12"
.title "CFC12 Absorption"
.wintype entry

.panel
  .textw "This window is only active if using generalised 2-stream LW radiation."  L
  .invisible ES_RAD==2||ES_RAD==3
    .gap
    .basrad "Define specification of CFC12 absorption." L 3 v LW2CFC12ABS
            "Excluded. " N
            "Included. Use a constant value." Y
            "Included. Use the complex method of specification." C
   
    .case  LW2CFC12ABS=="Y" 
      .block 1
        .entry "Specify mass mixing ratio of CFC12" L LW2CFC12MIX
      .blockend 
    .caseend

    .case  LW2CFC12ABS=="C" 
      .text "Define the time variation of the mass mixing ratio of CFC12"     L 
      .text "You can define up to 50 years to use as turning points in the calculation. See help." L
      .entry "Number of designated years for linear interpolation. 1 minimum." L CFC12NGASL
      .table gvals6 "Years and CFC12 Mass Mixing Ratios for linear interp." top h CFC12NGASL 5 INCR 
        .elementautonum "No." 1 CFC12NGASL 3
        .element "Years in ascending order." CFC12YGASL 5 35 in
        .element "CFC12 MRs at those years." CFC12VGASL 5 35 in
      .tableend
      .entry "Number of designated years for subsequent exponential increase. See help." L CFC12NGASR
      .table grate6 "Years and % compound growth of CFC12 MR pa in subsequent years." top h CFC12NGASR 5 INCR 
         .elementautonum "No." 1 CFC12NGASR 3
         .element "Years in ascending order." CFC12YGASR 5 35 in
         .element "CFC12 MR % compound growth pa from this year." CFC12RGASR 5 35 in
      .tableend
      .gap
    .caseend
   
  .invisend
  .text "Push LWG2 for general 2-stream LW radiation window.  Push CFC113 for the next minor gas." L
  .pushnext "LWG2" atmos_Science_Section_LWGen2
  .pushnext "CFC113" atmos_Science_Section_LW_CFC113
.panend





