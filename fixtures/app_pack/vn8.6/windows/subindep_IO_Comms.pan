.winid "subindep_IO_Comms"
.title "Communications Threading Model"
.wintype entry

.panel
  .case ATMOS=="T" && OCAAA!=5
  .basrad "Choose the threading model you want MPI to use" L 4 v THRD_LVL
      "Multithreading" MULTIPLE
      "Serialized" SERIALIZED
      "Funneled" FUNNELED 
      "Single" SINGLE 
  .caseend
  .gap
  .basrad "Force Threading Level of UM to be" L 5 v IOS_FTHR_MOD
      "Multithreading" 3
      "Serialized" 2
      "Funneled" 1 
      "Single" 0
      "Not used" IMDI 
  .gap
  .textw "Push Back for IO Services Options panel" L
  .textw "Push MACHINE for Submit Method panel" L
  .pushnext "Back" subindep_IO_Services
  .pushnext "MACHINE" subindep_SubmitMethod
.panend
