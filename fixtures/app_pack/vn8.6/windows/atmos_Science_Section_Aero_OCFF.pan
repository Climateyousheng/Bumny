.winid "atmos_Science_Section_Aero_OCFF"
.title "Section 17 : Aerosols. Fossil-fuel organic"
.wintype entry

.panel
  .text "Section 17 : Aerosols. OCFF Model." L
  .case (ATMOS_SR(17)!="0A")
      .check "Fossil Fuels Organic Carbon Scheme Included"  L CHEM_OCFF Y N
  .caseend
  .gap
  .case (ATMOS_SR(17)!="0A")&&(CHEM_OCFF=="Y")
    .block 1
      .check "Including surface OCFF emissions" L LOCFFSUREM Y N
      .gap
      .check "Including high level OCFF emissions" L LOCFFHILEM Y N
      .case LOCFFHILEM=="Y"
        .block 2
          .entry "Specify the level" L OCFFHL
        .blockend
      .caseend
    .blockend
  .caseend
  .gap
  .gap
  .textw "Push ANC for ancillary files: <ANC, OCFF>  " L
  .textw "Push AERO for the Aerosol Effects window." L
  .pushnext "ANC" atmos_InFiles_PAncil_OCFFEmis
  .pushsequence "AERO_FX" atmos_Science_Section_Aero_Effects
  .pushnext "BACK" atmos_Science_Section_Aero
.panend


