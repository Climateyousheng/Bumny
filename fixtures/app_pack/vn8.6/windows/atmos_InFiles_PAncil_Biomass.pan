.winid "atmos_InFiles_PAncil_Biomass"
.title "Biomass Emissions"
.wintype entry

.panel
   .text "Define the use of the Biomass Emissions ancillary fields and file" L
   .block 0
      .entry "Enter directory or Environment Variable" L APATH(28)
      .entry "and file name" L AFILE(28)
   .blockend
   .invisible ARECON=="N"
     .text "Fields cannot be configured as the reconfiguration is off!" L
   .invisend
   .gap


   .invisible ATMOS_SR(17)!="0A"&&CHEM_BIOM=="Y"&&EMBIOM=="Y"
     .textw "Surface biomass emissions are included. Field required." L
   .invisend
   .invisible ATMOS_SR(17)=="0A"||CHEM_BIOM=="N"||EMBIOM=="N"
     .textw "Surface biomass emissions are NOT included. Field  NOT required." L
   .invisend
   .basrad "Surface biomass emissions ancillary field to be" L 3 h ACON(121)
            "Configured" C "Updated" U "Not Used" N
   .case ACON(121)=="U"
   .block 1
      .entry "Every" L AFRE(121)
      .basrad "Time" L 4 h ATUN(121)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap


   .invisible ATMOS_SR(17)!="0A"&&CHEM_BIOM=="Y"&&EMBIOMH=="Y"
     .textw "High-level biomass emissions are included. Field required." L
   .invisend
   .invisible ATMOS_SR(17)=="0A"||CHEM_BIOM=="N"||EMBIOMH=="N"
     .textw "High-level biomass emissions are NOT included. Field  NOT required." L
   .invisend
   .basrad "High-level biomass emissions ancillary field to be" L 3 h ACON(122)
            "Configured" C "Updated" U "Not Used" N
   .case ACON(122)=="U"
   .block 1
      .entry "Every" L AFRE(122)
      .basrad "Time" L 4 h ATUN(122)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend

   

   .textw "Push BIOMASS to go to the Biomass Model window." L
   .pushnext "BIOMASS" atmos_Science_Section_Aero_Bmass
.panend


