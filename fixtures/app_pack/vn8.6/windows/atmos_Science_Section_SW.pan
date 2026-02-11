.winid "atmos_Science_Section_SW"
.title "Section 1: SW Radiation"
.wintype entry
.comment .procs {} {} {check_sw_lw ; # mirrow LW and SW sections and some switches}
.panel
.comment  .basrad "Choose version" L 2 v ATMOS_SR(1)
.comment      "SW radiation not included" 0A
.comment      "Include 2-stream and radiance code" 3Z
  .gap
  .case ATMOS_SR(1)!="0A"
    .basrad "Options for multiple calls to radiation:" L 4 v LSWUSE3C
        "Single call" 0
        "Diagnose radiative forcings" 1
        "Timestepping scheme" 2
        "Diagnostic calculation of radiances" 3
  .caseend   
  .block 1      
    .check "Run without radiation" L L_RADIATION Y N
    .check "Use mixing ratio formulation for the parallel physics" L LMRPHYSICS1 Y N 
  .blockend
  .case ATMOS_SR(1)!="0A"
    .block 1
    .basrad "Choose segment option" L 2 h SWSOPT
        "Use number of segments" 0
        "Use segment size" 1
 
      .invisible SWSOPT == "0"
        .entry "Number of segments" L SWSEG 15
      .invisend
      .invisible SWSOPT == "1"
        .entry "Segment size" L SWSEGSZ 15
      .invisend     
      .entry "Number of bands" L SWBND 20         
      .entry "Number of times per day to calculate increments (Prognostic)" L SWINC 20
      .case LSWUSE3C!="0"
        .entry "Number of times a day to calculate increments (Diagnostic)" L ASWRADSTDIAG 20       
      .caseend

      .check "Sea-ice semi-implicit scheme" L LSICEHTFLUX  T F
      .case (ATMOS=="T"&&NEMO=="T"&&CICE=="T")
        .check "Include dependence of sea-ice albedo on snow depth" L SSICEALBEDO Y N
        .invisible (ATMOS=="T"&&NEMO=="T"&&CICE=="T") && SSICEALBEDO=="Y"
          .entry "Albedo of snow free sea-ice" L SSALPHAB 20
          .entry "Albedo of melting deep snow on sea-ice" L SSALPHAM 20
          .entry "Albedo of cold deep snow on sea-ice" L SSALPHAC 20
          .entry "Temperature range over which deep snow albedo varies" L SSDTICE 20
          .check "Include dependence of sea-ice albedo on melt ponds" L L_SIMELTP Y N
          .case L_SIMELTP=="Y"
            .block 2
              .entry "Temperature below freezing at which melt ponds form (C)" L DT_BARE 15
              .entry "Increment to albedo for each degree temperature rises above minimum" L DALB_BAREWET 15
              .check "Enable HadGEM1A correction" L L_SIHADGEM1A Y N
            .blockend  
          .caseend
          .check "Including dependence of sea-ice albedo on internal scattering" L L_SISCATTER Y N
          .case L_SISCATTER=="Y"
            .block 2
              .entry "Fraction of SW radiation that penetrates sea-ice and scatters" L PEN_RAD_FRAC 22
              .entry "Attenuation factor" L SW_BETA 22
            .blockend
          .caseend
        .invisend
      .caseend    
      .invisible (CICE=="F" && NEMO=="F") || (ATMOS=="T" && NEMO=="T" && CICE=="T" && SSICEALBEDO=="N")
        .entry "Minimum albedo of sea ice" L ALPHAM 20
        .entry "Maximum albedo of sea ice" L ALPHAC 20
        .entry "Temperature range over which the albedo varies linearly between max and min values" L DTICE 20
      .invisend
      .check "Include the equation of time in the astronomy" L L_EQT T F
      .check "Include secular variation of the orbital parameters (see help)" L LSECVAR T F
      .check "Spatial degradation of radiation calculations" L RADDEG T F
    .blockend
    .gap
    .basrad "Orographic correction" L 5 v IUSEORCORR 
        "Flat surface" 0
        "Surface slopes affect direct SW (smoothed model orography)" 1
        "Surface slopes affect direct SW (ancillary gradient fields)" 2
        "Slopes and shading affect direct SW, skyview factor affects LW (smoothed model orography)" 3
        "Slopes and shading affect direct SW, skyview factor affects LW (ancillary gradient fields)" 4
  .caseend  
  .gap
  .pushsequence "Gen2" atmos_Science_Section_SWGen2  
  .pushnext "Cloud" atmos_Science_Section_RadCloud
  .pushnext "Call2" atmos_Science_Section_RadCall2
  .pushnext "Ozone" atmos_Science_Section_Ozone
  .pushnext "Aero_Clims" atmos_Science_Section_AeroClim

.panend
.comment .set_on_closure "3C Forcing & Timing switches" LSWUSE3C LSWCLDINH SWCLDINHOM
.set_on_closure "Hidden variable: Is this Edwards-Slingo Radiation. 0= not, 1SW 2LW 3Both" ES_RAD

