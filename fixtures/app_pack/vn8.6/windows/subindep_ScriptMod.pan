.winid "subindep_ScriptMod"
.title "Script Modifications"
.wintype entry

.panel
   .check "Using bottom and top script inserts" L SCIN T F
   .case SCIN=="T"
     .text "Define scripts that exist on the 'target' machine" L
     .textw "(i.e. where the model is to be run.)" L
     .block 1
     .entry "The directory name holding your script inserts" L SCINLIB
     .entry "The file name holding the top insert" L SCINMEMT
     .entry "The file name holding the bottom insert" L SCINMEMB
     .blockend
   .caseend
   .gap
   .text "Define general use environment variables (not for standard input directories):" L
      .table envirs1 "Defined Environment Variables" top h N_ENVARS 5 NONE
        .elementautonum "Number" 1 N_ENVARS 5
        .element "Variable Name   " GENVAR_NAME N_ENVARS 15 in
        .element "Value" GENVAR_VAL N_ENVARS 55 in
      .tableend
   .gap
.panend



