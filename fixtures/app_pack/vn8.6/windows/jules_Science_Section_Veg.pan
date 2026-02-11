.winid "jules_Science_Section_Veg"
.title "JULES Section 8: Dynamic Vegetation"
.wintype entry
.procs {store_A19_L19} {} {match_A19_L19 JULES ; # Ensure same veg setting in ATMOS and JULES}
.panel
  .gap
  .case JULES=="T"
    .block 1
      .basrad "Choose Vegetation version " L 2 v JULES_SR(8)
          "<1A> Fixed vegetation distribution" 1A
          "<2A> Interactive vegetation distribution" 2A
    .blockend 
  .caseend
.panend
.set_on_closure "Set Atmosphere Section 19" ATMOS_SR(19)
