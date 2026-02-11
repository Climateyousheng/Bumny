.winid "atmos_InFiles_PAncil_AeroClim"
.title "Aerosol Clim Ancils"
.wintype entry

.panel
   .invisible LUSEBIOGEN=="Y"
     .textw "Biogenic aerosol climatology is switched on. Field required." L
   .invisend
   .invisible LUSEBIOGEN=="N"
     .textw "Biogenic aerosol climatology is switched off. Field  NOT required." L
   .invisend
   .block 0
      .entry "Enter directory or Environment Variable" L APATH(38)
      .entry "and file name" L AFILE(38)
   .blockend
   .basrad "Biogenic aerosol climatology file to be" L 3 h ACON(157)
            "Configured" C "Updated" U "Not Used" N
   .case ACON(157)=="U"
   .block 1
      .entry "Every" L AFRE(157)
      .basrad "Time" L 4 h ATUN(157)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap
   .invisible LUARCLBIOM=="Y"
     .textw "Biomass-burning aerosol climatology is switched ON. Fields required." L
   .invisend
   .invisible LUARCLBIOM=="N"
     .textw "Biomass-burning aerosol climatology is switched OFF. These fields are NOT required" L
   .invisend
   .block 0
      .entry "Enter directory or Environment Variable" L APATH(39)
      .entry "and file name" L AFILE(39)
   .blockend
   .basrad "Biomass-burning (fresh) aerosol climatology to be" L 3 h ACON(158)
            "Configured" C "Updated" U "Not Used" N
   .case ACON(158)=="U"
   .block 1
      .entry "Every" L AFRE(158)
      .basrad "Time" L 4 h ATUN(158)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap  
   .invisible LUARCLBLCK=="Y"
     .textw "Black Carbon aerosol climatology is switched ON. Fields required." L
   .invisend
   .invisible LUARCLBLCK=="N"
     .textw "Black Carbon aerosol climatology is switched OFF. These fields are NOT required" L
   .invisend
   .block 0
      .entry "Enter directory or Environment Variable" L APATH(40)
      .entry "and file name" L AFILE(40)
   .blockend
   .basrad "Black Carbon aerosol climatology to be" L 3 h ACON(161)
            "Configured" C "Updated" U "Not Used" N
   .case ACON(161)=="U"
   .block 1
      .entry "Every" L AFRE(161)
      .basrad "Time" L 4 h ATUN(161)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap 
   .invisible LUARCLSSLT=="Y"
     .textw "Sea-salt aerosol climatology is switched ON. Fields required." L
   .invisend
   .invisible LUARCLSSLT=="N"
     .textw "Sea-salt aerosol climatology is switched OFF. These fields are NOT required" L
   .invisend
   .block 0
      .entry "Enter directory or Environment Variable" L APATH(41)
      .entry "and file name" L AFILE(41)
   .blockend
   .basrad "Sea-salt aerosol climatology to be" L 3 h ACON(163)
            "Configured" C "Updated" U "Not Used" N
   .case ACON(163)=="U"
   .block 1
      .entry "Every" L AFRE(163)
      .basrad "Time" L 4 h ATUN(163)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap
   .invisible LUARCLBIOM=="Y"
     .textw "Sulphate aerosol climatology is switched ON. Fields required." L
   .invisend
   .invisible LUARCLBIOM=="N"
     .textw "Sulphate aerosol climatology is switched OFF. These fields are NOT required" L
   .invisend
   .block 0
      .entry "Enter directory or Environment Variable" L APATH(42)
      .entry "and file name" L AFILE(42)
   .blockend
   .basrad "Sulphate aerosol climatology to be" L 3 h ACON(165)
            "Configured" C "Updated" U "Not Used" N
   .case ACON(165)=="U"
   .block 1
      .entry "Every" L AFRE(165)
      .basrad "Time" L 4 h ATUN(165)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap
   .invisible LUARCLDUST=="Y"
     .textw "Dust aerosol climatology is switched ON. Fields required." L
   .invisend
   .invisible LUARCLDUST=="N"
     .textw "Dust aerosol climatology is switched OFF. These fields are NOT required" L
   .invisend
   .block 0
      .entry "Enter directory or Environment Variable" L APATH(43)
      .entry "and file name" L AFILE(43)
   .blockend
   .basrad "Dust aerosol climatology to be" L 3 h ACON(168)
            "Configured" C "Updated" U "Not Used" N
   .case ACON(168)=="U"
   .block 1
      .entry "Every" L AFRE(168)
      .basrad "Time" L 4 h ATUN(168)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap
   .invisible LUARCLOCFF=="Y"
     .textw "Organic Carbon Fossil Fuel climatology is switched ON. Fields required." L
   .invisend
   .invisible LUARCLOCFF=="N"
     .textw "Organic Carbon Fossil Fuel climatology is switched OFF. These fields are NOT required" L
   .invisend
   .block 0
      .entry "Enter directory or Environment Variable" L APATH(44)
      .entry "and file name" L AFILE(44)
   .blockend
   .basrad "Organic Carbon Fossil Fuel climatology to be" L 3 h ACON(174)
            "Configured" C "Updated" U "Not Used" N
   .case ACON(174)=="U"
   .block 1
      .entry "Every" L AFRE(174)
      .basrad "Time" L 4 h ATUN(174)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap
   .invisible LUARCLDLTA=="Y"
     .textw "Delta climatology is switched ON. Fields required." L
   .invisend
   .invisible LUARCLDLTA=="N"
     .textw "Delta climatology is switched OFF. These fields are NOT required" L
   .invisend
   .block 0
      .entry "Enter directory or Environment Variable" L APATH(45)
      .entry "and file name" L AFILE(45)
   .blockend
   .basrad "Delta climatology to be" L 3 h ACON(177)
            "Configured" C "Updated" U "Not Used" N
   .case ACON(177)=="U"
   .block 1
      .entry "Every" L AFRE(177)
      .basrad "Time" L 4 h ATUN(177)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap
   .textw "Push AERO_Clim to go to the Aerosol Climatologies window." L
   .pushnext "AERO_Clim" atmos_Science_Section_AeroClim
.panend


