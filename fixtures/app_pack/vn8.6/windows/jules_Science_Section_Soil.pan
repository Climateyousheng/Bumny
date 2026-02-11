.winid "jules_Science_Section_Soil"
.title "JULES Section 4: Soil Processes"
.wintype entry

.panel
  .gap
  .case ATMOS_SR(3)!="0A"
    .block 1
      .basrad "Soil hydraulics (L_VG_SOIL)" L 2 v VGSOIL
            "Clapp and Hornberger" 1
            "van Genuchten" 2 
    .blockend
     .entry "Select method of calculating soil thermal conductivity (1 old, 2 new)" L SOILHC 8
     .check "Calculate gradient of soil suction from graient in soil moisture content" L LGRDSOILS Y N
    .gap
  .caseend
  .block 1
    .check "Use implicit numerics for land ice" L L_LAND_ICE_IMP Y N
  .blockend
.panend
