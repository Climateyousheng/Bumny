.winid "atmos_InFiles_OtherAncil_Spectral"
.title "LW and SW radiation Spectral files"
.wintype entry

.panel
  .text "Note, spectral files must be chosen in conjunction with radiation options." L
  .gap
  .case ES_RAD==1||ES_RAD==3
    .text "You have chosen general 2-stream SW radiation." L
    .gap
    .text "Specify the location of the shortwave spectral file" L
    .block 1
      .entry "Directory" L PATHSW
      .entry "Prognostic File" L FILESW
      .case ATMOS_SR(2)=="3Z" && LSWUSE3C!="0"
        .entry "Diagnostic File" L FILESWD
      .caseend      
    .blockend
  .caseend 
  .gap
  .case ES_RAD==2||ES_RAD==3
    .text "You have chosen general 2-stream LW radiation." L
    .gap
    .text "Specify the location of the longwave spectral file" L
    .block 1
      .entry "Directory" L PATHLW
      .entry "Prognostic File" L FILELW
      .case ATMOS_SR(2)=="3Z" && LSWUSE3C!="0"
        .entry "Diagnostic File" L FILELWD
      .caseend
    .blockend
  .caseend 
  .gap
  .textw "Push SW to go to SW radiation section choices." L
  .textw "Push LW to go to LW radiation section choices." L
  .pushnext "SW" atmos_Science_Section_SW 
  .pushnext "LW" atmos_Science_Section_LW 
.panend 



 


