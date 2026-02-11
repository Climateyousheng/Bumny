.include_begin 3
   .procs {user_progs %1 ; # set USRP_COUNT(%1) USRP_ITEM USRP_NAME} 
   .invisible USRP_COUNT(%1)==0
      .text "You have no user-prognostic fields" L
   .invisend 
   .invisible USRP_COUNT(%1)!=0
     .text "All user-prognostic fields must be initialised by the reconfiguration."  L
     .gap
     .invisible %2RECON=="N"
       .text "Fields cannot be configured as the reconfiguration is off!" L
       .text "Correct this." L
     .invisend
     .invisible %2RECON=="Y"
       .textw "Elsewhere, you have specified that the reconfiguration is on." L
     .invisend
     .gap
     .table progs "Specify Initialisation Option" top h USRP_COUNT(%1) 12 NONE
       .index USRP_ITEM USRP_ITEM
       .index USRP_NAME USRP_ITEM
       .index USRP_OPTN_%2 USRP_INDEX_%2
       .index USRP_CONST_%2 USRP_INDEX_%2
       .index USRP_FILE_%2 USRP_INDEX_%2
       .element "Item" USRP_ITEM USRP_COUNT(%1) 6 out
       .element "NAME" USRP_NAME USRP_COUNT(%1) 36 out
       .element "Option" USRP_OPTN_%2 USRP_COUNT(%1) 8 in
       .element "If 6: CONSTANT" USRP_CONST_%2 USRP_COUNT(%1) 12 in
       .element "If 7: NAMED FILE ON TARGET MACHINE" USRP_FILE_%2 USRP_COUNT(%1) 80 in
    .tableend
    .textw "Valid option codes are:"  L
    .textw "   1   Initialise from the field in the START dump."  L
    .textw "   2   Initialise from User Ancillary File (special item numbers no longer required)." L
    .textw "   3   Set to Zero."  L
    .textw "   4   Set to missing data."  L
    .textw "   5   Initialise Tracer data from a Tracer File." L
    .textw "   6   Set to a specified constant value. Specify a real number, it will be converted to an integer if required."  L
    .textw "   7   Initialise from a single-time field on a named file (in ancillary file format)"  L
    .textw "          Give the full pathname of a file on the target machine."  L
    .gap
  .invisend
  .textw "Push RECON to specify the reconfiguration options" L
  .textw "Push USER to specify user-preSTASHmaster files" L
  .pushnext "RECON" %3_InFiles_Start
  .pushnext "USER" %3_STASH_UserDiags
  .set_on_closure "Hidden variable: Automatically set to number of user prognostics" USRP_COUNT(%1)
.include_end
