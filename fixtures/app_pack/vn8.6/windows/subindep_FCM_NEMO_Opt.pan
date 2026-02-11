.winid "subindep_FCM_NEMO_Opt"
.title "FCM Options for NEMO"
.wintype entry
.procs {} {} {set_forcebuild; # set force build option}

.panel
 .case NEMO=="T"  
   .gap
   .text "Usually you should not override FCM configuration default values for NEMO" L 
    .block 1
     .entry "NEMO Repository URL (NEMO_SVN_URL)" L NEMO_SVN_URL
     .entry "NEMO code location" L NEMO_CODE_LOC
     .block 2
       .textw "Please note: the code version selected on the NEMO links panel is: [replace NEMOVERSION 302 vn3.2 3031 vn3.3.1 304 vn3.4 * Unknown]" L
     .blockend
     .entry "Specify revision number or keyword of NEMO code base" L FCM_NEMO_VER 15
     .entry "IOIPSL Repository URL (IOIPSL_SVN_URL)" L IOIPSL_SVN_URL
     .entry "IOIPSL code location" L IOIPSL_CODE_LOC
     .entry "Specify revision number or keyword of IOIPSL code base" L FCM_IOIPSL_VER 15
    .blockend
    .gap
    .check "Include additional source directories" L LFCM_SOURCE_NEMO Y N
    .block 1
     .case LFCM_SOURCE_NEMO=="Y"
       .table nemo_source "Additional NEMO source directories" top h NEMOFL_CNT 3 INCR
        .elementautonum "No" 1 10 3 
        .element "Source Directory" FCM_SOURCEDIR_NEMO NEMOFL_CNT 20 in 
        .element "Include Y/N" FCM_SOURCEUSE_NEMO NEMOFL_CNT 5 in   
       .tableend
     .caseend
    .blockend
    .block 1
     .entry "NEMO compiler flags file" L FCM_CFGFLNM_NEMO
     .entry "FPP keys configuration file" L FCM_KEYS_NEMO
    .blockend
   .gap
   .check "Include modifications from branches" L LFCM_USRBRN_NEMO Y N 
   .case  LFCM_USRBRN_NEMO=="Y" 
     .table fcm_nemo_branch "User Modifications" top h FCM_BRN_COUNT 5 INCR
       .elementautonum "No" 1 FCM_BRN_COUNT 3
       .element "Type" FCM_USRBRN_TYPE FCM_BRN_COUNT 8 in
       .element "Branch location" FCM_USRBRN_VAL_NEMO FCM_BRN_COUNT 65 in
       .element "Revision" FCM_USRBRN_VER_NEMO FCM_BRN_COUNT 5 in
       .element "Use Y/N" FCM_USRBRN_USE_NEMO FCM_BRN_COUNT 5 in
     .tableend  
   .caseend   
   .gap
   .check "Include modifications from NEMO working copy" L LFCM_WRKCP_NEMO Y N
   .case LFCM_WRKCP_NEMO=="Y"
     .block 1
     .entry "NEMO working copy location" L FCM_WRKCP_NEMO
     .blockend  
   .caseend
   .gap
   .check "Include modifications from IOIPSL working copy" L LFCM_WRKCP_IOIPSL Y N
   .case LFCM_WRKCP_IOIPSL=="Y"
     .block 1
     .entry "IOIPSL working copy location" L FCM_WRKCP_IOIPSL
     .blockend  
   .caseend
 .caseend   
   .gap   
   .text "Press Back to go to FCM main page" L
   .pushnext "Back" subindep_FCM_Gen
.panend


