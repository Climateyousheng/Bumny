.winid "atmos_InFiles_PAncil_GenSea"
.title "Sea Surface Fields"
.wintype entry

.panel
   .text "Specify the Sea surface file and fields." L
   .block 0
      .entry "Enter directory or Environment Variable" L APATH(13)
      .entry "and file name" L AFILE(13)
   .blockend
   .invisible ARECON=="N"
     .text "Fields cannot be configured as the reconfiguration is off!" L
   .invisend
   .gap
   .invisible LSEA_ALBCHL=="Y"
     .text "Filed is required" L
   .invisend
   .invisible LSEA_ALBCHL!="Y"
     .text "Filed is not required" L
   .invisend
   .gap
   .basrad "Ocean near surface chlorophyll content to be" L 3 h ACON(8)
            "Configured" C "Updated" U "Not used" N
   .case ACON(8)=="U"
   .block 1
      .entry "Every" L AFRE(8)
      .basrad "Time" L 4 h ATUN(8)
              "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend

.panend 
