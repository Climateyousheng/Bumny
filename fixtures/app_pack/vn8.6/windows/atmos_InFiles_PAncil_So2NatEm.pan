.winid "atmos_InFiles_PAncil_So2NatEm"
.title "SO2 Emissions (3D)."
.wintype entry

.panel
   .text "Define the use of the 3D Sulphur Emissions ancillary fields and file" L
   .block 0
      .entry "Enter directory or Environment Variable" L APATH(17)
      .entry "and file name" L AFILE(17)
   .blockend
   .invisible ARECON=="N"
     .text "Fields cannot be configured as the reconfiguration is off!" L
   .invisend
   .gap


   .invisible ATMOS_SR(17)!="0A" && CHEM_SULPC=="Y" && EMSO2N=="Y"
     .textw "Sulphur Cycle is on with Natural SO2 Emissions. The fields needs to be specified." L
   .invisend
   .invisible ATMOS_SR(17)=="0A" || CHEM_SULPC!="Y" || EMSO2N!="Y"
     .textw "Sulphur Cycle is on with Natural SO2 Emissions is NOT on. The field is NOT required." L
   .invisend

   .basrad "Natural SO2 Emissions ancillary field to be" L 3 h ACON(72)
            "Configured" C "Updated" U "Not Used" N
   .case ACON(72)=="U"
   .block 1
      .entry "Every" L AFRE(72)
      .basrad "Time" L 4 h ATUN(72)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap

   .textw "Push SULPHUR to go to the Sulphur Cycle window." L
   .pushnext "SULPHUR" atmos_Science_Section_Aero_Sulphur

.panend


