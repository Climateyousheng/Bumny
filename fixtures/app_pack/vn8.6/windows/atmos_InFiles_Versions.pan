.winid "atmos_InFiles_Versions"
.title "Ancillary version files"
.wintype entry

.panel
  .gap
  .case GEN_SUITE==0
    .check "User to specify ancillary version files" L LUSRANCVN Y N
    .case LUSRANCVN=="Y"
      .block 1
      .entry "Specify the Ancil filenames version" L USRANC_VN
      .entry "Specify the Ancil versions file" L USRANC_FLNM
      .blockend
    .caseend
  .caseend
  .gap
.panend
