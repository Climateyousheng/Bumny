proc wn_atmos {} {
    
    global fv_variable_name fv_index 
    # set window name for elements of ATMOS_, INDEP_SR and _SM

    # prefix of variable is same as prefix of associated system variable
    set splitvar [split $fv_variable_name "_"]
    set prefix [lindex $splitvar 0 ]

    # start is set to the lindex of the first element in the list to be checked
    set listarray "$prefix\_SI"
    
    set var_data [get_variable_value $listarray\($fv_index\)]
    set window [lindex $var_data 2]
    set winmessage "window $window"
    lappend list $winmessage
    lappend list $window
    return $list
}
		

proc wn_acon_ocon {} {


    # Window names for  ACON W errors
    # Window names for  AFRE W errors
    # Window names for  ATUN W errors
    # Should be called with index taking account of any start index

    global fv_index fv_variable_name

    # submodel A dependent on first character of variable
    set vname [lindex [split $fv_variable_name "()"] 0]
    set subm [string index $fv_variable_name 0 ]

    set var_data [get_variable_value $subm\_STASHAN\($fv_index\)]

    set window [lindex $var_data 3]
    set winmessage "window $window"
    lappend list $winmessage
    lappend list $window
    return $list
    
}


proc wn_afile {} {

    # window names for AFILE,APATH

    global fv_index fv_variable_name

    # submodel is determined by first character
    set vname [lindex [split $fv_variable_name "()"] 0]
    set subm [string index $fv_variable_name 0 ]


    set var_data [get_variable_value ANCIL_LIST$subm\($fv_index\)]

    set window [lindex $var_data [expr [llength $var_data]-1]]
    set winmessage "window $window"
    lappend list $winmessage
    lappend list $window
    return $list

}

    










