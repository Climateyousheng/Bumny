proc afile {value variable index} {

    #  this procedure tests to see if files need to be named.
    #  used for verification of AFILE, APATH.
    #  System variable ANCIL_LISTA define which fields live in 
    #  which files. Tracers are treated specially.
    # 

    if [regexp {\(|\)} $variable] {
	return [afile2 $value $variable]
    } else {

	set var "$variable\($index\)"
	set val [get_variable_value $var]
	return [afile2 $val $var]
    }
}

proc afile2 {value variable} {

    global verify_flag 
    #puts "afile: $variable = $value"

    if { $value != "" } { return 0 } ; # only worry if the file is not filled in.

    set subm [ string index $variable 0 ]
    set list_name ANCIL_LIST$subm
    set con_name $subm\CON
    if { [ string index $variable 1 ] == "F" } {
	    scan $variable "$subm\FILE(%d)" file_index   ; # which file index ? 
    } else {
	    scan $variable "$subm\PATH(%d)" file_index   ; # which file index ? 
    } 
    #puts "  using: $list_name\($file_index\)=\"[get_variable_value $list_name\($file_index\)]\""
    set an_list [ get_variable_value $list_name\($file_index\) ]
    if { [ lindex $an_list 1 ] == "NONE" } {
	if {$verify_flag==1} {
	    error "Unexpected call to function afile. $list_name is set to <NONE> "
	} else {
	    return 0
	}
    }

    # 1st element if F01 etc. Ignore
    set an_length [ expr [ llength $an_list ] -1 ] 
    set pos 1

    while { $pos < $an_length } {
	#    loop over elements, while used because of SLAB and tracers.     
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
		error_message .d {File Not Defined} "You are using the contents of the tracer file. See Tracer settings. Name and directory must be set." warning 0 {OK}
		return 1
	    }
	} else {
	    # Standard element. See if ACON(element) is used
	    #puts "  using: $con_name\($list_val\)=\"[get_variable_value $con_name\($list_val\)]\""
	    set con [ get_variable_value $con_name\($list_val\) ]
	    if { ($con == "U") || ($con == "C") } {
		error_message .d {File Not Defined} "You are using the contents of this file. Name and directory must be set." warning 0 {OK}
		return 1
	    }
	}
    } 
    return 0
}
