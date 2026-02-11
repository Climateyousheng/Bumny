  .include_begin 2
.procs {} {abandonProfile %1 time %2} {update_STASH %1 time %2}
.comment ======================================================================
.comment  When adding/removing profile variables, remember to change the
.comment  list in stash.tcl that perform functions to copy/remove profiles.
.comment ======================================================================
   .entry "Time profile name" L TIMPRO_%1(%2)
   .basrad "Specify time processing required " L 7 v ITYP_%1(%2)
           "No time processing. Field valid at output timesteps." 1
           "Time accumulation, specify accumulation period and sampling frequency below" 2
           "Time mean, specify meaning period and sampling frequency below" 3
           "Time series, specify recycling period and sampling frequency below" 4
           "Special daily-mean time series. Specify recycling period below." 8
           "Maximum value in a period, specify period and sampling frequency below" 5
           "Minimum value in a period, specify period and sampling frequency below" 6
   .case ITYP_%1(%2)!=1
         .invisible (ITYP_%1(%2)==1)
           .text "Define the period for time processing:" L   
         .invisend
         .invisible (ITYP_%1(%2)==2)
           .text "Define the period over which to accumulate. Use -1 for indefinite." L   
         .invisend
         .invisible (ITYP_%1(%2)==3)
           .text "Define the meaning period:" L   
         .invisend
         .invisible (ITYP_%1(%2)==4)||(ITYP_%1(%2)==8)
           .text "Define the recycling period for the time series:" L   
         .invisend
         .invisible (ITYP_%1(%2)==5)
           .text "Define the period over which to generate the maximum:" L   
         .invisend
         .invisible (ITYP_%1(%2)==6)
           .text "Define the period over which to generate the minimum:" L   
         .invisend
         .block 2
           .basrad "Time units " L 4 h UNT1_%1(%2) 
                   "Days" DA  "Hours" H  "Dump periods" DU  "Timesteps" T
           .entry "Sampling period" L INTV_%1(%2)
         .blockend
         .text "Define the sampling frequency to make up the above:" L
         .block 2
           .basrad "Time units " L 4 h UNT2_%1(%2) 
                   "Days" DA  "Hours" H  "Dump periods" DU  "Timesteps" T
           .entry "Frequency (every)" L ISAM_%1(%2)
           .entry "Sampling offset (0 for no offset) " L IOFF_%1(%2)
         .blockend
   .caseend
   .text "Specify the output times for the diagnostic" L
   .invisible IOPT_%1(%2)!=2||(IOPT_%1(%2)==2&&ITYP_%1(%2)==1)
   .invisend 
   .invisible IOPT_%1(%2)==2&&ITYP_%1(%2)==2
      .textw "For accumulation to work with 'Specified List' you must choose indefinite period above." L
   .invisend 
   .invisible IOPT_%1(%2)==2&&ITYP_%1(%2)!=1&&ITYP_%1(%2)!=2
      .textw "Your time processing choice means you must specify 'Regular Intervals' below" L
   .invisend 
   .invisible IOPT_%1(%2)==3&&ITYP_%1(%2)!=1&&ITYP_%1(%2)!=2&&ITYP_%1(%2)!=3
      .textw "Your time processing choice means you must specify 'Regular Intervals' below" L
   .invisend 
   .basrad "Specification type " L 3 h IOPT_%1(%2)
           "Regular intervals" 1
           "Specified List " 2
	   "Regular intervals Start/stop date" 3
   .basrad "Time units " L 4 h UNT3_%1(%2) 
           "Days" DA  "Hours" H  "Dump periods" DU  "Timesteps" T
   .invisible IOPT_%1(%2)==1||(ITYP_%1(%2)!=1&&ITYP_%1(%2)!=2)||IOPT_%1(%2)==3
     .invisible IOPT_%1(%2)==1||(ITYP_%1(%2)!=1&&ITYP_%1(%2)!=2&&IOPT_%1(%2)!=3)
       .block 2
         .entry "Starting " L ISTR_%1(%2)
         .entry "Ending   " L IEND_%1(%2)
       .blockend
       .text "Set ending to -1 for the whole run" L
     .invisend
       .block 2
     .entry "Frequency (every)" L IFRE_%1(%2)
       .blockend
   .invisend
   .invisible IOPT_%1(%2)==3
     .block 6
     .textw "" L
       .table dateStrt%1 "Start Date" top h 1 1 NONE
         .element "Year" ISDTY_%1(*,%2)  1 8 in
         .element "Month" ISDTM_%1(*,%2)  1 8 in 
         .element "Day" ISDTD_%1(*,%2)  1 8 in
         .element "Hour" ISDTH_%1(*,%2)  1 8 in
       .tableend
       .table dateEnd%1 "End Date" top h 1 1 NONE
         .element "Year" IEDTY_%1(*,%2)  1 8 in
         .element "Month" IEDTM_%1(*,%2)  1 8 in 
         .element "Day" IEDTD_%1(*,%2)  1 8 in
         .element "Hour" IEDTH_%1(*,%2)  1 8 in
       .tableend
      .blockend
     .invisend
     .invisible IOPT_%1(%2)==2&&(ITYP_%1(%2)==1||ITYP_%1(%2)==2)
       .block 2
         .entry "Number of times in the list " L ITIMES_%1(%2)
       .blockend
       .block 6
       .text "" L                                         
       .table levels16%1 "Output time list" top h ITIMES_%1(%2) 10 INCR
         .elementautonum "No." 1 10 3
         .element "Values need to be sorted" ISER_%1(*,%2) 10 25 in
       .tableend
       .blockend
     .invisend
  .include_end




