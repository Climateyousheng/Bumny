#==============================================================================
# RCS Header:
#   File         [$Source: /home/hc0300/umui/srce_code/UMUI_archive/umui2.0/vn7.6/UM/horiz_diff.tcl,v $]
#   Revision     [$Revision: 1.1 $]     Named [$Name: head#main $]
#   Last checkin [$Date: 2010/02/02 17:05:29 $]
#   Author       [$Author: umui $]
#==============================================================================
proc chk_coeffs {value variable index} {

    # Check that every level range has a value specified for the coefficient
    if {$index != 1} {
	return 0
    }
    set startLevs [get_variable_array STARTLEV_$variable]
    set len [llength $startLevs]

    set var_info [get_variable_info $variable]
    set help_text [lindex $var_info 10]

    for {set i 0} {$i < $len} {incr i} {
        set c_val [lindex $value $i]
	set row   [expr $i + 1]

	if {$c_val < -1.0 || $c_val > 1.0e+12} {
	    error_message .d {Range Check Error} "Row $row in the '$help_text' column should lie between -1.0 and 1.0e+12." warning 0 {OK}
	    return 1
	}
    }
    return 0
}

proc chk_orders {value variable index} {

    # Check that every level range has a value specified for the Diffusion order
    if {$index != 1} {
	return 0
    }

    set var_info [get_variable_info $variable]
    set help_text [lindex $var_info 10]

    regsub E $variable "" varname
    set startLevs [get_variable_array STARTLEV_$varname]
    set len [llength $startLevs]

    for {set i 0} {$i < $len} {incr i} {
        set o_val [lindex $value $i]
	set row   [expr $i + 1]

	if {$o_val < 0 || $o_val > 4} {
	    error_message .d {Range Check Error} "Row $row in the '$help_text' column should lie between 0 and 4." warning 0 {OK}
	    return 1
	}
    }
    return 0
}
