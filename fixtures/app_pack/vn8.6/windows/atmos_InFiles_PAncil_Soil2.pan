.winid "atmos_InFiles_PAncil_Soil2"
.title "Soil : VSMC, hydrological/thermal conductivity etc."
.wintype entry

.panel
   .textw "soil-parameters ancillary fields and file... continued" L
   .gap
   .textw "Clapp-Hornberg B parameter" L
   .block 1
   .basrad "Ancillary field to be:" L 3 h ACON(79)
            "Configured" C "Updated" U "Not used" N
   .case ACON(79)=="U"
      .entry "Every" L AFRE(79)
      .basrad "Time" L 4 h ATUN(79)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap

   .textw "Thermal capacity of soil" L
   .block 1
   .basrad "Ancillary field to be:" L 3 h ACON(17)
            "Configured" C "Updated" U "Not used" N
   .case ACON(17)=="U"
      .entry "Every" L AFRE(17)
      .basrad "Time" L 4 h ATUN(17)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap
   .textw "Thermal conductivity of soil" L
   .block 1
   .basrad "Ancillary field to be:" L 3 h ACON(18)
            "Configured" C "Updated" U "Not used" N
   .case ACON(18)=="U"
      .entry "Every" L AFRE(18)
      .basrad "Time" L 4 h ATUN(18)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap
   .invisible HYD_TYPE==1
     .text "Saturated soil water suction not required as you are using Single-layer hydrology." L
   .invisend
   .textw "Saturated soil water suction" L
   .block 1
   .basrad "Ancillary field to be:" L 3 h ACON(35)
            "Configured" C "Updated" U "Not used" N
   .case ACON(35)=="U"
      .entry "Every" L AFRE(35)
      .basrad "Time" L 4 h ATUN(35)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap
   .textw "Push BACK to go back, NEXT for the next in sequence." L
   .textw "Push HYD for hydrology section, BLAY for boundary-layer section" L
   .textw "Push BLAY for boundary-layer section" L
   .pushnext "BACK" atmos_InFiles_PAncil_Soil 
   .pushnext "NEXT" atmos_InFiles_PAncil_Soil3
   .pushnext "HYD" atmos_Science_Section_Hydrol
   .pushnext "BLAY" atmos_Science_Section_BLay
.panend


