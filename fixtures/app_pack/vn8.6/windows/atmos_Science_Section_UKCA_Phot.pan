.winid "atmos_Science_Section_UKCA_Phot"
.title "UKCA Photolysis Scheme"
.wintype entry

.panel
  .gap
  .case ATMOS_SR(34)!="0A" && I_UKCA_CHEM!=0 && I_UKCA_CHEM!=1
    .basrad "Select Photolysis scheme" L 3 v LUKCAPHOTO
        "2D Photolysis Scheme" 1
        "FASTJ Photolysis Scheme" 2
        "FASTJX Photolysis Scheme" 3
    .gap
    .block 1
      .case LUKCAPHOTO==1
        .entry "Directory pathname for the 2D photolysis rates" L PHOT2DDIR 50
      .caseend
      .case LUKCAPHOTO!=1
        .entry "Directory pathname for Fast-J spectral file" L JVSPECDIR 50
        .entry "Filename for Fast-J spectral file" L JVSPECFILE 50
      .caseend
      .case LUKCAPHOTO==3
        .entry "Filename for FASTJ-X scatter file" L JVSCATFILE 50
    .blockend
    .gap
    .block 1
        .basrad "Number of wavelengths to be used" L 3 h FASTJXWAVEL 
            "8" 8 
            "12" 12 
            "18" 18
    .blockend
    .gap
    .block 1
        .entry "Cutoff Pressure (Pa) for tabulated Photolysis" L FASTJXCUTOFF 10
    .blockend
    .block 1
        .basrad "Method above cut-off level" L 3 v FASTJXMODE
            "Use Lookup Tables" 1 
            "Use Lookup+FastJX" 2 
            "Use only FastJX" 3
      .caseend
    .blockend 
  .caseend
  .gap
  .textw "Push UKCA to go to the parent window" L
  .pushnext "UKCA" atmos_Science_Section_UKCA
 .panend
