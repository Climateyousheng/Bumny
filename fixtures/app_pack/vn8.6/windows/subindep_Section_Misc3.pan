.winid "subindep_Section_Misc3"
.title "Miscellaneous Sections"
.wintype entry

.panel

.comment   .text "Section 84 is hardwired to 1A" L
   .text "Section 96 is hardwired to 1C" L
   .gap            
   .basrad "Choose version of section 95" L 3 v INDEP_SR(95)
            "No IO service routine section" 0A
            "2A, Standard, portable IO" 2A
            "2B, Dev. portable IO" 2B
   .gap   
   .text "Section 96 options" L    
   .entry "GCOM collectives limit" L GCOMCLMT 10   
   .gap
   .basrad "Summation Type" L 3 v GLOBALSUM
            "Old Reproducible" 1
            "Double-Double Precision Reproducible" 2
            "Fast but Non-Reproducible" 3
   .case GLOBALSUM=="3"
       .check "Single precision solver" L S_DP_HLM Y N
   .caseend
   .basrad "Choose version of section 97" L 2 v INDEP_SR(97)
            "3A Timer code." 3A
            "4A Dummy timer code if you are running without timer." 4A
   .case INDEP_SR(97)!="4A"
      .check "Subroutine timer diagnostics in this run." L TIMER Y N
   .caseend
   .gap
   .basrad "Choose version of section 98" L 2 v INDEP_SR(98)
            "No Open MP service included" 0A
            "1A Includes direct use of Open MP" 1A               
   .gap

.panend


