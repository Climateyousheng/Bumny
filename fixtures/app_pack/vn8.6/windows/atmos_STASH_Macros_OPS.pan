.winid "atmos_STASH_Macros_OPS"
.title "OPS interface macros"
.wintype entry

.panel
  .basrad "CX fields macro:" L 3 v OPSINTM
          "No Macro" 0
          "Standard Macro" 1
          "Development Macro" 2
  .gap
  .textw "List of times for fields from which CX columns will be generated:" L
  .gap
  .case OPSINTM!=0
    .basrad "Units:" L 2 h CXUNITS
            "Hours" H
            "Timesteps" T
    .entry "Number of times in list" L CXTIMES
    .gap
    .case CXTIMES!=""
      .table cxouttime "Output time list" top h CXTIMES 10 INCR
        .elementautonum "No." 0 CXTIMES 10
        .element "Values need to be sorted" CXOUTTIME CXTIMES 35 in
      .tableend
    .caseend
  .caseend
  .gap
  .case OCAAA==1
    .basrad "Background error fields macro (global only):" L 3 v BEFM
            "No Macro" 0
            "Standard Macro" 1
            "Development Macro" 2
  .caseend
  .textw "Note: All fields will be written to unit 102 (CXBKGOUT)." L
.panend


