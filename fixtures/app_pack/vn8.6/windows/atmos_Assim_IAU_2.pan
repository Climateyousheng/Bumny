.winid "atmos_Assim_IAU_2"
.title "Continuation of Assimilation IAU"
.wintype entry

.panel

  .invisible (ATMOS_SR(18)!="0A")&&(AAS_IAU=="Y")
   .text "\"Incremental Analysis Update\" scheme is activated." L
  .invisend
  .invisible (ATMOS_SR(18)=="0A")||(AAS_IAU=="N")
   .text "\"Incremental Analysis Update\"  scheme is not activated." L
  .invisend
  .gap
  .case (ATMOS_SR(18)!="0A")&&(AAS_IAU=="Y")
    .block 1
    .check "Add level-one temperature incs to surface temperature on land surface tiles" L LIAU_INCTSTL Y N
    .check "Add level-one temperature incs to snow surface temperature"  L LIAU_INCTSSN Y N
    .check "Reset polar rows to their mean values"   L LIAU_RSTPOL Y N
    .check "Limit size of upper-level theta increments"    L LIAU_LMTUPTINC  Y N
    .case LIAU_LMTUPTINC=="Y"
      .block 2
      .entry "Pressure boundary for application of limit (Pa)" L IAU_LMTUPTPBND 12
      .entry "Maximum absolute value of increment after multiplication by IAU weight (K)" L IAU_LMTUPTMAXI 15
      .blockend
    .caseend
    .check "Reset ozone to oz_min if ozone was negative"   L LIAU_OZNMIN  Y N
    .check "Ignore theta increments for top model level"   L LIAU_IGNTLTINC   Y N
    .check "Add soil moisture perturbations to SMCL"    L LIAU_USESLPRT   Y N
    .check "Add surface temperature perturbations to TStar & TStar_tile"    L LIAU_USESFTP    Y N
    .check "Replace q with updated qT, bypassing Var_DiagCloud"    L LIAU_RQQTPLUS    Y N
    .check "Apply corrections for processing of qT increments"     L LIAU_APLQTCORR   Y N
    .case LIAU_RQQTPLUS=="N"
      .block 2
      .entry "Tolerance for qcl==0 and qcf==0 tests in VarDiag_Cloud" L DGCLD_TLQ 12
      .entry "Tolerance for (1-FM)==0 test in VarDiag_Cloud" L DGCLD_TLFM 12  
      .entry "Maximum number of loops for convergence in Var_DiagCloud (>50)"  L DGCLD_NMAXLP  12
      .check "Take measures to avoid machine precision issues in Var_DiagCloud?"  L DGCLD_APCOMPLIM  Y N
      .case DGCLD_APCOMPLIM=="Y"
        .block 3
        .entry "QN limit used for avoiding machine precision issues" L DGCLD_COMPRGLIM  12          
        .blockend
      .caseend
      .blockend
    .caseend
    .blockend
  .caseend
  .textw "Push Back to go to the beginning window" L
  .pushnext "Back" atmos_Assim_IAU
.panend 
