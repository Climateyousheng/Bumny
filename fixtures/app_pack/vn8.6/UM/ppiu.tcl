proc ppiu {value variable index} {
    # verification function for PPIU
    # each index must be either T H DA or RM
    # additionally, if any are RM, this must NOT be CAL360

    # First check that input values are  T H DA or RM
    set cal360 [get_variable_value CAL360]
    set indm1 [ expr $index -1 ] 
    set element [lindex $value $indm1 ]
    if {$element == "DA" || $element == "H" || $element == "T"} {
         return 0
    } elseif {$element == "RM" && $cal360 == "Y" } {	    
	error_message .d {Invalid Response} "Time units of RM are not allowed\
          for PP$indm1 (or any other) because you are using a 360-day calendar." warning 0 {OK}
        return 1
    } elseif {$element != "RM"} {
        # Blank case already checked by blank-allowed. Not called in this case.	    
	error_message .d {Bad Value} "Time units of \"$element\" are not allowed\
          for PP$indm1 (or any other). Use a valid time period." warning 0 {OK}
        return 1
    }


    return 0
}
