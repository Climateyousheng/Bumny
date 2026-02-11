.winid "atmos_Science_Section_AeroClim"
.title "Aerosol Climatologies"
.wintype entry

.panel
  .gap
  .basrad "Select the option of climatological aerosols (affects both the LW and SW code)" L 3 v ESRAD_AERO
          "Cusack climatological aerosol not included" 1
          "Only use Stratospheric Cusack climatological aerosol components (as used in HadGEM1)" 2
          "Use all components of Cusack climatological aerosol included" 3
  .gap
  .block 1
  .case ESRAD_AERO=="3"
    .basrad "Distribute the boundary layer aerosol vertically using" L 3 v LCAHGT
      "the diagnosed boundary layer depth"  1
      "the number of boundary layer levels" 2
      "a user specified number of levels"   3
     .case LCAHGT=="3"
       .block 2
       .entry "number of levels" L USRAEROBLEV 15
       .blockend 
     .caseend  
  .caseend

   .block 1
   .table tabcusack "Scalings for components of Cusack's climatology" top h 5 5 NONE
      .elementautonum "Num" 1 5 3
      .element "Field"         CSKNAME 5 20 out
      .element "Scaling"       CSKCLIM 5 20 in
   .tableend

   .case ESRAD_AERO!="1"
    .check "Specify climatological volcanic eruption?" L LCLIMVOLC Y N
      .case LCLIMVOLC=="Y"
        .entry "Eruption year:" L ERUPTYR 10
        .entry "Eruption month:" L ERUPTMTH 10
        .entry "Factor to scale climatological eruption:" L ERUPTWT 10
    .caseend  
   .blockend    

  .caseend  
  .gap
  .text "Use the following climatologies (specified by ancillary files)" L
  .check "Include biogenic aerosol climatology" L LUSEBIOGEN Y N
  .check "Include Biomass-burning aerosol climatology" L LUARCLBIOM Y N
  .check "Include Black Carbon aerosol climatology" L LUARCLBLCK Y N
  .check "Include Sea-salt aerosol climatology" L LUARCLSSLT Y N
  .check "Include Sulphate aerosol climatology" L LUARCLSULP Y N
  .check "Include Dust aerosol climatology" L LUARCLDUST Y N
  .check "Include Org. Carbon (Fossil Fuel) aerosol climatology" L LUARCLOCFF Y N
  .check "Include Delta aerosol climatology" L LUARCLDLTA Y N
  .case L_AUTOCMURK=="F"
    .check "Use climatological aerosols to calculate droplet number (second indirect effect)" L L_MCRARCL T F
  .caseend
  .blockend
  .gap
  .textw "Push SW for the SW Radiation window" L
  .textw "Push LW for the LW Radiation window" L
  .textw "Push AERO_FX for the Aerosol Effects window" L
  .textw "Push AERO_Ancils for the Aerosol Effects window" L    
  .pushnext "SW" atmos_Science_Section_SW
  .pushnext "LW" atmos_Science_Section_LW
  .pushnext "AERO_FX" atmos_Science_Section_Aero_Effects
  .pushnext "AERO_Ancils" atmos_InFiles_PAncil_AeroClim    
  .panend


