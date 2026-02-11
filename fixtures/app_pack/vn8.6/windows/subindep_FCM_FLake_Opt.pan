.winid "subindep_FCM_FLake_Opt"
.title "FCM Options for FLake"
.wintype entry
.procs {} {} {set_forcebuild; # set force build option}

.panel
  .case JULES=="T" && JL_FLAKE=="T"
   .gap
   .block 1
     .entry "The Subversion URL (UM_SVN_URL)" L FLAKE_SVN_URL
     .entry "Specify revision number or keyword of FLAKE code base" L FCM_FLAKE_VER 15
   .blockend
   .gap
   .check "Include modifications from branches" L LFCM_USRBRN_FLAKE Y N 
   .case  LFCM_USRBRN_FLAKE=="Y" 
     .table fcm_mod_br_flake "User Modifications" top h FCM_BRN_COUNT 5 INCR
      .elementautonum "No" 1 FCM_BRN_COUNT 3
      .element "Branch location" FCM_USRBRN_VAL_FLAKE FCM_BRN_COUNT 65 in
      .element "Revision" FCM_USRBRN_VER_FLAKE FCM_BRN_COUNT 5 in
      .element "Use Y/N" FCM_USRBRN_USE_FLAKE FCM_BRN_COUNT 5 in
     .tableend  
   .caseend   
   .check "Include modifications from user working copy" L LFCM_WRKCP_FLAKE Y N
   .case LFCM_WRKCP_FLAKE=="Y"
     .block 1
       .entry "User working copy location" L FCM_WRKCP_FLAKE 
     .blockend  
   .caseend
 .caseend
 .gap
 .text "Press Back to return to the JULES FCM options page" L
 .pushnext "Back" subindep_FCM_JULES_Opt
.panend
.set_on_closure "LFULL_BLD variable " LFULL_BLD

