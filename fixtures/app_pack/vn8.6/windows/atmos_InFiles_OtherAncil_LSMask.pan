.winid "atmos_InFiles_OtherAncil_LSMask"
.title "Land Sea Mask"
.wintype entry

.panel
   .text "Define the use of the Land-Sea-Mask ancillary file and fields" L
   .block 0
       .entry "Enter directory or environment variable" L APATH(9)
       .entry "and file name" L AFILE(9)
   .blockend
   .gap
   .text "NB! The number of land points in the mask generally needs changing when the mask changes." L
   .invisible ARECON=="N"
     .text "Fields cannot be configured as the reconfiguration is off!" L
   .invisend
   .gap   
   .check "The ancillary Land-Sea_mask to be configured" L ACON(1) C N 
   .invisible ATMOS=="T"&&OCEAN=="T"
     .textw "This model is defined elsewhere as atmosphere/ocean-GCM coupled." L
     .textw "River catchment is prognostic." L
   .invisend
   .invisible ATMOS!="T"||OCEAN!="T"
     .textw "This model is defined elsewhere  not coupled to the ocean." L
     .textw "River catchment is NOT prognostic." L
   .invisend
     .block 1
      .check "The ancillary river catchment field to be configured" L ACON(32) C N
     .blockend
.panend


   


