.winid "atmos_Science_Section_UKCA_Rad"
.title "Direct effect of MODE aerosols in radiation scheme (UKCA_RADAER)"
.wintype entry

.panel
  .gap
  .case (ATMOS_SR(34)!="0A")
    .case I_UKCA_CHEM!=0 && I_UKCA_CHEM!=13 && LUKCA_RADAER=="Y"
      .entry "Directory path to UKCA_RADAER input files:" L RADAER_DIR 50
      .gap
      .block 1
        .entry "File of precomputed values:" L UKCAPREC
        .entry "Look-up table for aitken modes and insoluble accumulation-mode aerosol optical properties in the shortwave" L UKCAACSW 40
        .entry "Look-up table for aitken modes and insoluble accumulation-mode aerosol optical properties in the longwave" L UKCAACLW 40
        .entry "Look-up table for soluble accumulation-mode aerosol optical properties in the shortwave" L UKCAANSW 40
        .entry "Look-up table for soluble accumulation-mode aerosol optical properties in the longwave" L UKCAANLW 40    
        .entry "Look-up table for coarse-mode aerosol optical properties in the shortwave" L UKCACRSW 40 
        .entry "Look-up table for coarse-mode aerosol optical properties in the longwave" L UKCACRLW 40
        .gap
        .check "Use sulphuric acid optical properties instead of ammonium sulphate for SO4 aerosol component in the stratosphere" L  UKCARDRSUST Y N
      .blockend
    .caseend
  .caseend
  .gap
  .textw "Push UKCA to go to the parent window" L
  .textw "Push Coupl to go to the UKCA Coupling window" L
  .pushnext "UKCA" atmos_Science_Section_UKCA
  .pushnext "Coupl" atmos_Science_Section_UKCA_Coupl
.panend
