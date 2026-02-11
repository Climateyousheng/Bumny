.winid "atmos_InFiles_PAncil_LSH"
.title "Large Scale Hydrology"
.wintype entry

.panel
   .gap
   .text "Define ancillary file for Large-Scale Hydrology mean topographic index" L 
   .gap
   .block 1
      .entry "Enter directory or Environment Variable" L APATH(98)
      .entry "Enter file name" L AFILE(98)
   .blockend
   .gap
   .invisible (ATMOS_SR(8)!="0A" && LTOP=="Y")
     .textw "Large-Scale Hydrology is included. Field required." L
   .invisend
   .invisible (ATMOS_SR(8)=="0A" || LTOP=="N")
     .textw "Large-Scale Hydrology is NOT included. Field  NOT required." L
   .invisend
   .gap
   .textw "Mean topographic index" L
   .basrad "ancillary field to be" L 3 h ACON(33)
          "Configured" C "Updated" U "Not Used" N
   .case ACON(33)=="U"
     .block 2
     .entry "Every" L AFRE(33)
     .basrad "Time" L 4 h ATUN(33)
       "Years" Y "Months" M "Days" D "Hours" H
     .blockend
   .caseend
   .gap
   .gap
   .text "Define ancillary file for Large-Scale Hydrology standard deviation in topographic index" L 
   .block 1
      .entry "Enter directory or Environment Variable" L APATH(99)
      .entry "Enter file name" L AFILE(99)
   .blockend
   .gap
   .invisible (ATMOS_SR(8)!="0A" && LTOP=="Y")
     .textw "Large-Scale Hydrology is included. Field required." L
   .invisend
   .invisible (ATMOS_SR(8)=="0A" || LTOP=="N")
     .textw "Large-Scale Hydrology is  NOT included. Field  NOT required." L
   .invisend
   .gap
   .textw "Standard deviation in topographic index " L
   .basrad "ancillary field to be" L 3 h ACON(34)
          "Configured" C "Updated" U "Not Used" N
   .case ACON(34)=="U"
     .block 2
     .entry "Every" L AFRE(34)
     .basrad "Time" L 4 h ATUN(34)
       "Years" Y "Months" M "Days" D "Hours" H
     .blockend
   .caseend
   .gap
   .textw "Push HYDROL to go back to the Hydrology window." L
   .pushnext "HYDROL" atmos_Science_Section_Hydrol
.panend


