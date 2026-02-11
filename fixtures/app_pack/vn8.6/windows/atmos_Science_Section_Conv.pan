.winid "atmos_Science_Section_Conv"
.title "Section 5 : Convection"
.wintype entry
.procs {} {} {check_cloud-conv}

.panel 
.textw "Please check your settings on the conv_diag panel as these apply to the 0A convective diagnosis" L 
 .basrad "Choose version" L 4 v ATMOS_SR(5) 
     "<0A>Convection not included" 0A 
     "<4A> Previously known as CMODS. Built on the basic 3C scheme but with major differences." 4A 
     "<5A> Turbulence and mass flux convection" 5A 
     "<6A> Turbulence and mass flux convection (research version)" 6A 
 .gap 
 .case ATMOS_SR(5)!="0A" 
   .block 1  
     .basrad "Choose segment option" L 2 h CSOPT 
          "Use number of segments" 0 
          "Use segment size" 1 
     .block 2 
       .invisible CSOPT == "0" 
          .entry "Number of segments" L CONSEG 15 
       .invisend 
       .invisible CSOPT == "1" 
          .entry "Segment size" L CONSEGSZ 15 
       .invisend 
     .blockend 
     .basrad "Choose convection option" L 2 v CONVOPT 
         "Convection turned off (only for idealised cases). Please see conv_diag panel. Some options may still influence Boundary layer." F 
         "Time level n* data, increments not advected (Recommended)" T 
   .blockend 
   .block 1 
     .entry "Number of convection calls per physics timestep" L CONFRE 15 
   .blockend  
   .block 1 
     .check "Apply various safety checks to convection" L LSAFECONV Y N 
     .check "With convective momentum transports included" L CON_MOM Y N   
   .blockend 
   .block 1   
     .entry "Deep CMT option" L DPCMTOPT 15 
     .entry "Mid-level CMT option" L MIDCMTOPT 15 
     .invisible ATMOS_SR(5)=="4A" 
       .check "Click for deep CMT to use KTERM instead of NTPAR" L L4A_KTERM Y N 
     .invisend 
   .blockend 
   .block 1 
     .basrad "Choice of detrainment scheme" L 8 v ADAPT 
         "No adaptive detrainment" 0 
         "Adaptive detrainment, deep convection (4a/5a)" 3 
         "Adaptive detrainment, deep and mid convection (operational/HadGem1a) (4a/5a)" 1 
         "Adaptive detrainment, deep, mid and shallow convection (4a/5a)" 4 
         "Smooted adaptive detrainment, deep and mid convection (4a/5a) " 5 
         "Smoothed adaptive detrainment, deep, mid and shallow convection (4a/5a)" 6 
         "Improved smoothed adaptive detrainment, deep and mid convection (4a/5a/6a)" 7 
         "Improved smoothed adaptive detrainment, deep mid and shallow convection (4a/5a/6a)" 8 
     .block 2 
       .entry "Parameter controlling deep mixing detrainment" L AMDET_FAC 15  
       .case ADAPT!=0 
         .entry "Parameter controlling adaptive detrainment" L R_DET 15 
       .caseend 
       .case ATMOS_SR(5)=="6A"        
         .entry "Method for calculating forced detrainment rate" L FDET_OPT 15 
       .caseend  
       .case ATMOS_SR(5)=="4A"        
         .entry "Parameter controlling mid-level and deep entrainment" L ENT_FAC 10 
       .caseend
     .blockend     
     .basrad "Choice of CAPE closure scheme" L 7 v CAPE_OPT 
         "RH based CAPE buoyancy closure" 0 
         "RH based CAPE buoyancy closure with timestep as min timescale" 1 
         "CAPE buoyancy closure with fixed timescale" 2 
         "Grid-box area scaled cape closure" 4 
         "Vertical velocity dependent CAPE closure" 3 
         "RH and vertical velocity dependent CAPE closure" 6 
         "Large-scale w based CAPE closure " 7
     .block 2   
       .invisible CAPE_OPT=="4" 
         .entry "Value of CAPE below which parametrized convection is reduced" L CAPE_MIN 15 
       .invisend  
       .invisible CAPE_OPT=="3"||CAPE_OPT=="6" 
         .entry "Threshold vertical velocity" L W_CAPE_LIMIT 15 
         .entry "Lowest model level for rescaling parametrized convection" L CAPE_BOTTOM 15 
         .entry "Highest model level for rescaling parametrized convection" L CAPE_TOP 15 
       .invisend  
     .blockend 
     .entry "Timescale in seconds for CAPE closure scheme" L CAPETSCALE 15 
   .blockend 
   .gap 
   .block 1 
     .check "Use Emanuel downdraught scheme" L LEMAN_DD Y N 
     .entry "Downdraught version" L DDOPT 15 
     .check "Allow melting of snow over a range of temperatures" L LSNOW_RAIN Y N
     .case LSNOW_RAIN=="Y"
       .entry "Temperature at which all snow melts" L TMELT_SNOW 15
      .caseend
     .entry "Minimum pressure for mid level convection (Pa)" L MDCNVPMIN 15 
     .entry "Sub cloud mixing method" L BLCNVMIX 15 
     .check "Use revised shallow cumulus parcel perturbations" L SHPERT 1 0 
     .entry "Limit initial parcel perturbation option" L LIMPERTOPT 15 
     .entry "Water Loading Option" L WATLDOPT 15 
   .blockend 
   .block 1 
     .check "Use new termination condition for deep and mid-level convection" L TERMCONV 1 0 
     .check "Include convective history prognostics" L LCONVHIST Y N 
   .blockend 
   .invisible ATMOS_SR(5)=="5A" || ATMOS_SR(5)=="6A" 
     .block 1 
       .entry "Shallow convection" L CONV_SHLW 15 
       .entry "Congestus convection" L CONV_CNGS 15 
       .entry "Deep convection" L CONV_DEEP 15 
       .entry "Mid-level convection" L CONV_MID 15 
       .entry "Entrainment profile for deep convection" L ENTOPTDP 15 
       .case ENTOPTDP=="3" 
         .entry "Power for deep entrainment option 3" L ENTDPPOWER 15 
       .caseend 
       .entry "Parameter controlling deep entrainment" L ENTFACDP 15 
       .entry "Entrainment profile for mid-level convection" L ENTOPTMID 15 
       .case ENTOPTMID=="3" 
         .entry "Power for mid entrainment option 3" L ENTMDPOWER 15 
       .caseend 
       .entry "Parameter controlling mid-level entrainment" L ENTFACMID 15 
       .check "Apply an energy correction to the convection scheme" L LCVCONSERVE Y N 
     .blockend 
   .invisend  
 .caseend   
 .case ATMOS_SR(5)=="6A" 
   .block 1
   .check "Include CMT heating (6a only)" L LCMTHEAT Y N
   .blockend
 .caseend
 .gap   
 .textw "Push Conv_CLOUD to set other parameters" L 
 .pushsequence "Conv_CLOUD" atmos_Science_Section_Conv2 
 .pushnext "Conv_Diag" atmos_Science_Section_ConvDiag 
.panend 
 
 
