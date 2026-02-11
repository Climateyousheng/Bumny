.winid "atmos_Science_Section_LW_HCFC22"
.title "HCFC22 Absorption"
.wintype entry

.panel
  .textw "This window is only active if using generalised 2-stream LW radiation."  L
  .invisible ES_RAD==2||ES_RAD==3
    .gap
    .basrad "Define specification of HCFC22 absorption." L 3 v LW2HCFC22ABS
            "Excluded. " N
            "Included. Use a constant value." Y
            "Included. Use the complex method of specification." C
   
    .case  LW2HCFC22ABS=="Y" 
      .block 1
        .entry "Specify mass mixing ratio of HCFC22" L LW2HCFC22MIX
      .blockend 
    .caseend

    .case  LW2HCFC22ABS=="C" 
      .text "Define the time variation of the mass mixing ratio of HCFC22"     L 
      .text "You can define up to 50 years to use as turning points in the calculation. See help." L
      .entry "Number of designated years for linear interpolation. 1 minimum." L HCFC22NGASL
      .table gvals2 "Years and HCFC22 Mass Mixing Ratios for linear interp." top h HCFC22NGASL 5 INCR 
        .elementautonum "No." 1 HCFC22NGASL 3
        .element "Years in ascending order." HCFC22YGASL 5 35 in
        .element "HCFC22 MRs at those years." HCFC22VGASL 5 35 in
      .tableend
      .entry "Number of designated years for subsequent exponential increase. See help." L HCFC22NGASR
      .table grate2 "Years and % compound growth of HCFC22 MR pa in subsequent years." top h HCFC22NGASR 5 INCR 
         .elementautonum "No." 1 HCFC22NGASR 3
         .element "Years in ascending order." HCFC22YGASR 5 35 in
         .element "HCFC22 MR % compound growth pa from this year." HCFC22RGASR 5 35 in
      .tableend
      .gap
    .caseend
   
  .invisend
  .text "Push LWG2 for LW general 2-stream radiation window.  Push HFC125 for the next minor gas." L
  .pushnext "LWG2" atmos_Science_Section_LWGen2
  .pushnext "HFC125" atmos_Science_Section_LW_HFC125
.panend





