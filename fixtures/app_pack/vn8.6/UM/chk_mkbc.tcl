proc chk_mkbc {value variable index} {
# checks frequency for Makebc STASH output is valid

   set time [expr [get_variable_value MBC_END]-[get_variable_value MBC_STRT]]

   if { $time < 0 } {
      # Error in time period definition - warning dealt with by MBC_END range check
      return 1
   }
   
   if { $time % $value != 0 } {
      error_message .d  {Invalid Value} "The frequency ($value) does not divide \
                         equally into the time period ($time)" warning 0 {OK}
      return 1     
                
   }

   return 0
}
