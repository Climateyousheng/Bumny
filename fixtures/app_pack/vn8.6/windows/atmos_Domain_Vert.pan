.winid "atmos_Domain_Vert"
.title "Vertical"
.wintype entry

.panel
   .gap
   .block 1
      .entry "Number of levels"       L NLEVSA 15
      .entry "Number of wet levels"   L NWLEVA 15
      .entry "Number of ozone levels" L NOZLEV 15
   .blockend
   .gap
   .case ARECON=="Y"
     .basrad "Type of vertical interpolation" L 2 v VINT
             "Linear" 1
             "Linear with no extrapolation" 2
   .caseend
   .gap
   .textw "Related parameters, defined elsewhere:" L
   .invisible ATMOS_SR(3)=="0A"||ATMOS_SR(6)=="0A"||ATMOS_SR(7)=="0A"||ATMOS_SR(8)=="0A"
     .textw "Greyed-out parameters relate to sections which are currently not selected" L
   .invisend
   .block 2
      .case ATMOS_SR(3)!="0A"
         .entry "Number of boundary layer levels" L NBLLV 15
         .entry "Number of non-local boundary layer levels" L NLBLLEV 15
      .caseend
      .case ATMOS_SR(8)!="0A"
        .entry "Number of deep soil levels (excluding surface)"   L NDSLV 15
      .caseend
      .entry "Number of cloud levels used in radiation"   L CLRAD 15
   .blockend
   .basrad "Vertical levels options" L 2 v VLEV_OPT
            "Set G3 - requires 38 levels and appropriate number of boundary layer levels" G3
            "User defined set" "USER"
   .case VLEV_OPT == "USER"
     .text "Specify the location of the user defined set on the Target Machine" L
     .block 1
       .entry "Directory:" L VLEV_PATH
       .entry "File" L VLEV_FILE
     .blockend
   .caseend
   .case ATMOS_SR(8)!="0A"
      .table soil_levels "Soil levels" top h NDSLV 5 INCR
        .elementautonum "Level" 1 NDSLV 5
        .element "Values must be in ascending order" SOILLEVS 5 25 in
      .tableend
   .caseend
.panend
