.winid "atmos_Science_Section_LW_CFC114"
.title "CFC114 Absorption"
.wintype entry

.panel
  .textw "This window is only active if using generalised 2-stream LW radiation."  L
  .invisible ES_RAD==2||ES_RAD==3
    .gap
    .basrad "Define specification of CFC114 absorption." L 3 v LW2CFC114ABS
            "Excluded. " N
            "Included. Use a constant value." Y
            "Included. Use the complex method of specification." C
   
    .case  LW2CFC114ABS=="Y" 
      .block 1
        .entry "Specify mass mixing ratio of CFC114" L LW2CFC114MIX
      .blockend 
    .caseend

    .case  LW2CFC114ABS=="C" 
      .text "Define the time variation of the mass mixing ratio of CFC114"     L 
      .text "You can define up to 50 years to use as turning points in the calculation. See help." L
      .entry "Number of designated years for linear interpolation. 1 minimum." L CFC114NGASL
      .table gvals2 "Years and CFC114 Mass Mixing Ratios for linear interp." top h CFC114NGASL 5 INCR 
        .elementautonum "No." 1 CFC114NGASL 3
        .element "Years in ascending order." CFC114YGASL 5 35 in
        .element "CFC114 MRs at those years." CFC114VGASL 5 35 in
      .tableend
      .entry "Number of designated years for subsequent exponential increase. See help." L CFC114NGASR
      .table grate2 "Years and % compound growth of CFC114 MR pa in subsequent years." top h CFC114NGASR 5 INCR 
         .elementautonum "No." 1 CFC114NGASR 3
         .element "Years in ascending order." CFC114YGASR 5 35 in
         .element "CFC114 MR % compound growth pa from this year." CFC114RGASR 5 35 in
      .tableend
      .gap
    .caseend
   
  .invisend
  .text "Push LWG2 for LW general 2-stream radiation window.  Push HCFC22 for the next minor gas." L
  .pushnext "LWG2" atmos_Science_Section_LWGen2
  .pushnext "HCFC22" atmos_Science_Section_LW_HCFC22
.panend





