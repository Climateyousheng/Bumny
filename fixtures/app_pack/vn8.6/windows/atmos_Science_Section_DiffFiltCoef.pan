.winid "atmos_Science_Section_DiffFiltCoef"
.title "Section 13 : Diffusion & Filtering"
.wintype entry
.panel
   .invisible ATMOS_SR(13)!="0A"
     .textw "Diffusion is enabled. Define the coefficients." L
   .invisend 
   .invisible ATMOS_SR(13)=="0A"
     .textw "Diffusion is not enabled." L
   .invisend 
   .gap
   .case ATMOS_SR(13)!="0A"
     .text "Input ranges of levels and specify the diffusion coefficients" L
     .block 2
       .text "K = Diffusion Coefficient" L
       .text "N = Order of Diffusion" L
     .blockend
     .case HDIFFOPT=="1"||HDIFFOPT=="2"
       .table levuv "Diffusion of Horizontal Wind" top h NLEVSA 5 INCR
         .element "Start Level" STARTLEV_K1 NLEVSA 11 in
         .element "End Level" ENDLEV_K1 NLEVSA 11 in
         .element "K(u,v)" K1 NLEVSA 11 in
         .element "N(u,v)" KE1 NLEVSA 11 in
       .tableend
       .table levt "Diffusion of Theta" top h NLEVSA 5 INCR
 	     .element "Start Level" STARTLEV_K3 NLEVSA 11 in
	     .element "End Level" ENDLEV_K3 NLEVSA 11 in
	     .element "K(T)" K3 NLEVSA 11 in
 	     .element "N(T)" KE3 NLEVSA 11 in
       .tableend
       .table levq "Diffusion of Moisture" top h NLEVSA 5 INCR
	     .element "Start Level" STARTLEV_K5 NLEVSA 11 in
         .element "End Level" ENDLEV_K5 NLEVSA 11 in
         .element "K(q)" K5 NLEVSA 11 in
         .element "N(q)" KE5 NLEVSA 11 in
       .tableend
     .caseend
   .caseend
     .gap   
   .textw "Push VERT to specify the vertical diffusion coefficients" L
   .textw "Push DIFF to go to the Diffusion & Filtering main window" L
   .pushsequence "VERT" atmos_Science_Section_VertDiffCoef 
   .pushnext "DIFF" atmos_Science_Section_DiffFilt 
.panend
