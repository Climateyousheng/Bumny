.winid "subindep_Recon_Output"
.title "Output Choices for the Reconfiguration"
.wintype entry

.panel
  .gap
  .check "Timer information for reconfiguration required" L RCF_TIMER Y N
  .basrad "Set level of print output from reconfiguration" L 4 v RCF_PRINTSTATUS
         "Minimum output; only essential messages" PrStatus_Min 
         "Normal informative messages and warnings" PrStatus_Normal 
         "Operational status; all information messages" PrStatus_Oper 
         "Extra diagnostic messages" PrStatus_Diag
    .textw "On MPP machines, each PE produces its own text output file in DATAW" L
    .basrad "Output option for distributed-memory parallel machines:" L 2 v RCF_DELMPPO
             "Delete all DATAW text output files on successful completion." Y
             "Always keep output from PEs in DATAW even when the reconfiguration works." N
.panend

