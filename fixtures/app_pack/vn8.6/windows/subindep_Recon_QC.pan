.winid "subindep_Recon_QC"
.title "Reconfiguration Quality Control"
.wintype entry

.panel
  .case ARECON=="Y"
  .block 1
    .case OCAAA=="1"
      .check "Check output dump for non-uniform polar rows" L LPOLARCHK Y N
    .caseend
    .check "Reset specific humidity to a minimum value" L RSTQMIN Y N
    .case RSTQMIN=="Y"
      .block 2
        .entry "Specify minimum value:" L RCF_QMIN
      .blockend
    .caseend
    .check "Reset w-components of wind to zero" L RSETWZ Y N
    .case RSETWZ=="Y"
      .block 2
      .entry "First Level" L RSETWST
      .entry "Last Level" L RSETWEND
      .blockend
    .caseend
  .blockend
  .block 1
    .check "Reset sea ice surface temperatures to global surface temperature field" L RECON49 Y N
    .case ATMOS=="T" && NEMO=="T" && CICE=="T"
      .check "Reset category sea ice surface temperatures to global surface temperature field" L RECON415 Y N
    .caseend
    .check "Reset convective cloud to zero" L RECONCCLD Y N
  .blockend
  .caseend
  .gap
  .textw "Push Recon_Gen for general reconfiguration options" L     
  .textw "Push Start_Dump for reconfiguration settings in atmosphere start dump" L
  .pushnext "Recon_Gen" subindep_Recon_Gen  
  .pushnext "Start_Dump" atmos_InFiles_Start
.panend
