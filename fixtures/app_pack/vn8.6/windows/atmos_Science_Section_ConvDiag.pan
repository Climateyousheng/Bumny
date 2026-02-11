.winid "atmos_Science_Section_ConvDiag"
.title "Section 5 : Convective Diagnosis"
.wintype entry
.procs {} {} {}

.panel
 .gap
   .block 1
     .entry "Convective diagnosis method" L ICVDIAG 15
     .entry "Std Dev level 1 virtual temperature option" L TV1SDOPT 15 
     .case ATMOS_SR(5)!="4A"
       .entry "Water loading for undilute plume in diagnosis" L WATLOAD 15
       .entry "Water loading for dilute plume in diagnosis" L DILWATLOAD 15
       .entry "w test value for shallow convection" L CVD_SHWTEST 15
       .entry "Inversion test for determining shallow convection" L CVD_INV 15
     .caseend
   .blockend 
 .case ATMOS_SR(5)!="0A"
   .block 1
     .check "Call convective diagnosis for every convection call" L REDIAGNOS Y N
   .blockend
 .caseend
 .gap  
 .textw "Push Convection to go BACK" L
 .pushnext "Convection" atmos_Science_Section_Conv 
.panend

