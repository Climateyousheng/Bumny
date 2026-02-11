.winid "atmos_Config_Prognos"
.title "Prognostic Variable Choices"
.wintype entry

.panel
  .gap
  .text  "Light Box to Include"   L
  .block 1
    .check "SST Anomalies" L SSTAN Y N
    .gap
    .check "Total aerosol fields" L TOTAE Y N
  .blockend
  .block 2 
    .case TOTAE=="Y"
      .check "Source sink terms" L TOTEM Y N
      .case ATMOS_SR(11)!="0A"
        .check "Advecting the aerosol" L TOTAA Y N
      .caseend
      .case ATMOS_SR(5)!="0A" && CONVOPT != "F"
        .check "Include transport by parametrized convection" L LMURKCONV Y N
      .caseend      
    .caseend 
    .gap
  .blockend
  .gap
  .text  "Prognostic related choices" L
  .gap
  .textw "Push ANCIL to specify Ozone ancillary file" L
  .pushnext "ANCIL" atmos_InFiles_PAncil_Ozone
.panend


