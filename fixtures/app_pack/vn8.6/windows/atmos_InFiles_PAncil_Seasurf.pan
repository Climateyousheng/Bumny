.winid "atmos_InFiles_PAncil_Seasurf"
.title "Sea surface currents"
.wintype entry

.panel
   .text "Specify the sea-surface-currents ancillary file and fields." L
   .block 0
      .entry "Enter directory or Environment Variable" L APATH(8)
      .entry "and file name" L AFILE(8)
   .blockend
   .invisible ARECON=="N"
     .text "Fields cannot be configured as the reconfiguration is off!" L
   .invisend
   .gap
   .basrad "Sea surface current ancillary field to be" L 3 h ACON(30)
            "Configured" C "Updated" U "Not used" N
   .case ACON(30)=="U"
     .block 1
        .entry "Every" L AFRE(30)
        .basrad "Time" L 4 h ATUN(30)
                "Years" Y "Months" M "Days" D "Hours" H
     .blockend
        .gap
        .textw "This window used to have an option to annually-cycle through the data when updating." L
        .textw "However, the option was removed as it did nothing." L
   .caseend
.panend


