.winid "subindep_FCM_CICE_Opt"
.title "FCM Options for CICE"
.wintype entry
.procs {} {} {set_forcebuild; # set force build option}

.panel
 .case CICE=="T"  
   .gap
   .text "Usually you should not override FCM configuration default values for CICE" L 
     .block 1
     .entry "CICE Repository URL (CICE_SVN_URL)" L CICE_SVN_URL
     .entry "Specify revision number or keyword of CICE code base" L FCM_CICE_VER 15
     .gap
     .entry "CICE machine compiler flags file" L FCM_CFGFLNM_CICE
     .entry "FPP keys configuration file" L FCM_KEYS_CICE
     .blockend
   .gap
   .check "Include modifications from branches" L LFCM_USRBRN_CICE Y N 
   .case  LFCM_USRBRN_CICE=="Y" 
     .table fcm_cice_branch "User Modifications" top h FCM_BRN_COUNT 5 INCR
       .elementautonum "No" 1 FCM_BRN_COUNT 3
       .element "Branch location" FCM_USRBRN_VAL_CICE FCM_BRN_COUNT 65 in
       .element "Revision" FCM_USRBRN_VER_CICE FCM_BRN_COUNT 5 in
       .element "Use Y/N" FCM_USRBRN_USE_CICE FCM_BRN_COUNT 5 in
     .tableend  
   .caseend   
   .gap
   .check "Include modifications from CICE working copy" L LFCM_WRKCP_CICE Y N
   .case LFCM_WRKCP_CICE=="Y"
     .block 1
     .entry "CICE working copy location" L FCM_WRKCP_CICE
     .blockend  
   .caseend
 .caseend
   .gap
   .text "Press Back to go to FCM main page" L
   .pushnext "Back" subindep_FCM_Gen
.panend


