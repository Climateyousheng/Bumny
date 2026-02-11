.winid "atmos_Science_Physics"
.title "General Physics"
.wintype entry

.panel
   .block 1
     .case ATMOS_SR(3)!="0A"
      .entry "Number of boundary layer levels" L NBLLV
     .caseend
     .case ATMOS_SR(8)!="0A"
      .entry "Number of deep soil temperature levels (excluding surface)," L NDSLV
     .caseend
     .entry "Number of cloud levels used in radiation" L CLRAD
   .blockend
   .gap
   .basrad "Define specification of CO2 absorption." L 3 v CO2OPT
           "Simple method with fixed value." 1
           "Complex method allowing linear and/or exponential variation." 2
           "From the interactive carbon cycle." 3
   .gap        
   .invisible  CO2OPT==1
     .block 2
        .entry "CO2 Mass Mixing Ratio for whole run (kg/kg)" L CO2START 
     .blockend
   .invisend
   .invisible  CO2OPT==2
     .text "You can define up to 50 years to use as turning points in the calculation. See help." L
     .entry "Number of designated years for linear interpolation. 1 minimum." L CO2NGASL
     .table gvals5 "Years and CO2 MMRs for linear interpolation." top h CO2NGASL 5 INCR 
       .elementautonum "No." 1 CO2NGASL 3
       .element "Years in ascending order." CO2YGASL 5 35 in
       .element "CO2 MMRs at those years." CO2VGASL 5 35 in
     .tableend
     .entry "Number of designated years for subsequent exponential increase. See help." L CO2NGASR
     .table grate5 "Years and % compound growth of CO2 pa in subsequent years." top h CO2NGASR 5 INCR 
         .elementautonum "No." 1 CO2NGASR 3
         .element "Years in ascending order." CO2YGASR 5 35 in
         .element "CO2 % compound growth pa from this year." CO2RGASR 5 35 in
     .tableend
   .invisend
   .invisible  CO2OPT==3
     .block 2
       .basrad "CO2 initialization option:" L 2 h CO2INITOPT
           "From the dump." 1
           "Define a constant value." 2
       .case  CO2INITOPT==2 
           .entry "Initial CO2 Mass Mixing Ratio (kg/kg) " L CO2INITVAL
       .caseend
       .basrad "CO2 emissions:" L 2 h CO2EMISOPT
           "Not using emissions." 0
           "Using Emissions from ancillary file." 1
     .blockend
   .invisend 
   .textw "Push CO2E for CO2 Emissions (Carbon Cycle Only)" L
   .pushnext  "CO2E" atmos_InFiles_PAncil_CO2Emis
.panend




