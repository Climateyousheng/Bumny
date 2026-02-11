.winid "atmos_STASH_Domain3"
.title "Domain Profile Specification (Horiz)"
.wintype entry
.comment ======================================================================
.comment  When adding/removing profile variables, remembe to change the
.comment  list in stash.tcl that perform functions to copy/remove profiles.
.comment ======================================================================

.panel
   .basrad "Select horizontal domain type" L 10 v IOPA_A(PROFILE)
            "Full model area" 1
            "Northern hemisphere only" 2
            "Southern hemisphere only " 3
            "90 to 30 degrees (90N - 30N)" 4
            "-30 to -90 degrees (30S - 90S)" 5
            "30 to 0 degrees (30N - 0)" 6
            "0 to -30 degrees (0 - 30S)" 7
            "30 to -30 degrees (30N - 30S)" 8
            "Specified area in whole degrees" 9
            "Specified area in gridpoints" 10
   .gap
   .invisible IOPA_A(PROFILE)==9
   .text "Specify your area in degrees. Ranges (90 to -90)   and   (0 to 360)." L
   .block 1
      .entry "Northern limit" L INTH_A(PROFILE)
      .entry "Southern limit" L ISTH_A(PROFILE)
      .entry "Western limit" L IWST_A(PROFILE)
      .entry "Eastern limit" L IEST_A(PROFILE)
   .blockend
   .invisend
   .gap
   .invisible IOPA_A(PROFILE)==10
   .text "Specify area in gridpoints:" L
   .block 1
      .entry "Northern limit" L GNTH_A(PROFILE)
      .entry "Southern limit" L GSTH_A(PROFILE)
      .entry "Western limit" L GWST_A(PROFILE)
      .entry "Eastern limit" L GEST_A(PROFILE)
   .blockend
   .invisend
   .gap
   .basrad "Specify point option" L 3 h IMSK_A(PROFILE)
            "All gridpoints" 1
            "Land gridpoints only" 2
            "Sea gridpoints only" 3
   .gap
   .basrad "Select meaning option" L 5 h IMN_A(PROFILE)
            "No spatial averaging" 0
            "Vertical mean" 1
            "Zonal mean" 2
            "Meridional mean" 3
            "Horizontal mean" 4
   .gap
   .basrad "Select weighting option" L 4 h IWT_A(PROFILE)
            "No weighting" 0
            "Horizontal area weighting" 1
            "Volume weighting" 2
            "Mass weighting" 3
   .gap
   .pushnext "LEVS" atmos_STASH_Domain
   .pushnext "PSEUDO" atmos_STASH_Domain2
   .pushsequence "TSERIES" atmos_STASH_Domain4 
.panend


