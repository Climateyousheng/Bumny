.winid "subindep_BldUMScr"
.title "UM Scripts Build"
.wintype entry

.panel
 .gap
 .check "Enable build of UM scripts" L LBLDUMSCR Y N
 .gap
 .textw "Your job has the following settings:" L  
 .block 1
 .invisible ATMOS=="T"
   .textw "ATMOS is ON" L
 .invisend
  .invisible ATMOS=="F"
   .textw "ATMOS is OFF" L
 .invisend
 .case 1==2
 .block 2
   .invisible COMP_ATM=="N" &&  RUN_ATM=="Y"
     .textw "Atmosphere model is set to RUN ONLY" L
   .invisend
   .invisible COMP_ATM=="N" &&  RUN_ATM=="N"
     .textw "Atmosphere model is not set to compile or run" L
   .invisend
   .invisible COMP_ATM=="Y" &&  RUN_ATM=="Y"
     .textw "Atmosphere model is set to COMPILE AND RUN" L
   .invisend
   .invisible COMP_ATM=="Y" &&  RUN_ATM=="N"
     .textw "Atmosphere model is set to COMPILE ONLY" L
   .invisend
 .blockend
 .caseend
 .invisible NEMO=="T"
   .textw "NEMO is ON" L
 .invisend
  .invisible NEMO=="F"
   .textw "NEMO is OFF" L
 .invisend
 .invisible CICE=="T"
   .textw "CICE is ON" L
 .invisend
  .invisible CICE=="F"
   .textw "CICE is OFF" L
 .invisend 
 .gap
 .case 1==2
   .basrad "NEMO" L 4 h CP_NEMOC
     "1 run only" 1
     "2 comp & run" 2
     "3 comp only" 3
     "undef" undef
   .basrad "CICE" L 4 h CP_CICEC
     "1 run only" 1
     "2 comp & run" 2
     "3 comp only" 3
     "undef" undef
 .blockend
 .caseend
 .gap
.panend


