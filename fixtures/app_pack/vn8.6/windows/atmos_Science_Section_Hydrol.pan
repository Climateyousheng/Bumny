.winid "atmos_Science_Section_Hydrol"
.title "Section 8 : Surface Hydrology"
.wintype entry
.panel
   .basrad "Choose version" L 2 v ATMOS_SR(8)
            "Surface Hydrology not included" 0A
	    "<8A> Using the JULES land surface model" 8A
   .gap
   .check "Run without a Hydrology Scheme" L L_HYDROLOGY Y N
   .case ATMOS_SR(8)!="0A" && L_HYDROLOGY!="Y"
     .block 1
       .check "Downward flow for super saturated soil water" L LSOILSATDN Y N   
     .blockend
     .case LPDM=="N"
         .check "Large-scale hydrology scheme (LSH)" L LTOP Y N
     .caseend
     .case LTOP=="N"
       .check "Probability Distributed Moisture hydrology scheme (PDM)" L LPDM Y N
     .caseend
     .case LPDM=="Y"
       .block 1
         .entry "Shape factor B for PDM" L BPDM 15
         .entry "Assumed soil depth in PDM (m)" L DZPDM 15
       .blockend
     .caseend
   .caseend
   .gap
   .textw "Push SMOW to see settings of soil-moisture and snow-depth ancillary" L
   .textw "Push SOIL to see settings of soil-parameters ancillary" L 
   .textw "Push LSH to see settings for large-scale hydrology ancillaries" L
   .textw "Push BLAY to go to the Boundary Layer Section" L 
   .pushnext "SMOW" atmos_InFiles_PAncil_Soilm
   .pushnext "SOIL" atmos_InFiles_PAncil_Soil
   .pushnext "LSH" atmos_InFiles_PAncil_LSH
   .pushnext "BLAY" atmos_Science_Section_BLay
.panend
