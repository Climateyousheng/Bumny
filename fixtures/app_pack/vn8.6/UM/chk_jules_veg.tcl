proc chk_jules_veg {value variable index} {
    # Procedure to check TKE boundary layer levels have been set appropriately
    # JR_ALBSNF_NVG == -1 flags the code to look elsewhere for this value

    set var_info [get_variable_info $variable]
    set help_text [lindex $var_info 10]
    set jules [get_variable_value JULES]
    if { $jules=="T" } {
       set ntype [get_variable_value JI_NVTYPE]
    } else {
       set ntype 4
    } 

    set lo_val 0.0
    set hi_val 1.0

    for {set i 0} {$i < $ntype } {incr i} {
       set elem [lindex $value $i]

       if { $elem!=-1 && ($elem < $lo_val || $elem > $hi_val) } {
	   error_message .d {Incorrect Setting} "$help_text (type [expr $i+1]) should be -1 or between $lo_val and $hi_val" warning 0 {OK}
          return 1
       }
    }

    return 0

}
