proc chk_frequecy {value variable index} {
  # This procedure checks coupling frequency
  
  set oasis [get_variable_value OASIS]
 
  if {$oasis == "T"} {
     set freq [expr fmod(24,$value)]
     if {$freq!=0.0} {
        
        error_message .d {Invalid Value } " Frequency must be \
        divisible to 24 hours" warning 0 {OK}
        return 1     
     }
  }
  
  return 0
}
  
