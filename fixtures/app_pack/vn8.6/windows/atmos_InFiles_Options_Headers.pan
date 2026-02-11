.winid "atmos_InFiles_Options_Headers"
.title "Header dimensions"
.wintype entry

.panel
   .text "Specify the maximum total number of lookup headers on the ancillary files used for updating" L
   .entry "Ancil Headers" L NANCILA
   .gap
   .textw "Model type is: [get_variable_value MODEL_TYPE(OCAAA)]" L
   .case OCAAA==2||OCAAA==3||OCAAA==4
     .text "Specify the maximum number of LBC sets (one per update period) in the LBC file" L
     .entry "LBC Headers" L NBOUNDA
   .caseend
.panend


