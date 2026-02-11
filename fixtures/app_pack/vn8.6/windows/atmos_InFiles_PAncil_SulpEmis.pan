.winid "atmos_InFiles_PAncil_SulpEmis"
.title "Sulphur Emissions (2D)"
.wintype entry

.panel
   .text "Define the use of the 2D Sulphur Emissions ancillary fields and file" L
   .block 0
      .entry "Enter directory or Environment Variable" L APATH(12)
      .entry "and file name" L AFILE(12)
   .blockend
   .invisible ARECON=="N"
     .text "Fields cannot be configured as the reconfiguration is off!" L
   .invisend
   .gap
   .invisible ATMOS_SR(17)!="0A"&&CHEM_SULPC=="Y"&&EMSO2=="Y"
     .textw "Surface sulphur-dioxide emissions are included. Field required." L
   .invisend
   .invisible ATMOS_SR(17)=="0A"||CHEM_SULPC=="N"||EMSO2=="N"
     .textw "Surface sulphur-dioxide emissions are NOT included. Field  NOT required." L
   .invisend
   .basrad "Surface sulphur-dioxide emissions ancillary field to be" L 3 h ACON(39)
            "Configured" C "Updated" U "Not Used" N
   .case ACON(39)=="U"
   .block 1
      .entry "Every" L AFRE(39)
      .basrad "Time" L 4 h ATUN(39)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap

   .invisible ATMOS_SR(17)!="0A"&&CHEM_SULPC=="Y"&&DMS=="Y"&&EMDMS=="Y"
     .textw "Dimethyl Sulphide emissions are included. Field required." L
   .invisend
   .invisible ATMOS_SR(17)=="0A"||CHEM_SULPC=="N"||DMS=="N"||EMDMS=="N"
     .textw "Dimethyl Sulphide emissions are NOT included. Field  NOT required." L
   .invisend
   .basrad "Dimethyl Sulphide emissions ancillary field to be" L 3 h ACON(40)
            "Configured" C "Updated" U "Not Used" N
   .case ACON(40)=="U"
   .block 1
      .entry "Every" L AFRE(40)
      .basrad "Time" L 4 h ATUN(40)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap

   .invisible ATMOS_SR(17)!="0A"&&CHEM_SULPC=="Y"&&EMSO2H=="Y"
     .textw "High-level sulphur dioxide emissions are included. Field required." L
   .invisend
   .invisible ATMOS_SR(17)=="0A"||CHEM_SULPC=="N"||EMSO2H=="N"
     .textw "High-level sulphur dioxide emissions are NOT included. Field  NOT required." L
   .invisend
   .basrad "High-level sulphur dioxide emissions ancillary field to be" L 3 h ACON(77)
            "Configured" C "Updated" U "Not Used" N
   .case ACON(77)=="U"
   .block 1
      .entry "Every" L AFRE(77)
      .basrad "Time" L 4 h ATUN(77)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap
   
   .invisible ATMOS_SR(17)!="0A"&&CHEM_SULPC=="Y"&&SULOZONE=="Y"&&((ATMOS_SR(17)=="2A"&&OXIOZ2A=="1")||(ATMOS_SR(17)=="2B"&&OXIOZ2B=="1"))
     .textw "Ammonia emissions are included. Field required." L
   .invisend
   .invisible ATMOS_SR(17)=="0A"||CHEM_SULPC=="N"||SULOZONE=="N"||(ATMOS_SR(17)=="2A"&&OXIOZ2A!="1")||(ATMOS_SR(17)=="2B"&&OXIOZ2B!="1")
     .textw "Ammonia emissions are NOT included. Field  NOT required." L
   .invisend
   .basrad "Ammonia emissions ancillary field to be" L 3 h ACON(68)
            "Configured" C "Updated" U "Not Used" N
   .case ACON(68)=="U"
   .block 1
      .entry "Every" L AFRE(68)
      .basrad "Time" L 4 h ATUN(68)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap
      
   .text "Define the use of DMS concentration in seawater ancillary fields and file" L
   .block 0
      .entry "Enter directory or Environment Variable" L APATH(29)
      .entry "and file name" L AFILE(29)
   .blockend
   .invisible ARECON=="N"
     .text "Fields cannot be configured as the reconfiguration is off!" L
   .invisend
   .gap
  
   .invisible ATMOS_SR(17)!="0A"&&CHEM_SULPC=="Y"&&DMS=="Y"&&EMDMS=="Y"&&IDMSE_SCH!="0"
     .textw "Interactive DMS emissions are included. Field required." L
   .invisend
   .invisible ATMOS_SR(17)=="0A"||CHEM_SULPC=="N"||DMS=="N"||EMDMS=="N"||IDMSE_SCH=="0"
     .textw "Interactive DMS emissions are NOT included. Field  NOT required." L
   .invisend
   .basrad "DMS concentration in seawater. Ancillary field to be" L 3 h ACON(123)
            "Configured" C "Updated" U "Not Used" N
   .case ACON(123)=="U"
   .block 1
      .entry "Every" L AFRE(123)
      .basrad "Time" L 4 h ATUN(123)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend 
   .gap

   .textw "Push SULPHUR to go to the Sulphur Cycle window." L
   .pushnext "SULPHUR" atmos_Science_Section_Aero_Sulphur

.panend


