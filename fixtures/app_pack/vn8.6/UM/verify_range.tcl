proc verify_range {value variable index} {

    # Check that every level has been accounted for
    # This only needs to be done once for the whole list
    if {$index != 1} {
	return 0
    }

    set startLevs $value
    set nlevsa  [get_variable_value NLEVSA]

    regexp _(.*$) $variable match sub
    set endLevs [get_variable_array ENDLEV$match]
    set coeffs [get_variable_array $sub]

    regsub K $sub KE order
    set orders [get_variable_array $order] 
    
    # Get length of arrays
    set len [llength $startLevs]

    set lastend 0
    # First element of value must be a 1
    for {set i 0} {$i < $len} {incr i} {
        set start [lindex $startLevs $i]
	set end   [lindex $endLevs $i]
	set row   [expr $i + 1]

	if {$i==0 && $start != 1} {
	    error_message .d {No Value Given} "Level 1 has no coefficient or order specified." warning 0 {OK}
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
	    error_message .d {No Value Given} "No Coefficient or Order of Diffusion specified for Level $lastendp1. Please ensure the table has been sorted" warning 0 {OK}
	    return 1
	}
        set lastend $end
    }
    if {$lastend != $nlevsa} {
	# Not all levels have values
	# The next missing level is...
        set lastendp1 [expr $lastend + 1]
	error_message .d {No Value Given} "No coefficient or Order of Diffusion specified for Level $lastendp1." warning 0 {OK}
	return 1
    }

    # Check coefficients are within the required range
    for {set i 0} {$i < $len} {incr i} {
        set c_val [lindex $coeffs $i]
	set o_val [lindex $orders $i]
	set row   [expr $i + 1]

	if {$c_val < -1.0 || $c_val > 1.0e+12} {
	    error_message .d {Range Check Error} "Row $row in the 'Coefficient (K)' column should lie between -1.0 and 1.0e+12." warning 0 {OK}
	    return 1
	}

	if {$o_val < 0 || $o_val > 4} {
	    error_message .d {Range Check Error} "Row $row in the 'Order (N)' column should lie between 0 and 4." warning 0 {OK}
	    return 1
	}
    }
    return 0
}


