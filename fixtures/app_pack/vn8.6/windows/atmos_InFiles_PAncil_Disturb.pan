.winid "atmos_InFiles_PAncil_Disturb"
.title "Vegetation Disturbance"
.wintype entry

.panel   
   .text "Specify ancillary files and fields for Vegetation disturbance:" L
   .invisible ARECON=="N"
     .text "Fields cannot be configured as the reconfiguration is off!" L
   .invisend
   .invisible VEG_TYPE!="2"
     .textw "No interactive-distribution veg param. No fields on this window required" L
   .invisend
   .invisible VEG_TYPE=="2"
     .textw "Interactive-distribution veg param included. Field should be considered" L
   .invisend
   .gap
   .case VEG_TYPE=="2"
     .check "Including vegetation disturbance" L  LVEGDIST T F
   .caseend
   .gap
   .block 0
      .entry "Enter directory or Environment Variable" L APATH(22)
      .entry "and file name" L AFILE(22)
   .blockend
   .gap
   .basrad "Disturbed fraction of vegetation to be:" L 3 h ACON(87)
            "Configured" C "Updated from ancil" U "Not used" N
   .case ACON(87)=="U"
   .block 1
      .entry "Every" L AFRE(87)
      .basrad "Time" L 4 h ATUN(87)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap
   .gap
   .textw "Push VEG to go to vegetation parametrization settings" L
   .textw "Push VFRAC to go to vegetation fraction ancillary file settings" L
   .pushnext "VEG" atmos_Science_Section_Veg
   .pushnext "VFRAC" atmos_InFiles_PAncil_VegFrac
.panend


