.winid "atmos_Science_Section_BLay_TKE"
.title "Section 3 : Boundary Layer - TKE Closure"
.wintype entry
.panel
  .gap
  .invisible ATMOS_SR(3)!="1A"
    .textw "This panel is only available with Version <1A> of the Boundary Layer Scheme" L
  .invisend
  .case ATMOS_SR(3)=="1A"
    .basrad "Type of TKE closure model" L 3 v TKE_MOD
         "The Mellor-Yamada Level 3 model"                                3
         "The Mellor-Yamad Level 2.5 model"                               2
         "The first order eddy diffusive model based on Deardorff (1980)" 1
    .check "Set TKE_LEVELS (different from BL_LEVELS)" L SETTKELEVS Y N
    .case SETTKELEVS=="Y"
      .block 1
        .entry "TKE_LEVELS" L TKE_LEVS 10
        .check "Use the local scheme above TKE_LEVELS and below BL_LEVELS" L LOCALABVTKE Y N
      .blockend
    .caseend
    .check "Force initialisation of the prognostic variables" L LINITPROG Y N
    .check "Initialize prognostics to zero" L LINITZERO Y N
    .entry "Minimum limit of the buoyancy gradient at initialisation" L INIDBDZLIM 10
    .check "Advection of the prognostic variables in the TKE schemes" L ADVTKEPROG Y N
    .gap
    .basrad "Buoyancy parameters" L 2 v BUOYPARAM
        "Evaluate with the turbulent covariances"              1
        "Use those calculated in the large scale cloud scheme" 2
    .check "Non-gradient buoyancy flux associated with the skewness in shallow convection" L LBUOYSKEW Y N
    .case LBUOYSKEW=="Y"
      .block 1
        .entry "Levels at which to apply the non-gradient buoyancy flux" L SHCULEVS 10
        .entry "Maximum limit of the non-gradient buoyancy flux" L WBNGMAX 10
      .blockend
    .caseend
    .basrad "Method for calculating production terms at the lowest level" L 3 v LOWPDSURF 
         "Without surface fluxes and related quantities"           0
         "With gradient functions by Businger (1971)"              1
         "With gradient functions by Beljaars and Holtslag (1991)" 2
    .case TKE_MOD=="3"
      .check "Adjustment of production terms for computational stability on each level" L LADJPROD Y N
      .case LADJPROD=="Y"
        .table tkeajd "Factors for adjustment of production terms" top h NBLLV 5 INCR
          .element "Start level" STARTLEV_TKE NBLLV 11 in
          .element "End level" ENDLEV_TKE NBLLV 11 in
          .element "Adjustment Factor" ADJPRODFAC NBLLV 20 in
        .tableend
      .caseend
    .caseend
    .gap
    .entry "Altitude above which the mixing length due to buoyancy is restricted (m)" L ZLIMELB 10
    .check "Print the maximum values of the prognostic variables" L LPRINTMAX Y N
    .textw "The following options are valid only for the first order model" L
    .case TKE_MOD=="1"
      .block 1
        .textw "Value of a coefficient (Cm) to determine diffusion coefficients" L
        .block 2
   	  .entry "Below the top of mixed layer" L TKE_CMMIX 10
	  .entry "Free atmosphere" L TKE_CMFA 10
        .blockend
	  .basrad "Method for calculating the mixing length" L 3 v TKE_DLEN
	      "The original Deardorff method"                                    2
	      "The method in the Mellor-Yamada model"                            1
	      "The original DearDorff method but with non-local like correction" 3
      .blockend
    .caseend
  .caseend
  .textw "Push BACK for Boundary Layer." L    
  .pushnext "BACK" atmos_Science_Section_BLay  
.panend
