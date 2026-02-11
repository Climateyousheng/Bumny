proc azprm {list variable index} {
  # This procedure is a verification function for AZPRM.
  #
  if { $variable == "AZPRM(*,1)" } {
        set sr [ get_variable_value ATMOS_SR(87) ]
        set mean [ get_variable_value AMEAN(1) ]
        set anmp 3
  } elseif { $variable == "AZPRM(*,2)" } {
        set sr "0A"
        set mean [ get_variable_value AMEAN(2) ]
        set anmp 3
  } elseif { $variable == "AZPRM(*,4)" } {
        set sr "0A"
        set mean [ get_variable_value AMEAN(4) ]
        set anmp 3
  } else {
        error "Please Report: Internal UMUI error in azp0. Variable is <$variable>" 
  }
  set count 0
  foreach value $list {
    incr count
    if { ($mean == "Y" ) && ($value != "") && ( $count <= $anmp ) } {
      if { $value<0 || $value>144 } {
        error_message .d {RANGE} "Frequency for writing zonal means should be in range 0 to 144 but is <$value>" warning 0 {OK}
        return 1  
      } 
      if { $value > 0 } {
        if { $sr == "0A" } {
         error_message .d {Cross Check} "Zonal-Means requested, but no section included." warning 0 {OK}
         return 1
        }
      }
    }
  }
  return 0
}
   
