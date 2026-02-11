proc tracers_lbc {value variable index} {
    # verification function for LBC_TCA and TCA
    # each index must be either 0 or 1 
    # additionally, if they are all 0, tracers should be switched off

    # If there is a blank value, then let inactive checking catch it.
    if [regexp \{\} $value] {return 0}

    # Check whole array at one go 
    if {$index!=1} {return 0}
    
    if {$variable == "TCA"} {
       set val_tca $value
       set val_lbc [get_variable_array LBC_TCA]
    } elseif {$variable == "LBC_TCA"} {
       set val_tca [get_variable_array TCA]
       set val_lbc $value
     } elseif {$variable == "VAL_TMP_LBC"} {
       set val_lbc $value  
    }

    # First check that input values for TCA are 0 to 1
    if {[set n [lsearch -regexp $value {[^01]}]]!=-1} {
	set row [expr $n+1]
        if { $variable == "TCA" } {
           set col "Select"
        } else {
           set col "LBCs input" 
        }
	set val [lindex $value $n]
	error_message .d {List check error} "Row $row, \"$col\" column should be set to one of the values 0 or 1 but is $val" warning 0 {OK}
	return 1
    }

    # Check that there is at least one tracer in use
    if { $variable != "VAL_TMP_LBC" } {
       if {([lsearch -regexp $val_tca {[1{}]}]==-1) \
         ||([lsearch -regexp $val_lbc {[1{}]}]==-1)} {	
          if { $variable == "TCA" && ([lsearch -regexp $value {[1{}]}]==-1) } {    
	     error_message .d {No tracers} "You are not using tracers. Please set 'Do you want to include tracers in the atmosphere?' to off" warning 0 {OK}
	     return 1
   	  } elseif {$variable == "LBC_TCA"} {
	     error_message .d {No tracer LBCs} "You are not using tracer LBCs. Please set 'Turn on free tracer LBCs' to off" warning 0 {OK}
             return 1
	  }
       }
    } else {
       if { [lsearch -regexp $val_lbc {[1{}]}]==-1 } {
	  error_message .d {No tracer LBCs} "You are not using tracer LBCs. Please set 'Turn on UKCA tracer LBCs' to off" warning 0 {OK}
	  return 1
       }
    }
    return 0
}
