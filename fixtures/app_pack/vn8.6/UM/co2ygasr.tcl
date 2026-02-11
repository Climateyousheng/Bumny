proc co2ygasr {value variable index} {
   # Verification function for METHYGASR, NOXYGASR, CFC11YGASR, CFC12YGASR, 
   #  C02YGASR, SU1YGASR & SU2YGASR the 
   # gas year array for compounded rates.
    
  if {$index != 1} { return 0 }
  
  foreach val $value { 
    set help_text [lindex [get_variable_info $variable] 10]
    if {$index == 1} {
      if {$variable=="CO2YGASR"} {
        set lastvar CO2YGASL
        set lastind CO2NGASL
      } elseif {$variable=="SU1YGASR"} {
        set lastvar SU1YGASL
        set lastind SU1NGASL
      } elseif {$variable=="SU2YGASR"} {
        set lastvar SU2YGASL
        set lastind SU2NGASL
      } elseif {$variable=="METHYGASR"} {
        set lastvar METHYGASL
        set lastind METHNGASL
      } elseif {$variable=="NOXYGASR"} {
        set lastvar NOXYGASL
        set lastind NOXNGASL
      } elseif {$variable=="CFC11YGASR"} {
        set lastvar CFC11YGASL
        set lastind CFC11NGASL
      } elseif {$variable=="CFC12YGASR"} {
        set lastvar CFC12YGASL
        set lastind CFC12NGASL
      } elseif {$variable=="CFC113YGASR"} {
        set lastvar CFC113YGASL
        set lastind CFC113NGASL
      } elseif {$variable=="HCFC22YGASR"} {
        set lastvar HCFC22YGASL
        set lastind HCFC22NGASL
      } elseif {$variable=="HFC125YGASR"} {
        set lastvar HFC125YGASL
        set lastind HFC125NGASL
      } elseif {$variable=="HFC134AYGASR"} {
        set lastvar HFC134AYGASL
        set lastind HFC134ANGASL
      } elseif {$variable=="CFC114YGASR"} {
        set lastvar CFC114YGASL
        set lastind CFC114NGASL          
      } else {
        error "Error in verification function co2ygasr, variable is <$variable>"
      }
      set lastindvar [get_variable_value $lastind]
      set lastval [get_variable_value $lastvar\($lastindvar\)]
      if { $val != [expr $lastval + 1] } {
	error_message .d {Bad First Year} "Bad entry at index $index in entry $help_text.\n\
        The first year is defined as $val.\n\
        This must be one year after the last \"linear interpolation\" year \n\
        <$lastval + 1 = [expr $lastval + 1]>. " warning 0 {OK}
	return 1
      }
    }
    if { ($val > 9999) || ($val < 0 )  } {
	error_message .d {Bad  Year} "Bad entry at index $index in entry $help_text.\n\
        The year is defined as $val.\n\
        This must lie between 0 and 9999." warning 0 {OK}
	return 1
    }    
    incr index
  }
  return 0

}

