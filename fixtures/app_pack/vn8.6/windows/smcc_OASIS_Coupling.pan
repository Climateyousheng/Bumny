.winid "smcc_OASIS_Coupling"
.title "The OASIS Coupler"
.wintype entry

.panel
  .case ATMOS=="T"
  .check "Use OASIS coupling" L OASIS T F
  .case OASIS=="T"
    .block 1
       .check "Perform atmosphere coupling through master PE" L LCPLMASTER T F
       .check "Time coupling operations" L OASIS_TIMERS T F
       .case NEMO=="T"
         .check "Perform NEMO coupling through master PE" L LCPLNEMOMR T F
       .caseend
    .blockend
    .block 1
    .entry "Coupling frequency (hours)" L OASCPLFREQ 
    .entry "Standard Coupling Macro" L STDCPLMACRO
    .check "Include iceberg calving ancillary" L LOASIS_ICECLV T F
    .blockend
    .gap
    .block 1
    .basrad "Choose OASIS version     " L 2 h OASISWHICH
       "OASIS3" 3
       "OASIS3-MCT" 4
    .blockend
    .block 1
    .case  OASISWHICH==4
       .entry "Task spacing repeat interval     " L CPL_TASK_SPACING 8
    .caseend
    .blockend
    .block 1
    .basrad "Select OASIS MPI version" L 2 h OASIS_MPI_TYPE
       "MPI1" 1
       "MPI2" 2
    .blockend 
  .gap  
  .invisible OASISWHICH==3
     .block 1
     .entry "Location of OASIS3 build         " L PRISMHOME3 
     .entry "Location of OASIS3 namcouple         " L XML_LCN3
     .text "and cf_name_table" L 
     .entry "Controlling namcouple file" L SCC3  
     .entry "Location of remapping weights files" L RMP_DIR   
     .gap  
     .blockend
  .invisend
  .invisible OASISWHICH==4
     .block 1
     .entry "Location of OASIS3-MCT build" L PRISMHOME4
     .entry "Location of OASIS3-MCT namcouple " L XML_LCN4
     .text "and cf_name_table" L
     .entry "Controlling namcouple file" L SCC4
     .entry "Location of remapping weights files" L RMP_DIR2  
     .gap  
     .blockend
  .invisend
  .block 1
  .check "Use existing grids files" L UGRDSDIR T F  
  .case UGRDSDIR=="T"
     .block 2
     .entry "Grids netcdf file" L NCGRIDS
     .entry "Masks netcdf file" L NCMASKS
     .entry "Areas netcdf file" L NCAREAS
     .entry "Angles netcdf file" L NCANGLES
     .gap
     .blockend
  .caseend
  
  .case ATMOS=="T" && NEMO=="T" && CICE=="T"
    .table ldflags "NEMO Load flags" top h NEMOFL_CNT 5 INCR
       .elementautonum "No" 1 NEMOFL_CNT 3
       .element "Flag value" NEMOFL_VAL NEMOFL_CNT 65 in
       .element "Use Y/N" NEMOFL_USE NEMOFL_CNT 5 in
    .tableend
  .caseend
  .caseend
  .caseend
  .gap

  .textw "Push ANCIL for Oasis coupling fields" L
  .pushnext "ANCIL" atmos_InFiles_PAncil_OASISCoupler
.panend


