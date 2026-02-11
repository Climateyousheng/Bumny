.winid "atmos_InFiles_PAncil_CO2Emis"
.title "CO2 Emissions  for Interactive Carbon Cycle"
.wintype entry

.panel
   .text "Define the use of the CO2 Emissions ancillary fields and file" L
   .block 0
      .entry "Enter directory or Environment Variable" L APATH(24)
      .entry "and file name" L AFILE(24)
   .blockend
   .invisible ARECON=="N"
     .text "Fields cannot be configured as the reconfiguration is off!" L
   .invisend
   .gap


   .invisible (CO2OPT==3)&&(CO2EMISOPT==1)
     .textw "Carbon cycle is on and CO2 Emissions are required. Field required." L
   .invisend
   .invisible (CO2OPT!=3)||(CO2EMISOPT!=1)
     .textw " CO2 Emissions field NOT required." L
   .invisend

   .basrad "CO2 emissions ancillary field to be" L 3 h ACON(78)
            "Configured" C "Updated" U "Not Used" N
   .case ACON(78)=="U"
   .block 1
      .entry "Every" L AFRE(78)
      .basrad "Time" L 4 h ATUN(78)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap

.panend


