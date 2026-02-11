.winid "atmos_Science_Section_Conv2"
.title "Convective Cloud"
.wintype entry

.panel
.gap
  .case ATMOS_SR(5)!="0A"
    .block 1
      .check "Use a phase change temperature in the plume other than 0 deg C" L LOTHERT Y N
      .case LOTHERT=="Y"
        .block 2
          .entry "Specify phase change temperature / K (Tice)" L TICE 15
          .entry "Estimate saturation specific humidity at this phase change T / kg kg-1 (qstice). See Help." L QSTICE 15
        .blockend
      .caseend
    .blockend
    .block 1
      .entry "Critical convective cloud condensate option" L CCW_PRECIP 15
      .entry "Minimum critical cloud condensate in kg/kg" L QLMIN 15
      .entry "QSat factor for critical cloud condensate" L FACQSAT 15 
      .entry "Maximum critical cloud condensate in kg/kg (MPARWTR)"  L  MPARWTR  15
      .entry "Updraught factor for reducing cloud water."  L  UD_FACTOR 15
      .case LCCRAD=="N"
        .check "Apply updraught factor to whole column" L LFIXUDF Y N
      .caseend
      .case ATMOS_SR(5)=="6A"
         .entry "Efficiency of liquid cloud creation" L EFF_DCFL 15
         .entry "Efficiency of frozen cloud creation" L EFF_DCFF 15
      .caseend
      .entry "Apply time decay of convective clouds" L RCLDDECAY 15
      .entry "Fixed Convective Cloud lifetime" L FIXCLDLIFE 15
      .entry "Convective Cloud Fraction threshold" L CCA_MIN 15
      .gap
      .check "Use 3D CCA cloud field" L L3DCCA Y N 
    .blockend
    .case L3DCCA=="Y" 
      .block 2
        .check "With radiative representation of anvils included."  L LANVIL Y N
        .case LANVIL=="Y"
          .check "Applying depth criteria for anvil clouds" L ANVIL_DEEP Y N
          .blockend
	  .block 2
	  .entry "Defining anvil factor" L ANVIL_FACTOR 15
          .entry "Defining tower factor" L TOWER_FACTOR 15
          .entry "Anvil profile basis" L ANV_OPT 15
        .caseend
      .blockend 
    .caseend
   .block 1  
      .gap
      .check "Use CCRad" L LCCRAD Y N
    .blockend
    .case LCCRAD=="Y"
      .block 2
        .entry "Cloud Decay lifetime option" L CLDLIFEOPT 15  
        .gap      
        .textw "Shallow convective cloud settings" L
        .entry "CCA 2D basis" L CCA2D_SH_OPT 15
        .entry "CCA scaling"  L CCA_SH_KNOB  15
        .entry "CCW Scaling"  L CCW_SH_KNOB  15
        .gap
        .textw "Deep convective cloud settings" L
        .entry "CCA 2D basis" L CCA2D_DP_OPT 15
        .entry "CCA scaling"  L CCA_DP_KNOB 15
        .entry "CCW Scaling"  L CCW_DP_KNOB 15
        .gap
        .textw "Mid-Level convective cloud settings" L
        .entry "CCA 2D basis" L CCA2D_MD_OPT 15
        .entry "CCA scaling"  L CCA_MD_KNOB 15
        .entry "CCW Scaling"  L CCW_MD_KNOB 15
      .blockend 
    .caseend
  .caseend
  .gap
  .textw "Push Convection to go Back" L
  .pushnext "Convection" atmos_Science_Section_Conv 
.panend
