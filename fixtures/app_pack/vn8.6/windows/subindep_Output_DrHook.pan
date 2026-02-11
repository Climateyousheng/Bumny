.winid "subindep_Output_DrHook"
.title "DrHook options"
.wintype entry

.panel
  .gap
  .case LDRHOOK=="Y"
    .block 1
      .basrad "Profile Type:" L 4 v DRH_PROF
           "No profile" none
           "Wallclock"  wallprof
           "CPU time"   cpuprof
           "MFlops"     hpmprof
    .blockend
    .block 1
      .case DRH_PROF != "none"
        .check "Include DrHook itself in profile?" L DRH_SELF Y N
      .caseend
      .check "Include traceback memory info?" L DRH_MEM Y N
      .check "Include traceback times info?" L DRH_TIME Y N 
    .blockend
  .caseend
  .gap
  .textw "Push BACK for Output options." L  
  .pushnext "BACK" subindep_Output  
.panend
