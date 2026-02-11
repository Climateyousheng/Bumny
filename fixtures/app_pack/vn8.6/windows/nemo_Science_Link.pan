.winid "nemo_Science_Link"
.title "Links to NEMO model"
.wintype entry

.panel
  .gap
  .invisible NEMO=="T"
     .textw "NEMO model is coupled" L
  .invisend
  .invisible NEMO!="T"
     .textw "NEMO model is not coupled" L
  .invisend  
  .gap
  .case NEMO=="T"
    .textw "Please note: the code revision selected on the FCM configuration panel is: [get_variable_value FCM_NEMO_VER]" L
    .basrad "Select NEMO version:" L 3 v NEMOVERSION
      "vn3.2" 302
      "vn3.3.1" 3031
      "vn3.4" 304
    .gap
    .table nemo_lnk "Symbolic links to NEMO files" top h 25 10 TIDY
      .elementautonum "No" 1 25 5
      .element "NEMO input file name   " LNK_NM_NEMO 25 26 in
      .element "Actual full path and file name  " LNK_VAL_NEMO 25 56 in
   .tableend
   .gap
   .block 1
   .entry "NEMO Model control namelist" L NMLST_NEMO
   .entry "NEMO LIM ice namelist (see Help)" L NEMONLICE  
   .entry "NEMO start dump (see Help)" L START_NEMO
   .check "NEMO restart dumps named by date" L NEMO_RESTRT Y N
   .check "Open new diagnostic output files every time restart dump is written" L NEMO_SEP_MEANS T F
   .blockend
   .gap
   .block 1
     .check "Use iomput for diagnostics (see Help for details)" L NEMOKEY_IOMPUT Y N
   .blockend
  .caseend
  .gap  
.panend



         
