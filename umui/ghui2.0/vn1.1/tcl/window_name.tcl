proc set_winname {} {

    # Produces message and window name relating to location of the
    # global variables fv_variable_name and fv_index
    # Also uses global win_prefix for dealing with cross submodel variables.

    global fv_variable_name fv_index

    # If 2D array, set fv_index to index in variable name
    if [regsub {\*,} $fv_variable_name {} temp] {
	set fv_index [lindex [split $temp "()"] 1]
    }
    return [set_window_name $fv_variable_name $fv_index]
}


proc set_window_name {variable index} {
    
    global fv_variable_name fv_index
    global win_prefix

    set fv_variable_name $variable
    set fv_index $index

    set var_info [get_variable_info $variable]

    # Get window name as listed in var.register and also get its prefix
    set window [lindex $var_info 5]
    set winpref [lindex [split $window "_"] 0]

    if [regsub "FN:" $window {} winfn] {
	# Window name and location description obtained using a function.
	set list [$winfn]
    } elseif [info exists win_prefix($winpref)] {
	# Prefix implies this is a cross-partition variable
	# Actual window name is obtained by replacing prefix with appropriate
	# partition name
	regsub [lindex $win_prefix($winpref) 0] $window [lindex $win_prefix($winpref) $index] window
	set winmessage "window $window"
	lappend list $winmessage 
	lappend list $window

    } else {
	# Straightforward window name.
	set winmessage "window $window"
	lappend list $winmessage 
	lappend list $window
    }
    # Return two string list containing a location message and a window name
    return $list
}

proc compare_list {value list start} {

    # Cross-checks value against a list of allowed values stored in $list.
    # $start is start point in the line for checks; generally first few
    # elements are used for storing other information about the variable
    # returns 1 if value is in list

    #puts "Value $value must be in $list"

    for {set i $start} {$i<=[expr [llength $list]-1]} {incr i} {
	if {$value==[lindex $list $i]} {return 1}
    }
    return 0
}










