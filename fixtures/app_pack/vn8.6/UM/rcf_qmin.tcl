proc rcf_qmin {rcf_qmin variable index} {
    # Verify value of RCF_QMIN and check to see if it is the same as
    # QLIMIT - the model resetting humidity value.
    set qmin 0
    set qmax 1.0

    if { $rcf_qmin < $qmin || $rcf_qmin > $qmax } {
	error_message .d {Range Check Error} "The entry 'Specify minimum value' should\
		lie between $qmin and $qmax" warning 0 {OK}
        return 1
    }

    if { [inactive_var QLIMIT] == 0 } {
	set qlimit [ get_variable_value QLIMIT ]

	if { $rcf_qmin != $qlimit } {

	    error_message .d {Inconsistent choice} "This is for Information only.\nThe\
		    reset humidity values for the reconfiguration ($rcf_qmin) and model\
                    ($qlimit) are different." warning 0 {OK}
	}
    }
	    
    return 0
}
