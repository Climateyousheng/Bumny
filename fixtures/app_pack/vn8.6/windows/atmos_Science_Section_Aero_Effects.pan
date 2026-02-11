.winid "atmos_Science_Section_Aero_Effects"
.title "Section 17 : Aerosols. Aerosol Effects."
.wintype entry

.panel
  .text "Section17 : Aerosols. Aerosol Effects." L
  .gap
  .block 1
  .invisible LUARCLSULP=="Y"
     .textw "Warning: Sulphate aerosol climatology has been selected - this climatology will be used for the direct radiative effect." L 
  .invisend
  .check "Use the same CDNC for both indirect effects (uses second indirect effect options)" L L_CONSISTENT_CDNC Y N
  .gap
  .case (ATMOS_SR(17)!="0A")&&(CHEM_SULPC=="Y")
    .check "Sulphate aerosol: DIRECT radiative effect (SW+LW)" L SULP_RAD_DIR Y N
    .check "Sulphate aerosol: FIRST INDIRECT effect (SW)" L SULP_SW_IND Y N
    .check "Sulphate aerosol: FIRST INDIRECT effect (LW)" L SULP_LW_IND Y N
    .case (ATMOS_SR(4)=="3C" || ATMOS_SR(4)=="3D")
      .check "Sulphate aerosol: SECOND INDIRECT effect" L SULP_AUTOCONV Y N
    .caseend
    .check "Sulphate aerosol: Use for CCN in aerosol scheme" L SULP_SULPC Y N
  .caseend
  .gap
    .case (ATMOS_SR(17)!="0A")&&(CHEM_NITR=="Y")
    .check "Nitrate aerosol: DIRECT radiative effect (SW+LW)" L NITRDRCT Y N
    .case (SULP_SW_IND=="Y")||(SULP_LW_IND=="Y")
      .check "Nitrate aerosol: FIRST INDIRECT effect (SW and/or LW)" L NITRINDRCT Y N
    .caseend
    .case SULP_AUTOCONV=="Y"
  	  .check "Nitrate aerosol: SECOND INDIRECT effect" L NITRACONV Y N
    .caseend
    .case SULP_SULPC=="Y"
	  .check "Nitrate aerosol: Use for CCN in aerosol scheme" L NITRSULPC Y N
    .caseend
  .caseend
  .gap
  .invisible LUARCLSSLT=="Y"
     .textw "Warning: Sea-salt aerosol climatology has been selected - this climatology will be used for the direct radiative effect." L
  .invisend
  .check "Sea-salt aerosol: DIRECT radiative effect (SW+LW)" L SEA_RAD_DIR Y N
  .case ATMOS_SR(17)!="0A" 
    .case CHEM_SULPC=="Y"
      .case SULP_SW_IND=="Y" || SULP_LW_IND=="Y"
        .check "Sea-salt aerosol: FIRST INDIRECT effect (SW and/or LW)" L SEA_IND Y N
      .caseend
      .case SULP_AUTOCONV=="Y" && (ATMOS_SR(4)=="3C" || ATMOS_SR(4)=="3D")
        .check "Sea-salt aerosol: SECOND INDIRECT effect" L SEA_AUTOCONV Y N
      .caseend
      .case SULP_SULPC=="Y"
        .check "Sea-salt aerosol: Use for CCN in aerosol scheme" L SEA_SULPC Y N
      .caseend
    .caseend
    .check "Include Sea Salt in PM diagnostics?" L SEA_PMDIAGS Y N
  .caseend
  .gap
  .invisible LUARCLBLCK=="Y"
     .textw "Warning: Black-carbon aerosol climatology has been selected - this climatology will be used for the direct radiative effect." L
  .invisend
  .case (ATMOS_SR(17)!="0A")&&(CHEM_SOOT=="Y")
    .case ES_RAD==3
      .check "Soot aerosol: DIRECT radiative effect (SW+LW)" L SOOT_RAD_DIR Y N
    .caseend
	.case 1==2
	  .check "Soot Aerosol: FIRST INDIRECT radiative effect (SW+LW)" L SOOTINDRCT Y N
  	  .check "Soot Aerosol: SECOND INDIRECT radiative effect" L SOOTACONV Y N
	  .check "Soot Aerosol: Use for CCN in aerosol scheme" L SOOTSULPC Y N
	.caseend
  .caseend
  .gap
  .block 1
  .invisible LUARCLBIOM=="Y"
     .textw "Warning: Biomass-burning aerosol climatology has been selected - this climatology will be used for the direct radiative effect." L
  .invisend
  .case (ATMOS_SR(17)!="0A")&&(CHEM_BIOM=="Y")
    .check "Biomass aerosol: DIRECT radiative effect (SW+LW)" L BMASSDRCT Y N
    .case (SULP_SW_IND=="Y")||(SULP_LW_IND=="Y")
      .check "Biomass aerosol: FIRST INDIRECT effect (SW and/or LW)" L BMASSINDRCT Y N
    .caseend
    .case SULP_AUTOCONV=="Y"
  	  .check "Biomass aerosol: SECOND INDIRECT effect" L BMASSACONV Y N
    .caseend
    .case SULP_SULPC=="Y"
	  .check "Biomass aerosol: Use for CCN in aerosol scheme" L BMASSSULPC Y N
    .caseend
  .caseend
  .blockend
  .gap
  .block 1
  .invisible LUARCLDUST=="Y"
     .textw "Warning: Dust aerosol climatology has been selected - this climatology will be used for the direct radiative effect." L
  .invisend
  .case (ATMOS_SR(17)!="0A")&&(I_DUST!="0")
    .check "Mineral Dust aerosol: DIRECT radiative effect (SW+LW)" L DUST_DRCT Y N
      .case (DUST_DRCT=="Y")
      .textw "Exact calculation of LW Scattering must be selected" L
      .caseend
  .caseend
  .blockend  
  .gap
  .invisible LUARCLOCFF=="Y"
     .textw "Warning: OCFF aerosol climatology has been selected - this climatology will be used for the direct radiative effect." L
  .invisend
  .case (ATMOS_SR(17)!="0A")&&(CHEM_OCFF=="Y")
    .case ES_RAD==3
      .check "OCFF aerosol: DIRECT radiative effect (SW+LW)" L OCFF_RAD_DIR Y N
    .caseend
	.check "OCFF Aerosol: FIRST INDIRECT radiative effect (SW+LW)" L OCFFINDRCT Y N
  	.check "OCFF Aerosol: SECOND INDIRECT radiative effect" L OCFFACONV Y N
	.check "OCFF Aerosol: Use for CCN in aerosol scheme" L OCFFSULPC Y N
  .caseend
  .blockend
  .gap
  .block 1
  .check "Enable aerosol optical depths diagnostics?" L LUSEAOD Y N
  .blockend
  .gap
.comment  .textw "Push SULP for Sulphur window" L
.comment  .textw "Push SOOT for Soot window" L
.comment  .textw "Push BIOM for Biomass-burning window" L
.comment  .textw "Push Aero_Clims to go to the Aerosol Climatologies" L  
  .pushnext "SULP" atmos_Science_Section_Aero_Sulphur
  .pushnext "SOOT" atmos_Science_Section_Aero_Soot
  .pushnext "BIOM" atmos_Science_Section_Aero_Bmass
  .pushnext "BACK" atmos_Science_Section_Aero
  .pushnext "Aero_Clims" atmos_Science_Section_AeroClim  
  .pushnext "OCFF" atmos_Science_Section_Aero_OCFF    
.panend
