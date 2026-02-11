.winid "subindep_FCM_Gen"
.title "FCM Extract and Build directories and Output levels"
.wintype entry

.procs {set_forcebuild; # set force build option} {} {}

.panel
   .gap
   .text "Top Level FCM repository" L
   .block 1
     .entry "The Repository URL (UM_SVN_URL)" L UMSVN_URL
     .entry "Bindings location (UM_SVN_BIND)" L UMSVN_BIND
     .entry "Container file name and location (UM_CONTAINER)" L UMFCM_CONTAINER
   .blockend
   .gap
     .text "Note: all environment variables used in this panel come from your local environment" L
     .gap
     .block 0
     .entry "Local machine root extract directory (UM_OUTDIR)" L UMFCM_OUTDIR
     .entry "Target machine root extract directory (UM_ROUTDIR)" L UMFCM_ROUTDIR
     .blockend
   .gap
     .block 1
     .text "NOTE: the Root Extract Directories will be extended automatically with RUNID subdirectory." L
     .text "In addition umscripts, umatmos, umrecon, nemo or cice subdirectories will be created, depending on model(s) choice." L   
     .blockend
   .gap
   .text "FCM Extract command options:" L
     .block 1
     .case LFCM_PREBUILD!="Y"
       .check "Force FULL Extract" L LFULL_EXT Y N
     .caseend
     .basrad "Level of output" L 4 h FCM_VERB_EXT
       "0" 0
       "1" 1
       "2" 2
       "3" 3
     .entry "FCM Extract output will be sent to" L FCM_OUT_EXT  
     .blockend
   .gap
   .text "FCM Build command options:" L
     .block 1 
     .case LFCM_PREBUILD!="Y"
       .check "Force FULL Build" L LFULL_BLD Y N
     .caseend
     .basrad "Level of output" L 4 h FCM_VERB_BLD
       "0" 0
       "1" 1
       "2" 2
       "3" 3
     .blockend 
   .gap
   .text "Follow links for model specific FCM  parameters" L
   .pushnext "UM"   subindep_FCM_UM_Opt
   .pushnext "JULES" subindep_FCM_JULES_Opt
   .pushnext "NEMO" subindep_FCM_NEMO_Opt
   .pushnext "CICE" subindep_FCM_CICE_Opt      
.panend




