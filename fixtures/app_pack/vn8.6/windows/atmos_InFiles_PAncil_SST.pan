.winid "atmos_InFiles_PAncil_SST"
.title "Sea surface temperatures"
.wintype entry

.panel
   .gap
   .text "Specify sea-surface-temperature ancillary file and fields" L
   .block 0
      .entry "Directory name or Environment Variable" L APATH(6)
      .entry "and file name" L AFILE(6)
   .blockend
   .gap
   .invisible ARECON=="N"
     .text "Fields cannot be configured as the reconfiguration is off!" L
   .invisend
   .basrad "Sea surface temperature field to be:" L 3 h ACON(28)
            "Configured" C "Updated" U  "Not used" N
   .gap
   .case ACON(28)=="U"
     .block 1
     .entry "Every" L AFRE(28)
     .basrad "Time" L 4 h ATUN(28)
        "Years" Y 
        "Months" M 
        "Days" D 
        "Hours" H
     .blockend
   .caseend
   .gap
   .check  "Tick box to include SST Anomalies (defined in prognostic variable choices)" L SSTAN Y N
   .case SSTAN== "Y"
      .block 1
      .basrad "Choose from" L 2 v SSTA
         "Config SST anomaly from ANCIL file named above" Y
         "Calculate SST anomaly from input dump" N
      .blockend
   .caseend
   .check "Using AMIP-II method of updating SST and sea ice." L AMIPII Y N
.panend


