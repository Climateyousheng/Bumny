.winid "atmos_Science_Section_RadCloud"
.title "Cloud in Radiation"
.wintype entry
.panel

    .gap
      .basrad "Select representation of clouds" L 3 v SW2CLOUD
           "Ice and water segregated for single cloud type" 2
           "Homogeneous mixed-phased clouds" 3    
           "Segregated mixed-phased clouds " 4 
      .gap
      .basrad "Select option for overlapping clouds" L 3 v SW2OLAPC
           "Maximum-random" 0
           "Random" 1
           "Exponential-random" 3
    .gap
    .block 1
    .case SW2OLAPC=="3"
      .entry "Decorrelation pressure scale for stratiform cloud" L DPCRSTRAT 15
    .caseend  
    .case SW2OLAPC=="3"&&(SW2CLOUD=="3"||SW2CLOUD=="4")
      .entry "Decorrelation pressure scale for convective cloud" L DPCRCONV 15
    .caseend      
    .blockend
    .basrad "Select method for representing horizontal water content variability" L 3 v I_INHOM 
           "Homogeneous" 0
           "Scaling factor" 1
           "McICA" 2

    .case I_INHOM=="1"||I_INHOM=="2"
      .entry "Select water content variability" L I_FSD 15
    .caseend

    .case I_INHOM=="1"&&I_FSD=="0"
      .table cloudinh "Cloud Inhomogeneties" top h 4 4 NONE
        .elementautonum "line" 1 4 5
        .element "Value" SWCLDINHOM 4 15 in
        .element "Value" LWCLDINHOM 4 15 in
      .tableend  
    .caseend

    .case I_INHOM=="2"&&I_FSD=="0"
      .entry "Normalised cloud condensate standard deviation" L MCICASIGMA 15
    .caseend
   .gap
   .text "Specify types of droplets and ice crystals consistent with the spectral file:" L
   .block 1
     .entry "Type number for water droplet in stratiform clouds (SW)" L SWTWSC 15
     .entry "Type number for water droplet in convective clouds (SW)" L SWTWCC 15
     .entry "Type number for ice crystals in stratiform clouds (SW)"   L SWTISC 15
     .entry "Type number for ice crystals in convective clouds (SW)"  L SWTICC 15
     .entry "Type number for water droplet in stratiform clouds (LW)" L LWTWSC 15
     .entry "Type number for water droplet in convective clouds (LW)" L LWTWCC 15
     .entry "Type number for ice crystals in stratiform clouds (LW)"  L LWTISC 15
     .entry "Type number for ice crystals in convective clouds (LW)"  L LWTICC 15
   .blockend

   .gap
   .check "Including cloud micro-physics in the LW" L LW2MICROP Y N
   .check "Number of columns to be sub-sampled by the ISCCP simulator" L LWISCCP Y N
   .case LWISCCP=="Y"
     .block 1
     .entry "only required for diagnostics 2,269-2,277" L LWISNCOL 15
     .blockend
   .caseend

   .gap
.comment  .textw "Push SW to go to SW Radiation panel" L
.comment  .textw "Push LW to go to LW Radiation panel" L
  .pushnext "SW" atmos_Science_Section_SW
  .pushnext "LW" atmos_Science_Section_LW

.panend 
