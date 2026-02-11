.winid "atmos_Science_Section_Advec"
.title "Section 12 : Primary Field Advection"
.wintype entry

.panel
   .gap
   .basrad "Choose version" L 2 v ATMOS_SR(12)
       "Primary Field advection not included" 0A
       "<2A> Semi-Lagrangian advection" 2A
   .basrad "Which dynamical core would you like to run?" L 2 v L_ENDGAME
      "ENDGame dynamical core code" T 
      "New dynamics" F
   .gap
   .block 0
   .case L_ENDGAME=="T"
     .entry "Eta value above which to apply vertical damping" L ETA_S 12
   .caseend
   .entry "Instability Diagnostics level of output" L INSTABDIAD 12
   .blockend
  .case ATMOS_SR(12)!="0A"
    .block 0
    .table sladv "Semi-Lagrangian Advection Settings" top h N_SLADVPAR 4 NONE
      .index SLADVPAR SLADVPARIN
      .index ADVMONO  SLADVIND
      .index ADVHIGH  SLADVIND
      .element "Field"                 SLADVPAR N_SLADVPAR 16 out
      .element "Monotone Scheme"       ADVMONO  N_SLADVPAR 10 in
      .element "High Order Scheme"     ADVHIGH  N_SLADVPAR 10 in
    .tableend
    .textw "Choose 1 or 2 for Monotone scheme, or 0 for no scheme" L
    .textw "Choose 1 to 7 for High Order scheme" L 
    .textw "Choose 0 for linear interpolation - no high order scheme" L
    .textw "See help for a description of each scheme" L
    .blockend
    .textj "Monotone Schemes:" L
    .block 2
      .textj "0: No scheme" L
      .textj "1: Tri-linear Lagrange interpolation" L
      .textj "2: ECMWF monotone quasi-cubic interpolation" L
    .blockend
    .textj "High order schemes:" L
    .block 2
      .textj "0: Linear interpolation - no high order scheme" L
      .textj "1: Cubic Lagrange interpolation" L
      .textj "2: Quintic Lagrange interpolation" L
      .textj "3: ECMWF quasi-cubic interpolation" L
      .textj "4: ECMWF monotone quasi-cubic interpolation" L
      .textj "5: Bi-cubic Lagrange interpolation in the horizontal, linear interpolation in the vertical" L
    .blockend
    .block 0
    .basrad "Moisture conservation" L 3 h LUMOIST 
      "None" 0   
      "Standard" 1
      "More accurate (Expensive, do not use for forecast runs)" 2  
    .blockend
    .gap 
    .block 1
    .check "Use mixing ratios for the moisture variables inside the dynamics" L LMIXMOIST T F
    .check "Running with free-slip boundary conditions (off for normal runs)" L LMT_FS T F
  .caseend 
  .check "Check global moisture conservation in physics and print results" L CHK_MOIST T F
  .check "Run variable resolution code" L LVARGRID Y N
  .case ATMOS_SR(12)!="0A"
    .blockend
    .block 1
    .entry "Height (m) up to which a monotone limiter is applied to advection of theta" L THMONOLVS 12
    .case L_ENDGAME!="T"
      .check "Used corrected monotone scheme (recommended)" L LTHMONOFX T F
    .caseend
    .entry "Vertical interpolation search tolerance" L VERTTOL 12
    .check "Use 2D vector coordinate geometry" L L2DGEOM T F 
    .blockend
    .text "Choices for Ritchie departure point scheme" L
      .block 1
      .entry "Iterations inside Ritchie scheme" L DEPORDER 12
      .basrad "Which monotone scheme" L 3 h RMONO
           "0" 0
           "1" 1
           "2" 2
      .basrad "Which high order scheme" L 8 h RHIGH
           "0" 0             
           "1" 1
           "2" 2
           "3" 3
           "4" 4
           "5" 5
           "6" 6
           "7" 7
      .blockend
    .case L_ENDGAME=="T"
      .block 1
      .check  "Enforce global mass conservation" L FIX_MASS T F
      .basrad "Alpha relaxation method" L 4 h ALPH_RELM
           "1" 1
           "2" 2
           "3" 3
           "4" 4     
      .basrad "EG vertical damping profile" L 6 h EG_VDPROF
           "0" 0
           "1" 1
           "2" 2
           "3" 3
           "4" 4
           "5" 5
      .blockend
    .caseend
    .case L_ENDGAME!="T"
      .text "Time Weight Coefficients" L
      .block 1
      .check "Use default values" L LALPHADEF T F
      .invisible LALPHADEF=="F"
        .block 4
        .entry "Alpha_1" L ALPHA_1 15
        .entry "Alpha_2" L ALPHA_2 15
        .entry "Alpha_3" L ALPHA_3 15
        .entry "Alpha_4" L ALPHA_4 15
        .blockend
      .invisend
      .invisible LALPHADEF=="T"
        .block 4
        .text "Alpha_1 = 0.6" L
        .text "Alpha_2 = 1.0" L
        .text "Alpha_3 = 0.6" L
        .text "Alpha_4 = 1.0" L
        .blockend
      .invisend
      .blockend
    .caseend
    .check "Do you require bit reproducible results whatever size the extended haloes are set to? N.B. This increases the cost of the code." L LHALREPROD T F
 .caseend 
  .textw "Push Next to set up Time weight coefficients after 1st cycle" L
   .pushnext "Next" atmos_Science_Section_Advec2 
.panend

