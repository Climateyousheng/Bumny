proc ppis {value variable index} {
    # verification function for PPIS
    # each index must be in range 0 9999
    # additionally, if any are RM, this must be 0

    set unit [ get_variable_value PPIU($index) ]
    set indm1 [ expr $index -1 ] 
    set element [lindex $value $indm1 ]
    if {$element < 0 || $element > 9999 } {	    
      # Add exception for unit==TS (allow -1)
      if {$unit =="T" && $element == -1} {
         # This is okay, so return 0
         return 0
      }
	error_message .d {Range} "Column 'Starting' in table 'PP files'\
          must be in the range 0 to 9999." warning 0 {OK}
        return 1
    } elseif {$unit == "RM" && $element != 0 } {	    
	error_message .d {Invalid Response} "Column 'Starting' in table 'PP files'\
          must be 0 if 'unit' is RM. See row  PP$indm1." warning 0 {OK}
        return 1
    }


    return 0
}
