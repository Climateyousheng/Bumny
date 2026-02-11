.include_begin 1  

  .comment ===================================================================
  .comment ===        %1 is the sub-model index.                           ===
  .comment ===================================================================

  .basrad "Select dumping and meaning option" L 4 v ADUMP(%1)
            "No dumping or climate meaning" 0
            "Regular frequency dumps with possible meaning sequence" 1
            "Irregular dump times - no climate meaning possible" 2
            "Regular frequency dumps for Gregorian-calendar Meaning" 3
  .gap
    .basrad "Select dumping packing option" L 3 v ADPACK(%1)
            "STASHmaster controlled packing for diagnostic and primary fields." 1
            "Unpacked primary fields. STASHmaster-packed diagnostics." 2
            "Unpacked primary and diagnostic fields." 3
  .gap
  .invisible ADUMP(%1)==1
    .basrad "Using Unit" L 3 h ADUMPU(%1)
            "Days" DA    
            "Hours" H  
            "Timesteps" T    
    .entry "Restart dumps every" L ADUMPP(%1)
    .invisible AMEAN(%1)=="Y"
      .textw "Review the climate meaning follow-on panel and STASH climate mean" L
      .textw "diagnostic requests when modifying the dump period" L
    .invisend
    .invisible AMEAN(%1)!="Y"
      .gap
      .gap
    .invisend
    .block 1
      .case (AUTOPP=="Y")&&(SYSTM!=0)
        .entry "archiving every (restart dump occurrences)" L ADUMPA(%1)
        .entry "...starting at the  (nth restart dump)" L ADMPAS(%1)
      .caseend
    .blockend
  .invisend 
  .invisible ADUMP(%1)==3
    .entry "Restart dumps every (1 to 24 hours)" L ADUMPPRM(%1)
    .block 1
      .case (AUTOPP=="Y")&&(SYSTM!=0)
        .basrad "archiving every " L 3 h ADUMPARM(%1)
            "Month" M
            "Season" S
            "Year" Y
      .caseend
    .blockend
  .invisend 
  .case ADUMP(%1)==1||ADUMP(%1)==3
    .invisible (AUTOPP!="Y")||(SYSTM==0)
       .block 1
         .textw "Automatic archiving disabled elswehere." L
       .blockend
    .invisend
    .block 1
      .text "Set frequencies to 0 for never" L
      .gap
      .check "Defining a meaning sequence" L AMEAN(%1) Y N 
    .blockend
    .case AMEAN(%1)=="Y"
      .block 2  
        .text "Using reference date for meaning" L
        .entry "Year" L ARYR(%1)
        .entry "Month" L ARMO(%1)
        .entry "Day" L ARDA(%1)
        .entry "Hour" L ARHR(%1)
        .entry "Minute" L ARMI(%1)
        .entry "Second" L ARSE(%1)
      .blockend   
    .caseend
  .caseend 
  .gap
.include_end
