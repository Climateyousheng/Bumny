.winid "atmos_Science_Section_Subgrid"
.title "Subgrid Turbulence Scheme Options"
.wintype entry

.panel
  .gap
  .textw "Polar filtering must be set to OFF for this window to activate" L
  .gap
  .case ATMOS_SR(13)!="0A"
    .case LCOMBI=="0"&&HDIFFOPT=="3"
      .block 1
      .check "Apply in horizontal (2D)" L LSUBFILHRZ T F
      .case LSUBFILHRZ=="T"
      .block 2
        .entry "Start level" L TRBSTRHRZ 15
        .entry "End level" L TRBENDHRZ 15
      .blockend  
      .caseend
      .check "Apply in vertical (1D)" L LSUBFILVER T F
      .case LSUBFILVER=="T"
      .block 2
        .entry "Start level" L TRBSTRVER 15
        .entry "End level" L TRBENDVER 15
      .blockend  
      .caseend
      .check "Blend diffusion coefficients in vertical" L LSUBFILBLND T F
      .entry "Fraction of maximum diffusion" L DIFFFACTOR 25
      .entry "Mixing length constant" L MIXFACTOR 25
    .blockend  
    .caseend  
  .caseend  
  .gap
  .textw "Push Back to go to the main Diffusion window" L
  
.pushnext "Back" atmos_Science_Section_DiffFilt
.panend



         
