proc check_nthreads_per_task {value variable index} {

   # Check number of tasks per node on Hector machines
   # xt4 (phase2a.hector.ac.uk)(4 cores per node) 1-4
   # xe6/mc (phase2b.hector.ac.uk)(6 cores per numa node) 4,8,12,16,20,24
   # xe6/il (login.hector.ac.uk or phase3.hector.ac.uk)(8 cores per numa node) 4,8,12,16,20,24,28,32

   set machname [get_variable_value MACH_NAME]

   if {$machname == "login.hector.ac.uk" || \
       $machname == "phase3.hector.ac.uk"} {
      if {$value != 1 && $value != 2 && $value != 3 && \
          $value != 4 && $value != 6 && $value != 8} {
        error_message .d {Invalid nthreads per task} "The number of threads per \
	    MPI task should have one of the values 1 2 3 4 6 8 but is $value" \
	    warning 0 {OK}
	return 1   
      }
   } else {
      if {$value != 1 && $value != 2  && $value != 4  && \
          $value != 8 && $value != 16 && $value != 32} {
        error_message .d {Invalid nthreads per task} "The number of threads per \
	    MPI task should have one of the values 1 2 4 8 16 32 but is $value" \
	    warning 0 {OK}
	return 1   
      }
   }

   return 0 
}
