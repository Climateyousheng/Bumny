.winid "subindep_ResOther"
.title "Other Machine Resources"
.wintype entry

.case GEN_SUITE==0 && SUBMIT_METHOD==0
  .gap
  .block 0
    .entry "Submission command prefix" L OTR_SUBM_PRE 25
    .entry "Submission command suffix" L OTR_SUBM_POST 25
  .blockend
  .gap 
  .check "Include user definitions instead of Standard file" L LUSROTHER Y N
  .text "Please see help file more more details" L
  .case LUSROTHER=="Y"
    .table usr_other_inc "User Definitions" top h USR_OTHR_CNT 15 INCR
      .elementautonum "No" 1 USR_OTHR_CNT 3
      .element "Statement" USR_OTHR_LEFT USR_OTHR_CNT 80 in  
.comment      .element "Right Part" USR_OTHR_RIGHT USR_OTHR_CNT 45 in  
      .element "Where" USR_OTHR_WHERE USR_OTHR_CNT 5 in
      .element "USE" USR_OTHR_USE USR_OTHR_CNT 3 in  
    .tableend    
  .caseend
  .gap
.panel
  .textw "Push Back to go to the Submit Method window" L
  .pushnext "Back" subindep_SubmitMethod
.panend
