proc tracers_mkbc34 {value variable index} {
    # verification function for MKBC33_TCA
    # each index must be either 0 or 1 
    # additionally, makebc33 cannot be 1 if tca is 0

    # If there is a blank value, then let inactive checking catch it.
    if [regexp \{\} $value] {return 0}

    # Check whole array at one go 
    if {$index!=1} {return 0}

    set val_tca [get_variable_array VAL_TMP]
    
    # First check that input values for TCA are 0 to 1
    if {[set n [lsearch -regexp $value {[^01]}]]!=-1} {
	set row [expr $n+1]
        set col "MakeBCs input"
	set val [lindex $value $n]
	error_message .d {List check error} "Row $row, \"$col\" column should be set to one of the values 0 or 1 but is $val" warning 0 {OK}
	return 1
    }

    for {set i 0} {$i < 150} {incr i} {
       if {[lindex $val_tca $i] == 0 && [lindex $value $i] == 1} {
	  set row [expr $i+1]
          set col "UKCA MakeBCs input"
	  error_message .d {List check error} "Row $row, \"$col\" column should be set to 0 as tracer is not available" warning 0 {OK}
	  return 1
       }
    }

    return 0
} 
