.winid "atmos_InFiles_OtherAncil_Transpl"
.title "Transplant data."
.wintype entry

.panel
   .check "Do you want to define transplanting of data?" L USE_TRA Y N
   .case USE_TRA=="Y"
     .entry "Specify the number of fields to transplant (maximum 100)." L NTRANSP   
     .gap
       .text "Define the dump holding the data to be transplanted." L
       .block 1
         .entry "Enter directory or Environment Variable" L PATH97
         .entry "and file name" L FILE97
       .blockend   
       .invisible ARECON=="N"
         .text "Fields cannot be configured as the reconfiguration is off!" L
       .invisend
       .gap                                    
       .table TRANS "Transplant table" top h NTRANSP 10 NONE
        .element "Section" TPSEC NTRANSP 10 in
        .element "STASH item" TPI NTRANSP 10 in
        .element "From level" TPL1 NTRANSP 10 in
        .element "To level  " TPL2 NTRANSP 10 in
        .element "From column" TPC1 NTRANSP 10 in
        .element "To column " TPC2 NTRANSP 10 in
        .element "From row  " TPR1 NTRANSP 10 in
        .element "To row    " TPR2 NTRANSP 10 in
       .tableend
       .text "Take care to define dimensions relative to the item's grid." L     
   .caseend
.panend   


