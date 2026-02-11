 .winid "atmos_Science_Section_Electr"
.title "Section 21: Thunderstorm Electrification"
.wintype entry

.panel
   .gap
   .block 1
   .case ATMOS_SR(4)!="0A"
     .check "Include prognostic graupel" L MCRGRPUP T F
     .gap
     .case MCRGRPUP=="T"
       .block 2
       .check "Include thunderstorm electrification scheme" L LUSE_ELECTR T F
         .gap
         .case LUSE_ELECTR=="T"
           .block 3
           .basrad "Select method used to generate lightning" L 2 v ELMETHOD
               "Graupel Water Path Scheme" 1
               "McCaul et al (2009) scheme" 2
           .gap
           .case ELMETHOD=="2"
             .entry "Lightning-graupel flux factor for McCaul et al (2009) scheme" L K1_EL
             .entry "Lightning-storm ice factor for McCaul et al (2009) scheme" L K2_EL
           .caseend
           .case ELMETHOD=="1"
             .entry "Lightning-graupel water path gradient for graupel water path scheme" L G1
             .entry "Intercept for graupel water path scheme " L G2
           .caseend
           .blockend
       .caseend
     .blockend
     .caseend
   .caseend
   .gap
   .textw "Push LSRain for Large Scale Precipitation section" L
   .blockend
   .pushnext "LSRain" atmos_Science_Section_LSRain 
.panend
