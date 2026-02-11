proc arxx {value variable index} {
  # This procedure is a verification function for 
  # ARYR, ARMO, ARDA, ARHR, ARMI, ARSE
  #

  if { $index == -1 } { 
    scan $variable "%4s(%d)" var ind
    set index $ind
  }

  set adump [ get_variable_value ADUMP($index) ]

  if { [regexp ARYR $variable] } {
    set lb 0
    set ub 3000
    set type year
  } elseif { [regexp ARMO $variable] } {
    set lb 1
    set ub 12
    set type month
  } elseif { [regexp ARDA $variable] } {
    set lb 1
    if {$adump == 3 } {
      set ub 1
    } else { 
      set ub 31
    }
    set type day
  } elseif { [regexp ARHR $variable] } {
    set lb 0
    if {$adump == 3 } {
      set ub 0
    } else { 
      set ub 23
    }
    set type hour
  } elseif { [regexp ARMI $variable] } {
    set lb 0
    if {$adump == 3 } {
      set ub 0
    } else { 
      set ub 59
    }
    set type minute
  } elseif { [regexp ARSE $variable] } {
    set lb 0
    if {$adump == 3 } {
      set ub 0
    } else { 
      set ub 59
    }
    set type  second
  } else {
    error "Sytem error in arxx. Variable is $variable"
  }

  if { ($adump==3) && ($type=="day" || $type=="hour" || $type=="minute" || $type=="second" ) } {
      set extra_text "The range is limited because you are using Gregorian calendar meaning"
  } else {
      set extra_text "" 
  }
  if { ($value < $lb) || ($value > $ub) } {
    error_message .d {Range Check} "Climate mean reference date/time
    for field '$type' must lie in the range $lb <= value <= $ub.\
    $extra_text" warning 0 {OK}
       return 1
  }

  return 0
}
   
