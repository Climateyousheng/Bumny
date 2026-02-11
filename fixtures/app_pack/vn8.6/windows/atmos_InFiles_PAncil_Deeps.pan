.winid "atmos_InFiles_PAncil_Deeps"
.title "Deep soil temperatures"
.wintype entry

.panel
   .text "Specify the deep-soil-temperature ancillary file and fields" L
   .block 0
      .entry "Directory name or Environment Variable" L APATH(3)
      .entry "and file name" L AFILE(3)
   .blockend
   .gap
   .invisible ARECON=="N"
     .text "Fields cannot be configured as the reconfiguration is off!" L
   .invisend
   .gap
   .textw "Deep-soil-temperature" L 
   .block 1
   .basrad "Ancillary fields to be:" L 3 h ACON(10)
            "Configured" C "Updated" U "Not used" N
   .case ACON(10)=="U"
      .entry "Every" L AFRE(10)
      .basrad "Time" L 4 h ATUN(10)
              "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap
   .textw "Push BLAY to go to the boundary layer section" L
   .pushnext "BLAY" atmos_Science_Section_BLay
.panend


