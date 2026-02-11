.winid "atmos_InFiles_OtherAncil_LBC"
.title "LBCs"
.wintype entry
.procs {} {} {set_LBC ; # set ATMOS_SR(31) ATMOS_SR(32)}
.panel
   .text "Define the use of the lateral boundary tendency input file(s)" L
   .textw "Elsewhere, this model is defined as [get_variable_value MODEL_TYPE(OCAAA)]" L
   .gap
   .case OCAAA==2
     .check "Is this limited area model using lateral boundary tendencies?" L UPD97 Y N
     .case UPD97=="Y"
       .gap
       .block 1
       .basrad "Number of lateral boundary files:" L 2 h LBTENCY 
         "1" 1
         "2" 2
       .gap  
       .colour red  GEN_SUITE==1
       .entry "Directory holding first lateral boundary file: " L PATH95
       .entry "and file name" L FILE95
       .invisible LBTENCY=="2"
         .entry "Directory holding second lateral boundary file:" L PATH95_2
         .entry "and file name" L FILE95_2
         .colourend
         .entry "Start time of second boundary file, in minutes from the start of the run :" L SEC_LBC_MIN
       .invisend
       .gap
       .blockend
       .table RIM "General RIMWIDTH table" top h NLBCRW 10 DESC 
          .elementautonum "Number from outside" 1 NLBCRW 10
          .element "Rim Weight  " RIMWGT NLBCRW 12 in
       .tableend
       .gap
       .text "Define whether optional LBC fields are in the input LBC file (see help):" L
       .block 1
       .check "Use interpolated wind trajectories in LBC's" L LIUVWLBC Y N
       .check "Input LBCs include rain" L MCRGRAIN_LBC T F
       .check "Input LBCs include graupel" L MCRGRPUP_LBC T F
       .check "Input LBCs include murk aerosol" L L_MURK_LBC Y N   
       .blockend
     .caseend
     .case ATMOS_SR(17)!="0A" && OCAAA=="2"
       .block 1
       .case I_DUST!="0" 
         .check "Input LBCs include dust"  L LDUSTLBC_IN Y N
       .caseend
       .case CHEM_SULPC=="Y"
         .check "Input LBCs include sulphates"  L LSULPLBC_IN Y N
	 .check "Input LBCs include dimethyl sulphide (DMS)"  L LDMSLBC_IN Y N
         .check "Input LBCs include ammonia (NH3)"  L LNH3LBC_IN Y N
       .caseend
       .case CHEM_SOOT=="Y"
         .check "Input LBCs include soot"  L LSOOTLBC_IN Y N
       .caseend
       .case CHEM_BIOM=="Y"
         .check "Input LBCs include biomass"  L LBIOLBC_IN Y N
       .caseend
       .case CHEM_OCFF=="Y"
         .check "Input LBCs include fossil fuel (OCFF)"  L LOCFFLBC_IN Y N  
       .caseend   
       .case ATMOS_SR(17)=="2B" && CHEM_NITR=="Y" && CHEM_SULPC=="Y"
         .check "Input LBCs include nitrate"  L LNITRLBC_IN Y N  
       .caseend
       .blockend
     .caseend
     .case  UPD97=="Y"
       .block 1
       .check "Input LBCs include PC2" L LPC2_LBC Y N
       .blockend
     .caseend
   .caseend
   .gap
.panend   
.comment ATMOS_SR(31) ATMOS_SR(32) set on exit for all configurations.
.set_on_closure "Hidden variable: LBC section 31 - Is this an atmosphere LAM model" ATMOS_SR(31)
.set_on_closure "Hidden variable: LBC section 32 - Is this an atmosphere configuration" ATMOS_SR(32)

