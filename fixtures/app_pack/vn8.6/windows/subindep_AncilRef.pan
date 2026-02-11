.winid "subindep_AncilRef"
.title "Ancillary reference time."
.wintype entry

.panel
   .text "Specify the reference time used for ancillary files for ALL models" L
   .block 1
      .entry "Year" L ANRYR
      .entry "Month" L ANRMO
      .entry "Day" L ANRDA
      .entry "Hour" L ANRHR
      .entry "Minute" L ANRMI
      .entry "Second" L ANRSE
   .blockend
   .text "Set all elements to 0 for a reference time equal to the basis time." L
   .text "All zeros is not normally recommended for climate model runs." L
.panend


