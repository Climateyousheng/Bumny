.winid "subindep_IOS_Accel"
.title "IO Services - Acceleration Options"
.wintype entry

.panel
  .gap
  .case ATMOS=="T" && OCAAA!=5 && LR_OPENMP=="Y" && NTHR_TASK!="1"
    .textw "Field Output:" L
    .block 1
      .check "Use asynchronous STASH output" L IOS_ASYNCSTSH Y N
      .check "Use asynchronous dump output" L IOS_ASYNCDUMP Y N
    .blockend
    .case IOS_ASYNCSTSH=="Y" || IOS_ASYNCDUMP=="Y"
      .block 1
        .entry "Number of field levels to coalesce" L IOS_COALESCE 10
        .entry "Accelerated payload concurrency" L IOS_ACCPAYLD 10
      .blockend
      .block 1
        .check "Send empty tiles to IOS" L IOS_ASYNCNULL Y N
      .blockend
    .caseend
    .gap
    .textw "Low Level IO:" L
    .block 1
      .check "Use Helper threads for low level IO" L IOS_USE_HELPERS Y N    
    .blockend
  .caseend
  .gap
  .pushnext "Back" subindep_IO_Services
.panend