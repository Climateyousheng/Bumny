.winid "atmos_Science_Section_Aero"
.title "Section 17 : Aerosols."
.wintype entry
.panel
  .gap
  .basrad "Choose the relevant section release" L 2 v ATMOS_SR(17)
          "<0A> Aerosol Modelling not included." 0A
          "<2B> CLASSIC Aerosol Modelling included" 2B
  .gap
  .case ATMOS_SR(17)!="0A"
    .block 1
    .check "With the Sulphur Cycle"  L CHEM_SULPC Y N
    .case CHEM_SULPC == "Y"
      .block 2
      .invisible ATMOS_SR(34)=="0A"
        .textw "Note that nitrate is only available when UKCA is turned on. UKCA is currently turned off and the model will fail" L
      .invisend
      .blockend
        .check "With the Ammonium Nitrate Scheme" L CHEM_NITR Y N
    .caseend
    .check "With the Soot Scheme" L CHEM_SOOT  Y N
    .check "With the Biomass Aerosol Scheme" L CHEM_BIOM Y N
    .basrad "Select Mineral Dust scheme" L 3 v I_DUST
       "dust switched off " 0
       "prognostic dust" 1
       "diagnostic dust" 2
    .check "With the Fossil Fuels Organic Carbon Scheme" L CHEM_OCFF Y N
.comment    .case CHEM_SULPC == "Y"
.comment      .block 2
.comment      .entry "Substep divison (for S cycle only)" L CHEMFRE 25
.comment      .blockend
.comment    .caseend
  .caseend
  .gap
  .invisible ATMOS_SR(17)!="0A"
     .textw "Aerosol Modelling included. The number of tracer levels must equal the number of model levels" L
  .invisend
  .invisible ATMOS_SR(17)=="0A"
     .textw "Aerosol Modelling is not included" L
  .invisend
  .invisible ATMOS_SR(34)!="0A"
     .textw "UKCA chemistry included. The number of tracer levels must equal the number of model levels" L
  .invisend
  .blockend
  .gap
    .textw "Push TRA for the Tracer window" L
    .textw "Push SULP for the Sulphur window" L
    .textw "Push SOOT for the Soot window" L
    .textw "Push BIOM for the Biomass window" L
    .textw "Push DUST for the Mineral dust window." L
    .textw "Push OCFF for the Organic Carbon from Fossil Fuels window." L
    .textw "Push LBCs to select which aerosol LBCs to generate" L
    .textw "Push Aero_Clims to go to the Aerosol Climatologies" L
    .textw "Push AERO_FX for the Aerosol Effects window" L
    .pushnext "TRA" atmos_Config_Tracer
    .pushnext "SULP" atmos_Science_Section_Aero_Sulphur
    .pushnext "SOOT" atmos_Science_Section_Aero_Soot
    .pushnext "BIOM" atmos_Science_Section_Aero_Bmass
    .pushnext "DUST" atmos_Science_Section_Aero_Dust
    .pushnext "OCFF" atmos_Science_Section_Aero_OCFF
    .pushnext "LBCs" atmos_Science_Section_Aero_LBC
    .pushnext "Aero_Clims" atmos_Science_Section_AeroClim      
    .pushsequence "AERO_FX" atmos_Science_Section_Aero_Effects
  .panend


