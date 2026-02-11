.winid "subindep_PostProc_Gen"
.title "Post Processing"
.wintype entry

.panel
  .gap
  .basrad "Is automatic post processing required" L 2 h AUTOPP
    "Yes" Y
    "No" N
  .gap  
  .text "Basic post processing allows for optional deletion of superseded files and" L
  .text "periodic submission of user defined scripts. Archiving is defined below." L
  .gap
  .case AUTOPP=="Y"
    .check "Delete superseded restart dumps" L GDDEL Y N
    .check "Delete superseded PP files"      L GPDEL Y N
    .check "Delete superseded climate means files" L GCMDEL Y N
    .gap
    .basrad "Specify archiving system required" L 4 v SYSTM
       "No archiving system." 0
       "The new system (MOOSE) " 2
       "MONSooN NERC disk archive " 3
       "HECToR archive " 5
    .gap
    .invisible SYSTM==2 || SYSTM==3
      .entry "Monsoon project group name" L PROJECTGROUP 12
    .invisend
    .invisible SYSTM==3
      .init FF2PP_NERC Y
      .gap
      .check "Convert UM fieldsfiles to PP format" L FF2PP_NERC Y N
    .invisend
    .invisible SYSTM==5
      .init HECTOR_TAPE_ARCH 1
      .init ARCHIVEDIR $DATAM/archive
      .basrad "Method of HECToR archiving" L 2 h HECTOR_TAPE_ARCH
         "Tape" 1
         "Disk" 0
       .case HECTOR_TAPE_ARCH==0
         .entry "Specify name of archive directory:" L ARCHIVEDIR
       .caseend
    .invisend
    .gap
    .case SYSTM==2
       .block 1
       .entry "Path to the archiving script" L ARCH_SCR_PATH 50 
       .entry "Name of the archiving script" L ARCH_SCR_NAME 25 
       .blockend
    .caseend
    .gap
  .caseend
  .gap
.panend


