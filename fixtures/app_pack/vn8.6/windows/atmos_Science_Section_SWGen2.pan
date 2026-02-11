.winid "atmos_Science_Section_SWGen2"
.title "Section 1 : SW Radiation, options for general 2-stream radiation"
.wintype entry
.panel
  .gap
  .entry  "Solar constant (W/m2)" L SCONST 
  .gap
  .invisible ES_RAD==1||ES_RAD==3
    .textw "You have chosen general 2-stream SW radiation. Define mode:" L
    .text "Specify the location of the shortwave spectral file" L
    .block 1
      .entry "Directory" L PATHSW
      .entry "Prognostic File" L FILESW
      .case ATMOS_SR(1)=="3Z" && LSWUSE3C!="0"
        .entry "Diagnostic File" L FILESWD
      .caseend
    .blockend
    .gap
    .basrad "Select 2-stream option" L 3 h SW2SOPT
            "PIFM80" 16    
            "Delta-Eddington" 2
            "Discrete Ordinate" 4
    .gap
    .basrad "Select treatment of overlapping for gaseous absorption" L 3 v SW2OLAPG
            "Random Overlap" 2    
            "Equivalent extinction" 5
            "Equivalent extinction (corrected scaling)" 4
    .check "Include absorption by oxygen" L SW2OXYABS Y N
    .case SW2OXYABS=="Y"
        .entry "Specify mass mixing ratio of oxygen" L SW2OXYMIX
    .caseend
    .check "Include absorption by CH4" L LCH4_SW Y N
    .check "Include absorption by N2O" L LN20_SW Y N
  .invisend 
  .invisible ES_RAD==1||ES_RAD==3
    .case ATMOS_SR(3)!="0A"
      .check "Include spectral land-surface albedos" L SPECALB Y N
      .case SPECALB=="Y"
        .check "Include prognostic snow albedo"  L SNOWALB Y N
        .check "Use a single value for both the direct and diffuse beams" L LSPECALBBS Y N
      .caseend
      .check "Scale albedos of land-surface tiles to agree with supplied observations" L OBSALB Y N
    .caseend
    .gap
    .case ATMOS_SR(17)!="0A" 
      .text "See the Aerosols window for Direct and Indirect effects of sulphate, sea-salt and soot" L 
    .caseend
  .invisend
  .gap
  .textw "Push SW to go back to SW Radiation section" L
  .textw "Push SLW_Forc to go to the Forsing window" L
  .textw "Push Aero_Clims to go to the Aerosol Climatologies" L
  .pushnext "SW" atmos_Science_Section_SW
  .pushnext "SLW_Forc" atmos_Science_Section_SLWForce
  .pushnext "Aero_Clims" atmos_Science_Section_AeroClim
.panend





