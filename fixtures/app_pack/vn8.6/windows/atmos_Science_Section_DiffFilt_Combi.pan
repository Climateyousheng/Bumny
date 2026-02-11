.winid "atmos_Science_Section_DiffFilt_Combi"
.title "Parameters for Combined Diffusion & Filtering"
.wintype entry

.panel
    .invisible LCOMBI=="Y"
      .textw "Combined Diffusion and filtering is selected. Set the parameters"      L
    .invisend
    .invisible LCOMBI=="N"
      .textw "Combined Diffusion and filtering is not selected." L
    .invisend  
    .case LCOMBI=="Y"
      .block 1
      .check "Polar filter theta" L LPFTHETA Y N
      .check "Polar filter horizontal winds" L LPFUV Y N
      .check "Polar filter w" L LPFW Y N
      .check "Polar filter increments" L LPFINCS Y N
      .blockend
      .gap
      .block 1
      .check "Diffusion of theta" L LDIFFTHERMO Y N
      .check "Diffusion of horizontal winds" L LDFNWIND Y N  
      .check "Diffusion of w" L LDFNW Y N
      .check "Diffusion of increments" L LDFNINCR Y N
      .blockend
    .caseend
    .gap
    .case LCOMBI!="0"
      .block 1
      .entry "Diffusion order theta/w" L DFNORDTHERMO 15
      .entry "Diffusion timescale theta/w (number of timesteps)" L DFNTSTHERMO 15 
      .entry "Diffusion order wind" L DFNORDWIND 15 
      .entry "Diffusion timescale wind (number of timesteps)" L DFNTSWIND 15
      .entry "Reference diffusion coefficient" L DFNCOEFFREF 15
      .blockend
    .caseend
    .gap
    .case LCOMBI=="Y"
      .block 1
      .check "Latest filtering and diffusion code (recommended)" L LPOFILNEW Y N 
      .case LPOFILNEW=="Y"
        .block 2
        .check "Automatic calculation of diffusion coefficients" L LDIFFAUTO Y N
        .blockend
      .caseend 
      .gap
      .entry "Reference latitude (Equator=0.0 recommended)" L REFLATDEG 15
      .entry "Scale ratio (2.0 recommended)" L SCALERATIO 15
      .entry "Polar filter start latitude (87.0 recommended)" L POLARCAP 15
      .entry "Maximum number of filter sweeps (8 recommended)" L MAXSWEEPS 15
      .blockend
    .caseend
    .gap
.textw "Push DIFF to go to the Diffusion & Filtering main window" L
.pushnext "DIFF" atmos_Science_Section_DiffFilt

.panend


