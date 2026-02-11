.winid "atmos_Science_Section_BLay"
.title "Section 3 : Boundary Layer"
.wintype entry
.panel
  .gap
  .basrad "Choose version " L 4 v ATMOS_SR(3)
	  "Boundary Layer not included" 0A
          "<9B> Non-local scheme with revised diagnosis of K profile depths" 9B
	  "<9C> Revised treatment of entrainment fluxes plus new scalar flux-gradient option" 9C
	  "<1A> Prognostic TKE based turbulent closure model" 1A

  .case ATMOS_SR(3)!="0A"
    .case ATMOS_SR(3)!="1A" || (LCOMBI=="0"&&HDIFFOPT=="3"&&(LSUBFILHRZ=="T"||LSUBFILVER=="T")) || (SETTKELEVS=="Y" && TKE_LEVS!=NBLLV && LOCALABVTKE=="Y")

      .basrad "Select type of stable boundary layer mixing scheme" L 10 v LSBLEQ
          "Richardson no. scheme (RiSc): Long tails" 0
          "SHARPEST function (RiSc)" 1
          "SHARPEST over sea; Long tails over land (RiSc)" 2
          "MESOSCALE model: Louis/SHARPEST blend (RiSc)" 3
          "Louis function (RiSc)" 4
          "Boundary layer depth based formulation" 5
          "SHARPEST over sea; MES tails over land (RiSc)" 6
          "SHARPEST over sea; Louis/Long over land" 8
          "LEM stability functions" 7
          "Equilibrium stable boundary layer scheme" Y

      .case LSBLEQ=="8"
        .entry "If using the option SHARPEST over sea; Louis/Long over land, enter weighting towards long tails" L WLOUISTL 10
      .caseend  

      .case LSBLEQ=="1"||LSBLEQ=="2"||LSBLEQ=="6"||LSBLEQ=="8"
        .check "Use critical Ri=0.25 for SHARPEST function" L VAR_RICIN Y N
      .caseend
    .caseend

    .basrad "Use a stability dependent stable Prandtl number" L 2 h PRAND
        "Off" 0
        "On"  1
    .entry "Enter option for including the effects of unresolved drainage flows (see help)" L SGOROGMIX 5 
 
    .case ATMOS_SR(3)!="1A" || (LCOMBI=="0"&&HDIFFOPT=="3"&&(LSUBFILHRZ=="T"||LSUBFILVER=="T")) || (SETTKELEVS=="Y" && TKE_LEVS!=NBLLV && LOCALABVTKE=="Y")
       .basrad "Select unstable stability functions:" L 4 h CBLOPIN
           "Original UM" 0
           "Neutral" 1
           "Conventional LEM" 2
           "Standard LEM" 3

    .check "Use enhanced mixing length in Richardson no. Scheme (global operational setting)" L LLAMBDAM2 Y N
    .check "Mixing lengths in RiSc not reduced above boundary layer (global operational setting)" L LFULL_LAMBDAS Y N  

    .caseend
    .case ATMOS_SR(3)!="1A" || (LCOMBI=="0"&&HDIFFOPT=="3"&&(LSUBFILHRZ=="T"||LSUBFILVER=="T")) || (SETTKELEVS=="Y" && TKE_LEVS!=NBLLV && LOCALABVTKE=="Y")
       .entry "Enter free atmospheric turbulent mixing option (see help)" L LOCALFA 5
    .caseend
    .case  ATMOS_SR(3)=="9C" 
       .basrad "Select scalar flux-gradient formulation" L 2 h FLUXGRAD     
             "Surface-driven gradient adjustment for heat only" 0
             "Generic flux-gradient relationship" 2
     .caseend
     .case  ATMOS_SR(3)=="9B" || ATMOS_SR(3)=="9C"
       .check "Suppress the coupling of entrainment and subsidence when the w profile is complex" L SUBSCOUPLE Y N
     .caseend
    .entry "Enter option for dynamic criteria in diagnosis of boundary layer types" L DYNDIAGIN 10
    .case  DYNDIAGIN == "4"
      .entry "Enter threshold fraction of the cloud layer depth" L ZHLOC_DF 10
    .caseend

     .case  ATMOS_SR(3)=="9C"
       .check "Enhance entrainment mixing in stratocumulus over cumulus" L ENHANENTR 1 0
       .check "Smoothly reduce surface-driven entrainment during decoupling" L ENTR_SMOOTH_DEC 1 0
       .check "Allow stratocumulus mixing to be diagnosed with deep as well as shallow convection" L RELAXSC 1 0
       .entry "Enter value of buoyancy flux threshold for decoupling" L DECTHRESCLD 5
     .caseend

     .check "Include effect of convective downdraughts on surface exchange" L CONVGUST Y N
     .check "Include heating arising from frictional dissipation of turbulence" L FRICHEAT 1 0
  .caseend 
  .invisible USE_TCA=="Y"
    .gap
    .textw "On the tracer panel you have specified:" L
    .block 1
     .basrad "any defined tracer variables are to be " L 2 h TRAM
           "Mixed" Y
           "Not mixed    by the boundary layer" N 
    .blockend
    .gap
  .invisend
  .textw "Note: The number of boundary layer levels is set on the Vertical Resolution panel" L
  .pushsequence "TKE_Closure" atmos_Science_Section_BLay_TKE
  .pushnext "TSTEP" atmos_Science_Tstep 
.panend
