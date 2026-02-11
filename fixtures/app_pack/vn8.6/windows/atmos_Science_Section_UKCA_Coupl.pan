.winid "atmos_Science_Section_UKCA_Coupl"
.title "Section 34: UKCA Chemistry Coupling "
.wintype entry

.panel
  .text "Section 34: UKCA Chemistry Coupling" L
  .gap
  .case ATMOS_SR(34)!="0A" && I_UKCA_CHEM!=0 && I_UKCA_CHEM!=1
    .block 1
    .textw "Select options to be included:" L
    .check "UKCA O3 in radiation scheme" L LUKCA_RADO3 Y N
    .check "UKCA CH4 in radiation scheme" L LUKCA_RADCH4 Y N
    .case I_UKCA_CHEM==51 || I_UKCA_CHEM==52
      .check "UKCA N2O in radiation scheme" L LUKCA_RADN2O Y N
      .check "UKCA CFC-11 in radiation scheme" L LUKCA_RADF11 Y N
      .check "UKCA CFC-12 in radiation scheme" L LUKCA_RADF12 Y N
      .check "UKCA CFC-113 in radiation scheme" L LUKCA_RADF113 Y N
      .check "UKCA HCFC-22 in radiation scheme" L LUKCA_RADF22 Y N
    .caseend 
    .check "UKCA interactive dry deposition scheme" L LUKCA_INTDD Y N  
    .case active LUKCAMODE
     .case LUKCAMODE=="Y"
      .check "Direct effect of MODE aerosols in radiation scheme (UKCA_RADAER)" L LUKCA_RADAER Y N  
      .check "1st Indirect Effect of MODE aerosols (on radiation)" L LUKCA_AE1  Y N
      .check "2nd Indirect Effect of MODE aerosols (on precip.)"   L LUKCA_AE2  Y N 
    .caseend 
   .caseend
    .blockend      
  .caseend
  .gap
  .textw "Push RADAER for MODE aerosols in radiation scheme options" L
  .textw "Push UKCA to go to the parent window" L
  .pushnext "RADAER" atmos_Science_Section_UKCA_Rad
  .pushnext "UKCA" atmos_Science_Section_UKCA
.panend
