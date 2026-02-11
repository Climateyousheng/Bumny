.winid "subindep_Compile_User"
.title "User Override Files"
.wintype entry
.panel
  .gap
  .check "Including the following list of user machine overrides" L LUM_OVR Y N
    .case LUM_OVR=="Y"
        .table tum_ovr "User machine overrides" top h NMODS 5 INCR
          .elementautonum "Number" 1 NMODS 3
          .element "Full path name" UMCOMP_OP NMODS 50 in
          .element "Include Y/N" UMUSE_COP NMODS 3 in
        .tableend
    .caseend
  .gap
  .check "Including the following list of user file overrides" L LUF_OVR Y N
    .case LUF_OVR=="Y"
        .table tuf_ovr "User file overrides" top h NMODS 5 INCR
          .elementautonum "Number" 1 NMODS 3
          .element "Full path name" UFCOMP_OP NMODS 50 in
          .element "Include Y/N" UFUSE_OP NMODS 3 in
        .tableend
    .caseend
  .check "Including the following list of user paths overrides" L LUP_OVR Y N
    .case LUP_OVR=="Y"
        .table tup_ovr "User paths overrides" top h NMODS 5 INCR
          .element "Path variable" UPCOMP_VAR NMODS 20 in
          .element "Full path name" UPCOMP_OP NMODS 50 in
          .element "Include Y/N" UPUSE_OP NMODS 3 in
        .tableend
    .caseend
.panend
