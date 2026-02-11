.winid "atmos_InFiles_OtherAncil_Orog"
.title "Orography"
.wintype entry

.panel
   .text "Define the use of the Orography ancillary file and fields" L
   .block 0
       .entry "Enter directory or Environment Variable" L APATH(10)
       .entry "and file name" L AFILE(10)
   .invisible ARECON=="N"
     .text "Fields cannot be configured as the reconfiguration is off!" L
   .invisend
   .gap   
   .check "The ancillary orography to be configured" L ACON(2) C N
   .gap
   .check "The ancillary standard deviation of orography to be configured" L ACON(3) C N
   .textw "Note: the squared gradient fields are also configured if required, see help" L
   .gap
   .invisible OROGR!="0"
      .textw "Your choice of boundary layer scheme includes orographic roughness" L
   .invisend
   .invisible OROGR=="0"
      .textw "Your choice of boundary layer scheme excludes orographic roughness" L
   .invisend
   .gap
   .check "The ancillary orographic roughness fields to be configured" L ACON(46) C N
   .gap 
   .invisible IUSEORCORR=="2"
     .textw "Your choice of orographic correction in SW radiation requires orographic gradient fields" L
   .invisend
   .invisible IUSEORCORR!="2"
     .textw "Your choice of orographic correction in SW radiation excludes orographic gradient fields" L
   .invisend
   .check "The orographic gradient fields to be configured" L ACON(155) C N     
   .check "The unfiltered orography to be configured" L ACON(188) C N
   .gap
   .textw "Elsewhere, this model is defined as [get_variable_value MODEL_TYPE(OCAAA)]" L
   .blockend
   .gap
   .case (OCAAA==2)&&(ACON(2)== "C" )
     .entry "Width of blending zone" L OBLENDW
     .table OBWGT "Blending Zone Table" top h OBLENDW 10 NONE
         .elementautonum "Number from outside" 1 OBLENDW 10
         .element "Blending weight" OBLENDWGT OBLENDW 12 in
     .tableend
   .caseend
.panend
.set_on_closure "Set ACON(155)" ACON(155)


   


