.winid "atmos_Science_Section_UKCA"
.title "Section 34: UKCA Chemistry and Aerosols"
.wintype entry
.procs {} {} {set_a38 ; # set Sections 38 and 50}
.panel
  .gap
  .basrad "Choose the relevant section release" L 2 v ATMOS_SR(34)
          "<0A> UKCA not included." 0A
          "<1A> UKCA included." 1A
  .gap
  .case ATMOS_SR(34)!="0A"
    .basrad "Select Chemical Scheme" L 6 v I_UKCA_CHEM
       "Age of air only" 1
       "Standard Tropospheric(BE)" 11
       "RAQ(BE)" 13
       "Tropospheric+Isoprene" 50
       "Standard Stratospheric" 52
       "Stratospheric + Tropospheric Chemistry" 51     
    .gap
    .case I_UKCA_CHEM==11 || I_UKCA_CHEM==13
      .check "Set Backward Euler Solver Settings to non-default values?" L BESOLVE Y N
        .case BESOLVE=="Y"
           .block 2 
           .entry "Backward Euler Timestep" L DTS0 15
           .entry "Number of iterations for BE solver" L NIT 15
           .blockend
        .caseend
    .caseend
    .case I_UKCA_CHEM !=0 && I_UKCA_CHEM !=1 && I_UKCA_CHEM != 13
      .check "Include aerosol chemistry" L L_UKCA_AERCHEM Y N
      .case L_UKCA_AERCHEM== "Y"
        .check "UKCA_MODE Aerosol Scheme" L LUKCAMODE Y N
      .caseend 
    .caseend
    .case I_UKCA_CHEM != 0
      .case LUKCA_PCH4=="N" && I_UKCA_CHEM != 1
        .check "Interactive wetland CH4 emissions" L LUKCA_QCH4I Y N
      .caseend
      .gap
      .textw "Specify Tropospheric Options to be included" L
      .case I_UKCA_CHEM==11 || I_UKCA_CHEM==13 || I_UKCA_CHEM==50
        .check "Use 2D top boundary data?" L LUSE2DTOP Y N
        .case LUSE2DTOP=="Y"
          .entry "Directory pathname for the 2D top boundary data:" L STRAT2DDIR 40
        .caseend
      .caseend
      .case active LUKCAMODE
       .case LUKCAMODE=="Y" && I_UKCA_CHEM !=11 && I_UKCA_CHEM !=52
        .check "Switch on Tropospheric Heterogenous Chemistry" L LUKCA_TROPHET Y N
       .caseend
      .caseend
      .gap
      .textw "Select Stratospheric options to be included:" L
      .case I_UKCA_CHEM==51 || I_UKCA_CHEM==52
        .check "Switch on water feedback from chemistry" L LH2O_FEEDBACK Y N
        .check "Switch on Heterogenous / PSC chemistry" L LHET_PSC Y N
        .case LHET_PSC=="Y"
          .check "Use climatological Aerosol for Surface Area" L LUKCA_SACLIM Y N
          .case LUKCA_SACLIM=="Y"
            .block 2
            .entry "Directory containing climatological aerosol file:" L STRATAERDIR 40
            .entry "File containing climatological aerosol data:" L STRATAERFIL 40
            .check "Use a cyclic, monthly-varying 'background' aerosol field instead of timeseries" L LUKCA_BCGAER Y N
            .blockend
          .caseend
        .caseend      
      .caseend
    .caseend
  .caseend


  .textw "Push PHOTO button for photolysis parameters" L
  .textw "Push LOWBC button to specify Trace gases and Lower Boundary Conditions" L
  .textw "Push COUPL button for Coupling between UKCA and Atmosphere" L
  .textw "Push UKCA_TRA to initialise tracers available" L
  .textw "Push MODE to setup aerosol model parameters" L
  .textw "Push NEW_EMISS to set up the new NetCDF emission system" L   
  .pushnext "PHOTO" atmos_Science_Section_UKCA_Phot
  .pushnext "LOWBC" atmos_Science_Section_UKCA_LowBC
  .pushnext "COUPL" atmos_Science_Section_UKCA_Coupl
  .pushnext "UKCA_TRA" atmos_Config_Tracer_UKCA
  .pushnext "MODE" atmos_Science_Section_UKCAMode
  .pushnext "NEW_EMISS" atmos_Science_Section_UKCA_Emiss
.panend
.set_on_closure "Set Section 38" ATMOS_SR(38) ATMOS_SR(50)
