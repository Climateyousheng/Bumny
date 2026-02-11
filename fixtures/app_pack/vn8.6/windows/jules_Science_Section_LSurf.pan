.winid "jules_Science_Section_LSurf"
.title "JULES Section 1: Land Surface"
.wintype entry

.panel
  .gap
  .block 1
  .case JULES=="T"
      .entry "Number of plant functional types" L JI_PFTYPE 8
      .entry "Number of non-veg types" L JI_NVTYPE 8
      .check "Aggregate tile properties" L JL_AGGREGATE Y N
      .case JL_AGGREGATE=="Y"
        .block 2
        .entry "Option for aggregation" L IAGGREGATE 5
        .blockend
     .caseend
  .caseend
  .blockend

  .block 1 
  .case ATMOS_SR(3) != "0A"
      .check "Using coastal tiling" L CTILE Y N
      .check "Use neighbouring sea point wind speeds in coastal grid points" L BUDDYSEA Y N  
      .textw "See help regarding the setting of emissivities" L
  .caseend
      .check "Treatment of surface emissivity and temperature as in GL4" L LGL4 Y N
  .blockend
  .block 1
  .case ATMOS_SR(3) != "0A"
     .basrad "Fractional snow cover for sublimation and melting" l 2 h FRSNSBMLT
            "Off" 0
            "On" 1
  .blockend
    .block 1
      .basrad "Select thermal vegetation canopy " L 4 v BLCANOPY
            "No thermal vegetation canopy" 1
            "Radiative coupling only" 2
            "Radiative coupling and thermal capacity" 3
            "Radiative coupling, thermal capacity and canopy snow" 4
    .blockend
    .block 1
      .entry "Method for treatment of canopy radiation (CAN_RAD_MOD)" L CANRADMOD 8
      .entry "Number of layers for canopy radiation (ILAYERS)" L ILAYERS 8  
      .check "Calculate the surface-energy balance on all tiles at all land points" L ALLTILES Y N
    .blockend
    .block 1
    .basrad "Select orographic stress scheme" L 3 h OROGR
        "No orographic stress" 0
        "Effective roughness" 1
        "Distributed form drag" 2
    .blockend
    .block 1
      .case OROGR!=0
        .block 2
        .entry "Set orographic form drag coefficient" L OROGDRAGP 15
        .check "Include orographic drag stability dependence" L FDSTABDP Y N
        .blockend
      .caseend
    .blockend
  .caseend
  .case JULES=="T"
    .block 1
      .case JL_AGGREGATE=="N"
        .check "Use the FLake model for inland water tiles" L JL_FLAKE T F
      .caseend
      .check "Correction to potential evap. calculation" L JL_EPOTCORR Y N
     .blockend
  .caseend
  .case ATMOS_SR(3) != "0A"  
    .entry "Select method of calculating soil thermal conductivity (1 old, 2 new)" L SOILHC 8 
    .textw "Please see help for Surface Type Parameter variable description and default values:" L
    .block 1
      .table jules_nvg "Non-Vegetation Surface Type Parameters" top h JI_NVTYPE 6 NONE
        .elementautonum "Non-Veg. Type" 1 6 13
        .element "ALBSNC_NVG_IO" ALBSNC_NVG JULES_NVT 14 in
        .element "ALBSNF_NVG_IO" ALBSNF_NVG JULES_NVT 14 in
        .element "CATCH_NVG_IO" CATCH_NVG JULES_NVT 14 in
        .element "GS_NVG_IO" GS_NVG JULES_NVT 14 in
        .element "INFIL_NVG_IO" INFIL_NVG JULES_NVT 14 in
      .tableend
      .table jules_nvg2 "Non-Vegetation Surface Type Parameters continued..." top h JI_NVTYPE 7 NONE
        .elementautonum "Non-Veg.Type" 1 6 12
        .element "Z0_NVG_IO" Z0_NVG JULES_NVT 12 in
        .element "CH_NVG_IO" CH_NVG JULES_NVT 12 in
        .element "VF_NVG_IO" VF_NVG JULES_NVT 12 in
        .case JULES=="T"
          .element "EMIS_NVG_IO" EMIS_NVG JULES_NVT 12 in
          .element "Z0HM_NVG_IO" Z0HM_NVG JULES_NVT 12 in
        .caseend
        .element "Z0HM_CLASSIC_NVG_IO" Z0HM_CLASSIC_NVG JULES_NVT 14 in
      .tableend
    .blockend
  .caseend
  .textw "Push BACK to return to the main Surface Exchange panel" L
  .pushnext "BACK" jules_Science_Section_Surface
.panend
