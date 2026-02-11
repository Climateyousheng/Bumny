.winid "atmos_Science_Section_Advec2"
.title "Time weight coefficients"
.wintype entry

.panel
  .gap
  .case L_ENDGAME!="T"
    .check "Use default values" L LALPHADEF2 T F
    .gap
    .invisible LALPHADEF2=="F"
      .block 4
      .entry "Alpha2_1" L ALPHA2_1 15
      .entry "Alpha2_2" L ALPHA2_2 15
      .entry "Alpha2_3" L ALPHA2_3 15
      .entry "Alpha2_4" L ALPHA2_4 15
      .blockend
    .invisend
    .invisible LALPHADEF2=="T"
      .block 4
      .text "Alpha2_1 = 0.6" L
      .text "Alpha2_2 = 1.0" L
      .text "Alpha2_3 = 0.6" L
      .text "Alpha2_4 = 1.0" L
      .blockend
    .invisend
  .caseend
  .gap
  .textw "Push Advection to go Back" L
  .pushnext "Advection" atmos_Science_Section_Advec 
.panend
