proc set_hydr_levels { } { 
       set hyd_type [get_variable_value HYD_TYPE ]
        if { $hyd_type == 3 ||  $hyd_type == 4 } {
	  return [ get_variable_value NDSLV ] 
        } elseif { $hyd_type == 0 ||  $hyd_type == 1 } {
	  return 0 
        } else {
           error "Error in set_hydr_levels. Hyrology type <$hyd_type> is unknown."
        }
}
