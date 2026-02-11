.winid "personal_gen"
.title "Personal details"
.wintype entry
.procs {} {} {job_descr; # checks job JOBDESC string}
.panel
  .gap
  .block 1
    .entry "Job description" L JOBDESC
    .entry "Target Machine user-id:" L USERID
    .entry "Mail-id for notification of end-of-run" L MAIL_ID
  .blockend 
  .gap
  .case GEN_SUITE==0
    .block 1
      .check "Override Met Office user's default IBM Account Group" L L_ACCGRP Y N
      .case L_ACCGRP=="Y"
        .block 2
          .basrad "Account" L 4 h ACCGRP
             "Science"  science
             "NWP"      nwp
             "CR"       cr
             "External" ext
          .invisible ACCGRP=="ext"
            .entry "Account name:" L ACCGRP_OTHR
          .invisend
        .blockend
      .caseend
    .blockend
    .gap
    .entry "Specify job-name. RUNID000 is recommended and converted." L CJOBN 18
  .caseend
  .case GEN_SUITE==0
    .textw "(8 chars total, last 2 must be digits for re-submitting runs, eg. \"CCCCCCNN\"." L
    .textw "Text \"RUNID\" is converted to your run-id)." L
  .caseend
  .gap
  .check "Rename the EXPT_ID (see help)." L PRODRUN Y N
  .case PRODRUN=="Y"
    .entry "Specify alternative name" L RUN_NAME
  .caseend
  .gap
.panend
.set_on_closure "JOBDESC variable " JOBDESC



