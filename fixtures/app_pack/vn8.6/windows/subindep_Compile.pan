.winid "subindep_Compile"
.title "Compile and run options for Atmosphere and Reconfiguration"
.wintype entry

.panel
 .gap
 .case ATMOS=="T"
   .text "Compile Control" L
   .block 1
     .case COMP_ATM=="Y" || COMP_RCF == "Y"
       .entry "Time limit for compilation (-1 for the queue default)" L COMPTLIM 15
     .caseend
     .gap
     .check "Compile Model executable" L COMP_ATM Y N
     .case COMP_ATM=="Y"
       .case GEN_SUITE==0
         .block 2
         .check "Change the system default (1) for the max no of compilation processes?" L SETNPROC Y N
         .blockend
         .case SETNPROC=="Y"
           .block 2
             .entry "Specify max (6) no of compilation processes" L NPROC 15
           .blockend
           .case SUBMIT_METHOD==3 || SUBMIT_METHOD==7
                 .block 2    
                    .entry "Specify compile memory limit (Mb)" L CMEMO 15
                 .blockend
           .caseend
         .caseend
       .caseend
       .block 2
         .basrad "Define the level of optimisation" L 3 v FCM_COMP_GEN
            "safe (e.g. climate)" safe
            "high (e.g. operational)" high
            "debug" debug
       .blockend
     .caseend
     .gap
     .check "Compile Reconfiguration executable" L COMP_RCF Y N
     .case COMP_RCF == "Y"
       .block 2
         .check "Compile serial executable" L RCFSERIAL Y N
       .blockend
     .caseend
   .blockend
   .gap
   .text "Run Control" L
   .block 1
     .check "Run the model" L RUN_ATM Y N
   .blockend
 .caseend
 .case GEN_SUITE==0
   .invisible (ATMOS=="T" && (RUN_ATM=="N" || COMP_ATM=="Y" || ARECON=="Y")) || (NEMO=="T" && NEMOC!=1) || (CICE=="T" && NEMO=="F" && CICEC!=1)
     .block 2
       .text "The chosen combination of compile/run options require an NRUN." L
     .blockend
   .invisend
   .case ((RUN_ATM=="Y" && COMP_ATM=="N" && ARECON=="N") || ATMOS=="F") && (NEMOC==1 || NEMO=="F") && (CICEC==1 || CICE=="F" || NEMO=="T")
     .block 2
       .basrad "Type of model run:" L 2 v NCRUN
          "Normal run (NRUN)" NRUN
          "Continuation run (CRUN)" CRUN
     .blockend
    .caseend
 .caseend
 .case ATMOS=="T"
   .block 1
     .check "Run the reconfiguration" L ARECON Y N
   .blockend
   .gap
   .text "Specify Executable Paths/Filenames" L
   .block 1     
     .colour red GEN_SUITE==1
       .entry "Directory for the Reconfiguration executable" L PATHREC
       .entry "Filename for the Reconfiguration executable"      L FILEREC
       .entry "Directory for the Model executable" L PATHEXEC
       .entry "Filename for the Model executable"      L FILEEXEC
     .colourend
   .blockend   
 .caseend
 .gap
.panend


