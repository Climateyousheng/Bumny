.winid "atmos_Science_Section_GWD"
.title "Section 6 : Gravity Wave Drag"
.wintype entry
.panel
  .gap
  .basrad "Choose version" L 3 v ATMOS_SR(6)
      "Gravity wave drag not included" 0A
      "<4A> New orographic scheme including flow blocking AND/OR spectral gravity wave scheme" 4A
      "<5A> New Orographic Scheme AND/OR spectral gravity wave scheme" 5A
  .gap
  .case ATMOS_SR(6)!="0A"
    .check "Include orographic drag scheme" L LORODS T F
    .case LORODS=="T"
      .block 1
        .case ATMOS_SR(6)=="4A"
          .entry "Surface gravity wave constant" L SGWCON 25
        .caseend
        .entry "Critical Froude Number" L CFNUM 25
      .blockend
    .caseend
    .gap 
    .case ATMOS_SR(6)=="5A"
      .block 1
        .entry "Inverse critical Froude number for wave saturation" L GWDFSAT 15
        .entry "Mountain wave amplitude constant" L GSHARP 15
        .entry "Flow blocking drag coefficient" L FBCDRAG 15
        .check "Smooth gravity wave drag over a vertical wavelength" L LSMOOTH Y N
        .check "Apply heating due to gravity-wave dissipation" L LGWDHEAT Y N
      .blockend
    .caseend
    .gap
    .check "Include spectral gravity wave scheme" L LFBLOK T F
    .case LFBLOK=="T"
      .block 1
        .check "Use Opaque model lid condition" L LOPAQUE T F
        .entry "Factor enhancement for wave launch amplitude" L USSP_LNCHF 15
      .blockend
    .caseend
  .caseend
  .gap
.panend


