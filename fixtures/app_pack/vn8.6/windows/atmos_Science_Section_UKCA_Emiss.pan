.winid "atmos_Science_Section_UKCA_Emiss"
.title "UKCA NetCDF Emission System"
.wintype entry

  .case ATMOS_SR(34)!="0A"
    .check "Use new UKCA emissions" L LNEW_EMISS Y N
    .gap
    .case LNEW_EMISS=="Y"
      .entry "Directory pathname for NetCDF emission files" L NEMS_DIR 25
      .gap
      .table new_emiss "NetCDF emission files" top h NEMSFL 10 TIDY
      .elementautonum "Number" 1 NEMSFL 6
      .element "File name                            " EMISSFILE NEMSFL 50 in
      .element "Include Y/N" USE_EMISSFILE NEMSFL 3 in
    .tableend
    .caseend
  .caseend
  .textw "Push UKCA to go to the parent window" L
  .pushnext "UKCA" atmos_Science_Section_UKCA
.panend 
