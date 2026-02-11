.winid "subindep_Runlen"
.title "Run Time Info."
.wintype entry

.panel
   .invisible GEN_SUITE == 0 
      .text "Specify the date and time of the start dump(s)" L
   .invisend 
   .invisible GEN_SUITE != 0 
      .textw "The date and time for the start of the run is not required for generalised suite runs" L
   .invisend 
   .case GEN_SUITE == 0
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
   .invisible RUN_ATM=="N"
     .textw "Warning, elsewhere you have not requested \"Run Model\"" L
   .invisend
   .gap
   .text "Target run length (relative to basis time)" L
   .block 1
      .entry "Years" L ERYR
      .entry "Months" L ERMO
      .entry "Days" L ERDA
      .entry "Hours" L ERHR
      .entry "Minutes" L ERMI
      .entry "Seconds" L ERSE
   .blockend
.panend


