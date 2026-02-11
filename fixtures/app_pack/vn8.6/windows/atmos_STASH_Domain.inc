.include_begin 2
.procs {} {abandonProfile %1 domain %2} {update_STASH %1 domain %2}
.loop %2 1 NDPROF_A
.comment ======================================================================
.comment  When adding/removing profile variables, remembe to change the
.comment  list in stash.tcl that perform functions to copy/remove profiles.
.comment ======================================================================

   .entry "Domain profile name" L DOMPRO_A(%2)
   .basrad "Select vertical level type" L 9 v IOPL_A(%2)
            "Variables derived on a single or unspecified level" 5
            "Variables derived on model rho levels (Charney-Philips grid)" 1
            "Variables derived on model theta levels (Charney-Philips grid) " 2
            "Variables on deep soil levels" 6
            "Variables on pressure levels (hPa)" 3
            "Variables on geometric height levels (m)" 4
            "Variables on constant theta surfaces (K)" 7
            "Variables on potential vorticity levels" 8
            "Variables on cloud threshold levels (octas)" 9
   .gap
   .invisible IOPL_A(%2)==1||IOPL_A(%2)==2||IOPL_A(%2)==6
     .basrad "Specification of levels by" L 2 v ILEVS_A(%2) 
              "Range of model levels" 1
              "List of selected model levels" 2 
      .invisible ILEVS_A(%2)==1
         .entry_active "Range starting at (see Level Names Help)" L lnConvertInput LEVB_A(%2)
         .entry_active "Range ending at (see Level Names Help)" L lnConvertInput LEVT_A(%2)
      .invisend                        
      .invisible ILEVS_A(%2)==2
         .table levels4 "Select Integer Levels" top h 40 10 INCR
           .elementautonum "Lev" 1 40 3
           .element "Levels" LEVLST_A(*,%2) 40 35 in
        .tableend
      .invisend                        
   .invisend    
   .invisible IOPL_A(%2)==4||IOPL_A(%2)==7||IOPL_A(%2)==8||IOPL_A(%2)==9
      .table levels5 "Select real levels" top h 40 10 INCR
           .elementautonum "Lev" 1 40 3
           .element "Levels" RLEVLST_A(*,%2) 40 35 in
        .tableend
   .invisend         
   .invisible IOPL_A(%2)==3
     .basrad "Specification of levels by" L 2 v ISCCP_A(%2)
	         "List of selected model levels" 1
			 "ISCCP simulator levels" 2
	 .invisible ISCCP_A(%2)==1		 
      .table levels6 "Select real levels" top h 40 10 DESC
           .elementautonum "Lev" 1 40 3
           .element "Levels" PLEVLST_A(*,%2) 40 35 in
        .tableend
     .invisend		
   .invisend  
   .pushbutton "Level Names Help" lnDisplayHelp
   .pushsequence "PSEUDO" atmos_STASH_Domain2
   .pushnext "HORIZ" atmos_STASH_Domain3
   .pushnext "TSERIES" atmos_STASH_Domain4 
.include_end




