.include_begin 1
  .invisible AMEAN(%1)=="Y"&&ADUMP(%1)==1
    .text "For regular dumping with climate meaning" L
    .entry "Specify the number of meaning periods to use (1 to 4)" L ANMP(%1)
    .gap
    .text "Define requirement for your meaning sequence." L
    .text "Specify period lengths in terms of number of restart dumps for period 1" L
    .text "and then in multiples of the previous period" L
    .text "Specify frequencies as 'every nth period-m mean'. Set to 0 if not required" L
    .table Means_%1 "Means" top h ANMP(%1) 4 NONE
      .element "Period length     " AMP(*,%1) ANMP(%1) 19 in
      .element "PP files Required Y/N" AMPP(*,%1) ANMP(%1) 22 in
      .case (AUTOPP=="Y")&&(SYSTM!=0)
        .element "PP files archived Y/N" AMPA(*,%1) ANMP(%1) 22 in
      .caseend
    .tableend
    .invisible (AUTOPP!="Y")||(SYSTM==0)
      .textw "Automatic archiving has been disabled elsewhere." L
    .invisend
  .invisend

  .invisible (AMEAN(%1)=="Y")&&(ADUMP(%1)==3)
    .text "For Gregorian-calendar climate meaning" L
    .text "Define requirement for your meaning sequence." L
    .entry "Specify the number of meaning periods to use (1 to 3)" L ANMPRM(%1)
    .text "Specify frequencies as 'every nth period-m mean'. Set to 0 if not required" L
    .table Means1_%1 "Means" top h ANMPRM(%1) 3 NONE
      .element "Type  " GREGCPDS ANMPRM(%1) 7 out
      .element "PP files Required Y/N" AMPPRM(*,%1) ANMPRM(%1) 22 in
      .case (AUTOPP=="Y")&&(SYSTM!=0)
        .element "PP files archived Y/N" AMPARM(*,%1) ANMPRM(%1) 22 in
      .caseend
    .tableend
    .invisible (AUTOPP!="Y")||(SYSTM==0)
      .textw "Automatic archiving has been disabled elsewhere." L
    .invisend
  .invisend
  .invisible AMEAN(%1)!="Y"&&ADUMP(%1)!=2
    .textw "Climate meaning has not been selected" L
  .invisend
  .gap
  .invisible ADUMP(%1)==2
    .text "For irregular dumping" L
    .text "Define the dump times from basis time." L
    .basrad "Using units" L 3 h ADTU(%1)
            "Timesteps" T
            "Hours"     H
            "Days "     DA
    .entry "Number of dumps (up to [get_variable_value NDUMPT])" L ADTLEN(%1)
    .table Dumps_%1 "Dumps" top h ADTLEN(%1) 10 INCR
      .element "Dumps at" ADT(*,%1) ADTLEN(%1) 19 in
    .tableend
    .gap
  .invisend
.include_end



