.winid "atmos_Config_Tracer"
.title "Atmospheric Tracers"
.wintype entry
.procs {} {} {set_tracers ; # set ATMOS_SR(33)}
.panel

   .check "Do you want to include tracers in the atmosphere?" L USE_TCA Y N
   .case USE_TCA=="Y"
     .block 1
     .text "Mark the STASH tracer items to be included - these will have STASHmaster entries from section 33"  L
     .text "The format of the left column is :-  <ITEM(TRACER NO: CONVENTIONAL USE)>"  L 
     .textw "For the middle column you should enter:-" L 
     .text "     0 - Do not include" L   
     .text "     1 - Include from dump" L
     .invisible OCAAA!=2
       .textw "Note: LBC tracers cannot be used without the Limited Area Model (Classic) in use" L
     .invisend
     .blockend
     .gap     
     .check "Turn on free tracer LBCs" L ATMOS_SR(36) 1A 0A
     .block 1
     .text "The right column indicates which tracers have lateral boundary condition data in the LBC input file." L 
     .textw "For the right column you should enter:" L
     .text "     0 - No LBC data" L  
     .text "     1 - LBC data present" L  
     .blockend
     .table tracers "Tracers" top h 150 10 NONE
       .element "Tracers available" TCA_DEF 150 23 out
       .element "Select" TCA 150 29 in
       .case (ATMOS_SR(36)=="1A")&&(OCAAA==2)
         .element "LBCs input" LBC_TCA 150 23 in
       .caseend
       .case IMKBC==1
         .element "MakeBCs input" MKBC33_TCA 150 23 in
       .caseend
     .tableend
     .gap
     .check "With boundary layer mixing of tracers" L TRAM Y N
   .caseend
   .invisible ATMOS_SR(17)!="0A" || ATMOS_SR(34)!="0A"
      .textw "Chemistry is included. The number of tracer levels must equal the number of model levels" L
   .invisend
   .gap
.panend
.set_on_closure "Hidden variable: Tracers section 33 - Are prognostic tracers using" ATMOS_SR(33)

