   .include_begin 0
     .block 0
     .case OCAAA!=5
       .check "Use OpenMP" L LR_OPENMP Y N
       .case LR_OPENMP=="Y"
         .block 1
         .entry "Number of threads" L NTHR_TASK 10
         .blockend
       .caseend
     .caseend   
     .blockend  
     .gap
     .case GEN_SUITE==0
       .block 0
       .case ATMOS=="T"
         .entry "Number of processes for ATMOS East-West (must be 1 or an even number)"   L NMPPE 8
         .entry "Number of processes for ATMOS North South" L NMPPN 8
       .caseend
       .blockend
       .case NEMO=="T"
         .block 0
         .entry "Number of PEs for NEMO East-West" L NEMO_IPROC 8
         .entry "Number of PEs for NEMO North-South" L NEMO_JPROC 8
         .blockend
         .block 0
	 .check "Use CICE type domain decomposition for NEMO (see Help for how to set other parameters with this option)" L NEMOKEY_DECOMP Y N
         .blockend
       .caseend
       .block 0
       .case CICE=="T"
         .case NEMO=="F"
           .entry "Number of PEs for CICE" L CICE_NPROC 8
         .caseend
         .entry "Number of columns for CICE East-West" L CICE_NXGLOB 8
         .entry "Number of rows for CICE North-South" L CICE_NYGLOB 8
         .entry "Number of columns per block for CICE East-West" L CICE_BLCKX 8
         .entry "Number of rows per block for CICE North-South" L CICE_BLCKY 8
         .case NEMO=="F" || NEMOKEY_DECOMP == "N"
           .entry "Maximum number of CICE blocks per processor" L CICE_MXBLCKS 8
         .caseend
         .blockend
         .invisible NEMO=="T" && NEMOKEY_DECOMP =="Y"
	   .block 2
           .textw "\"Maximum number of CICE blocks per processor\" is set to 1 since" L
           .textw "\"Use CICE type domain decomposition for NEMO\" is selected." L
           .blockend
         .invisend
       .caseend
       .block 0
       .invisible OASISWHICH==3 && OASIS_MPI_TYPE==2
              .block 0
              .textw "MPI2 in use for OASIS3: PEs for OASIS set to 1" L
              .blockend
       .invisend   
       .invisible OASISWHICH==4 
              .block 0
              .textw "OASIS-MCT in use: no OASIS processors required. " L
              .blockend
       .invisend     
       .case (ATMOS=="T" && OASIS=="T") && OASISWHICH==3 && OASIS_MPI_TYPE==1 
          .entry "Number of PEs for OASIS3 Coupler" L OASIS3_NPROC 8
       .caseend
     .caseend
     .blockend
   .include_end
