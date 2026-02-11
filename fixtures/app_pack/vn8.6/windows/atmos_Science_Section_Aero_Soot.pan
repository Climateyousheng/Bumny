.winid "atmos_Science_Section_Aero_Soot"
.title "Section 17 : Aerosols. Soot Model."
.wintype entry

.panel
  .text "Section 17 : Aerosols. Soot Model." L
  .case (ATMOS_SR(17)!="0A")
      .check "Soot Modelling Included"  L CHEM_SOOT Y N
  .caseend
  .gap
  .case (ATMOS_SR(17)!="0A")&&(CHEM_SOOT=="Y")
    .block 1
      .check "Including surface soot emissions." L EMSOOT Y N
      .gap
      .check "Including high-level soot emissions." L EMSOOTH Y N
      .case EMSOOTH=="Y"
        .block 2
          .entry "Specify the level" L EMSOOTHL
        .blockend
      .caseend
    .blockend
  .caseend
  .gap
  .gap
  .textw "Push for ancillary files: <ANC, emissions>  " L
  .textw "Push AERO for the Aerosol Effects window." L
  .pushnext "ANC" atmos_InFiles_PAncil_SootEmis
  .pushsequence "AERO_FX" atmos_Science_Section_Aero_Effects
  .pushnext "BACK" atmos_Science_Section_Aero
.panend


