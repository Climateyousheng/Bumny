.winid "atmos_STASH_Macros_VAR"
.title "VAR interface macro"
.wintype entry

.panel

  .basrad "LS fields macro:" L 4 v VARINTM
                  "No Macro" 0
                  "Standard Macro (with PF Physics)" 1
                  "Development Macro A" 2
                  "Development Macro B" 3

  .case VARINTM!=0
    .gap
    .check "Include aerosol (90)" L VARAERO Y N
    .check "Include qcf, qcl (12,254)" L VARQ Y N
    .check "WGDOS pack fields" L PACKVAR Y N
    .gap
    .basrad "" L 2 v VARINTFC
                    "3D-Var interface" 3
                    "4D-Var interface" 4
    .gap
    .case VARINTFC==3
      .entry "Length of data assimilation cycle (hours)" L VARCYCLEN 5
    .caseend
    .gap
    .case VARINTFC==4
      .textw "Time profile for fieldsfiles from which LS states will be generated:" L
      .gap
      .block 1                      
        .basrad "Units:" L 2 h VARUNITS
            "Hours" H
            "Timesteps" T
        .entry "Starting" L VARSTART
        .entry "Ending"   L VAREND
        .entry "Interval" L VARINTVL
      .blockend  
    .caseend
    .gap
    .block 0
      .textw "NOTE: Fields will be written to unit 150 (PPVAR). For the 4D-Var" L
      .textw "interface, the output stream will be reinitialised and the files written" L
      .textw "to $DATAM/*ca_*." L
    .blockend  
  .caseend
  .gap
.panend
