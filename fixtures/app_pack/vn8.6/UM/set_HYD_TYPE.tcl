proc set_HYD_TYPE {} {
    # Procedure for setting variable set_HYD_TYPE. What basic type of hydrology.
    # Designed to catch net types coming along and give an error

    # Mode is used to say if the routine sets the value (set) eg on
    # exit from the window, or returns the results (retrun) without setting.

    set h_sr [get_variable_value ATMOS_SR(8)] 

    if { ($h_sr=="0A") } {
      set type 0 
    } elseif { $h_sr=="1A" } {
      set type 1
    } elseif { $h_sr=="5A" } {
      set type 3
    } elseif { $h_sr=="7A" || $h_sr=="8A" } {
      set type 4
    } else {
	if {[check_variable_value ATMOS_SR(8) $h_sr scalar -1 2]!=1} {
	    error "Error in proc set_HYD_TYPE. Unknown Hydrology version $h_sr"
	} else {
	    set type 0
	}
    }

    set_variable_value HYD_TYPE  $type 
}
