.winid "atmos_Science_Section_LW_HFC125"
.title "HFC125 Absorption"
.wintype entry

.panel
  .textw "This window is only active if using generalised 2-stream LW radiation."  L
  .invisible ES_RAD==2||ES_RAD==3
    .gap
    .basrad "Define specification of HFC125 absorption." L 3 v LW2HFC125ABS
            "Excluded. " N
            "Included. Use a constant value." Y
            "Included. Use the complex method of specification." C
   
    .case  LW2HFC125ABS=="Y" 
      .block 1
        .entry "Specify mass mixing ratio of HFC125" L LW2HFC125MIX
      .blockend 
    .caseend

    .case  LW2HFC125ABS=="C" 
      .text "Define the time variation of the mass mixing ratio of HFC125"     L 
      .text "You can define up to 50 years to use as turning points in the calculation. See help." L
      .entry "Number of designated years for linear interpolation. 1 minimum." L HFC125NGASL
      .table gvals2 "Years and HFC125 Mass Mixing Ratios for linear interp." top h HFC125NGASL 5 INCR 
        .elementautonum "No." 1 HFC125NGASL 3
        .element "Years in ascending order." HFC125YGASL 5 35 in
        .element "HFC125 MRs at those years." HFC125VGASL 5 35 in
      .tableend
      .entry "Number of designated years for subsequent exponential increase. See help." L HFC125NGASR
      .table grate2 "Years and % compound growth of HFC125 MR pa in subsequent years." top h HFC125NGASR 5 INCR 
         .elementautonum "No." 1 HFC125NGASR 3
         .element "Years in ascending order." HFC125YGASR 5 35 in
         .element "HFC125 MR % compound growth pa from this year." HFC125RGASR 5 35 in
      .tableend
      .gap
    .caseend
   
  .invisend
  .text "Push LWG2 for LW general 2-stream radiation window.  Push HFC134A for the next minor gas." L
  .pushnext "LWG2" atmos_Science_Section_LWGen2
  .pushnext "HFC134A" atmos_Science_Section_LW_HFC134A
.panend





