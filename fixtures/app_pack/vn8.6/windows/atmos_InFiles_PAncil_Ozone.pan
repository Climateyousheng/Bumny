.winid "atmos_InFiles_PAncil_Ozone"
.title "Ozone"
.wintype entry

.panel
   .text "Define the use of the Ozone ancillary fields and file" L
   .block 0
      .entry "Enter directory or Environment Variable" L APATH(1)
      .entry "and file name" L AFILE(1)
   .blockend
   .invisible ARECON=="N"
     .text "Fields cannot be configured as the reconfiguration is off!" L
   .invisend
   .gap
   .basrad "Ozone ancillary field to be" L 3 h ACON(7)
            "Configured" C "Updated" U "Not Used" N
   .case ACON(7)=="U"
   .block 1
      .entry "Every" L AFRE(7)
      .basrad "Time" L 4 h ATUN(7)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap
   .textw "Elsewhere you have specified:" L
   .entry "Number of ozone levels" L NOZLEV
   .basrad "Ozone is held as " L 2 h EXPOZ 
    "zonal average values" Y "Full field" N
   .textw "The ancillary file and internal use must be the same." L 
   .gap
   .invisible (OZINT==1||OZINT==2)&&OCAAA==1&&LUCARIOLLE=="Y"
     .textw "Cariolle scheme to calculate ozone tracer is ON. Below fileds are required" L
   .invisend
   .invisible !((OZINT==1||OZINT==2)&&OCAAA==1&&LUCARIOLLE=="Y")
     .textw "Cariolle scheme to calculate ozone tracer is OFF. None of these fields are required." L
   .invisend
   .block 0
      .entry "Enter directory or Environment Variable" L APATH(46)
      .entry "and file name" L AFILE(46)
   .blockend
   .gap
   .basrad "Ozone tracer ancillary fields to be" L 3 h ACON(178)
            "Configured" C "Updated" U "Not Used" N
   .case ACON(178)=="U"
   .block 1
      .entry "Every" L AFRE(178)
      .basrad "Time" L 4 h ATUN(178)
               "Years" Y "Months" M "Days" D "Hours" H
   .blockend
   .caseend
   .gap   

.panend


