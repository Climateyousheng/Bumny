.winid "atmos_Science_Section_UKCAMode"
.title "UKCA Aerosol Model (MODE) Parameters"
.wintype entry

.panel
  .gap
  .case ATMOS_SR(34)!="0A"
    .case active LUKCAMODE
     .case LUKCAMODE=="Y"
      .basrad "Set Aerosol Species and Modes (Please refer to Help panel)" L 2 v IMODESET
          "H2SO4, NaCl in 4 modes" 1
          "H2SO4, NaCl, BC, OC in 5 modes" 2
      .textw "Primary Emissions" L
      .block 1
      .check "Primary Sulphate Emissions ON" L LUKCAPSU Y N
      .case LUKCAPSU=="Y"
        .block 2
        .entry "\% SO2 emitted as SO4" L MDPARFRAC 15
        .blockend
      .caseend
      .check "Primary Seasalt Emissions ON" L LUKCAPSS Y N
      .check "Primary BC/OC Emissions ON" L LUKCAPBCOC Y N 
      .case LUKCAPBCOC=="Y"
        .block 2
        .check "Fossil fuel BC/OC ON (ancil required)" L LBCOC_FF Y N
        .check "Biofuel BC/OC ON (ancil required)" L LBCOC_BF Y N
        .check "Biomass burning BC/OC ON (ancil required)" L LBCOC_BM Y N
        .blockend
      .caseend
      .blockend            
      .gap
      .textw "Define Aerosol Processes" L
      .block 1
      .entry "Number of substeps for Nucleation/Sedimentation" L IMDNZTS 15
      .check "Include binary homogenous sulphate nucleation" L MDNUCLBHN Y N
      .check "Include Boundary Layer sulphate nucleation" L MDNUCLBLN Y N
      .blockend
      .case MDNUCLBLN == "Y"
        .block 2
        .basrad "Parameterisation mothod for BL Nucleation" L 3 v IMDBLN_PARAM
            "Activation" 1
            "Kinetic" 2
            "Organic-mediated rate (Metzer et al,2010,PNAS)" 3
        .blockend
      .caseend
      .block 1
      .check "Calculate Cloud Droplet Number using Abdul-Razzak and Ghan Activation Method" L LMDACT_ARG Y N
      .case LMDACT_ARG == "Y"
        .check "Calculate CCN at fixed super saturation" L LMDARG_SFIX Y N
      .caseend
      .entry "Fraction of Aitken mode scavenged by convection" L MAITSOL 15
      .blockend
    .caseend
   .caseend
  .caseend
  .gap
  .textw "Push UKCA to go back" L
  .pushnext "UKCA" atmos_Science_Section_UKCA
.panend


