proc check_ntasks_per_node {value variable index} {

   # Check number of tasks per node on Hector machines
   # xt4 (phase2a.hector.ac.uk)(4 cores per node) 1-4
   # xe6/mc (phase2b.hector.ac.uk)(6 cores per numa node) 4,8,12,16,20,24
   # xe6/il (login.hector.ac.uk or phase3.hector.ac.uk)(8 cores per numa node) 4,8,12,16,20,24,28,32

   set machname [get_variable_value MACH_NAME]
   set useopenmp [get_variable_value LR_OPENMP]
   set nthreads [get_variable_value NTHR_TASK]
   
   if {$useopenmp == "Y" && $nthreads > 1} {
      if {$machname == "login.hector.ac.uk" || \
          $machname == "phase3.hector.ac.uk"} {
         if {$nthreads == 2} {
            set values "4 8 12 16"
	 } elseif {$nthreads == 3} {
            set values "4 8"
	 } elseif {$nthreads == 4} {
            set values "4 8"
	 } elseif {$nthreads == 6} {
            set values "4"
	 } elseif {$nthreads == 8} {
            set values "4"
	 } else {
            error_message .d {Invalid nthreads per task} "The number of threads per \
	        MPI task should have one of the values 1 2 3 4 6 8 but is $nthreads" \
	       warning 0 {OK}
	    return 1
	 }
      } else {
         return 0
      }
      if {[lsearch -exact $values $value] == -1} {
        error_message .d {Invalid ntasks per node} \
        "The number of MPI tasks per node \
         should have one of the values $values but is $value" \
         warning 0 {OK}
        return 1   
      }
   } else {
      if {$machname == "login.hector.ac.uk" || \
          $machname == "phase3.hector.ac.uk"} {
         set values "4 8 12 16 20 24 28 32"
	 if {[lsearch -exact $values $value] == -1} {
           error_message .d {Invalid ntasks per node} \
	   "The number of MPI tasks per node \
   	    should have one of the values $values but is $value" \
   	    warning 0 {OK}
           return 1   
         }
      }
   }

   return 0 
}
