.winid "atmos_InFiles_PAncil_OCFFEmis"
.title "OCFF Emissions"
.wintype entry

.panel
   .text "Define the use of the OCFF Emissions ancillary fields and file" L
   .block 0
      .entry "Enter directory or Environment Variable" L APATH(47)
      .entry "and file name" L AFILE(47)
   .blockend
   .invisible ARECON=="N"
     .text "Fields cannot be configured as the reconfiguration is off!" L
   .invisend
   .gap

   .invisible ATMOS_SR(17)!="0A"&&CHEM_OCFF=="Y"&&LOCFFSUREM=="Y"
     .textw "Surface OCFF emissions are included. Field required." L
   .invisend
   .invisible ATMOS_SR(17)=="0A"||CHEM_OCFF=="N"||LOCFFSUREM=="N"
     .textw "OCFF emissions are NOT included. Field  NOT required." L
   .invisend
   .basrad "Surface OCFF emissions ancillary field to be" L 3 h ACON(186)
            "Configured" C "Updated" U "Not Used" N
   .case ACON(186)=="U"
   .block 1
      .entry "Every" L AFRE(186)
      .basrad "Time" L 4 h ATUN(186)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap

   .invisible ATMOS_SR(17)!="0A"&&CHEM_OCFF=="Y"&&LOCFFHILEM=="Y"
     .textw "High-level OCFF emissions are included. Field required." L
   .invisend
   .invisible ATMOS_SR(17)=="0A"||CHEM_OCFF=="N"||LOCFFHILEM=="N"
     .textw "High-level OCFF emissions are NOT included. Field  NOT required." L
   .invisend
   .basrad "High-level OCFF emissions ancillary field to be" L 3 h ACON(187)
            "Configured" C "Updated" U "Not Used" N
   .case ACON(187)=="U"
   .block 1
      .entry "Every" L AFRE(187)
      .basrad "Time" L 4 h ATUN(187)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend

   .textw "Push OCFF to go to the OCFF Model window." L
   .pushnext "OCFF" atmos_Science_Section_Aero_OCFF

.panend


