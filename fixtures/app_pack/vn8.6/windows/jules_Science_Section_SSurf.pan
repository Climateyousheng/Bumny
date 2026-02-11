.winid "jules_Science_Section_SSurf"
.title "JULES Section 1: Sea Surface"
.wintype entry

.panel
  .gap
  .case ATMOS_SR(3)!="0A"
    .block 1
      .case ATMOS=="T" && NEMO=="F" && CICE=="F"
        .check "Calculate Tstar over sea ice in same way as over land points"  L LTSTARSICEN Y N
      .caseend
      .check "Include the effect of salinity on evaporative fluxes" L SEASALFAC Y N
      .entry "Charnock parameter for roughness length over sea points" L CHARNOCK 15
      .entry "Number of sea ice categories" L NCICECAT 15
      .entry "Emissivity of open sea" L EMIS_SEA 15
      .entry "Emissivity of sea ice" L EMISSICE 15
      .gap
      .entry "Marginal ice zone" L Z0_MIZ 15
      .entry "Pack ice" L Z0_SICE 15
      .check "Use wind-speed dependent thermal roughness lengths" L L_SRFDIVZ Y N
     .blockend
  .caseend
  .gap
  .block 1
     .entry "Ratio of thermal to momentum roughness lengths for marginal ice" L Z0H_Z0M_MIZ 15
     .entry "Ratio of thermal to momentum roughness lengths for pack ice" L Z0H_Z0M_SICE 15
     .entry "Thermal conductivity of sea ice in zero-layer ice model"  L KAPPAI 15
     .entry "Thermal conductivity of snow on sea ice" L KAPPAS 15
     .entry "Effective thermal conductivity of sea surface layer"  L KAPPA_SSL 15
  .blockend
  .gap
  .block 1
    .basrad "Open sea albedo from" L 3 v SEA_ALBMTH
      "Original UM" 1
      "Modified Barker (1995)" 2
      "Jin et al (2011)" 3
    .check "Use spectrally dependent sea albedos" L LSPEC_SALB Y N
    .case SEA_ALBMTH=="3"
      .check "Include varying chlorophyll content in open sea albedo" L LSEA_ALBCHL Y N
    .caseend
  .blockend
  .gap
  .textw "Push BACK to return to the main Surface Exchange panel" L
  .pushnext "BACK" jules_Science_Section_Surface
.panend
