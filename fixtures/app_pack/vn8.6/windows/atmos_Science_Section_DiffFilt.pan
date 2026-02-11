.winid "atmos_Science_Section_DiffFilt"
.title "Section 13 : Diffusion, Divergence Damping & Filtering"
.wintype entry

.panel
   .basrad "Choose version" L 2 v ATMOS_SR(13)
            "<0A> Diffusion, Divergence Damping and filtering not included" 0A
            "<2A> Standard schemes" 2A
   .case ATMOS_SR(13)!="0A"
     .block 1
     .basrad "Polar Filter" L 3 h LCOMBI 
         "No polar filter" 0
         "Combined diffusion/filtering" Y 
         "Old polar filter" N
     .blockend
     .textw "Push COMBI or POLAR to set parameters for diffusion or filtering" L
     .block 1
     .basrad "Horizontal Diffusion" L 4 h HDIFFOPT
         "Off" 0
         "Old (not recommended)" 1
         "Conservative" 2
         "Subgrid turbulence scheme" 3
     .blockend    
     .case  (LCOMBI=="0"||LCOMBI=="Y")&&(HDIFFOPT=="0")
       .block 1
       .entry "Start level for additional upper-level horizontal diffusion" L TOPFILTSTART 25
       .entry "End level for additional upper-level horizontal diffusion" L TOPFILTEND 25
       .entry "Upper-level diffusion coefficient" L TOPDIFF 25
       .check "Ramp additional upper-level horizontal diffusion coefficient" L LUPPERRAMP T F
       .blockend
       .case LUPPERRAMP=="T"
         .block 2 
         .entry "Upper-level diffusion ramp value" L UPDIFFSCALE 25
         .blockend
       .caseend      
     .caseend 
     .block 1
     .case (LCOMBI=="Y"||LCOMBI=="N")||(HDIFFOPT=="1"||HDIFFOPT=="2")
       .textw "Specify the first horizontal level where the model surfaces are flat; 0 if no steep slope checking" L
       .entry "Horizontal level (32 is recommended for global 38/50 levels)" L STSLDIFF 25
     .caseend
     .case ATMOS_SR(13)!="2A" || LCOMBI!="N"
       .check "Truly horizontal combi-filtering and targeted diffusion" L ZLEVDIFF Y N
     .caseend
     .blockend 
     .gap
.comment VERTICAL DIFFUSION PART 
     .block 1    
     .basrad "Vertical Diffusion" L 3 h VDIFFOPT
            "Off" 0
            "Uniform" 1
            "Ramped (operational)" 2
     .blockend       
     .block 1
      .check "Energy-conserving dry convective adjustment of theta" L LADJTHETA T F
      .case LADJTHETA=="T"
        .block 2
        .entry "Start level" L ADJTHETSTART 25
        .entry "End level" L ADJTHETEND 25
        .blockend
      .caseend
      .check "Targeted diffusion of moisture - Push TARG to specify the targeted diffusion of moisture" L TDIFFOPT T F
      .case ZLEVDIFF=="N" || ATMOS_SR(13)!="2A" || LCOMBI=="N"
        .check "Use HadGEM2 settings for polar filtering" L LPOLFHG2 T F
      .caseend
      .check "Diagnostic prints - Push DIAG_PRN to specify the diagnostic prints" L PDIFFOPT T F
      .check "Using Divergence Damping" L LDIVDAMP T F
      .check "Using Moisture resetting (QPOS)" L LQPOS T F
      .block 2
        .case LQPOS=="T"
          .basrad "Moisture reset method" L 6 h QPOSMETHOD
             "Original" 1
             "Local"    2
             "Reset"    3
             "Column"   4
             "Level"    5
             "Hybrid"   6
          .entry "Minimum value for reset moisture" L QLIMIT 25
          .check "QPOS diagnostic prints" L LQPOSDIAG Y N
          .case LQPOSDIAG=="Y"
             .entry "Diagnostic print lower limit" L QPOSPRNT 25
          .caseend
        .caseend
        .basrad "Tracer reset method" L 6 h QPOSTRACER
           "Original" 1 
           "Local"    2
           "Reset"    3
           "Column"   4 
           "Level"    5 
           "Hybrid"   6
      .blockend
      .gap
      .check "Set lateral sponge zone (LAMs only)" L LSPONGE T F
      .case LSPONGE=="T"
        .block 2
        .entry "Width (at EW boundaries)" L SPONGEEW 25
        .entry "Width (at NS boundaries)" L SPONGENS 25
        .entry "Sponge weights" L SPONGEPWR 25
        .blockend
      .blockend  
      .caseend
      .gap
      .textw "Push HORIZ or VERT to specify the horizontal or vertical diffusion coefficients" L
      .textw "Push SUBGRID to specify the subgrid turbulence scheme options" L
    .caseend  
    .pushnext "COMBI" atmos_Science_Section_DiffFilt_Combi 
    .pushnext "POLAR" atmos_Science_Section_DiffFilt_Polar 
    .pushnext "HORIZ" atmos_Science_Section_DiffFiltCoef
    .pushnext "VERT" atmos_Science_Section_VertDiffCoef
    .pushnext "TARG" atmos_Science_Section_TargDiff
    .pushnext "DIAG_PRN" atmos_Science_Section_DiagPrn
    .pushnext "SUBGRID" atmos_Science_Section_Subgrid    
.panend



         
