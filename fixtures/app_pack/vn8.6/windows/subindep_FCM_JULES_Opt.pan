.winid "subindep_FCM_JULES_Opt"
.title "FCM Options for JULES"
.wintype entry
.procs {} {} {set_forcebuild; # set force build option}

.panel
  .case JULES=="T"
   .gap
   .block 1
     .entry "The Subversion URL (JULES_SVN_URL)" L JULES_SVN_URL
     .entry "Specify revision number or keyword of JULES code base" L FCM_JULES_VER 15
   .blockend
   .gap
   .check "Include modifications from branches" L LFCM_USRBRN_JULES Y N 
   .case  LFCM_USRBRN_JULES=="Y" 
     .table fcm_mod_br_jules "User Modifications" top h FCM_BRN_COUNT 5 INCR
       .elementautonum "No" 1 FCM_BRN_COUNT 3
       .element "Branch location" FCM_USRBRN_VAL_JULES FCM_BRN_COUNT 65 in
       .element "Revision" FCM_USRBRN_VER_JULES FCM_BRN_COUNT 5 in
       .element "Use Y/N" FCM_USRBRN_USE_JULES FCM_BRN_COUNT 5 in
     .tableend  
   .caseend   
   .check "Include modifications from user working copy" L LFCM_WRKCP_JULES Y N
   .case LFCM_WRKCP_JULES=="Y"
     .block 1
       .entry "User working copy location" L FCM_WRKCP_JULES 
     .blockend  
   .caseend
 .caseend
 .gap
 .text "Press FLake for FLake repository settings" L
 .text "Press Back to go to FCM main page" L
 .pushnext "FLake" subindep_FCM_FLake_Opt
 .pushnext "Back" subindep_FCM_Gen
.panend
.set_on_closure "LFULL_BLD variable " LFULL_BLD

