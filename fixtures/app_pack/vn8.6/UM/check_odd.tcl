proc check_odd {value variable index} {

  # This procedure doesn't allow odd values and 
  # checks the range [1 2999]
  
   set var_info [get_variable_info $variable]
   set help_text [lindex $var_info 10]
  
   if {($value > 2999) || ($value < 1)} {
       error_message .d {Incorrect Setting} "The entry '$help_text'\
       should be between 1 and 2999" warning 0 {OK}
       return 1   
   }
 
   set reminder [expr $value % 2]
   if { $reminder != 0 } {

       error_message .d {Incorrect Setting} "UM does not allow the entry \
       '$help_text' to be odd." warning 0 {OK}
       return 1
   } 
  
   return 0 
}
