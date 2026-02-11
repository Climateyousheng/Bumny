.winid "atmos_Science_Section_LW_CFC11"
.title "CFC11 Absorption"
.wintype entry

.panel
  .textw "This window is only active if using generalised 2-stream LW radiation."  L
  .invisible ES_RAD==2||ES_RAD==3
    .gap
    .basrad "Define specification of CFC11 absorption." L 3 v LW2CFC11ABS
            "Excluded. " N
            "Included. Use a constant value." Y
            "Included. Use the complex method of specification." C
   
    .case  LW2CFC11ABS=="Y" 
      .block 1
        .entry "Specify mass mixing ratio of CFC11" L LW2CFC11MIX
      .blockend 
    .caseend

    .case  LW2CFC11ABS=="C" 
      .text "Define the time variation of the mass mixing ratio of CFC11"     L 
      .text "You can define up to 50 years to use as turning points in the calculation. See help." L
      .entry "Number of designated years for linear interpolation. 1 minimum." L CFC11NGASL
      .table gvals4 "Years and CFC11 Mass Mixing Ratios for linear interp." top h CFC11NGASL 5 INCR 
        .elementautonum "No." 1 CFC11NGASL 3
        .element "Years in ascending order." CFC11YGASL 5 35 in
        .element "CFC11 MRs at those years." CFC11VGASL 5 35 in
      .tableend
      .entry "Number of designated years for subsequent exponential increase. See help." L CFC11NGASR
      .table grate4 "Years and % compound growth of CFC11 MR pa in subsequent years." top h CFC11NGASR 5 INCR 
         .elementautonum "No." 1 CFC11NGASR 3
         .element "Years in ascending order." CFC11YGASR 5 35 in
         .element "CFC11 MR % compound growth pa from this year." CFC11RGASR 5 35 in
      .tableend
      .gap
    .caseend

     
  .invisend
  .text "Push LWG2 for general 2-stream LW radiation window.  Push CFC12 for the next minor gas." L
  .pushnext "LWG2" atmos_Science_Section_LWGen2
  .pushnext "CFC12" atmos_Science_Section_LW_CFC12
.panend





