proc match_A19_L19 { model } {
    # Procedure checks that Atmosphere (ATMOS_SR(19) and 
    # JULES (JULES_SR(8)) vegetation version selections are the same 
    
    set jules [get_variable_value JULES]
    if { $jules=="T" } {
      if { $model=="JULES" } {
        set jules8 [get_variable_value JULES_SR(8)]
	set triffid [string range $jules8 0 0]
        set_variable_value ATMOS_SR(19) "${triffid}B"
      } elseif { $model=="ATMOS" } {
        set atm19 [get_variable_value ATMOS_SR(19)]
	set triffid [string range $atm19 0 0]
        set_variable_value JULES_SR(8) "${triffid}A"
      } else {
        error_message .d {Function Error} "The function match_A19_L19 has been called by an unexpected model: $model." warning 0 {OK}
      }
    }
}
