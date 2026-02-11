.winid "atmos_Science_Section_UKCA_LowBC"
.title "UKCA Lower Boundary Conditions and Trace Gases"
.wintype entry

.panel
  .gap
  .case ATMOS_SR(34)!="0A" && I_UKCA_CHEM!=0 && I_UKCA_CHEM!=1
      .gap
      .textw "CH4, CO2, N20 and CFC concentrations are specified elsewhere in the UMUI under:" L
      .block 2
        .textw "Settings for methane concentrations are located in panel:" L
        .textw "Atmosphere => Scientific parameters and sections => Spec of trace gases" L
      .blockend
      .gap
      .case LW2METHABS=="Y" && (ES_RAD==2||ES_RAD==3)
        .block 1
          .check "Use prescribed surface CH4 concentrations from UMUI" L LUKCA_PCH4 Y N
        .blockend
      .caseend 
      .case I_UKCA_CHEM==51 || I_UKCA_CHEM==52
        .block 1
          .basrad "Specify the Lower Boundary Condition" L 3 v UKCA_SCEN
             "Prescribed CO2,N2O,CFC concentrations from the UMUI" 0
             "Prescribed CO2, N2O, CFC concentrations from the WMO A1(b) scenario (1950-2100)" 1
             "Prescribed CO2, N2O, CFC concentrations from a file in RCP format" 2
             .gap
          .case UKCA_SCEN=="2"
            .entry "Directory containing the RCP file" L UKCA_RCPDIR 80
            .entry "Name of RCP file" L  UKCA_RCPFILE 80
            .gap
          .caseend
        .blockend 
        .case UKCA_SCEN == 0
          .block 1
            .table ukca_cfc "Specify Values for CFCs" top h N_UKCATRG 13 NONE
              .element "CFC" UKCA_CFC_NM N_UKCATRG 20 out
              .element "Value" UKCA_CFC_VAL N_UKCATRG 20 in
            .tableend
          .blockend 
        .caseend
      .caseend
      .gap
      .case I_UKCA_CHEM == 51 || I_UKCA_CHEM == 52
        .block 1
          .check "Specify Values for Trace Gases" L LUKCA_SETTRG Y N
        .blockend
        .case LUKCA_SETTRG=="Y"
          .block 2
            .entry "H2 as MMR" L UKCA_H2MMR 15
            .entry "N2 as MMR" L UKCA_N2MMR 15
          .blockend
        .caseend
      .caseend
  .caseend
  .gap
  .textw "Push UKCA to go to the parent window" L
  .pushnext "UKCA" atmos_Science_Section_UKCA
.panend
