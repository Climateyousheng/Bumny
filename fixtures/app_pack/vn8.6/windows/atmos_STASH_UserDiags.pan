.winid "atmos_STASH_UserDiags"
.title "Specify User STASHmaster files"
.wintype entry
.procs {} {} {user_progs 1 ; # set USRP_COUNT(1) USRP_ITEM USRP_NAME}

.panel
   .check "Using user STASHmaster files for the Atmosphere." L USERPRE_A Y N
   .case USERPRE_A=="Y"
     .table ban1 "Specify the STASHmaster files" top h 20 10 INCR
       .elementautonum "No." 1 20 3
       .element "Specify Local File" USERLST_A 20 50 in
     .tableend
     .gap
     .textw "You are advised to visit the Prognostics follow-on window" L
     .textw "every time you change the above table or change a file in the table" L
     .gap
     .check "Extending level or pseudo level code definitions." L USERCODES_A Y N
     .case USERCODES_A=="Y"
       .text "Note. This will only work with modifications at this release." L
       .textw "Set codes that are not required to zero. See help." L
       .gap
       .table code "New level code." top h 3 3 NONE
         .elementautonum "Code" 101 3 4
         .element "Define level for code." ULEV_A 3 30 in
       .tableend  
       .gap
       .table code1 "Define limits of first and last pseudo-level codes" top h 3 3 NONE
         .elementautonum "Code" 101 3 4
         .element "First level Minimum" UPSF_A 3 30 in
         .element "Last level Maximum " UPSL_A 3 30 in
       .tableend  
     .caseend
   .caseend  
   .pushnext "Prognostics" atmos_STASH_UserProgs
   .gap
.panend
.set_on_closure "Hidden variable: Automatically set to number of user prognostics" USRP_COUNT(1)

