.winid "atmos_Science_Section_DiagPrn"
.title "Section 13 : Diagnostic Prints"
.wintype entry

.panel
   .invisible ATMOS_SR(13)!="0A"&&PDIFFOPT=="T"
     .textw "When Diagnostic prints are enabled, set the options." L
   .invisend 
   .invisible !(ATMOS_SR(13)!="0A"&&PDIFFOPT=="T")
     .textw "Diagnostic prints are not enabled." L
   .invisend 
   .gap
   .case ATMOS_SR(13)!="0A"
     .check "Diagnostic prints" L PDIFFOPT T F
       .case PDIFFOPT=="T"
       .block 1
       .check "Flush print buffer if run fails" L LFLUSH6 T F
       .check "Operational prints" L LDIAGPROPS T F
       .check "Print output on all processors" L LPRINTPE T F
       .entry "Printing frequency (number of timesteps)" L PDFSTEP 25
       .entry "Diagnostic calculation frequency" L DIAGINTRV 25
       .check "Print vertical velocity information" L LPDFVELINF T F
       .entry "Vertical velocity print test value" L PDFVEL 25
       .blockend
       .block 1
       .check "Print max vertical velocity found" L PDFMAXVEL T F
	   .check "Print divergence information" L LPDFDIVINF T F
	   .check "Print lapse-rate information" L LPDFLAPINF T F
	   .check "Print level 1 theta minimum" L LPDFTMIN T F
       .check "Print maximum horizontal winds" L LPRMAXWND T F
       .check "Print wind KE" L LDIAGWIND T F
       .check "Print wind shear" L LPRNSHEAR T F
       .check "Print noise statistics" L LDIAGNOISE T F
       .blockend
       .textw "Printing of two norms (print frequency is as above)" L
       .block 1
       .check "Print fields and increments two norms during time step" L LDIAGL2NORMS T F
       .check "Print solver coefficients two norms" L LDIAGL2HELM T F
       .entry "First timestep to print two norms" L FRSTNORMPR 15
       .entry "Two norm start level" L NRMLEVSTRT 25
       .entry "Two norm end level" L NORMLEVEND 25
       .text "Setting two norm start and end level to the same value will result" L
	   .text "in printing the norm for every level" L
       .gap
       .blockend
     .caseend
   .caseend
   .textw "Push DIFF to go to the Diffusion & Filtering main window" L
   .pushnext "DIFF" atmos_Science_Section_DiffFilt
.panend
