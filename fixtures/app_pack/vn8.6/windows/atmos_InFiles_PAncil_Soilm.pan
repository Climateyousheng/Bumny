.winid "atmos_InFiles_PAncil_Soilm"
.title "Soil moisture and snow depth"
.wintype entry

.panel
   .text "Specify the use of the soil-moisture and snow-depth ancillary file and fields" L
   .block 0
      .entry "Directory name or Environment Variable" L APATH(2)
      .entry "and file name" L AFILE(2)
   .blockend
     .textw "Surface hydrology, standard file is qrclim.smow" L
   .gap
   .invisible ARECON=="N"
     .text "Fields cannot be configured as the reconfiguration is off!" L
   .invisend
   .gap

   .block 1
   .textw "Snow amount" L
 
   .basrad "Ancillary field to be:" L 3 h ACON(9)
            "Configured" C "Updated" U "Not used" N
   .case ACON(9)=="U"
      .entry "Every" L AFRE(9)
      .basrad "Time" L 4 h ATUN(9)
               "Years" Y "Months" M "Days" D "Hours" H
   .caseend
   .gap
   .textw "Snow-depth" L
   .basrad "Ancillary field to be:" L 2 h ACON(193)
            "Configured" C "Not used" N
   .blockend

   .gap
   .invisible HYD_TYPE==1
     .textw "Single-layer hydrology specified. Layer content not needed. " L
   .invisend
   .invisible HYD_TYPE!=1
     .textw "Hydrology specified. Layer content needed. " L
   .invisend
   .textw "Layer Soil-moisture-content" L
   .block 1
   .basrad "Ancillary field to be:" L 3 h ACON(36)
             "Configured" C "Updated" U "Not used" N
   .case ACON(36)=="U"
      .entry "Every" L AFRE(36)
      .basrad "Time" L 4 h ATUN(36)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend

   .gap
   .textw "Push HYDROL to go to soil hydrology settings" L
   .textw "Push BLAY to go to boundary-layer settings" L
   .pushnext "HYDROL" atmos_Science_Section_Hydrol
   .pushnext "BLAY" atmos_Science_Section_BLay
.panend



