.winid "atmos_Science_Section_Stochastic_RP"
.title "Section 35: Stochastic Schemes - Random Parameters"
.wintype entry
.procs {check_rp IN} {} {check_rp OUT}

.panel
  .case ATMOS_SR(35)!="0A"
  .case LRPRM!="N"
    .entry "Max independent random numbers to use (see help)" L RANMAX 10  
    .case ATMOS_SR(5) == "4A" 
      .block 1
        .table rpconv "Convection parameters" top h 2 2 NONE
          .element "Parameter" RPCV_PARAMS 2 45 out
          .element "Minimum" RPCV_MINS 2 15 in
          .element "Default Value" RPCV_DEFS 2 15 out      
          .element "Maximum" RPCV_MAXES 2 15 in        
        .tableend
      .blockend 
    .caseend
    .case ATMOS_SR(4) != "0A"
      .block 1
        .table rplsp "Large Scale Precipitation Parameters" top h 2 2 NONE
          .element "Parameter" RPLSP_PARAMS 2 45 out
          .element "Minimum" RPLSP_MINS 2 15 in
          .element "Default Value" RPLSP_DEFS 2 15 in      
          .element "Maximum" RPLSP_MAXES 2 15 in
        .tableend
      .blockend
    .caseend
    .case ATMOS_SR(3)!="0A" && ATMOS_SR(3)!="1A"
      .block 1
        .table rpbl "Boundary Layer Parameters" top h 7 7 NONE
          .element "Parameter" RPBL_PARAMS 7 45 out
          .element "Minimum" RPBL_MINS 7 15 in
          .element "Default Value" RPBL_DEFS 7 15 in      
          .element "Maximum" RPBL_MAXES 7 15 in
        .tableend
      .blockend
    .caseend
    .case ATMOS_SR(6) == "4A"
      .block 1
        .table rpgwd "Gravity Wave Drag parameters" top h 2 2 NONE
          .element "Parameter" RPGWD_PARAMS 2 45 out
          .element "Minimum" RPGWD_MINS 2 15 in
          .element "Default Value" RPGWD_DEFS 2 15 out      
          .element "Maximum" RPGWD_MAXES 2 15 in        
        .tableend
      .blockend
    .caseend
  .caseend
  .caseend
  .gap
    .textw "Push CONV for the Convection window, LSP for the Large Scale Precipitation window" L
    .textw "Push BL for the Boundary Layer window, GWD for the Gravity Wave Drag window" L
    .pushnext "Back" atmos_Science_Section_Stochastic
    .pushnext "CONV" atmos_Science_Section_Conv
    .pushnext "LSP" atmos_Science_Section_LSRain
    .pushnext "BL" atmos_Science_Section_BLay
    .pushnext "GWD" atmos_Science_Section_GWD
.panend
