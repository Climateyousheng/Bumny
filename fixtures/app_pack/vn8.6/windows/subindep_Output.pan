.winid "subindep_Output"
.title "Output options"
.wintype entry

.panel
   .invisible INDEP_SR(97)=="4A"
      .textw "Timer diagnostic section is not chosen. Diagnostics not possible:" L
   .invisend
   .invisible INDEP_SR(97)!="4A"
      .textw "Timer diagnostic section is chosen. Diagnostics are possible" L
   .invisend
   .gap
   .block 1
   .case INDEP_SR(97)!="4A"
     .check "Subroutine timer diagnostics" L TIMER Y N
   .caseend
   .gap
   .check "Copy Jobsheet to the job library" L JSHEET Y N
   .blockend
   .block 2
   .case JSHEET=="Y" 
         .textw  "Including :" L
         .check "Data files and meaning and dumping sequences." L SECTFL Y N
         .check "Decoded user diagnostic requests and profiles" L SECTST Y N
   .caseend
   .blockend
   .gap
   .block 1
   .basrad "Set level of print output from model" L 4 v PRINT_STATUS
         "Minimum output; only essential messages" PrStatus_Min
         "Normal informative messages and warnings" PrStatus_Normal
         "Operational status; all information messages" PrStatus_Oper
         "Extra diagnostic messages" PrStatus_Diag
   .blockend
   .gap
   .block 1
   .check "Prefix output with originating source file" L PR_SRC_PREF Y N
   .check "Split long lines" L PR_SPL_LINES Y N
   .check "Flush output after each line" L PR_FRC_FLUSH Y N
   .blockend
   .block 1
   .entry "Maximum width of output" L PR_PAP_WD 15
   .basrad "Select tasks for output" L 2 v PR_NT_WRT
       "All pes write output" 1
       "Only PE0 writes output" 2
   .check "Use DrHook" L LDRHOOK Y N
   .blockend
   .gap
   .pushsequence "DRHOOK" subindep_Output_DrHook
.panend







