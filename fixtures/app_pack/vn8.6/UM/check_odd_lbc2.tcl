proc check_odd_lbc2 {value variable index} {

  # This procedure doesn't allow odd values and 
  # checks the range [1 999]
  
   set var_info [get_variable_info $variable]
   set help_text [lindex $var_info 10]
  

   set ind [get_variable_value OCBMLA]
   set arrvalue [get_variable_value ILMACOLS($ind)]
 
   if {($arrvalue > 999) || ($arrvalue < 1)} {
       error_message .d {Incorrect Setting} "The entry '$help_text'\
       should be between 1 and 999" warning 0 {OK}
       return 1   
   }
 
   set reminder [expr $arrvalue % 2]
   if { $reminder != 0 } {

       error_message .d {Incorrect Setting} "UM does now allow the entry \
       '$help_text' to be odd." warning 0 {OK}
       return 1
   } 
  
   return 0 
}
