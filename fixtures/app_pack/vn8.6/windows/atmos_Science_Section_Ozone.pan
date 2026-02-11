.winid "atmos_Science_Section_Ozone"
.title "Section: Ozone"
.wintype entry

.panel
  .basrad "Select option for the ozone treatment in radiation" L 3 v OZINT
          "Impose prescribed 2D field" 2
		  "Impose prescribed 3D field" 1
          "Match ozone tropopause in ancillary to terminal tropopause conserving the column mass" 5
  .gap
  .case (OZINT==1||OZINT==2)&&(OCAAA==1) 
    .check "Use Cariolle scheme to calculate ozone tracer" L LUCARIOLLE Y N
    .case LUCARIOLLE=="Y" 
      .block 1
      .check "Use Cariolle ozone tracer in radiation scheme" L LUOZNINRAD Y N
      .blockend
    .caseend
  .caseend
          
.panend



