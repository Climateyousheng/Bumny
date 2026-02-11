.winid "subindep_PostProc_PPInit"
.title "Initialization and processing of standard PP files"
.wintype entry

.panel
   .basrad "Select packing profile for mean PP files" L 6 v PPXM
            "Unpacked, profile 0" 0
            "Packed as required for operational output streams, profile 1" 1
            "Packed as required for standard climate output, profile 2" 2
            "Packed as required for stratosphere model output, profile 4" 4
            "New standard climate packing, profile 5" 5
            "Simple GRIB packing, profile 6" 6
   .check "GRIB format mean PP files" L PPXG Y N
   .gap
   .text "Define processing and post-processing requirements for the PP output streams." L
   .text "Define periodic re-initialization for those files which require automatic post processing." L
   .gap
   .table PP "PP Files" top h 11 11 NONE
     .super "Basics"
      .element "PP File/Unit" PPFU 11 6 out
      .element "Packing profile" PPX 11 2 in
      .element "Override size" PPOS 11 2 in
      .element "GRIB FORMAT (Y/N)" PPG 11 1 in
      .element "Periodic Re-init" PPI 11 1 in
     .superend 
     .super "For re-initialised PP files, also specify"
      .element "Period" PPIF 11 2 in
      .element "Starting" PPIS 11 2 in
      .element "Ending" PPIE 11 2 in
      .element "Time Unit" PPIU 11 1 in
      .element "Sub Model" PPM 11 1 in
      .case (AUTOPP=="Y")&&(SYSTM!=0)
        .element "Archiving" PPA 11 1 in
      .caseend
     .superend
   .tableend
   .text "Time units are: DA=days, H=hours, T=timesteps, RM=real months. " L 
   .text "Packing profiles numbers are as defined for mean PP file." L
   .text "A (Atmosphere) is currently the only valid sub-model." L
   .gap
    .invisible (AUTOPP!="Y")||(SYSTM==0)
      .textw "Automatic archiving has been disabled elsewhere." L
    .invisend
.panend



