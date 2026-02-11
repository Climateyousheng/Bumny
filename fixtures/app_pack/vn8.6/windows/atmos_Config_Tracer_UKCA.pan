.winid "atmos_Config_Tracer_UKCA"
.title "UKCA Tracers"
.wintype entry
.procs {fetch_tracers ; # available for selected switches} {} {set_ukcatca}

.panel
  .case ATMOS_SR(34)=="1A"
     .text "Mark the STASH UKCA_Tracer items to be included - these will have STASHmaster entries from section 34"  L
     .textw "For the middle column you should enter:-" L 
     .text "     0 - Do not include" L   
     .text "     1 - Include from dump" L
     .invisible OCAAA!=2
       .textw "Note: LBC tracers cannot be used without the Limited Area Model (Classic) in use" L
     .invisend
     .gap
     .check "Turn on UKCA tracer LBCs" L ATMOS_SR(37) 1A 0A
     .text "The right column indicates which UKCA tracers have lateral boundary condition data in the LBC input file" L 
     .textw "For the right column you should enter:" L
     .text "     0 - No LBC data" L  
     .text "     1 - LBC data present" L
     .table fetched_trc "UKCA_Tracers Available" top h N_UKCA_TMP 10 NONE
        .element "Tracers available" NAME_TMP N_UKCA_TMP 23 out
        .element "Select" VAL_TMP N_UKCA_TMP 29 in
        .case (ATMOS_SR(37)=="1A")&&(OCAAA==2)
          .element "LBCs input" VAL_TMP_LBC N_UKCA_TMP 23 in
        .caseend
       .case IMKBC==1
         .element "UKCA MakeBCs input" MKBC34_TMP N_UKCA_TMP 23 in
       .caseend
     .tableend
     .gap
  .caseend
  .textw "Push UKCA to go to the main UKCA window" L
  .pushnext "UKCA" atmos_Science_Section_UKCA
.panend
.gap
.set_on_closure "Hidden var: from temporary table to UKCA_TCA array " UKCA_TCA
.set_on_closure "Hidden var: from temporary table to UKCA_LBC array " UKCA_LBC
.set_on_closure "Hidden var: from temporary table to UKCA_LBC array " MKBC34_TCA


