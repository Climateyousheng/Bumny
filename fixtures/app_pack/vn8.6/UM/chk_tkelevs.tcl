proc chk_tkelevs {value variable index} {
    # Procedure to check TKE boundary layer levels have been set appropriately
    # TKE_LEVS == -1 indicates that TKE_LEVS == NBLLV
    # SHCULEVS == -1 indicates that SHCULEVS == TKE_LEVS

    if { $value == -1 } {
       return 0
    }

    set var_info [get_variable_info $variable]
    set help_text [lindex $var_info 10]
    set nbllv [get_variable_value NBLLV]

    if { $variable == "SHCULEVS" } {
        set tkelevs [get_variable_value TKE_LEVS]
	if { $tkelevs != -1 } {
           set nbllv $tkelevs
        }
    } 


    if { $value <= 0 || $value > $nbllv } {
       error_message .d {Incorrect Setting} "$help_text should be between 1 and $nbllv" warning 0 {OK}
       return 1
    }

    return 0

}
