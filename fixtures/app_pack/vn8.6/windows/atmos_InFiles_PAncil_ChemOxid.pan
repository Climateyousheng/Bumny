.winid "atmos_InFiles_PAncil_ChemOxid"
.title "Chemical Oxidants"
.wintype entry

.panel
   .text "Define the use of the Chemical Oxidants ancillary fields and file" L
   .block 0
      .entry "Enter directory or Environment Variable" L APATH(18)
      .entry "and file name" L AFILE(18)
   .blockend
   .invisible ARECON=="N"
     .text "Fields cannot be configured as the reconfiguration is off!" L
   .invisend
   .gap

   .invisible  (ATMOS_SR(17)!="0A") && (CHEM_SULPC=="Y") && ((LSULPOXI=="N")||(ATMOS_SR(34)=="0A")||(UKCA_SOLV==0))
     .textw "Sulphur Cycle is on. Ozone-oxidant is the only optional field." L
   .invisend
   .invisible (ATMOS_SR(17)=="0A") || (CHEM_SULPC=="N") || ((LSULPOXI=="Y")&&(ATMOS_SR(34)!="0A")&&(UKCA_SOLV!=0))
     .textw "Sulphur Cycle is NOT on or S cycle is coupled to UKCA. None of these fields are required." L
   .invisend 

   .basrad "OH Concentrations ancillary field to be" L 3 h ACON(73)
            "Configured" C "Updated" U "Not Used" N
   .case ACON(73)=="U"
   .block 1
      .entry "Every" L AFRE(73)
      .basrad "Time" L 4 h ATUN(73)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap

   .basrad "HO2 Concentrations ancillary field to be" L 3 h ACON(74)
            "Configured" C "Updated" U "Not Used" N
   .case ACON(74)=="U"
   .block 1
      .entry "Every" L AFRE(74)
      .basrad "Time" L 4 h ATUN(74)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap

   .basrad "H2O2 Concentrations ancillary field to be" L 3 h ACON(75)
            "Configured" C "Updated" U "Not Used" N
   .case ACON(75)=="U"
   .block 1
      .entry "Every" L AFRE(75)
      .basrad "Time" L 4 h ATUN(75)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap

   .invisible (ATMOS_SR(17)!="0A")&&(CHEM_SULPC=="Y")&&(SULOZONE=="Y")&&((LSULPOXI=="N")||(ATMOS_SR(34)=="0A")||(UKCA_SOLV==0))
     .textw "Ozone-oxidant is included." L
   .invisend
   .invisible (ATMOS_SR(17)=="0A")||(CHEM_SULPC=="N")||(SULOZONE!="Y")||((LSULPOXI=="Y")&&(ATMOS_SR(34)!="0A")&&(UKCA_SOLV!=0))
     .textw "Ozone-oxidant is not required." L  
   .invisend

   .basrad "Ozone-Oxidant Concentrations ancillary field to be" L 3 h ACON(76)
            "Configured" C "Updated" U "Not Used" N
   .case ACON(76)=="U"
   .block 1
      .entry "Every" L AFRE(76)
      .basrad "Time" L 4 h ATUN(76)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap

   .textw "Push SULPHUR to go to the Sulphur Cycle window." L
   .pushnext "SULPHUR" atmos_Science_Section_Aero_Sulphur

.panend


