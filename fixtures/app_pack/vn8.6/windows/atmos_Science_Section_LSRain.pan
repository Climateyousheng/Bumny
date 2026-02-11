.winid "atmos_Science_Section_LSRain"
.title "Section 4 : Large Scale Precipitation"
.wintype entry
.procs {} {} {check_cloud-rain}

.panel
   .basrad "Choose version" L 2 v ATMOS_SR(4)
       "Large scale precipitation not included" 0A
       "<3D> Advanced microphysics scheme compatible with PC2" 3D
   .gap
   .check "Run without precipitation scheme" L L_RAIN Y N
   .check "Use mixing ratio formulation for the parallel physics" L LMRPHYSICS1 Y N   
   .case ATMOS_SR(4)!="0A"
     .check "Run with multiple iterations of the precipitation scheme" L LMCRITER Y N
     .block 1
       .case LMCRITER=="Y"
         .entry "Number of substeps over each level" L MCRITS 15
         .entry "Number of substeps over full column" L NITER_BS 15
       .caseend
     .blockend
     .text "Choose additional prognostics (see help)" L
     .block 1

     .check "Include prognostic rain" L MCRGRAIN T F
     .check "Include prognostic graupel" L MCRGRPUP T F
     .blockend
     .check "Enable tapering of cloud droplets towards surface" L LDROP_TPR Y N
     .case LDROP_TPR=="Y"
       .block 1
       .entry "Select Altitude below which to taper in metres" L ZPEAK_ND 15
       .entry "Surface droplet number concentration (per cubic metre)" L NDROP_SURF 15
       .check "Use variable taper curve" L LTAPERNEW Y N
       .case LTAPERNEW=="Y"
         .entry "Max surface droplet number concentration (per cubic metre)" L MAXDROP_SURF 15
       .caseend
       .blockend
     .caseend
     .check "Run with iterative melting" L L_ITMELT T F
     .textw "Choose autoconversion options (see help)" L
     .check "Use bias-removal scheme in autoconversion parametrisation" L DEBIAS Y N
     .check "Use autoconversion formulation based on Tripoli and Cotton formulation" L L_AUTOC3B T F
     .check "Use improved warm rain microphysics scheme (see help)" L LMICRO_KK Y N
     .case LMICRO_KK=="Y"
       .block 1
       .entry "Cloud-rain correlation coefficient" L ALPHA_Q 10
       .check "Use same FSD for warm rain microphysics as used in cloud generator" L LFSD_GEN Y N
       .blockend
     .caseend 
     .check "Use Abel and Shipway (2007) rain fall speeds " L LRAINFALL T F
     .case TOTAE == "Y" && L_MCRARCL=="F"
       .check "Use the murk aerosol to calculate droplet number" L L_AUTOCMURK T F
     .caseend
     .case L_AUTOCMURK=="T"
       .check "Change to Clark et al murk aerosol scheme" L L_CLARKAERO T F
     .caseend
     .case L_AUTOCMURK=="F"
       .check "Use climatological aerosols to calculate droplet number (second indirect effect)" L L_MCRARCL T F
         .block 2
         .case L_MCRARCL=="T"
           .entry "Scaling factor for drop number derived from climatological aerosols" L ARCLINHSC 10
         .caseend
         .blockend
     .caseend 
     .gap
     .basrad "Choose drizzle and rain representation" L 3 v DRREP
         "Standard rain and autoconversion parameters (recommended)" 1
         "Use HadGEM tuning of ec_auto (for HadGEM family)" 2
         "Explicitly define parameters (see Help)" 3
       .case DRREP=="3"
         .block 2
         .textw "Set raindrop size distribution parameters:" L
         .entry "X1R" L X1R 15
         .entry "X2R" L X2R 15
         .blockend 
       .caseend
   .caseend   
   .textw "Push ICE to set parameters for ice particles." L
   .textw "Push CLD for Cloud section." L
   .pushsequence "ICE" atmos_Science_Section_LSRain2 
   .pushnext "CLD" atmos_Science_Section_Cloud   
.panend
