proc set_a38 {} {
    # Procedure to set ATMOS_SR(38) and ATMOS_SR(50)
    
     if { [get_variable_value ATMOS_SR(34)]!="0A" } {
      set_variable_value ATMOS_SR(38) "1A"
      set_variable_value ATMOS_SR(50) "1A"
    } else {
      set_variable_value ATMOS_SR(38) "0A"
      set_variable_value ATMOS_SR(50) "0A"
    }
}
