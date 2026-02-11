# set_VEG_TYPE
#  Currently vegetation distribution is not active so routine always
#  sets VEG_TYPE to 0

proc set_VEG_TYPE {} {
    # Procedure for setting variable set_VEG_TYPE. What basic type of Vegetation.
    # 0=No param, 1 Fixed dist, 2 Interactive dist
    # Mode is used to say if the routine sets the value (set) eg on
    # exit from the window, or returns the results (retrun) without setting.

    set_variable_value VEG_TYPE  0

    set h_sr [get_variable_value ATMOS_SR(19)] 
    set j_sr [get_variable_value JULES_SR(8)] 
    set atm_in [get_variable_value ATM19_IN] 
    set jules_in [get_variable_value JULES8_IN] 

    set match_jules F
    if {[string equal -nocase -length 3 $j_sr $jules_in]==1 } {
       set match_jules T
    }

    if { $h_sr=="0A" } {
      set type 0 
    } elseif { ($match_jules=="T" && ($h_sr=="1A" || $h_sr=="1B")) || ($match_jules=="F" && $j_sr=="1A")} {
      set type 1
    } elseif { ($match_jules=="T" && ($h_sr=="2A" || $h_sr=="2B")) || ($match_jules=="F" && $j_sr=="2A")} {
      set type 2
    } else {
	if {[check_variable_value ATMOS_SR(19) $h_sr scalar -1 2]!=1} {
	    error "Error in proc set_VEG_TYPE. Unknown Vegetation version $h_sr"
	} else {
	    set type 0
	}
    }

    set_variable_value VEG_TYPE  $type 
}
