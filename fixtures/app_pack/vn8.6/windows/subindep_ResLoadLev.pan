.winid "subindep_ResLoadLev"
.title "LoadLeveler Resources"
.wintype entry

.panel
.case GEN_SUITE==0 && SUBMIT_METHOD==3
  .text "The host name is [get_variable_value MACH_NAME]" L
  .gap

  .basrad "Class name" L 5 h QIBM
    "serial" serial
    "parallel" parallel
    "run_cr" run_cr
    "run_nwp" run_nwp
    "other" other

  .gap         
  .case QIBM=="other"
    .entry "Specifiy other class name:"  L CJOTHER 17 
  .caseend  
  .gap  
  .textw "On IBM input number of Gb. Any fraction is converted to Mb (eg. 1.4 converts to 1400Mb)" L    
  .entry "Job memory limit (See Help text)" L CJSIZE 12
  .entry "Job time limit" L CJTLIM   12  
.caseend
.gap
  .textw "Push Back to go to the Submit Method window" L
  .pushnext "Back" subindep_SubmitMethod
.panend
