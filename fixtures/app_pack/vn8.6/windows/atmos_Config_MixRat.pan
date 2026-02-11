.winid "atmos_Config_MixRat"
.title "Switches controlling the use of mixing ratios"
.wintype entry

.panel
   .gap
   .block 1
     .check "Use mixing ratios in atmos_physics2" L LMRPHYSICS2 Y N
     .check "Use mixing ratios in atmos_physics1" L LMRPHYSICS1 Y N 
     .check "Use mixing ratios for the moisture variables inside the dynamics" L LMIXMOIST T F
   .blockend
   .gap
.panend 
