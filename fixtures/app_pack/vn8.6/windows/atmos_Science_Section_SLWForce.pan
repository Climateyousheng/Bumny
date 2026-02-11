.winid "atmos_Science_Section_SLWForce"
.title "SW / LW Forcing "
.wintype entry

.panel
  .text "Select options for both SW and LW schemes:" L
  .case ATMOS_SR(2)=="3Z" && LSWUSE3C=="1"
     .block 1
     .check "CO2" L C2C_CO2 Y N
     .check "O3" L C2C_O3 Y N
     .check "All GHG" L C2C_WMG Y N
     .check "Sulphur" L C2C_SULPC_D Y N
     .check "Sea Salt" L C2C_SEAS_D Y N
     .check "Soot" L C2C_SOOT_D Y N
     .check "Biomass" L C2C_BMB_D Y N  
     .check "OCFF" L C2C_OCFF_D Y N
     .check "Nitrate" L C2C_NITR_D Y N
     .check "Mineral Dust" L C2C_DUST_D Y N
     .check "Biogenic" L C2C_BIOG_D Y N
     .check "UKCA-MODE aerosols" L C2C_UKCA_D Y N
     .check "All aerosols" L C2C_AEROSOL Y N   
     .check "Forcing due to land use" L C2C_LAND_S Y N
     .check "All forcings on" L C2C_ALL Y N
     .blockend
  .caseend
  .gap 
  .text "Select option for SW scheme" L
  .case (ATMOS_SR(1)=="3Z"&&LSWUSE3C=="1")
     .block 1
     .check "O2" L C2C_O2 Y N       
     .blockend
  .caseend
  .gap
  .text "Select options for LW scheme" L
  .case (ATMOS_SR(2)=="3Z"&&LSWUSE3C=="1")
     .block 1
     .check "N2O" L C2C_N2O Y N  
     .check "CH4" L C2C_CH4 Y N
     .check "CFC11" L C2C_CFC11 Y N
     .check "CFC12" L C2C_CFC12 Y N
     .check "C113" L C2C_C113 Y N
     .check "HCFC22" L C2C_HCFC22 Y N
     .check "HFC125" L C2C_HFC125 Y N
     .check "HFC134" L C2C_HFC134 Y N
     .blockend
  .caseend  
  .gap
  .textw "Push SW_Rad to go to the SW Radiation window" L
  .textw "Push LW_Rad to go to the LW Radiation window" L  
  .pushnext "SW_Rad" atmos_Science_Section_SW
  .pushnext "LW_Rad" atmos_Science_Section_LW  
.panend
