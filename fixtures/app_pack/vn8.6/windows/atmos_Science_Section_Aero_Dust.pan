.winid "atmos_Science_Section_Aero_Dust"
.title "Section 17 : Aerosols. Mineral Dust"
.wintype entry

.panel
  .gap
  .text "Section 17 : Aerosols. Mineral Dust" L
  .case ATMOS_SR(17)!="0A"
    .basrad "Select Mineral Dust scheme" L 3 v I_DUST
       "dust switched off " 0
       "prognostic dust" 1
       "diagnostic dust" 2
    .gap
    .case I_DUST != 0
      .block 0
       .basrad "Dust emission and transport uses" L 3 v SIZEDIST
         "6 size divisions, variable emission size distribution" 1
         "6 size divisions, constant emission size distribution" 2
         "2 size divisions, constant emission size distribution" 3
      .blockend
      .gap
      .block 0
       .entry "Tuning factor by which to multiply U*" L DUSTUSAM 15 
       .entry "Tuning factor by which to multiply level 1 soil moisture" L SMCORR 15
       .entry "Global tuning factor by which to multiply dust emissions" L HORIZD 15
      .blockend
      .gap
      .basrad "Emit dust from bare soil components of vegetated gridboxes:" L 2 v DUSTVEG
        "Emit dust only from the bare soil tile" 0
        "Emit dust from seasonally bare soil, using LAI" 1 
      .gap
      .text "Specify dust parent soil properties ancillary fields" L
      .gap
      .block 1
       .entry "Enter directory or Environment Variable" L APATH(27)
       .entry "and file name" L AFILE(27)
      .blockend
      .gap
    .caseend
  .invisible ATMOS_SR(17)!="0A" && I_DUST==1
    .textw "Prognostic Mineral Dust Scheme is included. Fields required." L
  .invisend
  .invisible ATMOS_SR(17)!="0A" && I_DUST==2
    .textw "Diagnostic Mineral Dust Scheme is included. Fields required." L
  .invisend
  .invisible ATMOS_SR(17)!="0A" && I_DUST==0
    .textw "Mineral Dust Scheme is NOT included. Fields NOT required." L
  .invisend
  .block 1
   .basrad "Ancillary file to be" L 2 h ACON(112)
     "Configured" C
     "Not Used"   N
  .blockend
  .gap
  .textw "Push AERO_FX to switch on/off the radiative effects of dust" L
  .textw "Push LW_GEN2 for LW radiation Gen2 window." L
  .textw "Push BACK for Aerosols window" L
  .pushsequence "AERO_FX" atmos_Science_Section_Aero_Effects
  .pushnext "LW_GEN2" atmos_Science_Section_LWGen2
  .pushnext "BACK" atmos_Science_Section_Aero  
.panend
