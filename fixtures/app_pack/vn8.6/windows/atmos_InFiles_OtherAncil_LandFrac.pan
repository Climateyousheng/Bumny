.winid "atmos_InFiles_OtherAncil_LandFrac"
.title "Land fraction file"
.wintype entry

.panel
   .textw "If using COASTAL TILING define the use of the land fraction ancillary" L
   .case CTILE=="Y"
     .entry "Land fraction ancil file path:" L APATH(26)
     .entry "Land fraction ancil file name:" L AFILE(26)
     .check "The ancillary land fraction to be configured." L ACON(111) C N
     .invisible ARECON=="N"
       .text "Fields cannot be configured as the reconfiguration is off!" L
     .invisend
   .caseend


   .gap
   .textw "Push BLAY to set the coastal tiling switch." L
   .pushnext "BLAY" atmos_Science_Section_BLay
.comment ===========================================================
.comment  ACON(111) is handled specially for verification checking.
.comment  If changing the .case of ACON(110) make a corresponding
.comment  change to UM/vi_acon_ocon.
.comment ===========================================================
.panend
