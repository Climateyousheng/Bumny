.winid "atmos_Science_Section_LW_CFC113"
.title "CFC113 Absorption"
.wintype entry

.panel
  .textw "This window is only active if using generalised 2-stream LW radiation."  L
  .invisible ES_RAD==2||ES_RAD==3
    .gap
    .basrad "Define specification of CFC113 absorption." L 3 v LW2CFC113ABS
            "Excluded. " N
            "Included. Use a constant value." Y
            "Included. Use the complex method of specification." C
   
    .case  LW2CFC113ABS=="Y" 
      .block 1
        .entry "Specify mass mixing ratio of CFC113" L LW2CFC113MIX
      .blockend 
    .caseend

    .case  LW2CFC113ABS=="C" 
      .text "Define the time variation of the mass mixing ratio of CFC113"     L 
      .text "You can define up to 50 years to use as turning points in the calculation. See help." L
      .entry "Number of designated years for linear interpolation. 1 minimum." L CFC113NGASL
      .table gvals2 "Years and CFC113 Mass Mixing Ratios for linear interp." top h CFC113NGASL 5 INCR 
        .elementautonum "No." 1 CFC113NGASL 3
        .element "Years in ascending order." CFC113YGASL 5 35 in
        .element "CFC113 MRs at those years." CFC113VGASL 5 35 in
      .tableend
      .entry "Number of designated years for subsequent exponential increase. See help." L CFC113NGASR
      .table grate2 "Years and % compound growth of CFC113 MR pa in subsequent years." top h CFC113NGASR 5 INCR 
         .elementautonum "No." 1 CFC113NGASR 3
         .element "Years in ascending order." CFC113YGASR 5 35 in
         .element "CFC113 MR % compound growth pa from this year." CFC113RGASR 5 35 in
      .tableend
      .gap
    .caseend
   
  .invisend
  .text "Push LWG2 for LW general 2-stream radiation window.  Push CFC114 for the next minor gas." L
  .pushnext "LWG2" atmos_Science_Section_LWGen2
  .pushnext "CFC114" atmos_Science_Section_LW_CFC114
.panend





