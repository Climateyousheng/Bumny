.include_begin 3
.procs {} {abandonProfile %1 usage %2} {update_STASH %1 usage %2}

.comment ======================================================================
.comment  When adding/removing profile variables, remember to change the
.comment  list in stash.tcl that perform functions to copy/remove profiles.
.comment ======================================================================

   .entry "Usage profile name" L USEPRO_%1(%2)
   .basrad "Specify the final destination of the diagnostic" L 5 v LOCN_%1(%2)
           "Dump store with user specified TAG, specify tag below." 1
           "Secondary store with user specified TAG, specify tag below." 6
           "Dump store with climate mean TAG. Specify meaning periods below" 2
           "PP-file. Specify stream below" 3
           "Send mean diagnostic direct to mean PP-file (climate mean sections only) " 5
           
   .gap        
   .invisible LOCN_%1(%2)==1||LOCN_%1(%2)==6
     .block 1
         .entry "Specify TAG for user tagged diagnostics" L TAG_%1(%2)
     .blockend    
   .invisend
   .invisible LOCN_%1(%2)==2
     .block 1
         .check "Tagged for climate mean period 1" L TAGCM1_%1(%2) T F
         .check "Tagged for climate mean period 2" L TAGCM2_%1(%2) T F
         .check "Tagged for climate mean period 3" L TAGCM3_%1(%2) T F
         .check "Tagged for climate mean period 4" L TAGCM4_%1(%2) T F        
     .blockend    
   .invisend
   .invisible LOCN_%1(%2)==3
     .block 1
         .entry "Specify PP output unit (unit 60-69 for stream 0-9;151 for stream PP10)" L IUNT_%1(%2)
     .blockend    
   .invisend
   .gap
   .gap
   .textw "Elsewhere you have set up climate meaning as follows:" L
    .invisible AMEAN(%3)=="Y"&&ADUMP(%3)==1
      .textw "Climate meaning is specified" L
      .textw "Number of climate mean periods:  [get_variable_value ANMP(%3)]" L 
    .invisend     
    .invisible AMEAN(%3)!="Y"&&ADUMP(%3)!=1
      .textw "Without climate meaning specified" L
    .invisend     
   .textw "Push FILES to see settings of PP-files to sub-models and reinitialisation." L
   .pushand "FILES" subindep_PostProc_PPInit
.include_end



