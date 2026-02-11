.winid "subindep_OutputMan"
.title "Output Management options"
.wintype entry

.panel
  .case GEN_SUITE==0
    .entry "Specify job-name. RUNID000 is recommended and converted " L CJOBN
    .textw "(8 chars total, last 2 must be digits for re-submitting runs, eg. \"CCCCCCNN\". Text \"RUNID\" is converted to your run-id.)" L
  .caseend
  .gap
  .check "Specifying extended script output" L LONGOUT Y N
  .entry "Specify maximum length for 'STANDARD OUT' stream" L LOUTPUT
  .gap
  .check "Copy control files to run output" L UIPRINT Y N
  .gap
  .textw "On MPP machines, each PE produces its own text output file in DATAW" L
  .basrad "Output option for distributed-memory parallel machines:" L 2 v DELMPPO
           "Delete all DATAW text output files on successful completion." Y
           "Always keep output from PEs in DATAW even when the run works." N
  .gap
  .check "Mail the user when the job starts" L START_MAIL Y N
  .check "Mail the user when the job completes" L END_MAIL Y N
  .gap
.panend
