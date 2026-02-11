.winid "atmos_InFiles_PAncil_OASISCoupler"
.title "OASIS coupling fields"
.wintype entry

.panel
   .text "Specify the Iceberg Calving file and fields." L
   .block 0
      .entry "Enter directory or Environment Variable" L APATH(11)
      .entry "and file name" L AFILE(11)
   .blockend
   .invisible ARECON=="N"
     .text "Fields cannot be configured as the reconfiguration is off!" L
   .invisend
   .gap
   .invisible LOASIS_ICECLV=="T" && OASIS=="T"
     .text "Filed is required" L
   .invisend
   .invisible LOASIS_ICECLV!="T" || OASIS!="T"
     .text "Filed is not required" L
   .invisend
   .gap
   .basrad "Iceberg calving ancillary to be" L 3 h ACON(13)
            "Configured" C "Updated" U "Not used" N
   .case ACON(13)=="U"
   .block 1
      .entry "Every" L AFRE(13)
      .basrad "Time" L 4 h ATUN(13)
              "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend

  .textw "Push OASIS for Oasis coupling window" L
  .pushnext "OASIS" smcc_OASIS_Coupling

.panend  
