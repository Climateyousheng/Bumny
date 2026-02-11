.winid "atmos_Science_Section_Veg"
.title "Section 19 : Vegetation"
.wintype entry
.procs {store_A19_L19} {} {match_A19_L19 ATMOS ; # Ensure same veg setting in ATMOS and JULES}
.panel
  .gap
  .basrad "Choose version " L 3 v ATMOS_SR(19)
	  "Vegetation distribution not included" 0A
	  "<1B> Fixed vegetation distribution" 1B
	  "<2B> Interactive vegetation distribution" 2B
  .gap
  .block 1
  .case ATMOS_SR(19)!="0A"
    .check "Include leaf phenology" L INC_VEGLPF Y N
    .case INC_VEGLPF=="Y"
      .entry "Update frequency for leaf phenology (days)" L VEGLPF
    .caseend
    .case ATMOS_SR(19)=="2B"
      .entry "Update frequency for interactive veg distribution (days)" L VEGIVF
      .check "Start an NRUN mid way through a TRIFFID calling period." L VEGSTRT Y N
      .check "Run TRIFFID in equilibrium mode" L VEGTEQ Y N
      .basrad "Choose soil decomposition dependence on temperature" L 2 v LQ10
          "Standard, RothC temperature function" 1
          "Q10 temperature function" 2
    .caseend
  .caseend
  .blockend
  .gap
  .textw "Changes require consideration of ancillary file settings:" L
  .block 1
    .textw "Push VEGA to see settings of vegetation ancillary." L
    .textw "Push VFRAC to see settings of veg fractions & structures ancillary/initialisation." L
    .textw "Push SOIL to see settings of soil-parameters ancillary." L
    .textw "Push DIST to see settings of veg disturbance ancillary." L
    .textw "Push BLAY to see settings the boundary layer section." L
    .textw "Push ACO2 to go to atmospheric CO2 specification" L
  .blockend
  .pushnext "VEGA" atmos_InFiles_PAncil_Veg
  .pushnext "VFRAC" atmos_InFiles_PAncil_VegFrac
  .pushnext "SOIL" atmos_InFiles_PAncil_Soil
  .pushnext "DIST" atmos_InFiles_PAncil_Disturb
  .pushnext "BLAY" atmos_Science_Section_BLay
  .pushnext "ACO2" atmos_Science_Physics
.panend
.set_on_closure "Set JULES section 19" JULES_SR(8)
