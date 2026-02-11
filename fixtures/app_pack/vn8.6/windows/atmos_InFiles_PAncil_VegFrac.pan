.winid "atmos_InFiles_PAncil_VegFrac"
.title "Vegetation"
.wintype entry

.panel   
   .text "Specify ancillary files and fields for the Vegetation Parametrization:" L
   .invisible ARECON=="N"
     .text "Fields cannot be configured as the reconfiguration is off!" L
   .invisend
   .invisible VEG_TYPE=="0"
     .textw "No direct vegetation parametrization. No fields on this window required" L
   .invisend
   .invisible VEG_TYPE!="0"
     .textw "Direct vegetation param. All fields should be considered" L
   .invisend
   .gap
   .gap
   .text "Specify ancillary file and fields for the fractions of surface types:" L
   .block 0
      .entry "Enter directory or Environment Variable" L APATH(20)
      .entry "and file name" L AFILE(20)
   .blockend
   .gap
   .basrad "Fractional covering of surface types to be:" L 3 h ACON(83)
            "Configured" C "Updated from ancil" U "Not used" N
   .case ACON(83)=="U"
   .block 1
      .entry "Every" L AFRE(83)
      .basrad "Time" L 4 h ATUN(83)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap
   .gap
   .text "Specify ancillary file and fields for plant functional types:" L
   .block 0
      .entry "Enter directory or Environment Variable" L APATH(21)
      .entry "and file name" L AFILE(21)
   .blockend
   .gap
   .basrad "Leaf area index of plant functional types to be:" L 3 h ACON(84)
            "Configured" C "Updated from ancil" U "Not used" N
   .case ACON(84)=="U"
   .block 1
      .entry "Every" L AFRE(84)
      .basrad "Time" L 4 h ATUN(84)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap
   .basrad "Canopy height of plant functional types to be:" L 3 h ACON(85)
            "Configured" C "Updated from ancil" U "Not used" N
   .case ACON(85)=="U"
   .block 1
      .entry "Every" L AFRE(85)
      .basrad "Time" L 4 h ATUN(85)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap
   .basrad "Grid-box-mean canopy conductance to be:" L 3 h ACON(86)
            "Configured" C "Updated from ancil" U "Not used" N
   .case ACON(86)=="U"
   .block 1
      .entry "Every" L AFRE(86)
      .basrad "Time" L 4 h ATUN(86)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap
   .gap
   .textw "Push VEG to go to vegetation parametrization settings" L
   .textw "Push BLAY to go to boundary-layer settings" L
   .textw "Push DIST to go to vegetation disturbance ancillary" L
   .pushnext "VEG" atmos_Science_Section_Veg
   .pushnext "BLAY" atmos_Science_Section_BLay
   .pushnext "DIST" atmos_InFiles_PAncil_Disturb
.panend


