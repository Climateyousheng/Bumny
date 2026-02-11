.winid "atmos_InFiles_PAncil_Soil"
.title "Soil : VSMC, hydrological/thermal conductivity etc."
.wintype entry

.panel
   .text "Specify the soil-parameters ancillary fields and file" L
   .block 0
      .entry "Enter directory or Environment Variable" L APATH(4)
      .entry "and file name" L AFILE(4)
   .blockend

   .invisible ARECON=="N"
     .text "Fields cannot be configured as the reconfiguration is off!" L
   .invisend

   .invisible HYD_TYPE==1
     .textw "Single-Layer Surface Hydrology, standard file is qrparm.soil" L
   .invisend
   .invisible (HYD_TYPE==3)||(HYD_TYPE==4)
     .textw "Surface Hydrology, standard file is qrparm.soil" L
   .invisend
   .gap
   .textw "Volumetric soil moisture concentration at wilting point" L
   .block 1
   .basrad "Ancillary field to be:" L 3 h ACON(11)
            "Configured" C "Updated" U "Not used" N
   .case ACON(11)=="U"
      .entry "Every" L AFRE(11)
      .basrad "Time" L 4 h ATUN(11)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap
   .textw "Volumetric soil moisture content at critical point" L
   .block 1
   .basrad "Ancillary field to be:" L 3 h ACON(12)
            "Configured" C "Updated" U "Not used" N
   .case ACON(12)=="U"
      .entry "Every" L AFRE(12)
      .basrad "Time" L 4 h ATUN(12)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap
   .textw "Volumetric soil moisture concentration at saturation" L
   .block 1
   .basrad "Ancillary field to be:" L 3 h ACON(14)
            "Configured" C "Updated" U "Not used" N
   .case ACON(14)=="U"
      .entry "Every" L AFRE(14)
      .basrad "Time" L 4 h ATUN(14) 
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap
   .textw "Saturated hydraulic conductivity" L
   .block 1
   .basrad "Ancillary field to be:" L 3 h ACON(15)
            "Configured" C "Updated" U "Not used" N
   .case ACON(15)=="U"
      .entry "Every" L AFRE(15)
      .basrad "Time" L 4 h ATUN(15)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap
   .textw "Push NEXT for more fields" L
   .textw "Push HYDROL for hydrology section" L
   .textw "Push BLAY for boundary-layer section" L
   .pushsequence "NEXT" atmos_InFiles_PAncil_Soil2
   .pushnext "HYDROL" atmos_Science_Section_Hydrol
   .pushnext "BLAY" atmos_Science_Section_BLay
.panend


