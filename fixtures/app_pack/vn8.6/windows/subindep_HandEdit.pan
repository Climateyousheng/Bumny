.winid "subindep_HandEdit"
.title "Hand edits to be applied on processing"
.wintype entry

.panel
    .text "Specify full path to hand edit scripts to be applied to the processed output." L
    .text "Alternatively type a command to be applied to the processed output" L
    .gap
    .table hedits "Hand edits" top h 25 10 TIDY
      .elementautonum "Script" 1 25 6
      .element "Full path name                            " HEDFILE 25 40 in
      .element "Include Y/N" USE_HEDFILE 25 3 in
    .tableend
    .gap
    .text "See help for more information" L
    .gap
.panend
