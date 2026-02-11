.winid "atmos_Science_ModelTesting"
.title "Model Testing"
.wintype entry

.panel
   .gap
   .text "Variables required for model testing:" L
   .block 1
     .check "Running a dry model (off for normal runs)"         L LMT_DRY T F
     .check "Running with free-slip boundary conditions (off for normal runs)"         L LMT_FS T F
     .check "Run with dry_static_adjustment (off for normal runs)" L LMT_ADJWET T F
     .check "Run dynamics only (off for normal runs)" L L_DYN_ONLY T  F  
     .check "Add perturbation to initial theta field (IC sensitivity work)" L LPICTHETA T F
     .case LPICTHETA=="T"
        .block 2 
        .entry "Integer seed for random number (range 0 to 10000)" L IRNDSEED 15
        .blockend
     .caseend
     .check "Run Idealised problems" L LIDEAL Y N
     .case LIDEAL=="Y"
       .basrad "Choose idealised Test Problem:" L 4 v IPROBNUM
               "1:  Monsoon" 1
               "2:  Dynamical core" 2
               "3:  Idealised Problem" 3
               "4:  Standard run from namelist" 4
       .gap
         .text "Specify path for namelist file (required for all problems):" L
         .entry "Directory" L IDIR
         .entry "File" L INAME
     .caseend
   .blockend 

   .gap
   .text "Backwards integration option (Physics must not be Included)" L
   .case L_DYN_ONLY=="T"
     .block 1
       .check "Running the dynamics backwards" L L_BACKWARDS T F 
     .blockend  
   .caseend 
   
.panend




