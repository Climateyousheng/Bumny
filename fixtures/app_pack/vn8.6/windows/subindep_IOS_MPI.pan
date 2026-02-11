.winid "subindep_IOS_MPI"
.title "IO Services - MPI and Debugging Options"
.wintype entry

.panel
  .gap
  .case ATMOS=="T" && OCAAA!=5 && LR_OPENMP=="Y" && NTHR_TASK!="1"
    .textw "MPI behaviour:" L
    .block 1
      .check "Serialize all MPI calls" L IOS_SERIALIZE Y N
      .check "MPI only allowed on thread 0" L IOS_THREAD0 Y N
      .check "Relay Commands from lead task to IOS team" L IOS_RLTOSLAV Y N
    .blockend
    .block 1
      .basrad "IOS Decomposition" L 2 h IOS_DECOMPMOD
        "Frontloaded" 0
        "Backloaded" 1
    .blockend
    .gap 
    .textw "Tuning:" L
    .block 1
      .case IOS_ASYNCSTSH=="Y" || IOS_ASYNCDUMP=="Y"
        .check "Report message characteristics" L IOS_ASYNCSTAT Y N
      .caseend
      .check "Profile OpenMP locks" L IOS_LOCK Y N
    .blockend
    .gap 
    .textw "Debugging:" L
    .block 2
      .textw "These options materially alter model output, and are intended for debugging purposes." L
    .blockend 
    .block 1
      .case IOS_ASYNCSTSH=="Y" || IOS_ASYNCDUMP=="Y"
        .check "Omit data writes" L IOS_NOWRITE Y N
	.check "Omit data packing" L IOS_NOPACK Y N
	.check "Omit data subdomaining" L IOS_NOSUBDOM Y N
      .caseend      
    .blockend
  .caseend
  .gap
  .pushnext "Back" subindep_IO_Services
.panend
