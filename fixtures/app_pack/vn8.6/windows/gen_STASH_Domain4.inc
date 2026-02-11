  .include_begin 1
.comment ======================================================================
.comment  When adding/removing profile variables, remember to change the
.comment  list in stash.tcl that perform functions to copy/remove profiles.
.comment ======================================================================
  .check "Is this a time-series domain profile?" L DDOMTS_%1(PROFILE) Y N
  .invisible DDOMTS_%1(PROFILE)=="Y"
    .entry "Specify the number of Timeseries domains (up to [get_variable_value MAX_TS]): " L NDOMTS_%1(PROFILE)
    .basrad "Specify method of data input" L 2 v TDOMTS_%1(PROFILE)
            "Volumes defined by a range of levels and points" 1
            "Single points on a range of levels"  2
    .invisible TDOMTS_%1(PROFILE)==1
    .gap
    .textw "Your profile indicates that you should only fill in the following dimensions:" L
    .textw "Other dimensions should be left blank." L
    .invisible IMN_%1(PROFILE)!=1&&(IOPL_%1(PROFILE)==1||IOPL_%1(PROFILE)==2||IOPL_%1(PROFILE)==6)
      .textw "       From-level, To-level as Integers " L
    .invisend
    .invisible IMN_%1(PROFILE)!=1&&(IOPL_%1(PROFILE)==3||IOPL_%1(PROFILE)==4||IOPL_%1(PROFILE)==7||IOPL_%1(PROFILE)==8||IOPL_%1(PROFILE)==9)
      .textw "       From-level, To-level as Reals " L
    .invisend
    .invisible IMN_%1(PROFILE)==0||IMN_%1(PROFILE)==1||IMN_%1(PROFILE)==2
      .textw "       First-Row-limit, Last-Row-limit in gridpoints" L
    .invisend
    .invisible IMN_%1(PROFILE)==0||IMN_%1(PROFILE)==1||IMN_%1(PROFILE)==3
      .textw "       First-Column-limit, Last-Column-limit in gridpoints" L
    .invisend
    .gap
    .table timeseries1_%1 "Timeseries Specification by multiple gridpoint boxes" top h NDOMTS_%1(PROFILE) 10 NONE
      .elementautonum "Number" 1 NDOMTS_%1(PROFILE) 8
      .case IMN_%1(PROFILE)==0||IMN_%1(PROFILE)==1||IMN_%1(PROFILE)==2
        .element "North Row" DOMTS_N_%1(*,PROFILE) NDOMTS_%1(PROFILE) 8 in
        .element "South Row" DOMTS_S_%1(*,PROFILE) NDOMTS_%1(PROFILE) 8 in 
      .caseend
      .case IMN_%1(PROFILE)==0||IMN_%1(PROFILE)==1||IMN_%1(PROFILE)==3
        .element "West Col" DOMTS_W_%1(*,PROFILE) NDOMTS_%1(PROFILE) 8 in 
        .element "East Col" DOMTS_E_%1(*,PROFILE) NDOMTS_%1(PROFILE) 8 in
      .caseend
      .case IMN_%1(PROFILE)!=1&&(IOPL_%1(PROFILE)==1||IOPL_%1(PROFILE)==2||IOPL_%1(PROFILE)==6)
        .element "First Level (INT)" DOMTS_LF_%1(*,PROFILE) NDOMTS_%1(PROFILE) 15 in
        .element "Last  Level (INT)" DOMTS_LL_%1(*,PROFILE) NDOMTS_%1(PROFILE) 15 in 
      .caseend
      .case IMN_%1(PROFILE)!=1&&(IOPL_%1(PROFILE)==3||IOPL_%1(PROFILE)==4||IOPL_%1(PROFILE)==7||IOPL_%1(PROFILE)==8||IOPL_%1(PROFILE)==9)
        .element "First Level (REAL)" DOMTS_RF_%1(*,PROFILE) NDOMTS_%1(PROFILE) 15 in
        .element "Last  Level (REAL)" DOMTS_RL_%1(*,PROFILE) NDOMTS_%1(PROFILE) 15 in 
      .caseend 
    .tableend
   .invisend
    .invisible TDOMTS_%1(PROFILE)==2
    .gap
    .textw "Your profile indicates that you should only fill in the following dimensions:" L
    .textw "Other dimensions should be left blank." L
    .invisible IMN_%1(PROFILE)!=1&&(IOPL_%1(PROFILE)==1||IOPL_%1(PROFILE)==2||IOPL_%1(PROFILE)==6)
      .textw "       From-level, To-level as Integers " L
      .textw "       Note that each level produces a separate timeseries" L
    .invisend
    .invisible IMN_%1(PROFILE)!=1&&(IOPL_%1(PROFILE)==3||IOPL_%1(PROFILE)==4||IOPL_%1(PROFILE)==7||IOPL_%1(PROFILE)==8||IOPL_%1(PROFILE)==9)
      .textw "       From-level, To-level as Reals " L
      .textw "       Note that each level produces a separate timeseries" L
    .invisend
    .invisible IMN_%1(PROFILE)==0||IMN_%1(PROFILE)==1||IMN_%1(PROFILE)==2
      .textw "       Row in gridpoints" L
    .invisend
    .invisible IMN_%1(PROFILE)==0||IMN_%1(PROFILE)==1||IMN_%1(PROFILE)==3
      .textw "       Column in gridpoints" L
    .invisend
    .gap
    .table timeseries2_%1 "Timeseries Specification by single gridpoints" top h NDOMTS_%1(PROFILE) 10 NONE
      .elementautonum "Number" 1 NDOMTS_%1(PROFILE) 8
      .case IMN_%1(PROFILE)==0||IMN_%1(PROFILE)==1||IMN_%1(PROFILE)==2
        .element "Row" DOMTSR_NS_%1(*,PROFILE) NDOMTS_%1(PROFILE) 8 in
      .caseend
      .case IMN_%1(PROFILE)==0||IMN_%1(PROFILE)==1||IMN_%1(PROFILE)==3
        .element "Column" DOMTSR_EW_%1(*,PROFILE) NDOMTS_%1(PROFILE) 8 in 
      .caseend
      .case IMN_%1(PROFILE)!=1&&(IOPL_%1(PROFILE)==1||IOPL_%1(PROFILE)==2||IOPL_%1(PROFILE)==6)
        .element "First Level (INT)" DOMTSR_LF_%1(*,PROFILE) NDOMTS_%1(PROFILE) 15 in
        .element "Last  Level (INT)" DOMTSR_LL_%1(*,PROFILE) NDOMTS_%1(PROFILE) 15 in 
      .caseend
      .case IMN_%1(PROFILE)!=1&&(IOPL_%1(PROFILE)==3||IOPL_%1(PROFILE)==4||IOPL_%1(PROFILE)==7||IOPL_%1(PROFILE)==8||IOPL_%1(PROFILE)==9)
        .element "First Level (REAL)" DOMTSR_RF_%1(*,PROFILE) NDOMTS_%1(PROFILE) 15 in
        .element "Last  Level (REAL)" DOMTSR_RL_%1(*,PROFILE) NDOMTS_%1(PROFILE) 15 in 
      .caseend 
    .tableend
   .invisend
  .invisend
  .include_end

