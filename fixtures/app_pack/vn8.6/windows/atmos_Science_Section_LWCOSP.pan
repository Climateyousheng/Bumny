.winid "atmos_Science_Section_LWCOSP"
.title "COSP satellite simulator"
.wintype entry

.panel
  .gap
  .case ATMOS_SR(2)!="0A"
    .check "Run with COSP" L LCOSP Y N
    .case LCOSP=="Y"
      .block 1
      .check "CLOUDSAT simulator" L LCOSP_CLDSAT Y N
      .check "CALIPSO/CALIOP simulator" L LCOSP_LIDAR Y N
      .check "ISCCP simulator" L LCOSP_ISCCP Y N
      .check "MISR simulator" L LCOSP_MISR Y N
      .check "MODIS simulator" L LCOSP_MODIS Y N
      .check "RTTOV simulator" L LCOSP_RTTOV Y N
      .check "Compute outputs on standard vertical grid" L LCOSP_VGRID Y N
      .blockend
      .gap
      .block 1
      .entry "Number of subcolumns" L COSP_NSUBCLM 10
      .entry "Number of points per iteration" L COSP_NPNTITR 10
      .blockend
      .gap
    .caseend
.panend


