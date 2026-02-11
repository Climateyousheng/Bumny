.winid "cice_Science_Link"
.title "Links to CICE model"
.wintype entry

.panel
  .gap
  .invisible CICE=="T"
     .textw "CICE model is coupled" L
  .invisend
  .invisible CICE!="T"
     .textw "CICE model is not coupled" L
  .invisend  
  .gap
  .entry "Number of sea ice categories:" L NCICECAT 15
  .gap
  .case CICE=="T"
    .table cice_lnk "Symbolic links to CICE files" top h 25 10 TIDY
      .elementautonum "No" 1 25 5
      .element "CICE input file name   " LNK_NM_CICE 25 26 in
      .element "Actual full path and file name  " LNK_VAL_CICE 25 56 in
   .tableend
   .gap
   .block 1
   .entry "CICE Model control namelist" L NMLST_CICE
   .entry "CICE start dump (see Help)" L START_CICE
   .entry "CICE Grid file" L CICEGRID
   .entry "CICE kmt file" L CICEKMT  
   .case NEMO=="F"
     .entry "CICE atmos forcing location" L CICEATM
     .entry "CICE ocean forcing location" L CICEOCN
   .caseend
   .blockend
   .invisible ATMOS=="T"
    .textw "Elsewhere, you have set the number of sea-ice categories to [get_variable_value NCICECAT]" L
   .invisend
  .caseend
  .gap
  
.panend



         
