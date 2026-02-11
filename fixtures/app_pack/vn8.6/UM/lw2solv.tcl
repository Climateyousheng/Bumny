proc lw2solv {value variable index} {
  # This procedure is a verification function for LW2SOLV.
  #
  set lw2olapc [ get_variable_value LW2OLAPC ]
  set var_info [get_variable_info $variable]
  set help_text [lindex $var_info 10]

  if { $value!=8 && $value!=9 && $value!=10 && $value!=11 && \
       $value!=14 && $value!=15 } {
    error_message .d {Invalid Choice} "The entry '$help_text'\
    must take one of the listed responses." warning 0 {OK}
    return 1
  }

  if { $lw2olapc==6 && ($value!=14 && $value!=15) } { 
    error_message .d {Inconsistent} "The entry '$help_text'\
    must be one of the VCCC solvers if you are using the cloud overlap\
    option: 'MRO & VCCC'" warning 0 {OK}
    return 1
  }

  if { $lw2olapc!=6 && ($value==14 || $value==15) } { 
    error_message .d {Inconsistent} "The entry '$help_text'\
    must not be one of the VCCC solvers as you are not using the cloud overlap\
    option: 'MRO & VCCC'" warning 0 {OK}
    return 1
  }

  return 0
}
   
