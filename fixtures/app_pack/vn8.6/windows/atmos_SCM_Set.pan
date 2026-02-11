.winid "atmos_SCM_Set"
.title "Single Column Settings"
.wintype entry
   .case OCAAA==5
     .block 0
     .gap
     .text "Single Column Model (Specify in degrees)" L
   .case 1==2
     .entry " Latitude" L LATS 11
     .entry " Longitude" L LONS 11
   .caseend
     .gap
     .entry "Specify path for forcing SCM namelists" L SCM_NAMELIST
     .blockend   
     .gap  
     .table scm_output "Output Data Files" top h SCM_OD_CNT 5 INCR
       .elementautonum "No" 1 SCM_OD_CNT 3
       .element "File name" SCM_OD_NAME SCM_OD_CNT 65 in
       .element "Use Y/N" SCM_OD_USE SCM_OD_CNT 5 in
     .tableend  
   .caseend
   .gap
.panend
