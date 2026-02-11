proc envar_name {value variable index} {
    #  This is a verification function.
    #  this procedure checks variable ENVAR_NAME to make sure that it is not
    #  DATAW or DATAM and that there are no repeats.

    # Run check only when called the first time
    if {$index!=1} {return 0}

    set count 0
    set ev_list [lsort -ascii $value]
    foreach name $ev_list {
	if { $name == "DATAW" || $name == "DATAM" } {
	    error_message .d {Bad Name} "Do not use the Environment Variable  $name in the table." warning 0 {OK}
	    return 1
	}
	incr count
	if { $count == 1 } {
	    set lastname $name
	} else {
	    if { $name != "" } {
		if { $name == $lastname } {
		    error_message .d {Bad Name} "The Environment Variable named <$name> is duplicated in table." warning 0 {OK}
		    return 1
		}
	    }
	}
	set lastname $name
    }
    return 0
}
