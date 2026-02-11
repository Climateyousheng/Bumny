.winid "jules_Science_Section_Surface"
.title "JULES Section 1: Surface Exchange"
.wintype entry

.panel
  .gap
  .case ATMOS_SR(3)!="0A"
    .block 1
      .case JL_FLAKE=="F"||JULES=="F"
        .entry "Options for correcting Monin-Obukhov surface exchange calculations" L CORMOITR 5
      .caseend
    .blockend
    .block 1
      .check "Make surface exchange consistent with flux differencing" L MODISCOPT 1 0
    .blockend
  .caseend
  .gap
  .textw "Push LAND_SURF to go to the Land Surface panel" L
  .textw "Push SEA_SURF to go to the Sea Surface panel" L
  .pushnext "LAND_SURF" jules_Science_Section_LSurf
  .pushnext "SEA_SURF" jules_Science_Section_SSurf
.panend
