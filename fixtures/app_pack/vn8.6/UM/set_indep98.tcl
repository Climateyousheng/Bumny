proc set_indep98 {} {
# Procedure to set INDEP_SR(98) depending on the value of LR_OPENMP

   set scm [get_variable_value OCAAA]
   set omp [get_variable_value LR_OPENMP]

   if { $scm!="5" && $omp=="Y"} {
      set_variable_value INDEP_SR(98) "1A"      
   } else {
      set_variable_value INDEP_SR(98) "0A"    
   }

}
