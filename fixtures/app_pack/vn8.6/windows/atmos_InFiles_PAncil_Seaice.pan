.winid "atmos_InFiles_PAncil_Seaice"
.title "Sea ice fields"
.wintype entry

.panel
   .text "Specify the Sea-Ice ancillary file and fields." L
   .block 0
      .entry "Enter directory or Environment Variable" L APATH(7)
      .entry "and file name" L AFILE(7)
   .blockend
   .invisible ARECON=="N"
     .text "Fields cannot be configured as the reconfiguration is off!" L
   .invisend
   .gap
   .basrad "Sea ice fraction. Ancillary field to be" L 3 h ACON(27)
            "Configured" C "Updated" U "Not used" N
   .case ACON(27)=="U"
   .block 1
      .entry "Every" L AFRE(27)
      .basrad "Time" L 4 h ATUN(27)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap
   .basrad "Sea ice thickness. Ancillary field to be" L 3 h ACON(29)
            "Configured" C "Updated" U "Not used" N
   .case ACON(29)=="U"
   .block 1
      .entry "Every" L AFRE(29)
      .basrad "Time" L 4 h ATUN(29)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .check "Using AMIP-II method of updating SST and sea ice." L AMIPII Y N
.panend


