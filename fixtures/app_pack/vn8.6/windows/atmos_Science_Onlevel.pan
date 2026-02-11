.winid "atmos_Science_Onlevel"
.title "Level by Level Physical Constants"
.wintype entry

.panel
   .invisible ATMOS_SR(13)=="0A"
     .gap
     .textw "Most columns are currently unused because diffusion and filtering is not yet selected." L 
   .invisend
   .gap
   .textw "Input ranges of levels and specify the coefficients and Ratios" L    
   .gap
   .table levels8 "Parameter on all levels" top h NLEVSA 10 INCR 
     .case ATMOS_SR(13)!="0A"
       .super ""
         .element "Start Level" STARTLEV_KDF NLEVSA 11 in
         .element "End Level" ENDLEV_KDF NLEVSA 11 in
       .superend
       .super "Div.damping coeffs. "
         .element "Forecast" KDF NLEVSA 10 in
       .superend
     .caseend
   .tableend
   .gap
   .table levels9 "Parameter on wet levels" top h NWLEVA 10 INCR
     .case ATMOS_SR(13)!="0A"
       .super ""
         .element "Start Level" STARTLEV_RHC NWLEVA 11 in
         .element "End Level" ENDLEV_RHC NWLEVA 11 in
       .superend
       .super "Critical humidity"
         .element "Ratio    " RHC NWLEVA 17 in
       .superend
     .caseend
   .tableend
   .gap
.panend



