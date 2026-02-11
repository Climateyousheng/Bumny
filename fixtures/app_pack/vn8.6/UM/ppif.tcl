proc ppif {value variable index} {
    # verification function for PPIF
    # each index must be in range 0 99999
    # additionally, if any are RM, this must be 1 3 or 12

    set unit [ get_variable_value PPIU($index) ]
    set indm1 [ expr $index -1 ] 
    set element [lindex $value $indm1 ]
    if {$element < 1 || $element > 99999 } {	    
	error_message .d {Range} "Column 'Period' in table 'PP files'\
          must be in the range 1 to 99999." warning 0 {OK}
        return 1
    } elseif {$unit=="RM" && $element!=1 && $element!=3 && $element!=12 } {	    
	error_message .d {Invalid Response} "Column 'Period' in table 'PP files'\
          must be 1, 3 or 12 if 'unit' is RM. See row  PP$indm1." warning 0 {OK}
        return 1
    }


    return 0
}
