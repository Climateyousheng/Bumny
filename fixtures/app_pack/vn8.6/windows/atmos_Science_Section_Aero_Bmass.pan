.winid "atmos_Science_Section_Aero_Bmass"
.title "Section 17 : Aerosols. Biomass Model."
.wintype entry

.panel
  .text "Section 17 : Aerosols. Biomass Model." L
  .case (ATMOS_SR(17)!="0A")
      .check "Biomass Modelling Included"  L CHEM_BIOM Y N
  .caseend
  .gap
  .case (ATMOS_SR(17)!="0A")&&(CHEM_BIOM=="Y")
    .block 1
      .check "Including surface biomass emissions." L EMBIOM Y N
      .gap
      .check "Including high-level biomass emissions." L EMBIOMH Y N
      .case EMBIOMH=="Y"
        .block 2
          .entry "Specify the lowest level for biomass emissions" L EMBIOMHL1
		  .entry "Specify the highest level for biomass emissions" L EMBIOMHL2
        .blockend
      .caseend
    .blockend
  .caseend
  .gap
  .gap
  .textw "Push ANC for ancillary files: <biomass>  " L
  .textw "Push AERO FX for the Aerosol Effects window" L
  .textw "Push BACK for Aerosols window" L
  .pushnext "ANC" atmos_InFiles_PAncil_Biomass
  .pushsequence "AERO_FX" atmos_Science_Section_Aero_Effects
  .pushnext "BACK" atmos_Science_Section_Aero
.panend
