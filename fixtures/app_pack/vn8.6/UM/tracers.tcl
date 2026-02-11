proc tracers {value variable index} {
    # verification function for TCA
    # each index must be either 0 1 2 or 3
    # additionally, if they are all 0, tracers should be switched off

    # If there is a blank value, then let inactive checking catch it.
    if [regexp \{\} $value] {return 0}

    # Check whole array at one go 
    if {$index!=1} {return 0}

    # First check that input values are 0 to 3
    if {[set n [lsearch -regexp $value {[^0123]}]]!=-1} {
	set row [expr $n+1]
	set val [lindex $value $n]
	error_message .d {List check error} "Row $row should be set to one of the values 0, 1, 2, or 3 but is $val" warning 0 {OK}
	return 1
    }


    # Check that there is at least one tracer in use
    if {[lsearch -regexp $value {[1-3{}]}]==-1} {	    
	error_message .d {No tracers} "You are not using tracers. Please set 'Do you want to include tracers in the atmosphere?' to off" warning 0 {OK}
	return 1
    }
    return 0
}
