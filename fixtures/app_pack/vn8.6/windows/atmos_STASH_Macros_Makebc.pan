.winid "atmos_STASH_Macros_Makebc"
.title "Makebc Macro"
.wintype entry

.panel
  .text "Specify the macro for Makebc" L
  .basrad "Choose mode" L 2 v IMKBC
	  "No Macro" 0
	  "Standard Macro" 1
  .gap
  .case IMKBC==1
    .check "WGDOS pack fields" L PACKVARBC Y N
    .gap
    .textw "Optional Fields:" L
    .block 1
      .case TOTAE=="Y"
        .check "murk" L MBC_MURK Y N
      .caseend
      .case ATMOS_SR(4)=="3D"
        .check "PC2" L MBC_PC2 Y N
          .check "Cloud Ice" L MBC_CLD Y N
        .case MCRGRAIN=="T"
          .check "Rain" L MBC_RAIN Y N
        .caseend
        .case MCRGRPUP=="T"
          .check "Graupel" L MBC_GRA Y N
        .caseend
      .caseend
      .case ATMOS_SR(17)!="0A"
        .case I_DUST=="1"
          .check "Dust" L MBC_DUST Y N
        .caseend
        .case CHEM_SULPC=="Y"
          .check "Sulphates" L MBC_SULP Y N
          .case DMS=="Y"
            .check "DMS." L MBC_DMS Y N
          .caseend
          .case SULOZONE=="Y"
            .check "Ammonia" L MBC_NH4 Y N
          .caseend
        .caseend
        .case CHEM_SOOT=="Y"
          .check "Black carbon" L MBC_BLKC Y N
        .caseend
        .case CHEM_BIOM=="Y"
          .check "Biomass burning" L MBC_BIOM Y N
        .caseend
        .case CHEM_OCFF=="Y"
          .check "Fossil fuel organic carbon" L MBC_OCFF Y N
        .caseend
        .case ATMOS_SR(17)=="2B" && CHEM_SULPC=="Y" && CHEM_NITR=="Y"
          .check "Nitrate" L MBC_NITR Y N
        .caseend
       .caseend
    .blockend
    .gap
    .textw "STASH output:" L
    .block 1 
      .basrad "Time Specification" L 2 h MBC_UNT
        "Timesteps" T
        "Hours"     H
      .entry "Start" L MBC_STRT 15
      .entry "End" L MBC_END 15
      .entry "Frequency" L MBC_FREQ 15
    .blockend
  .caseend
  .gap
  .pushnext "Tracers" atmos_Config_Tracer
  .pushnext "UKCA_Tracers" atmos_Config_Tracer_UKCA
.panend


