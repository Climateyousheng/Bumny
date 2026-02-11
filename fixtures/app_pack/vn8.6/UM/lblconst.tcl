#==============================================================================
# RCS Header:
#   File         [$Source: /home/hc0300/umui/srce_code/UMUI_archive/umui2.0/vn7.6/UM/lblconst.tcl,v $]
#   Revision     [$Revision: 1.1 $]     Named [$Name: head#main $]
#   Last checkin [$Date: 2010/02/02 17:05:29 $]
#   Author       [$Author: umui $]
#==============================================================================
proc chk_kdf {value variable index} {

    # Check that every level range has a value specified for the Diffusion Damping coefficient
    if {$index != 1} {
	return 0
    }
    set startLevs [get_variable_array STARTLEV_$variable]
    set len [llength $startLevs]

    for {set i 0} {$i < $len} {incr i} {
        set val [lindex $value $i]
	set row   [expr $i + 1]

	if {$val < 0.0 || $val > 1.0e+8} {
	    error_message .d {Range Check Error} "Row $row in the 'Forecast' column should lie between 0.0 and 1.0e+8." warning 0 {OK}
	    return 1
	}
    }
    return 0
}

proc chk_rhc {value variable index} {

    # Check that every level range has a value specified for RHCrit
    if {$index != 1} {
	return 0
    }
    set startLevs [get_variable_array STARTLEV_$variable]
    set len [llength $startLevs]

    for {set i 0} {$i < $len} {incr i} {
        set val [lindex $value $i]
	set row   [expr $i + 1]

	if {$val < 0.5 || $val > 1.0} {
	    error_message .d {Range Check Error} "Row $row in the 'Forecast' column should lie between 0.5 and 1.0." warning 0 {OK}
	    return 1
	}
    }
    return 0
}
