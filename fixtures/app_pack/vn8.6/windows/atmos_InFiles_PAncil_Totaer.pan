.winid "atmos_InFiles_PAncil_Totaer"
.title "Total aerosol fields"
.wintype entry

.panel     
  .text "Specify the Total-aerosol ancillary file and fields" L
  .block 1
      .text "Specify the file" L
      .entry "Enter directory or Environment Variable" L APATH(14)
      .entry "and file name" L AFILE(14)
      .gap
  .blockend   
   .invisible ARECON=="N"
     .text "Fields cannot be configured as the reconfiguration is off!" L
   .invisend
  .gap

  .invisible TOTAE=="Y"
    .textw "Total aerosol fields are included" L
  .invisend
  .invisible TOTAE=="N"
    .textw "Total aerosol fields are not included" L
  .invisend

.comment  .basrad "Elsewhere, total aerosol fields are defined to be:" L 2 h TOTAE 
.comment          "included" Y 
.comment          "not included" N

  .block 1
      .basrad "Total aerosol concentration is:" L 3 h ACON(45)
            "Configured" C "Updated" U "Not used" N
  .blockend
  .case ACON(45)=="U"
    .block 2
      .entry "Every" L AFRE(45)
      .basrad "Time" L 4 h ATUN(45)
               "Years" Y "Months" M "Days" D "Hours" H
      .gap
    .blockend
  .caseend   

.comment       .basrad "Elsewhere, source sink terms are defined to be:" L 2 h TOTEM 
.comment               "included" Y 
.comment               "not included" N

  .invisible (TOTAE=="Y" && TOTEM=="N") || (TOTAE=="N" && TOTEM=="Y") || (TOTAE=="N" && TOTEM=="N")
    .textw "Source and sink terms cannot be used as total fields are not included" L 
  .invisend
  .invisible TOTAE=="Y" && TOTEM=="Y"
    .textw "Source and sink terms can be used " L 
  .invisend
  .block 2
      .basrad "Source and sink terms are" L 3 h ACON(44)
              "Configured" C "Updated" U "Not used" N
  .blockend
  .case ACON(44)=="U"
    .block 3
      .entry "Every" L AFRE(44)
      .basrad "Time" L 4 h ATUN(44)
               "Years" Y "Months" M "Days" D "Hours" H
    .blockend
  .caseend
  .gap
  .text "Note: use of the source is incompatible with updating concentration" L
.panend


