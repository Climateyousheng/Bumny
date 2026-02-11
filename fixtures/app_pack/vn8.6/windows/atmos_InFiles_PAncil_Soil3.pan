.winid "atmos_InFiles_PAncil_Soil3"
.title "Soil : VSMC, hydrological/thermal conductivity etc."
.wintype entry

.panel
   .textw "soil-parameters ancillary fields and file... continued" L
   .gap
   .invisible VEG_TYPE==0
     .text "Snow-free soil albedo not required as you are not using a vegetation distribution scheme." L
   .invisend
   .textw "Snow-free soil albedo" L
   .block 1
   .basrad "Ancillary field to be:" L 3 h ACON(88)
            "Configured" C "Updated from ancill" U "Not used" N
   .case ACON(88)=="U"
      .entry "Every" L AFRE(88)
      .basrad "Time" L 4 h ATUN(88)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap


   .invisible VEG_TYPE==0
     .text "Soil carbon content not required as you are not using a vegetation distribution scheme" L
   .invisend
   .textw "Soil carbon content" L
   .block 1
   .basrad "Ancillary field to be:" L 3 h ACON(89)
            "Configured" C "Updated from ancill" U "Not used" N
   .case ACON(89)=="U"
      .entry "Every" L AFRE(89)
      .basrad "Time" L 4 h ATUN(89)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap
   .textw "Push BACK to go back" L
   .textw "Push HYD, BLAY, VEG for hydrology, boundary-layer and veg sections" L
   .pushnext "BACK" atmos_InFiles_PAncil_Soil2
   .pushnext "HYD" atmos_Science_Section_Hydrol
   .pushnext "BLAY" atmos_Science_Section_BLay
   .pushnext "VEG" atmos_Science_Section_Veg
.panend


