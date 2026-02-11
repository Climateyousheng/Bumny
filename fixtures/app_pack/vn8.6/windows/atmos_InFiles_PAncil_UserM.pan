.winid "atmos_InFiles_PAncil_UserM"
.title "Multi-level user ancillary file"
.wintype entry

.panel
   .text "Specify multi-level user ancillary file" L
   .block 0
      .entry "Directory name or Environment Variable" L APATH(16)
      .entry "and file name" L AFILE(16)
   .blockend
   .invisible ARECON=="N"
     .text "Fields cannot be configured as the reconfiguration is off!" L
   .invisend
   .gap
   .basrad "All fields on the file to be:" L 2 h ACON(90)
            "Updated" U "Not Used" N
   .case ACON(90)=="U"
     .block 1
       .entry "Every" L AFRE(90)
       .basrad "Time" L 4 h ATUN(90)
               "Years" Y "Months" M "Days" D "Hours" H
     .blockend
   .caseend
   .gap
   .textw "See also the STASH user-diagnostics/prognostics for initialisation" L
.panend


