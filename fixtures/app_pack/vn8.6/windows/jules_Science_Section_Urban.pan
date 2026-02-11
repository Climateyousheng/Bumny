.winid "jules_Science_Section_Urban"
.title "JULES Urban Schemes Parameters"
.wintype entry
.procs {} {} {}
.panel
 .case JULES=="T"
  .gap
  .block 0
    .basrad "Choose version" L 3 v JULES_SR(2) 
      "<URBAN-1T> Original urban scheme with one urban tile" 1T
      "<URBAN-2T> Two tile urban scheme using canyon and roof tiles" 2T
      "<MORUSES> Met Office Reading Urban Surface Exchange Scheme" 3M
  .blockend
  .gap
 .caseend
  .block 1
    .check "Include anthropogenic heat source?" L LAHEATSRC Y N
 .case JULES=="T"
    .case JULES_SR(2)!="1T" && LAHEATSRC=="Y"
      .entry "Value of distribution scale factor" L ANTHRHEAT 10 
    .caseend
 .caseend
    .block 2
      .textw "WARNING: only valid in Northern Hemisphere, mid latitude Limited Area Models" L
    .blockend  
  .blockend
  .gap
 .case JULES=="T"
  .invisible JULES_SR(2)=="2T" 
    .block 1
      .table urban2T "Urban Surface Type Parameters" top h 9 5 NONE
	.element "Parameter" URB2T_PRM 9 50 out
	.element "Canyon" CANYON_2T 9 12 in
	.element "Roof" ROOF_2T 9 12 in  
      .tableend
    .blockend
  .invisend
  .case JULES_SR(2)=="3M" 
    .invisible JULES_SR(2)=="3M"
      .basrad "Use urban surface parameters not set by MORUSES" L 2 h MORUSES_TAB
        "Default values" 0
	"From table" 1
      .case MORUSES_TAB=="1"
        .block 1
          .table morusesDefs "Urban Surface Type Parameters" top h 3 3 NONE
	    .element "Parameter" URB3M_PRM 3 50 out
	    .element "Canyon" CANYON_3M 3 12 in
	    .element "Roof" ROOF_3M 3 12 in  
  	  .tableend
        .blockend
        .block 1
	  .entry "Snow-free albedo - Roof tile:" R ALBSNF_RF 10
        .blockend
      .caseend
    .invisend
    .gap
  .caseend
  .case JULES_SR(2)!="1T"
    .block 1
    .basrad "Choose urban geometry" L 2 v LURBEMP
     "Prescribe own values (requires ancillary data)" N
     "Use empirical relationships" Y
   .blockend
   .block 2
     .textw "WARNING: Empirical relationships only valid for high resolution (~1km)" L
  .caseend
  .gap
  .case JULES_SR(2)=="3M"
    .block 1
      .check "Use default MORUSES" L LMORUSES_DEFS Y N
      .block 3
      .textw "or select from the following list of MORUSES parameterisations:" L
      .blockend
      .case LMORUSES_DEFS=="N"
    .blockend
    .block 1
      .check "Use shortwave radiative exchange" L LMORUSES_ALB Y N
      .invisible JULES_SR(2)=="3M" && LMORUSES_ALB=="N" && LMORUSES_DEFS=="N"
        .block 2
  	  .entry "Snow-covered albedo - Canyon tile:" L ALBSNC_C 10
	  .entry "Snow-covered albedo - Roof tile:" L ALBSNC_RF 10
          .entry "Snow-free albedo - Canyon tile:" L ALBSNF_C 10
	  .blockend
	.invisend
.comment	 .check "Use longwave radiative exchange" L LMORUSES_EMIS Y N
	.check "Use transfer of heat" L LMORUSES_RGH Y N
	.invisible JULES_SR(2)=="3M" && LMORUSES_RGH=="N" && LMORUSES_DEFS=="N"
	  .block 2
	   .entry "Roughness length (m) - Canyon tile:" L RGHLEN_C 10
	   .entry "Roughness length - Roof tile:" L RGHLEN_RF 10
	   .entry "Ratio of roughness lengths (heat/momentum) - Canyon tile:" L RGHRATIO_C 10
	   .entry "Ratio of roughness lengths - Roof tile:" L RGHRATIO_RF 10
	  .blockend
	.invisend
        .check "Use thermal inertia and soil coupling" L LMORUSES_STOR Y N
	.invisible JULES_SR(2)=="3M" && LMORUSES_STOR=="N" && LMORUSES_DEFS=="N"
	  .block 2
	    .entry "Canopy heat capacity (J/K/m2) - Canyon tile:" L CANHEAT_C 10
	    .entry "Canopy heat capacity - Roof tile:" L CANHEAT_RF 10
	    .entry "Fractional canopy coverage - Canyon tile:" L FRACCAN_C 10
	    .entry "Fractional canopy coverage - Roof tile:" L FRACCAN_RF 10
	  .blockend
	.invisend
        .case LMORUSES_STOR=="Y"
	  .block 2
	  .check "Use thin roofs (includes effects of insulation)" L LMORUSES_THIN Y N
	  .blockend
	.caseend
	.case LURBEMP=="N"
	  .check "Use MacDonald (1998) formulation for roughness length of momentum and displacement height" L LMORUSES_MACD Y N
 	.caseend
	.invisible LURBEMP=="Y" && LMORUSES_DEFS=="N"
 	  .block 2
	    .textw "Please note: MacDonald formulation MUST be used with empirical geometry relationships" L
	  .blockend
	.invisend
      .blockend
    .caseend
  .caseend 
 .caseend
.panend
