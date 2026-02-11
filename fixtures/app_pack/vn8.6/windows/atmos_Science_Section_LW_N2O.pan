.winid "atmos_Science_Section_LW_N2O"
.title "Nitrous Oxide Absorption"
.wintype entry

.panel
  .textw "This window is only active if using generalised 2-stream LW radiation."  L
  .invisible ES_RAD==2||ES_RAD==3
    .gap
    .basrad "Define specification of Nitrous Oxide absorption." L 3 v LW2NOXABS
            "Excluded. " N
            "Included. Use a constant value." Y
            "Included. Use the complex method of specification." C
   
    .case  LW2NOXABS=="Y" 
      .block 1
        .entry "Specify mass mixing ratio of  Nitrous Oxide" L LW2NOXMIX
      .blockend 
    .caseend

    .case  LW2NOXABS=="C" 
      .text "Define the time variation of the mass mixing ratio of  Nitrous Oxide"     L 
      .text "You can define up to 50 years to use as turning points in the calculation. See help." L
      .entry "Number of designated years for linear interpolation. 1 minimum." L NOXNGASL
      .table gvals2 "Years and  Nitrous Oxide Mass Mixing Ratios for linear interp." top h NOXNGASL 5 INCR 
        .elementautonum "No." 1 NOXNGASL 3
        .element "Years in ascending order." NOXYGASL 5 35 in
        .element "N2O MRs at those years." NOXVGASL 5 35 in
      .tableend
      .entry "Number of designated years for subsequent exponential increase. See help." L NOXNGASR
      .table grate2 "Years and % compound growth of N2O MR pa in subsequent years." top h NOXNGASR 5 INCR 
         .elementautonum "No." 1 NOXNGASR 3
         .element "Years in ascending order." NOXYGASR 5 35 in
         .element "N2O MR % compound growth pa from this year." NOXRGASR 5 35 in
      .tableend
      .gap
    .caseend
   
  .invisend
  .text "Push LWG2 for LW general 2-stream radiation window.  Push CFC11 for the next minor gas." L
  .pushnext "LWG2" atmos_Science_Section_LWGen2
  .pushnext "CFC11" atmos_Science_Section_LW_CFC11
.panend





