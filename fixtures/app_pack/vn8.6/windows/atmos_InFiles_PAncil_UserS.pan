.winid "atmos_InFiles_PAncil_UserS"
.title "Single-level user ancillary file"
.wintype entry

.panel
   .text "Specify single-level user ancillary file" L
   .block 0
      .entry "Directory name or Environment Variable" L APATH(15)
      .entry "and file name" L AFILE(15)
   .blockend
   .invisible ARECON=="N"
     .text "Fields cannot be configured as the reconfiguration is off!" L
   .invisend
   .gap
   .basrad "All fields on the file to be:" L 2 h ACON(48)
           "Updated" U "Not Used" N
   .case ACON(48)=="U"
     .block 1
       .entry "Every" L AFRE(48)
       .basrad "Time" L 4 h ATUN(48)
               "Years" Y "Months" M "Days" D "Hours" H
     .blockend
   .caseend
   .gap
   .textw "See also the STASH user-prognostic/diagnostic section for initialisation" L
.panend


