.winid "subindep_ResLinux"
.title "Linux Resources"
.wintype entry

.case GEN_SUITE==0 && SUBMIT_METHOD==1
  .text "The host name is [get_variable_value MACH_NAME]" L
  .gap
  .block 1
  .entry "Job stack limit" L JSTACK   12
  .entry "Specify when to run in 'at' format" L AT_WHEN 12
  .gap
  .blockend


.caseend

.panel
  .textw "Push Back to go to the Submit Method window" L
  .pushnext "Back" subindep_SubmitMethod
.panend
