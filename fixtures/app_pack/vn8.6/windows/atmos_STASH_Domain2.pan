.winid "atmos_STASH_Domain2"
.title "Domain Profile Specification (Pseudo)"
.wintype entry
.comment ======================================================================
.comment  When adding/removing profile variables, remembe to change the
.comment  list in stash.tcl that perform functions to copy/remove profiles.
.comment ======================================================================

.panel
   .basrad "Specify pseudo level type" L 15 v PLT_A(PROFILE)
            "No pseudo level dimension" 0
            "SW radiation bands" 1
            "LW radiation bands" 2
            "Atmospheric assimilation groups" 3 
            "HadCM2 Sulphate Loading Pattern Index" 8
            "Land and Vegetation Surface types" 9
            "Multiple sea-ice categories" 10
            "COSP radar reflectivity intervals" 12
            "COSP hydrometeors" 13
            "COSP lidar SR intervals" 14
            "COSP tau bins" 15
            "COSP subcolumns" 16
            "Atmos User Defined Type 101" 101 
            "Atmos User Defined Type 102" 102 
            "Atmos User Defined Type 103" 103 
   .gap
   .case PLT_A(PROFILE)!=0
     .table ban "Specify the bands/groups required" top h 20 10 INCR
       .elementautonum "Psl" 1 20 3
       .element "Pseudo level" PSLIST_A(*,PROFILE) 20 35 in
     .tableend
   .caseend  
   .gap
   .pushnext "LEVS" atmos_STASH_Domain
   .pushsequence "HORIZ" atmos_STASH_Domain3
   .pushnext "TSERIES" atmos_STASH_Domain4
.panend


