proc chk_machcfg {value variable index} {
# This procedure checks submit method and switch for 
# overriding a machine config file
  
   set var_info [get_variable_info $variable]
   set help_text [lindex $var_info 10]

   set sbmt_method [get_variable_value SUBMIT_METHOD]
   
   if {$sbmt_method=="0" && $value=="N" } {
       error_message .d {Incorrect Setting} "The '$help_text'\
       should be activated." warning 0 {OK}
       return 1      
   }
   
   return 0 
}   
