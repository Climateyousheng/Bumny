.winid "atmos_Science_Section_Stochastic_SKEB"
.title "Stochastic Kinetic Energy Backscatter 2"
.wintype entry

.panel
  .gap
  .block 1
  .case  ATMOS_SR(35)!="0A" && LSKEB2=="Y"
    .check "Include Numerical Dissipation Rate" L SKEBPSISDISP Y N
    .case L_ENDGAME=="T"
      .check "Include Biharmonic numerical dissipation instead of Smagorinsky" L SKEB2_BIHRM Y N
    .caseend
    .check "Include SKEB1-type Dissipation Rate" L LSKEB1DISP Y N
    .check "Include Convective Dissipation Rate" L SKEBPSICDISP Y N
    .case CDISPSCHEME == "4"
      .check "Convective dissipation resolution dependent factor" L SKEB2_DISPM Y N
    .caseend
    .gap
    .case SKEBPSICDISP=="Y"
      .basrad "Choose dissipation type to include" L 2 v CDISPSCHEME
        "Using CAPE*UPFLX (Conv scheme 4)" 4
        "Using vertical MFLX (Conv scheme 5)" 5
      .block 2  
      .case CDISPSCHEME=="5"
        .entry "Updraught fraction (for vertical MFLX conv Diss Rate)" L UPDFRAC 10
      .caseend
      .blockend
    .caseend
    .entry "Min wavenumber of streamfunction forcing pattern" L WAVMIN 10
    .entry "Max wavenumber of streamfunction forcing pattern" L WAVMAX 10
    .textw "(usually the N-number of the global model version" L
    .entry "Global-mean rate of energy backscatter in m^2/s^3" L TOTBKSCAT 10
    .entry "Backscatter ratio (fraction)" L BKSCATR 10
    .entry "Lower model limit for backscatter (MIN=2)" L SKEB2BOTLEV 10
    .entry "Upper model limit for backscatter (MAX=MODLEVS-1)" L SKEB2TOPLEV 10
    .entry "Decorrelation time of forcing pattern (secs)" L DECORTIME 10
    .entry "Numerical dissipation factor" L SDISPFAC 10 
    .entry "Convective dissipation factor" L CDISPFAC 10
    .entry "SKEB1-type dissipation factor" L KDISPFAC 10
    .entry "Dissipation smoothing iterations" L NSMOOTH 10
    .check "Include Velocity Potential Wind Increments" L LVELPOT Y N 
    .check "Use advanced smoothing of local dissipation" L LSKEBADV Y N 
    .check "Print global dissipation values" L LSKEBPRN Y N 
  .caseend
  .blockend
  .gap
  .pushnext "RP" atmos_Science_Section_Stochastic_RP
  .pushnext "Back" atmos_Science_Section_Stochastic
.panend
