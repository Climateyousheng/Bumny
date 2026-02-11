.winid "smcc_Model_Coupling"
.title "Sub Model Inclusion Switches"
.wintype entry
.panel
  .gap
  .text "Include your choice from the following models:" L
  .gap
     .block 1
     .check "Atmosphere" L ATMOS T F
     .check "JULES Surface Model" L JULES T F
     .check "NEMO" L NEMO T F
     .check "CICE" L CICE T F
     .blockend  
   .gap
   .textw "Allowed choices:" L
     .block 1
     .textw "Atmosphere, NEMO or CICE on its own" L
     .textw "Atmosphere, NEMO and CICE together" L
     .textw "NEMO and CICE together without Atmosphere" L
     .textw "JULES must be used in conjunction with Atmosphere" L
     .blockend
   .gap
   .invisible ARECON == "Y"
     .textw "This job has reconfiguration switched ON" L
   .invisend 
   .invisible ARECON == "N"
     .textw "This job has reconfiguration switched OFF" L   
   .invisend
   .gap

.panend

