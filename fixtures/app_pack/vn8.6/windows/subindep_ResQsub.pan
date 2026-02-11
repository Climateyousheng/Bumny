.winid "subindep_ResQsub"
.title "Qsub Resources"
.wintype entry

.panel
.case GEN_SUITE==0

  .case SUBMIT_METHOD==6 || SUBMIT_METHOD==7
    .text "The host name is [get_variable_value MACH_NAME]" L
    .gap
  .caseend

  .invisible SUBMIT_METHOD==7
    .init QCRAY normal
    .basrad "Class name" L 3 h QCRAY
      "normal" normal
      "shared" shared
      "other" other

    .case QCRAY=="other"
      .entry "Specify other class name:" L CJOTHER2 17
    .caseend
    .gap
    .init HYPERTHREAD F
    .check "Use Hyperthreads" L HYPERTHREAD T F
    .gap
  .invisend

  .case SUBMIT_METHOD==6 || SUBMIT_METHOD==7
    .entry "Job time limit" L CJTLIM2   12
  .caseend 

  .invisible SUBMIT_METHOD==6
    .init SETNTASKS_PER_NODE N
    .invisible MACH_NAME=="login.archer.ac.uk" || MACH_NAME=="tds1.archer.ac.uk"
      .text "Default number of MPI tasks per node is 24" L
    .invisend
    .invisible MACH_NAME=="login.hector.ac.uk" || MACH_NAME=="phase3.hector.ac.uk"   
      .text "Default number of MPI tasks per node is 32" L
    .invisend
    .check "Use non-default number of MPI tasks per node?" L SETNTASKS_PER_NODE Y N
    .block 1
      .invisible SETNTASKS_PER_NODE=="Y"
        .entry "Number of MPI tasks per node" L NTASKS_PER_NODE 12
      .invisend
    .blockend
  .invisend

.caseend

.gap
  .textw "Push Back to go to the Submit Method window" L
  .pushnext "Back" subindep_SubmitMethod
.panend
