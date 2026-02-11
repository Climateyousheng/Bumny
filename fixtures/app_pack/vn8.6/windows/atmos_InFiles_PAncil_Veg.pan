.winid "atmos_InFiles_PAncil_Veg"
.title "General land surface ancillaries"
.wintype entry

.panel
   .text "Specify general land surface ancillary file and fields" L
   .block 0
      .entry "Enter directory or Environment Variable" L APATH(5)
      .entry "and file name" L AFILE(5)
   .blockend
   .invisible ARECON=="N"
     .text "Fields cannot be configured as the reconfiguration is off!" L
   .invisend
   .gap
   .basrad "Roughness length of sea points, for first timestep. Ancillary field to be" L 3 h ACON(26)
            "Configured" C "Updated" U "Not used" N
   .case ACON(26)=="U"
   .block 1
      .entry "Every" L AFRE(26)
      .basrad "Time" L 4 h ATUN(26)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap
   .block 5
   .invisible !(OBSALB=="Y" && SPECALB=="N")
      .textw "Snow-free surf SW albedo is not required !" L
   .invisend
   .blockend
   .basrad "Snow-free surf SW albedo. Ancillary field to be" L 3 h ACON(194)
            "Configured" C "Updated" U "Not used" N
   .case ACON(194)=="U"
   .block 1
      .entry "Every" L AFRE(194)
      .basrad "Time" L 4 h ATUN(194)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap
   .block 5
   .invisible !(OBSALB=="Y" && SPECALB=="Y")
      .textw "Snow-free surf VIS and NIR albedos are not required !" L
   .invisend
   .blockend
   .basrad "Snow-free surf VIS albedo. Ancillary field to be" L 3 h ACON(195)
            "Configured" C "Updated" U "Not used" N
   .case ACON(195)=="U"
   .block 1
      .entry "Every" L AFRE(195)
      .basrad "Time" L 4 h ATUN(195)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap   
   .basrad "Snow-free surf NIR albedo.  Ancillary field to be" L 3 h ACON(196)
            "Configured" C "Updated" U "Not used" N
   .case ACON(196)=="U"
   .block 1
      .entry "Every" L AFRE(196)
      .basrad "Time" L 4 h ATUN(196)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap
   .textw "Push Back to go to SW Radiation, options for general 2-stream radiation" L
   .pushnext "Back" atmos_Science_Section_SWGen2
.panend


