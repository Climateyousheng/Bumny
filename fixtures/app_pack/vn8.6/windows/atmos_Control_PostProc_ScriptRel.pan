.winid "atmos_Control_PostProc_ScriptRel"
.title "User defined script release"
.wintype entry

.panel
  .basrad "Specify release of user-supplied scripts during execution of the atmospheric model ?" L 2 h USE_AJR(1)
          "Yes" Y
          "No" N
  .gap
  .case USE_AJR(1)=="Y"
    .entry "Offset in atmospheric timesteps applied to when the scripts are executed" L SRC_OFFSET(1) 15
    .entry "Choose between 1 and 10 scripts for release" L AJRN(1)
    .basrad "Using time units." L 3 h AJRU(1)
          "Hours"     H 
          "Days"      DA
          "Timesteps" T
    .entry "Specify the directory holding all the scripts" L AJRPATH(1) 
    .table SCRIPT "Script Release" top h AJRN(1) 10 NONE
      .element "after 'n' units" AJR(*,1) 10 15 in
      .element "File name      " AJRS(*,1) 10 15 in
      .element "Periodic release" AJRP(*,1) 10 16 in
    .tableend
   .caseend
.panend



