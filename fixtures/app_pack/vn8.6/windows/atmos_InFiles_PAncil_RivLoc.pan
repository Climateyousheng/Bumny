.winid "atmos_InFiles_PAncil_RivLoc"
.title "River Routing Schemes"
.wintype entry

.panel
   
  .gap 
  .invisible ATMOS_SR(26)=="0A"
       .textw "You have not choosen River Routing Scheme <2A>" L
       .textw "Ancillary files should not be configured !!!" L
   .invisend     
  
  .invisible ATMOS_SR(26)=="2A"
    .textw "You have choosen River Routing Scheme <2A>" L
    .textw "Specify ancillary file and fields River Routing Scheme <2A>" L 
  .invisend  
    .gap
    .block 0
      .entry "Enter directory or Environment Variable" L APATH(32)
      .entry "and file name" L AFILE(32)
    .blockend
    .gap
    .block 1
      .check "The ancillary drainage areas file to be configured." L ACON(127) C N
      .check "The ancillary X-coordinate of downstream PT to be configured." L ACON(128) C N
      .check "The ancillary Y-coordinate of downstream PT to be configured." L ACON(129) C N
      .check "The ancillary slope to be configured." L ACON(130) C N
      .check "The ancillary initialization file for river flows to be configured." L ACON(131) C N
      .check "The ancillary land or river to be configured." L ACON(132) C N
    .blockend
.gap
.textw "Push RIVER to go to River Routing panel." L
.pushnext "RIVER" atmos_Science_Section_River
.panend
