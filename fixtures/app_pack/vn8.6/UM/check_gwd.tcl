proc check_gwd {value variable index} {
  # This procedure checks atmos_Science_Section_GWD
  # If option 4A is chosen then either LFBLOK or LORODS must be "T"
  set lfblok [ get_variable_value LFBLOK ]
  set lorods [ get_variable_value LORODS ]
  set model  [ get_variable_value ATMOS_SR(6) ]
  set var_info [get_variable_info $variable]
  set help_text [lindex $var_info 10]

  if {($value != "T") && ($value != "F")} {
    error_message .d {Invalid Choice } "The entry '$help_text'\
    does not have a valid value." warning 0 {OK}
    return 1
  }

  if {$model!="0A"} {
    if {($lorods!="T") && ($lfblok!="T")} {
      error_message .d {Choice Confirmation} "You have chosen to run \
      with GWD turned off, are you sure about this?" warning 0 {OK}
      #return 1  
    }
  }
  return 0
}
  
