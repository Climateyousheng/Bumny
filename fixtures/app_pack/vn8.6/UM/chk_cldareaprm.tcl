proc chk_cldareaprm {value variable index} {
# checks consistency between PC2 and cloud area parametrisation

   set cld_area [get_variable_value CLD_AREA]

   if {$cld_area == "Y"} {
      if {$value == "0"} {
      # Method of cloud area parametrization
      error_message .d  {Invalid Value} "The method of cloud area parametrization \
         must be chosen." warning 0 {OK}
         return 1
      
      } 
   }
   return 0
}
