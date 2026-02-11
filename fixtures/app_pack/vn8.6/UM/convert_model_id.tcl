# convert model number to model letter
proc modnumber_to_letter {number} {
    if { $number < 1 || $number > 4} {
	error "Unknown model number $number - should be 1 2 3 or 4"
    }
    return [  get_variable_value MODEL_ID($number) ] ; # A,O,S,W
}



# convert model letter to upper case model name
proc modnumber_to_name {number} {
    if { $number < 1 || $number > 4} {
	error "Unknown model number $number - should be 1 2 3 or 4"
    }
    return [  get_variable_value MODEL_NAME($number) ] ; # ATMOS, etc
}


# Convert uppercase model letter to model number
#
# Called from processing stashc_all
#
proc modletter_to_number {letter} {
    if { $letter != "A" && $letter != "O" && $letter != "S" && $letter != "W" } {
	error "Unknown model letter $letter - should be A O S or W"
    }
    # Returns 1 2 3 or 4
    return [string first $letter "_AOSW"]
}

