.winid "subindep_IOS_Gen"
.title "IO Services - General Options"
.wintype entry

.panel
  .gap
  .case ATMOS=="T" && OCAAA!=5 && LR_OPENMP=="Y" && NTHR_TASK!="1"
    .textw "General Options:" L
    .block 1
      .entry "Buffering memory per IO task (MB)" L IOS_BUFFER 10 
      .entry "General Messaging Max Memory (MB)" L IOS_CMAXMEM 10
      .entry "General messaging concurrency " L IOS_CONCUR 10
      .entry "Polling delay" L IOS_BACKOFF 10 
      .entry "Timeout period" L IOS_TIMEOUT 10 
      .check "Force read-only files to open locally" L IOS_OPNLOCAL Y N
    .blockend 
    .block 1   
      .basrad "IOS Allocation policy" L 4 v IOS_ALLOC
          "Static allocation based on unit number" 1
          "Static allocation based on usage order" 2
          "Dynamic reallocation at reinitialisation points (round robin)" 3
          "Dynamic reallocation at reinitialisation points (load balanced)" 4
    .blockend
    .block 1
      .check "IO Servers acquire level of print output from model" L IOS_PRINTMOD Y N
    .blockend
    .block 1
      .basrad "Set level of print output from IO servers" L 5 v IOS_VERBOSE
          "Minimum output; only essential messages" 1
          "Normal informative messages and warnings" 2
          "Operational status; all information messages" 3
          "Extra diagnostic messages" 4
          "Development and tuning" 5
    .blockend
    .block 1
      .case IOS_NPROC!="1" && IOS_NTASK!="1"
        .check "Interleave parallel servers" L IOS_INTER Y N
      .caseend
    .blockend
  .caseend
  .gap
  .pushnext "Back" subindep_IO_Services
.panend
