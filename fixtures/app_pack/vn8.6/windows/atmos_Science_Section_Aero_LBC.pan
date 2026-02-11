.winid "atmos_Science_Section_Aero_LBC"
.title "Section 17 : Aerosols LBCs"
.wintype entry

.panel
  .gap

  .text "Select which aerosol tracer LBCs you would like to generate." L
  .case ATMOS_SR(17)!="0A"
    .block 1
    .case I_DUST!="0" 
      .check "Generate dust LBCs?"  L LDUSTLBC Y N
    .caseend
    .case CHEM_SULPC=="Y"
      .check "Generate sulphate LBCs?"  L LSULPLBC Y N
      .case DMS=="Y"
        .check "Generate DMS LBCs?"  L LDMSLBC Y N
      .caseend
      .case SULOZONE=="Y"
        .check "Generate NH3 LBCs?"  L LNH3LBC Y N
      .caseend
     .caseend
    .case CHEM_SOOT=="Y"
      .check "Generate soot LBCs?"  L LSOOTLBC Y N
    .caseend
    .case CHEM_BIOM=="Y"
      .check "Generate biomass LBCs?"  L LBIOLBC Y N
    .caseend
    .case CHEM_OCFF=="Y"
    .check "Generate OCFF LBCs?"  L LOCFFLBC Y N  
    .caseend  
    .case ATMOS_SR(17)=="2B" && CHEM_NITR=="Y" && CHEM_SULPC=="Y"
      .check "Generate nitrate LBCs?"  L LNITRLBC Y N  
    .caseend            
    .blockend
  .caseend
  .gap
  .pushnext "BACK" atmos_Science_Section_Aero
.panend


