.winid "atmos_Science_Section_Nudging"
.title "Section 39 : Nudging"
.wintype entry
.procs {} {} {}

.panel
 .gap
 .basrad "Choose version" L 2 v ATMOS_SR(39)
     "<0A> Nudging not included."   0A
     "<1A> Nudging with analysis data." 1A
 .gap
 .case ATMOS_SR(39)!="0A"
   .block 1
     .textw "Nudging Relaxation parameters:" L
     .block 2
       .entry "Variable U" L NDG_UVAL 15
       .entry "Variable V" L NDG_VVAL 15
       .entry "Variable T" L NDG_TVAL 15
     .blockend
   .blockend
   .gap
   .block 1
     .entry "Lowermost model level to start nudging" L NDG_LEVBOT 15
     .entry "Topmost model level to apply nudging"  L NDG_LEVTOP 15
   .blockend
   .block 1
     .textw "Number of levels to go from none to full-strength nudging:" L
     .block 2
       .entry "from bottom" L NDG_ONLEVBOT 15
       .entry "from top" L NDG_ONLEVTOP 15
     .blockend
   .entry "Stratospheric Reduction factor" L NDG_STRAT_FAC 15
   .blockend
   .gap
   .block 1
    .basrad "Analysis Data Source" L 4 v NDG_ANALSRC
       "ERA on hybrid levels"   0
       "ERA on pressure levels" 1
       "UM analysis"            2
       "Japanese Reanalysis"    3
    .blockend
   .block 1
     .entry "Interval between Analysis data (hours)" L NDG_HRSDATA 15
     .entry "Directory pathname for Analysis files" L NDG_DATAPATH 40
   .blockend
 .caseend  
 .gap  
 .textw "Push STASH to go to the STASH macro panel" L
 .pushsequence "STASH" atmos_STASH_Macros_Nudging 
.panend
