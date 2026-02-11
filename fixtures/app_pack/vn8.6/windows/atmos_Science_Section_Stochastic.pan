.winid "atmos_Science_Section_Stochastic"
.title "Section 35: Stochastic Schemes"
.wintype entry

.panel
  .gap
  .basrad "Choose the relevant section release" L 2 v ATMOS_SR(35)
    "<0A> Stochastic Scheme not included." 0A
    "<1A> Stochastic Scheme included." 1A
  .case  ATMOS_SR(35)!="0A" 
    .check "Random Parameters" L LRPRM Y N
    .check "Stochastic Kinetic Energy Backscatter 2" L LSKEB2 Y N
    .case ( LRPRM == "Y" || LSKEB2 == "Y" )
      .basrad "Use of seed file" R 3 v STPHSEED
         "Do not use seed file" 0
         "Read seed from file"  1
         "Write seed from file" 2
      .case STPHSEED!="0"
        .block 1
        .entry "Directory:" L RSEED_PATH
        .entry "File:" L RSEED_FILE
        .blockend
      .caseend
    .caseend
  .caseend
  .gap
  .pushnext "RP" atmos_Science_Section_Stochastic_RP
  .pushnext "SKEB2" atmos_Science_Section_Stochastic_SKEB
.panend
