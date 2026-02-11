.winid "atmos_InFiles_Start"
.title "Specification of the start dump"
.wintype entry

.panel
   .case GEN_SUITE == 0
     .textw "Elsewhere, you have specified the start date for all sub-models as" L
     .block 1
       .entry "Year" L SRYR
       .entry "Month" L SRMO
       .entry "Day" L SRDA
       .entry "Hour" L SRHR
       .entry "Minute" L SRMI
       .entry "Second" L SRSE
     .blockend
   .caseend
   .gap
   .case ATMOS=="T"
     .check "Run Reconfiguration" L ARECON Y N
   .caseend
   .case ARECON=="Y"
     .basrad "Type of vertical interpolation" L 2 h VINT
       "Linear" 1
       "Linear with no extrapolation" 2
     .block 1
     .check "The dump is in ECMWF GRIB format" L AGRIB Y N 
     .basrad "Choose horizontal interpolation method" L 2 h AINTERPOL
        "Bilinear." 1
        "Area weighted." 2
        .text "Specify the input dump for the Reconfiguration" L 
     .colour red GEN_SUITE==1
        .entry "Directory name or DATAW" L PATH20 
        .entry "and file name" L FILE20 
     .colourend
     .blockend
   .caseend
   .gap
   .textw "Elsewhere, you have specified:" L
   .basrad "Dumping packing option" L 3 v ADPACK(1)
            "STASHmaster controlled packing for diagnostic and primary fields." 1
            "Unpacked primary fields. STASHmaster-packed diagnostics." 2
            "Unpacked primary and diagnostic fields." 3
            
   .gap 
   .invisible ARECON=="N" 
     .text "Specify the input dump for the atmosphere model" L 
   .invisend 
   .invisible (ARECON=="Y")&&(RUN_ATM=="N") 
     .text "Specify the output dump for the Reconfiguration" L 
   .invisend 
   .invisible (ARECON=="Y")&&(RUN_ATM=="Y") 
     .text "Specify the Reconfiguration output/atmosphere model input dump" L 
   .invisend 
   .block 0 
     .colour red GEN_SUITE==1 
       .entry "Enter directory or Environment Variable" L PATH21 
       .entry "and file name" L FILE21 
     .colourend 
   .blockend 
   .gap         
  .textw "Push Recon_Gen for general reconfiguration options" L   
  .textw "Push Recon_QC for reconfiguration quality control" L
  .pushnext "Recon_Gen" subindep_Recon_Gen
  .pushnext "Recon_QC" subindep_Recon_QC
.panend


