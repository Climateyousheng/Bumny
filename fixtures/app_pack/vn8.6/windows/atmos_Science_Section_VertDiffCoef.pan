.winid "atmos_Science_Section_VertDiffCoef"
.title "Section 13 : Diffusion & Filtering"
.wintype entry

.panel
  .gap
  .invisible ATMOS_SR(13)!="0A" && VDIFFOPT!="0"
    .textw "Vertical Diffusion is enabled." L
  .invisend
  .invisible ATMOS_SR(13)=="0A" || VDIFFOPT=="0"
    .textw "Vertical Diffusion is not enabled." L
  .invisend
  .gap
  .case  ATMOS_SR(13)!="0A"
    .block 1
    .case VDIFFOPT=="2"
      .entry "Latitude to start ramp diffusion (default for operational is 30.0 degrees):" L VDIFF_LAT 15
    .caseend
    .gap  
    .check "Vertical diffusion of winds based on wind shear" L LVDIFFUV T F
      .case LVDIFFUV=="T"
        .block 2
        .entry "Start level" L VDIFFUVSTART 25
        .entry "End level" L VDIFFUVEND 25
        .entry "Vertical diffusion timescale (timesteps)" L VDIFFTIMESCL 25
        .entry "Wind shear test value" L VDIFFUVTEST 25
        .blockend
      .caseend   
    .blockend     
    .gap
    .textw "Specify the diffusion coefficients" L
    .table vdifflev "Vertical Diffusion coefficients" top h 3 3 NONE
      .element "Type" VDTYPE 3 10 out
      .case VDIFFOPT!="0"
        .element "Diffusion Coefficient" VDCOEF 3 11 in
        .element "Start Level" VDSTLEV 3 11 in
        .element "Stop Level" VDSPLEV 3 11 in
      .caseend
    .tableend
  .caseend
  .gap
 .textw "Push DIFF to go to the Diffusion & Filtering main window" L
 .pushnext "DIFF" atmos_Science_Section_DiffFilt
.panend
