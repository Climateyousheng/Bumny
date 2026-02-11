.winid "atmos_Science_Section_Aero_Sulphur"
.title "Section 17 : Aerosols. Sulphur Cycle."
.wintype entry

.panel
  .gap
  .block 1
  .text "Section 17 : Aerosols. Sulphur Cycle." L
  .case ATMOS_SR(17)!="0A"
      .check "Sulphur Cycle Included"  L CHEM_SULPC Y N
  .caseend
  .gap
  .case (ATMOS_SR(17)!="0A")&&(CHEM_SULPC=="Y")
      .check "Including surface sulphur dioxide emissions." L EMSO2 Y N
      .gap
      .check "Including high-level sulphur dioxide emissions." L EMSO2H Y N
      .case EMSO2H=="Y"
        .block 2
          .entry "Specify the level" L EMSO2HL
        .blockend
      .caseend
      .gap
      .check "Including natural sulphur dioxide emissions (3D)." L EMSO2N Y N
      .gap
      .check "Including Dimethyl Sulphide (DMS)" L DMS Y N
      .case DMS=="Y"
        .block 3
          .check "Including surface DMS emissions " L EMDMS Y N
          .case EMDMS == "Y"
            .block 4
            .basrad "Including ocean DMS emissions" L 3 v IDMSE_SCH 
              "No ocean emissions" 0 
              "Ocean DMS concentrations from ancillary file" 1
              "Ocean DMS emissions from coupled ocean model" 2
            .blockend
            .gap
            .block 4  
            .case IDMSE_SCH!="0"  
              .basrad "Choose air/sea exchange scheme" L 3 v SIDMSE_SCH
                "Liss & Merlivat scheme" 1
                "Wanninkhof scheme" 2
                "Nightingale scheme" 3
           .caseend
           .blockend
          .caseend
        .blockend
        .caseend
      .gap
      .case (ATMOS_SR(34)!="0A")&&(UKCA_SOLV!=0)
        .check "Use oxidants from UKCA instead of from ancillary" L LSULPOXI Y N
        .invisible (ATMOS_SR(17)!="2B")||(LSULPOXI!="Y")
	  .textw "Depleted oxidants fed back to UKCA only available with the improved aerosol scheme <2B>" L
	.invisend
	.case (ATMOS_SR(17)=="2B")&&(LSULPOXI=="Y")
          .check "With oxidants depleted and fed back to UKCA" L LOXIDEPL Y N
        .caseend
      .caseend
      .gap
      .check "Include ozone in DMS oxidation scheme." L SULOZONE Y N
      .case SULOZONE=="Y"
        .block 2
        .case ATMOS_SR(17)=="2B"
          .basrad "Select option for oxidation of SO2 by ozone" L 3 v OXIOZ2B
            "Do not include oxidation of SO2 by ozone" 0
            "Include oxidation of SO2 by ozone, with buffering by NH3" 1
            "Include oxidation of SO2 by ozone, without buffering by NH3" 2
        .caseend        
        .blockend
      .caseend
    .blockend
    .gap
  .caseend
  .gap
  .gap
  .textw "Push for ancillary files: <SUR, surface and DMS emissions> <NAT, natural emissions> <OXI, oxidants> " L
  .pushnext "SUR" atmos_InFiles_PAncil_SulpEmis
  .pushnext "NAT" atmos_InFiles_PAncil_So2NatEm
  .pushnext "OXI" atmos_InFiles_PAncil_ChemOxid
  .pushnext "SOOT" atmos_Science_Section_Aero_Soot
  .pushnext "AERO_FX" atmos_Science_Section_Aero_Effects
  .pushnext "BACK" atmos_Science_Section_Aero
.panend


