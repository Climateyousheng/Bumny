.winid "atmos_Science_Section_RadCall2"
.title "Options for Second Radiation Call"
.wintype entry
.panel

      .basrad "Select representation of clouds" L 3 v SW2CLOUD_2
           "Ice and water segregated for single cloud type" 2
           "Homogeneous mixed-phased clouds" 3    
           "Segregated mixed-phased clouds " 4 
      .gap
      .basrad "Select option for overlapping clouds" L 3 v SW2OLAPC_2
           "Maximum-random" 0
           "Random" 1
           "Exponential-random" 3

      .basrad "Select method for representing horizontal water content variability" L 3 v I_INHOM_2 
           "Homogeneous" 0
           "Scaling factor" 1
           "McICA" 2

      .case I_INHOM_2=="1"||I_INHOM_2=="2"
        .entry "Select water content variability" L I_FSD_2 15
      .caseend
   .gap
   .text "Specify types of droplets and ice crystals consistent with the spectral file:" L
   .block 1
     .entry "Type number for water droplet in stratiform clouds (SW)" L SWTWSC_2 15
     .entry "Type number for water droplet in convective clouds (SW)" L SWTWCC_2 15
     .entry "Type number for ice crystals in stratiform clouds (SW)"   L SWTISC_2 15
     .entry "Type number for ice crystals in convective clouds (SW)"  L SWTICC_2 15
     .entry "Type number for water droplet in stratiform clouds (LW)" L LWTWSC_2 15
     .entry "Type number for water droplet in convective clouds (LW)" L LWTWCC_2 15
     .entry "Type number for ice crystals in stratiform clouds (LW)"  L LWTISC_2 15
     .entry "Type number for ice crystals in convective clouds (LW)"  L LWTICC_2 15
   .blockend

   .check "Including cloud micro-physics in the LW" L LW2MICROP_2 Y N

   .gap
   .textw "Gas Options" L
    .basrad "Select treatment for gaseous absorption (SW)" L 3 h SW2OLAPG_2
            "Random Overlap" 2    
            "Equivalent extinction" 5
            "Equivalent extinction (corrected scaling)" 4

    .check "Include absorption by O2 (SW)"  L SW2OXYABS_2 Y N
    .check "Include absorption by CH4 (SW)" L LCH4_SW_2 Y N
    .check "Include absorption by N2O (SW)" L LN20_SW_2 Y N

    .gap
    .basrad "Select treatment for gaseous absorption (LW)" L 4 h LW2OLAPG_2
            "Random Overlap" 2    
            "Equivalent extinction" 5
            "Equivalent extinction (modulus of fluxes)" 6
            "Equivalent extinction (corrected scaling)" 4
  
    .check "Include absorption by N2O (LW)" L LW2NOXABS_2 Y N
    .check "Include absorption by CH4 (LW)" L LW2METHABS_2 Y N
    .check "Include absorption by CFC11 (LW)" L LW2CFC11ABS_2 Y N
    .check "Include absorption by CFC12 (LW)" L LW2CFC12ABS_2 Y N
    .check "Include absorption by CFC113 (LW)" L LW2CFC113ABS_2 Y N    
    .check "Include absorption by CFC114 (LW)" L LW2CFC114ABS_2 Y N
    .check "Include absorption by HCFC22 (LW)" L LW2HCFC22ABS_2 Y N
    .check "Include absorption by HFC125 (LW)" L LW2HFC125ABS_2 Y N
    .check "Include absorption by HFC134A (LW)" L LW2HFC134AABS_2 Y N

    .gap
    .basrad "Enter treatment of scattering in LW" L 3 h LW2APPSC_2
        "Full" 1
        "Approximate" 4
        "Hybrid" 5

    .check "Include tail of solar flux in the LW radiation" L LSLRTLFLUX_2 T F   
  .gap
.comment  .textw "Push Back to go to Cloud panel" L
.comment  .textw "Push SW to go to SW Radiation panel" L
.comment  .textw "Push LW to go to LW Radiation panel" L
  .pushnext "Back" atmos_Science_Section_RadCloud
  .pushnext "SW" atmos_Science_Section_SW
  .pushnext "LW" atmos_Science_Section_LW
.panend
 
