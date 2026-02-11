.winid "atmos_InFiles_PAncil_RivRout"
.title "River Routing Schemes"
.wintype entry

.panel
 
  .invisible ATMOS_SR(26)=="0A"
     .textw "You have not choosen River Routing Scheme <1A>" L
     .textw "Ancillary files should not be configured !!!" L
  .invisend     
  .gap
  .invisible ATMOS_SR(26)=="1A"
    .textw "You have choosen River Routing Scheme <1A>" L
    .textw "Specify ancillary file and fields River Routing Scheme <1A>" L 
  .invisend  
    .gap
    .block 1
      .entry "Enter directory or Environment Variable" L APATH(31)
      .entry "and file name" L AFILE(31)
    .blockend  
      .gap
    .block 1  
      .basrad "The ancillary river direction to be configured." L 2 h ACON(126)
                "Configured" C "Not used" N
      .basrad "The ancillary river sequence to be configured." L 2 h ACON(125)
                "Configured" C "Not used" N
    .blockend
    .gap
    .gap
    .textw "Specify river water storage ancillary file and fields" L 
    .gap
    .block 1
      .entry "Enter directory or Environment Variable" L APATH(30)
      .entry "and file name" L AFILE(30)
    .blockend  
      .gap
    .block 1  
      .basrad "Ancillary fields to be:" L 2 h ACON(124)
                "Configured" C "Not used" N
    .blockend
.gap
.textw "Push RIVER to go to River Routing panel." L
.pushnext "RIVER" atmos_Science_Section_River
.panend
