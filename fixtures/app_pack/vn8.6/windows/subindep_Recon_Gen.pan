.winid "subindep_Recon_Gen"
.title "Options for the Reconfiguration"
.wintype entry

.panel
 .case ARECON=="Y"
   .block 1
     .check "Run the reconfiguration in the VAR suite" L VAR_RECON Y N
   .blockend
   .gap
   .textw "Elsewhere you have requested that the model is run on [get_variable_value NMPPE] x [get_variable_value NMPPN] processors" L
   .textw "Total number for reconfiguration should normally be the same as or fewer than for model" L
   .block 1
     .colour red GEN_SUITE==1
       .entry "Define the number of processors East-West"   L RCF_NMPPE 15
       .entry "Define the number of processors North-South" L RCF_NMPPN 15
     .colourend
   .blockend
   .gap
   .case GEN_SUITE!=1
       .invisible SUBMIT_METHOD != 1
         .textw "On IBM input number of Gb. Any fraction is converted to Mb (eg. 1.4 converts to 1400Mb)" L             
     .block 1
         .entry "Reconfiguration job memory limit (see help)" L RCFJSIZE 15
         .entry "Reconfiguration job time limit" L RCFJTLIM   15
       .invisend
       .invisible SUBMIT_METHOD == 1
         .entry "Reconfiguration job stack limit (Gb)" L RCFSTACK 15
       .invisend      
     .blockend
   .caseend
   .gap
   .block 1
     .check "Override year in dump with year in model basis time" L USEMBT Y N
     .check "Resetting data time to verification time" L ADTVT Y N   
     .check "Using the spiral coastal adjustment algorithm" L ASPIR Y N   
     .check "Using soil moisture stress for interpolating soil moisture" L USMCSTRESS Y N  
     .check "Using nearest neighbour interpolation method for soil properties" L SMCPIMTHD Y N
     .case OCAAA == "2" || OCAAA == "3" || OCAAA == "4"
       .check "Avoid rotating grid when interpolating" L L_LIMROT Y N
     .caseend
     .case JL_AGGREGATE=="N"
       .check "Perform canopy snow throughfall" L LCANSNOWTHR Y N
     .caseend
   .blockend   
 .caseend
 .gap
 .textw "Push Recon_QC for reconfiguration quality control" L 
 .textw "Push Start_Dump for reconfiguration settings in atmosphere start dump" L
 .pushnext "Recon_QC" subindep_Recon_QC
 .pushnext "Start_Dump" atmos_InFiles_Start  
.panend
