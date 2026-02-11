.winid "atmos_Domain_Horiz"
.title "Horizontal"
.wintype entry

.panel
   .basrad "Select Area Option" L 6 v OCAAA 
            "Global Model       " 1 
            "Limited Area Model (Classic style)" 2 
            "Limited Area Model (Cyclic boundary conditions - EW only)" 3
            "Limited Area Model (Cyclic boundary conditions - EW and NS)" 4
            "Single Column Model (see help)" 5
            "Site Specific Forecast Model (SSFM) (see help)" 6
   .gap         
   .check "Variable resolution grids" L LVARGRID Y N        
   .invisible LVARGRID=="Y"
     .block 1
     .entry "Directory:" L PATHVARGRD
     .entry "Variable Resolution Horizontal Grid File" L FILEVARGRD
     .gap
     .blockend
   .invisend
   .case OCAAA==1
      .textw "Global Model" L
      .block 1
         .entry "Number of Columns ( X - Direction )" L NCOLSAG
         .entry "Number of Rows    ( Y - Direction )" L NROWSAG
      .blockend
   .caseend
   .gap
   .case OCAAA==2||OCAAA==3||OCAAA==4
      .textw "Limited Area" L
      .block 1
         .entry "Number of Columns" L NCOLSAL
         .entry "Number of Rows" L NROWSAL
         .entry "Column Spacing" L EWSPACEA
         .entry "Row Spacing" L NSSPACEA
         .entry "First Latitude" L FRSTLATA
         .entry "First Longitude" L FRSTLONA
         .entry "North Pole Latitude" L POLELATA
         .entry "North Pole Longitude" L POLELONA
         .entry "Frame size" L NRIMSTODO
         .check "Mesoscale Model" L MESO Y N
      .blockend
   .caseend
   .gap
.comment   .case OCAAA==5
   .case 1==2
      .text "Single Column Model (Specify in degrees)" L
      .block 1
         .entry " Latitude" L LATS
         .entry " Longitude" L LONS
      .blockend
   .caseend
   .gap
   .entry "Number of Land Points" L NLAND
   .gap
   .case ATMOS_SR(12)!="0A"
     .text "Extended halo size of prognostic fields" L
     .block 1
       .entry "Halo size for EW boundaries of PEs" L EW_HALO
       .entry "Halo size for NS boundaries of PEs" L NS_HALO
     .blockend
     .gap
     .check "Do you require bit reproducible results whatever size the extended haloes are set to?" L LHALREPROD T F
     .text "N.B. This increases the cost of the code." L
   .caseend
.panend

