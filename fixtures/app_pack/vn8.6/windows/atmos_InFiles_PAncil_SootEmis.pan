.winid "atmos_InFiles_PAncil_SootEmis"
.title "Soot Emissions"
.wintype entry

.panel
   .text "Define the use of the Soot Emissions ancillary fields and file" L
   .block 0
      .entry "Enter directory or Environment Variable" L APATH(23)
      .entry "and file name" L AFILE(23)
   .blockend
   .invisible ARECON=="N"
     .text "Fields cannot be configured as the reconfiguration is off!" L
   .invisend
   .gap


   .invisible ATMOS_SR(17)!="0A"&&CHEM_SOOT=="Y"&&EMSOOT=="Y"
     .textw "Surface soot emissions are included. Field required." L
   .invisend
   .invisible ATMOS_SR(17)=="0A"||CHEM_SOOT=="N"||EMSOOT=="N"
     .textw "Surface soot emissions are NOT included. Field  NOT required." L
   .invisend
   .basrad "Surface soot emissions ancillary field to be" L 3 h ACON(69)
            "Configured" C "Updated" U "Not Used" N
   .case ACON(69)=="U"
   .block 1
      .entry "Every" L AFRE(69)
      .basrad "Time" L 4 h ATUN(69)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap


   .invisible ATMOS_SR(17)!="0A"&&CHEM_SOOT=="Y"&&EMSOOTH=="Y"
     .textw "High-level soot emissions are included. Field required." L
   .invisend
   .invisible ATMOS_SR(17)=="0A"||CHEM_SOOT=="N"||EMSOOTH=="N"
     .textw "High-level soot emissions are NOT included. Field  NOT required." L
   .invisend
   .basrad "High-level soot emissions ancillary field to be" L 3 h ACON(70)
            "Configured" C "Updated" U "Not Used" N
   .case ACON(70)=="U"
   .block 1
      .entry "Every" L AFRE(70)
      .basrad "Time" L 4 h ATUN(70)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend

   

   .textw "Push SOOT to go to the Soot Model window." L
   .pushnext "SOOT" atmos_Science_Section_Aero_Soot

.panend


