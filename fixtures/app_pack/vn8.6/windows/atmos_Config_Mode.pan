.winid "atmos_Config_Mode"
.title "Run Mode"
.wintype entry

.panel
   .textw "Using Normal earth surface lower boundary condition option" L
   .textw "Stratospheric option removed for version 5.3" L
   .block 2
       .check "Growing orography" L FLOOR Y N
     .textw "If growing orography is selected" L
     .textw "the file name must be specified elsewhere" L
   .blockend
   .gap
.panend


