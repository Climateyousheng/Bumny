.winid "atmos_Science_Section_LW"
.title "Section 2: LW Radiation"
.wintype entry
.comment .procs {} {} {check_lw_sw ; # mirrow LW and SW sections and some switches}
.panel
.comment  .basrad "Choose the relevant option" L 2 v ATMOS_SR(2)
.comment      "LW radiation not included" 0A
.comment      "Include 2-stream and radiance code" 3Z 
  .gap         
  .block 1
  .case  ATMOS_SR(2)!="0A"
   .block 1
    .basrad "Options for multiple calls to radiation:" L 4 v LSWUSE3C
        "Single call" 0
        "Diagnose radiative forcings" 1
        "Timestepping scheme" 2
        "Diagnostic calculation of radiances" 3
   .blockend
   .gap
   .check "Treatment of surface emissivity and temperature as in GL4" L LGL4 Y N
  .check "Run without radiation" L L_RADIATION Y N 
  .check "Use mixing ratio formulation for the parallel physics" L LMRPHYSICS1 Y N 
  .blockend
  .gap 
  .block 1  
  .case ATMOS_SR(2)!="0A"
   .basrad "Choose segment option" L 2 h LWSOPT
      "Use number of segments" 0
      "Use segment size" 1    
     .block 2
     .invisible LWSOPT == "0"
        .entry "Number of segments" L LWSEG 15
     .invisend
     .invisible LWSOPT == "1"
        .entry "Segment size" L LWSEGSZ 15
     .invisend
     .blockend
    .gap
    .block 1
     .entry "Number of bands" L LWBND 15
     .entry "Number of times a day to calculate increments (Prognostic)" L LWINC 15
     .case LSWUSE3C!="0"
       .entry "Number of times a day to calculate increments (Diagnostic)" L ALWRADSTDIAG 15
     .caseend
    .blockend
  .caseend
  .gap
  .case ATMOS_SR(1)!="0A"
    .check "Spatial degradation of radiation calculations" L RADDEG T F 
  .caseend
  .blockend
  .case ATMOS_SR(2)!="0A"
  .gap
  .textw "Push GEN2 to go on to get options for general 2-stream radiation" L
  .textw "Push CO2 to define CO2 Mass Mixing Ratios." L
  .textw "Push Ozone to go to Ozone window" L
  .textw "Push Aero_Clims to go to the Aerosol Climatologies" L
  .textw "Push COSP to go to the COSP Satellite Simulator" L
  .pushsequence "Gen2" atmos_Science_Section_LWGen2
  .pushnext "CO2" atmos_Science_Physics
  .pushnext "Cloud" atmos_Science_Section_RadCloud
  .pushnext "Call2" atmos_Science_Section_RadCall2
  .pushnext "Ozone" atmos_Science_Section_Ozone
  .pushnext "Aero_Clims" atmos_Science_Section_AeroClim  
  .pushnext "COSP" atmos_Science_Section_LWCOSP 
.panend
.comment .set_on_closure "3C Forcing & Timing switches" LLWUSE3C LLWCLDINH LWCLDINHOM RADPERTLW ATMOS(2)
.set_on_closure "Hidden variable: Is this Edwards-Slingo Radiation. 0= not, 1SW 2LW 3Both" ES_RAD





