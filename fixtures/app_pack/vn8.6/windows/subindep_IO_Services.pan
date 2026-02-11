.winid "subindep_IO_Services"
.title "IO Services Options"
.wintype entry

.panel
    .check "Change default I/O buffering and data alignment" L LIO_DEFS Y N
    .case LIO_DEFS=="Y"
      .block 1
      .entry "Size of I/O Write Buffer (words)" L IO_BUFFSIZE 10
      .entry "Size of I/O Read Buffer (words) " L IO_RBUFFSIZE 10
      .entry "Number of read buffers per IO stream" L IO_RBUFFER_COUNT 10
      .entry "Number of read buffers a helper thread should prefetch whilst reading" L IO_RBUFFER_PREFETCH 10 
      .entry "Alignment of Data (in words)" L IO_DATAALIGN 10
      .entry "Field padding (in words)" L IO_FIELDPAD 10 
      .check "Maintain coherence between read and write cached blocks" L IO_RBUFFER_UPDATE Y N 
      .blockend
    .caseend
    .check "Time IO Operations" L LIOTIMER Y N
    .gap
    .case ATMOS=="T" && OCAAA!=5
      .textw "NOTE: The rest of this paneland IOS subpanels are only active when using  multiple OpenMP threads" L
      .case LR_OPENMP=="Y"
        .block 2
        .textw "Number of threads is set to [get_variable_value NTHR_TASK] on 'Target Machine' panel" L
        .blockend
        .gap
        .case NTHR_TASK!="1" 
          .textw "MPI Task configuration:" L 
          .block 1  
            .entry "Number of IO Servers" L IOS_NPROC 10 
            .case IOS_NPROC!="0" 
              .entry "MPI task spacing" L IOS_SPACE 10 
              .entry "IO Server parallelism" L IOS_NTASK 10 
              .entry "Task offset" L IOS_OFFSET 10 
            .caseend 
          .blockend 
        .caseend 
      .caseend 
    .caseend 
    .gap
    .check "Control of File Completion (Rose)" L IOS_EXTCNTL Y N
    .gap
  .textw "Push COMMS for Communications Threading Model panel" L
  .textw "Push MACH for the Machine Submission panel" L
  .textw "Push GEN (general), MPI or ACCEL (acceleration) for additional IO-Server options" L
  .pushsequence "COMMS" subindep_IO_Comms
  .pushnext "GEN" subindep_IOS_Gen
  .pushnext "MPI" subindep_IOS_MPI
  .pushnext "ACCEL" subindep_IOS_Accel
  .pushnext "MACH" subindep_SubmitMethod
.panend
