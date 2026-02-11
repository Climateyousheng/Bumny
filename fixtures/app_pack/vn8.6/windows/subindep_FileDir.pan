.winid "subindep_FileDir"
.title "Control"
.wintype entry

.panel
   .basrad "Select Time Convention File Naming Option" L 4 v OCATC 
              "Relative Time. e.g. T+NN relative to the basis" 1
              "Relative Time In Timesteps - Short Runs Only  " 2
    "Absolute time, Date stamp convention  (Recommended for climate runs)" 7
              "Sub-hourly Relative Time (hhmm) - valid upto 15 days" 6
   .gap
   .text "Define other environment variables for Read-Only data directories. These variables are set in the UMUI generated SCRIPT." L
   .textw "Check the UM scripts to reduce risk that your names do not clash with standard UM variables." L
   .table envirs "Defined Environment Variables for Directories" top h N_ENVARS 8 TIDY
     .elementautonum "Number" 1 N_ENVARS 5
     .element "Variable Name   " ENVAR_NAME N_ENVARS 50 in
     .element "Value, full path name           " ENVAR_VAL N_ENVARS 55 in
   .tableend
   .gap
   .textw "The following may use variables defined in the table above" L
   .block 1
     .colour red  GEN_SUITE==1
      .entry "DATAM            : Define the directory for written output with time-stamped names" L DATAM
      .entry "DATAW            : Define the directory for other output file" L DATAW
     .colourend
   .blockend  
   .gap
   .check "Override default value of UM_TMPDIR" L LOVERTMP Y N
     .block 1
     .case  LOVERTMP=="Y"
       .entry "UM_TMPDIR: Define the directory for temp files in the format of this/path/temp_$RUNID" L OVERTMPDIR
       .textw "i.e. any path, but the final directory must be temp_$RUNID" L
     .caseend
     .blockend
   .check "Override default value of UMDIR" L UMDIR_OPT Y N
   .block 1
   .case UMDIR_OPT=="Y"
     .entry "Define the directory for UMDIR" L UMDIR_VAL
   .caseend
   .blockend  
   .check "Override default value of MY_OUTPUT" L MYOUTPUT_OPT Y N
   .block 1
   .case MYOUTPUT_OPT=="Y"
     .entry "Define the directory for MY_OUTPUT" L MYOUTPUT_VAL
   .caseend
   .blockend  
   .gap
.panend


