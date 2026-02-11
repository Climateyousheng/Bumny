.winid "subindep_FCM_UM_Opt"
.title "FCM Options for UM Atmosphere and Reconfiguration"
.wintype entry
.procs {} {} {set_forcebuild; # set force build option}

.panel
   .gap
   .text "Usually you should not override FCM configuration default values for UM" L 
     .block 1
     .entry "The Subversion URL (UM_SVN_URL)" L UMSVN_URL
     .entry "Bindings location (UM_SVN_BIND)" L UMSVN_BIND
     .entry "Container file name and location (UM_CONTAINER)" L UMFCM_CONTAINER
     .blockend
   .gap
   .check "Use different version of the UM code base from the default for this UMUI version" L LFCM_USRTRNK Y N
   .case LFCM_USRTRNK=="Y"
     .block 2 
     .entry "Specify revision number or keyword of code base to use" L FCM_USR_VER 15
     .blockend   
   .caseend
   .gap
   .check "Use precompiled build" L LFCM_PREBUILD Y N
   .case LFCM_PREBUILD=="Y"
     .block 1
     .entry "Local prebuild location (UM_PREBUILD)" L UMFCM_PREBLD
     .entry "Remote prebuild location (UM_REM_PREBLD)" L UMFCM_REM_PREBLD
     .entry "Model name" L UMFCM_MODNAME
     .blockend
   .caseend
   .gap
   .check "Include modifications from branches" L LFCM_USRBRN Y N 
   .case  LFCM_USRBRN=="Y" 
     .textw "Normally, all branches listed here should be derived from the UM code base selected above - see help" L
     .table fcm_mod_branch "User Modifications" top h FCM_BRN_COUNT 5 INCR
       .elementautonum "No" 1 FCM_BRN_COUNT 3
       .element "Branch location" FCM_USRBRN_VAL FCM_BRN_COUNT 65 in
       .element "Revision" FCM_USRBRN_VER FCM_BRN_COUNT 5 in
       .element "Use Y/N" FCM_USRBRN_USE FCM_BRN_COUNT 5 in
     .tableend  
   .caseend   
   .check "Use central script modifications" L LFCM_CENSRCMOD Y N
   .invisible LFCM_CENSRCMOD=="Y"
     .table fcm_mod_central "Central Script Modifications" top h FCM_CMS_COUNT 5 INCR
       .elementautonum "No" 1 FCM_CMS_COUNT 3
       .element "Script branch location" FCM_CMSCR_VAL FCM_CMS_COUNT 65 in
       .element "Revision" FCM_CMSCR_VER FCM_SMC_COUNT 5 in
       .element "Use Y/N" FCM_CMSCR_USE FCM_CMS_COUNT 5 in
     .tableend  
   .invisend
   .check "Include modifications from user working copy" L LFCM_USRWRKCP Y N
   .case LFCM_USRWRKCP=="Y"
     .block 1
     .entry "User working copy location" L FCM_USRWRKCP 
     .blockend  
   .caseend
   .gap
   .text "Press Back to go to FCM main page" L
   .pushnext "Back" subindep_FCM_Gen
.panend


