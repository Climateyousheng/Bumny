.winid "jules_Science_Section_Plant"
.title "JULES Section 5: Plant Physiology"
.wintype entry

.panel
  .gap
  .case ATMOS_SR(3) != "0A" 
    .textw "Please see help for Surface Type Parameter variable descriptions and default values." L
    .block 1
      .table jules_pft "Vegetation Surface Type Parameters" top h JI_PFTYPE 7 NONE
        .elementautonum "Plant Functional Type:" 1 6 18
        .element "ALBSNC_MAX_IO" ALBSNC_MAX JULES_PFT 18 in
        .element "ALBSNC_MIN_IO" ALBSNC_MIN JULES_PFT 18 in
        .element "ALBSNF_MAX_IO" ALBSNF_MAX JULES_PFT 18 in
        .element "SURFACE EMISSIVITY" EMIS_PFT JULES_PFT 18 in
        .element "DZ0V_DH_IO" DZ0V_DH JULES_PFT 18 in
        .element "CATCH0_IO" CATCH0 JULES_PFT 18 in
      .tableend
      .table jules_pft2 "Vegetation Surface Type Parameters continued..." top h JI_PFTYPE 7 NONE
        .elementautonum "Plant Func.Type" 1 6 15
        .element "DCATCH_DLAI_IO" DCATCH_DLAI JULES_PFT 12 in
        .element "INFIL_F_IO" INFIL_F JULES_PFT 12 in
        .element "KEXT_IO" KEXT JULES_PFT 12 in
        .element "ROOTD_FT_IO" ROOTD_FT JULES_PFT 12 in
        .case JULES=="T"
          .element "Z0HM_PFT_IO" Z0HM_PFT JULES_PFT 12 in
        .caseend
        .element "Z0HM_CLASSIC_PFT_IO" Z0HM_CLASSIC_PFT JULES_PFT 20 in
      .tableend
    .blockend
  .caseend
  .gap
.panend
