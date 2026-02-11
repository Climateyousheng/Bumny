.winid "subindep_JobRes2"
.title "Job Resources and Re-submission, 2"
.wintype entry

.panel
  .case GEN_SUITE==0
    .check "Using automatic re-submission" L JRESUB Y N
    .case JRESUB=="Y"
      .gap
      .textw "Job name set in Personal Details is:   [get_variable_value CJOBN]" L
      .textw "Ensure that it 8 chars total, last 2 must be digits for re-submitting runs." L
      .gap
      .text "Specify the target run length for each job in the sequence" L
      .block 1
        .entry "Years  " L IRYR
        .entry "Months " L IRMO 
        .entry "Days   " L IRDA 
        .entry "Hours  " L IRHR 
        .entry "Minutes" L IRMI 
        .entry "Seconds" L IRSE
      .blockend
      .gap 
      .case SUBMIT_METHOD==0 || SUBMIT_METHOD==3 || SUBMIT_METHOD==6 || SUBMIT_METHOD==7
        .entry "Job time limit for resubmit" L CJTLIMR  20
      .caseend 
    .caseend 
  .caseend
 
  .gap 
  .textw "Push Back to go to the Submit Method window" L
  .pushnext "BACK" subindep_SubmitMethod 
.panend


