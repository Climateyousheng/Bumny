proc set_LSPICECOMP {} {
    # Procedure for setting variable LSPICECOMP
    # 0=No prognostic ice. 1=Prognostic ice. What basic type of Cloud
    # 0=Not compliant with LSPICE. 1=Compliant. 
    #
    # 
    # Designed to catch net types coming along and give an error
    # Mode is used to say if the routine sets the value (set) eg on
    # exit from the window, or returns the results (retrun) without setting.


    set h_sr [get_variable_value ATMOS_SR(9)] 

    if { ($h_sr=="0A") } {
      set type 0 
    } elseif { $h_sr=="1A" } {
      set type 0
    } elseif { $h_sr=="2A" } {
      set type 1
    } elseif { $h_sr=="2B" } {
      set type 1
    } else {
	if {[check_variable_value ATMOS_SR(9) $h_sr scalar -1 2]!=1} {
	    error "Error in proc LSPICECOMP. Unknown Cloud Scheme $h_sr"
	} else {
	    set type 0
	}
    }

    set_variable_value LSPICECOMP  $type 
}
