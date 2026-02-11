#==============================================================================
# RCS Header:
#   File         [$Source: /home/hc0300/umui/srce_code/UMUI_archive/umui2.0/vn7.6/UM/chk_level_ranges.tcl,v $]
#   Revision     [$Revision: 1.1 $]     Named [$Name: head#main $]
#   Last checkin [$Date: 2010/02/02 17:05:29 $]
#   Author       [$Author: umui $]
#==============================================================================
proc chk_level_ranges {value variable index} {

    # Check that every level has been accounted for
    # This only needs to be done once for the whole list
    if {$index != 1} {
	return 0
    }

    set startLevs $value
    set nlevsa  [get_variable_value NLEVSA]

    regexp _(.*$) $variable match sub
    set endLevs [get_variable_array ENDLEV$match]
    
    # RHCrit only specified for each Wet Level
    if {$sub == "RHC"} {
	set nlevsa [get_variable_value NWLEVA]
    }

    # TKE levels only for Bounday Layer TKE levels
    if {$sub == "TKE"} {
        set nlevsa [get_variable_value NBLLV]
        set tkelev [get_variable_value TKE_LEVS]
        if { [get_variable_value SETTKELEVS]=="Y" && $tkelev > 0 && $tkelev <= $nlevsa } {
            set nlevsa $tkelev
	}
    }

    # Get length of arrays
    set len [llength $startLevs]

    set lastend 0
    # First element of value must be a 1
    for {set i 0} {$i < $len} {incr i} {
        set start [lindex $startLevs $i]
	set end   [lindex $endLevs $i]
	set row   [expr $i + 1]

	if {$i==0 && $start != 1} {
	    error_message .d {No Value Given} "Table should begin with Level 1. Please sort table." warning 0 {OK}
	    return 1
	}
	if {$start < 1 || $start > $nlevsa} {
	    error_message .d {Range Check Error} "Row $row in the 'Start Level' column should lie between 1 and $nlevsa." warning 0 {OK}
            return 1
        } elseif {$end < 1 || $end > $nlevsa} {
	    error_message .d {Range Check Error} "Row $row in the 'End Level' column should lie between 1 and $nlevsa." warning 0 {OK}
	    return 1
	}
	if {$start > $end} {
	    # Fail
	    error_message .d {Cross Check} "Row $row: Start Level must be less than End Level." warning 0 {OK}
	    return 1
	}
        if {$start <= $lastend} {
	    # Overlapping ranges
	    error_message .d {Cross Check} "Overlapping Range of Levels specified: Row $row" warning 0 {OK}
            return 1
	}
	set lastendp1 [expr $lastend + 1]
	if {$start != $lastendp1} {
	    # Level missing
	    error_message .d {No Value Given} "No values specified for Level $lastendp1. Please ensure the table has been sorted" warning 0 {OK}
	    return 1
	}
        set lastend $end
    }
    if {$lastend != $nlevsa} {
	# Not all levels have values
	# The next missing level is...
        set lastendp1 [expr $lastend + 1]
	error_message .d {No Value Given} "No values specified for Level $lastendp1." warning 0 {OK}
	return 1
    }
    return 0
}
