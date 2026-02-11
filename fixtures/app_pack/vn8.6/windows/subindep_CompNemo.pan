.winid "subindep_CompNemo"
.title "NEMO Compile and Run Options"
.wintype entry

.panel
 .case NEMO=="T"  
   .text "Specify options for the NEMO executable" L
   .gap
   .basrad "Choose option" L 3 v NEMOC
      "Run from existing executable, as named below" 1
      "Compile and build the executable named below, then run" 2
      "Compile and build the executable named below, then stop" 3
   .gap
 .caseend
 .case GEN_SUITE==0
   .invisible (ATMOS=="T" && (RUN_ATM=="N" || COMP_ATM=="Y" || ARECON=="Y")) || (NEMO=="T" && NEMOC!=1) || (CICE=="T" && NEMO=="F" && CICEC!=1)
     .text "The chosen combination of compile/run options require an NRUN." L
   .invisend
   .case ((RUN_ATM=="Y" && COMP_ATM=="N" && ARECON=="N") || ATMOS=="F") && (NEMOC==1 || NEMO=="F") && (CICEC==1 || CICE=="F" || NEMO=="T")
     .block 1
       .basrad "Type of model run:" L 2 v NCRUN
          "Normal run (NRUN)" NRUN
          "Continuation run (CRUN)" CRUN
     .blockend
    .caseend
 .caseend
 .case NEMO=="T"
   .gap
   .case NEMOC!=1 && GEN_SUITE==0
     .check "Change the system default for the max No of compilation processes?" L SETNPROC_N Y N
     .case SETNPROC_N=="Y"
       .block 1
       .entry "Specify max no of compilation processes" L NPROC_N 14
       .blockend
     .caseend
     .gap
   .caseend
   .gap
   .block 1
   .block 1
     .colour red GEN_SUITE==1
       .entry "Specify the directory for the executable" L PATHNEMO
       .entry "Specify the file for the executable"      L FILENEMO
     .colourend
   .blockend
 .caseend 
.panend


