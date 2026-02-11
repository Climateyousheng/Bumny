.winid "atmos_Science_Section_LW_Meth"
.title "Methane Absorption"
.wintype entry

.panel
  .textw "This window is only active if using generalised 2-stream LW radiation."  L
  .invisible ES_RAD==2||ES_RAD==3
    .gap
    .basrad "Define specification of methane absorption." L 3 v LW2METHABS
            "Excluded. " N
            "Included. Use a constant value." Y
            "Included. Use the complex method of specification." C
   
    .case  LW2METHABS=="Y" 
      .block 1
        .entry "Specify mass mixing ratio of Methane" L LW2METHMIX
      .blockend 
    .caseend

    .case  LW2METHABS=="C" 
      .text "Define the time variation of the mass mixing ratio of Methane"     L 
      .text "You can define up to 50 years to use as turning points in the calculation. See help." L
      .entry "Number of designated years for linear interpolation. 1 minimum." L METHNGASL
      .table gvals3 "Years and Methane Mass Mixing Ratios for linear interp." top h METHNGASL 5 INCR 
        .elementautonum "No." 1 METHNGASL 3
        .element "Years in ascending order." METHYGASL 5 35 in
        .element "Methane MRs at those years." METHVGASL 5 35 in
      .tableend
      .entry "Number of designated years for subsequent exponential increase. See help." L METHNGASR
      .table grate3 "Years and % compound growth of Methane MR pa in subsequent years." top h METHNGASR 5 INCR 
         .elementautonum "No." 1 METHNGASR 3
         .element "Years in ascending order." METHYGASR 5 35 in
         .element "Methane MR % compound growth pa from this year." METHRGASR 5 35 in
      .tableend
      .gap
    .caseend
   
  .invisend
  .text "Push LWG2 for general 2-stream LW radiation window.  Push N2O for the next minor gas." L
  .pushnext "LWG2" atmos_Science_Section_LWGen2
  .pushnext "N2O" atmos_Science_Section_LW_N2O
.panend




