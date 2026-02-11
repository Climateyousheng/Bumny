proc job_name {value variable index} {
    # Verification of CJOBN
    # If automatic resubmission is being used CJOBN should have 
    # last two characters as numbers.

    set var_info [get_variable_info $variable]
    set help_text [lindex $var_info 10]

    set jresub [get_variable_value JRESUB]

    if {$value == ""} {
	error_message .d {Blank Not Allowed} "Entry '$help_text' should be a name 8 characters long" warning 0 {OK}
	return 1
    }
    if {[string length $value] != 8} {
	error_message .d {Name incorrect length} "Entry '$help_text' should be 8 characters long" warning 0 {OK}
	return 1
    }

    if { $jresub=="Y"} {
	set d1 [string range $value 6 6]
	set d2 [string range $value 7 7]
	if { ($d1<0) || ($d1>9) || ($d2<0) || ($d2>9) } {
	    error_message .d {Invalid name} "You have requested automatic resubmission. Therefore the last two characters \
		    of '$help_text' should be digits" warning 0 {OK}
	    return 1
	}
    }
    return 0
}

proc job_resub {value variable index} {
    # Verification of JRESUB
    # If automatic resubmission is being used CJOBN should have 
    # last two characters as numbers.

    set var_info [get_variable_info $variable]
    set help_text [lindex $var_info 10]

    set cjobn [get_variable_value CJOBN]

    if { ($value != "Y") && ($value != "N") } {
	error_message .d {Blank Not Allowed} "Entry '$help_text' is never allowed to be blank" warning 0 {OK}
	return 1
    }

    if { $value=="Y"} {
	set d1 [string range $cjobn 6 6]
	set d2 [string range $cjobn 7 7]
	if { ($d1<0) || ($d1>9) || ($d2<0) || ($d2>9) } {
	    error_message .d {Invalid name} "You have requested automatic resubmission. Therefore the last two characters \
		    of your job name should be digits. See information on panel." warning 0 {OK}
	    return 1
	}
    }
    return 0
}
