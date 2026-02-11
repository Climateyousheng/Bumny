.winid "atmos_Science_Section_LWGen2"
.title "Section 2 : LW Radiation, options for general 2-stream radiation."
.wintype entry
.panel
  .invisible ES_RAD==2||ES_RAD==3
    .textw "You have chosen general 2-stream LW radiation. Define mode:" L
    .text "Specify the location of the longwave spectral file" L 
    .block 1
      .entry "Directory:" L PATHLW
      .entry "Prognostic File" L FILELW
      .case ATMOS_SR(2)=="3Z" && LSWUSE3C!="0"
        .entry "Diagnostic File" L FILELWD
      .caseend
    .blockend
    .gap
    .basrad "Select 2-stream option" L 4 h LW2SOPT
            "PIFM85 with D=1.66" 12    
            "PIFM85" 6    
            "Discrete ordinate" 4
            "Hemispheric Mean" 14
    .gap
    .basrad "Select treatment of overlapping for gaseous absorption" L 4 v LW2OLAPG
            "Random Overlap" 2    
            "Equivalent extinction" 5
            "Equivalent extinction (modulus of fluxes)" 6
            "Equivalent extinction (corrected scaling)" 4
  .invisend 

  .invisible ES_RAD==2||ES_RAD==3
    .gap
    .basrad "Enter treatment of scattering" L 3 h LW2APPSC
        "Full" 1
        "Approximate" 4
        "Hybrid" 5
    .basrad "Choose option for variation of source function across layers" L 2 h LW2VSF
            "Linear." 1    
            "Quadratic." 2
    .check "Include tail of solar flux in the LW radiation" L LSLRTLFLUX T F    
    .gap
    .case ATMOS_SR(17)!="0A"
       .text "See the Aerosols window for direct and indirect effects of sulphate, sea-salt and soot" L 
    .caseend
  .invisend
  .invisible  ES_RAD!=2&&ES_RAD!=3
    .textw "You have NOT chosen general 2-stream LW radiation. Empty window" L 
  .invisend
  .textw "Push LW to go back to LW rad section" L
  .invisible ES_RAD==2||ES_RAD==3
     .textw "Push Trace Gases to set MMRs of CH4, N2O, CFC11, CFC12, CFC113, CFC114 ,HCFC22, HFC125 and HFC134A" L
  .invisend
  .invisible  ES_RAD!=2&&ES_RAD!=3
    .textw "Ignore Trace Gases button. This is for general 2-stream LW radiation " L
  .invisend
  .gap
  .pushnext "LW" atmos_Science_Section_LW
  .pushnext "Trace_Gases" atmos_Science_Section_LW_Meth
  .pushnext "SW_Forc" atmos_Science_Section_SLWForce
  .pushnext "Aero_Clims" atmos_Science_Section_AeroClim  
.panend





