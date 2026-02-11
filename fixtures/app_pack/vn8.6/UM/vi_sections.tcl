proc vi_sections {variable call_type index} {

    # inactive checking of ATMOS_SR, INDEP_SR
    # Cross-checks values of variables against lists of allowed values in system register
    # Should be called with index taking account of any start index

    if {$call_type=="PRELIM"} {
	# Preliminary check - this function deals with variable element by element
	# so return 2 meaning cannot evaluate yet
	return 2
    }

    set var_info [get_variable_info $variable]
    set help_text [lindex $var_info 10]
    set splitvar [split $variable "_()"]
    set prefix [lindex $splitvar 0 ]

    set in_use [lindex [get_variable_value $prefix\_SI\($index\)] 0]
    if {$in_use!="Y" && $in_use!="U"} {
	# Element not in use so end checking (apart from following system check)
	# NB "U" setting means used in UMUI and UPDEFS but not SECT_MODE file
	if [regexp {\(|\)} $variable] {
	    # System error - variable is listed as not being in use but function has been 
	    # called following window closure
	    error "Unexpected call to function vi_sections. $prefix\_SI\($index\) is listed as not used. Please report"
	}
	return 1
    } else {
	# This index is in use _SR variables are active but compile mode variables depend on _SR

	if {[regexp {_SR} $variable] == 0} {	
	    # Checking compile mode variables
	    if {[get_variable_value $prefix\_SR\($index\)]=="0A"} {
		# inactive
		return 1 
	    } 
	}
	return 0
    }
}

