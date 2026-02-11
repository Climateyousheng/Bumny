.winid "atmos_Science_Tstep"
.title "Time Step"
.wintype entry

.panel
  .block 0
    .entry "Number of timesteps per 'period'" L ATPP 15
    .entry "Number of days per 'period', typically 1" L AHPP 15
    .textw "Note, timesteps must divide into one hour." L
  .blockend
  .gap
  .case L_ENDGAME!="T"
    .check "Cycle model" L LCYCLMOD Y N
    .case LCYCLMOD == "Y"
      .block 1
      .entry "Number of semi-Lagrangian scheme cycles" L NUM_CYCLES 15
      .check "Activate improved implicit time scheme when cycling" L L_NEWTDIST Y N
      .blockend
    .caseend
  .caseend
  .gap
  .case ATMOS_SR(3)!="0A"  
    .textw "Parameters for unconditionally stable BL solver" L
    .block 1
    .entry "P parameter (nonlinearity degree) for stable BL" L PSTB 15
    .entry "P parameter (nonlinearity degree) for unstable BL" L PUNS 15
    .blockend
  .caseend
  .gap
  .case ATMOS_SR(3)!="0A"
    .check "Use time weights of 1 for all tracers (recommended)" L LTRWEIGHTS1 Y N
    .entry "Input ranges of levels and specify time weights" L NBLLV_BL 5
    .table alphacd "Time weights for Boundary Layer Levels" top h NBLLV_BL 4 NONE
        .element "Start Level" STARTLEV_BL NBLLV_BL 11 in  
        .element "End Level" ENDLEV_BL NBLLV_BL 11 in
        .element "Time Weight Ratio" ALPHACD_BL NBLLV_BL 25 in
    .tableend 
  .caseend  
  .gap
  .textw "Elsewhere, you have specified the related parameters:" L
  .invisible ATMOS_SR(10)=="0A"||ATMOS_SR(5)!="0A"||ATMOS_SR(1)=="0A"||ATMOS_SR(2)=="0A"
    .textw "Greyed-out parameters relate to sections which are currently switched off." L
  .invisend
  .block 2
  .case ATMOS_SR(5)!="0A"
    .entry "Convection calling frequency (Timesteps)" L CONFRE 15
  .caseend
  .case ATMOS_SR(1)!="0A"
    .entry "Number of calculations of SW radiation increments per day" L SWINC 15 
  .caseend
  .case ATMOS_SR(2)!="0A"
    .entry "Number of calculations of LW radiation increments per day" L LWINC 15 
  .caseend
  .blockend 
.panend







