proc co2ygasl {value variable index} {
  # Verification function for C02YGASL,SU1YGASL,SU2YGASL,
  # METHYGASL,NOXYGASL,CFC11YGASL,CFC12YGASL, the gas year 
  # array for linear interp.
    
  if {$index != 1} { return 0 }
  
  foreach val $value {
    set help_text [lindex [get_variable_info $variable] 10]
    if {$index == 1} {
      set sryr  [get_variable_value SRYR]
      if { $val > $sryr  } {
	error_message .d {Bad First Year} "Bad entry at index $index in entry $help_text.\n\
        The first year is defined as $val.\n\
        This must be at or before the start of your integration in year $sryr" warning 0 {OK}
	return 1
      }
    }
    if { ($val > 9999) || ($value < 0 )  } {
	error_message .d {Bad  Year} "Bad entry at index $index in entry $help_text.\n\
        The year is defined as $val.\n\
        This must lie between 0 and 9999." warning 0 {OK}
	return 1
    }   
    incr index
  }
  return 0

}

