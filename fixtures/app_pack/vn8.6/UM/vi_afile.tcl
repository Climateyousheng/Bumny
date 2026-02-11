proc vi_afile {variable call_type index} {
    # Inactive checking of AFILE, APATH etc


    if { $call_type=="PRELIM" } {
	# On windows, Input boxes are never greyed out so do not evaluate on preliminary
	# call otherwise may cause a consistency_check
	# On Check Setup, elements need to be checked one by one.
	return 2
    }

    if [regexp {\(|\)} $variable] {
	# Called following window closure
	return [vi_afile2 $variable]
    } else {
	# called during Check Setup
	set var "$variable\($index\)"
	return [vi_afile2 $var]
    }
}


proc vi_afile2 {variable} {

    global verify_flag 
    #puts "afile: $variable"

    # Get appropriate list name etc given variable name
    # and get file index
    set subm [ string index $variable 0 ] 
    set list_name ANCIL_LIST$subm
    set con_name $subm\CON
    if { [ string index $variable 1 ] == "F" } {
	    scan $variable "$subm\FILE(%d)" file_index   ; # which file index ? 
    } else {
	    scan $variable "$subm\PATH(%d)" file_index   ; # which file index ? 
    } 

    #puts "  using: $list_name\($file_index\)=\"[get_variable_value $list_name\($file_index\)]\""

    # Get list of indices etc with which to check whether file needs to be filled in
    set an_list [ get_variable_value $list_name\($file_index\) ]
    if { [ lindex $an_list 1 ] == "NONE" } {
	if {$verify_flag==1} {
	    # Inactive elements should not be on windows
	    error "Unexpected call to function afile. $list_name is set to <NONE> "
	} else {
	    # Check Setup: This element is inactive
	    return 1
	}
    }

    # 1st element if F01 etc. Ignore
    set an_length [ expr [ llength $an_list ] -1 ] 
    set pos 1

    while { $pos < $an_length } {
	# loop over elements, while used because of tracers.     
	# NB last element in list is window name - this is not checked
	set list_val [ lindex $an_list $pos ]
	incr pos
	if { $list_val == "TRACERS" } {
	    set pos [expr $an_length + 1 ] ; # force end of loop.
	    set codes [ get_variable_array TCA ]
	    set use_tca [ get_variable_value USE_TCA ]
	    set init [ lsearch $codes 2 ]
	    set upd [ lsearch $codes 3 ]
	    if { (($init != -1) || ($upd != -1)) && ($use_tca == "Y")} {
		# Element is active
		return 0
	    }
	} else {
	    # Standard element. See if ACON(element) is used
	    #puts "  using: $con_name\($list_val\)=\"[get_variable_value $con_name\($list_val\)]\""
	    set con [ get_variable_value $con_name\($list_val\) ]
	    if { ($con == "U") || ($con == "C") } {
		# Element is active
		return 0
	    }
	}
    }
    # Element is inactive
    return 1
}
