.winid "atmos_Science_Section_SurfType"
.title "Land Surface - Surface Type Parameters"
.wintype entry
.panel
  .case ATMOS_SR(3)!="0A"
  .textw "Plant Funtional Type Surface Parameters:" L
      .table pftsurf "Plant Functional Type Surface Parameters" top h JI_PFTYPE 5 NONE
        .element "Plant Functional Type:" PRM_NAME JULES_PFT 14 out
        .element "ALBSNC_MAX" ALBSNC_MAX JULES_PFT 16 in
        .element "ALBSNC_MIN" ALBSNC_MIN JULES_PFT 16 in
        .element "ALBSNF_MAX" ALBSNF_MAX JULES_PFT 16 in
        .element "DZ0V_DH" DZ0V_DH JULES_PFT 16 in
        .element "CATCH0" CATCH0 JULES_PFT 16 in
      .tableend
      .table pftsurf2 "Plant Functional Type Surface Parameters continued..." top h JI_PFTYPE 5 NONE
        .element "Plant Functional Type:" PRM_NAME JULES_PFT 14 out
        .element "DCATCH_DLAI" DCATCH_DLAI JULES_PFT 16 in
        .element "INFIL_F" INFIL_F JULES_PFT 16 in
        .element "KEXT" KEXT JULES_PFT 16 in
        .element "ROOTD_FT" ROOTD_FT JULES_PFT 16 in
      .tableend
  .gap
  .textw "Non-Vegetation Surface Type Parameters:" L
      .table nvgsurf "Non-Vegetation Surface Type Parameters" top h JI_NVTYPE 4 NONE
        .element "Non-Veg. Type:" PRM2_NAME JULES_NVT 13 out
        .element "ALBSNC_NVG" ALBSNC_NVG JULES_NVT 16 in
        .element "ALBSNF_NVG" ALBSNF_NVG JULES_NVT 16 in
        .element "CATCH_NVG" CATCH_NVG JULES_NVT 16 in
        .element "GS_NVG" GS_NVG JULES_NVT 16 in
        .element "INFIL_NVG" INFIL_NVG JULES_NVT 16 in
      .tableend
      .table nvgsurf2 "Non-Vegetation Surface Type Parameters continued..." top h JI_NVTYPE 4 NONE
        .element "Non-Veg. Type:" PRM2_NAME JULES_NVT 13 out
        .case JULES=="F"
          .element "ROOTD_NVG" ROOTD_NVG JULES_NVT 16 in
        .caseend
        .element "Z0_NVG" Z0_NVG JULES_NVT 16 in
        .element "CH_NVG" CH_NVG JULES_NVT 16 in
        .element "VF_NVG" VF_NVG JULES_NVT 16 in
      .tableend
  .caseend
  .gap
  .textw "Push BACK to return to the Land Surface Panel" L
  .pushnext "BACK" atmos_Science_Section_LSurf
.panend
