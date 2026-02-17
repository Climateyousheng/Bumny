# read_link_variables
#    Reads in a list of link variables, the functions that set
#    them and the GHUI variables on which they depend.
# Globals
#    link_variables : An array indexed by link variable. Each index
#                     is a list of variables on which link variable
#                     depends
#    link_function  : An array indexed by link variable. Each index
#                     is set to the function that sets the link var
# Method
#    Called from load_variables so that link variables are reset
#    after hand edits or uploads ect.

proc read_linked_variables {} {
    global link_variables link_function
    catch {unset link_variables}
    set link_variables() ""
    set link_file [directory_path windows]/links

    if [file readable $link_file] {
	set fn [open $link_file]
	while {[gets $fn line] != -1} {
	    if {[string index $line 0]=="#"} {continue}
	    set link_variable [lindex $line 0]
	    set link_function($link_variable) [lindex $line 1]
	    $link_function($link_variable)
	    foreach var [lrange $line 2 end] {
		lappend link_variables($var) $link_variable
	    }
	}
	close $fn
    }
}
	


#    link_variable: name of "link-variable"
#    function     : name of function that sets link-variable
#    args         : list of variables to which link-variable is linked


#    link_variable: name of link-variable

proc linked_variable_changed {link_variable_list} {

    global sensitive_variables link_function

    foreach var $link_variable_list {
	#set before [get_variable_value $var]
	$link_function($var)
	#puts "Called $link_function($var) to set $var from $before to [get_variable_value $var]"
	if [check_variable_value $var [get_variable_value $var] scalar -1 2] {
	error "SYSTEM ERROR: Link variable $var took on invalid value [get_variable_value $var] .\
		Please report"
	}

	if [info exists sensitive_variables($var)] {
	    foreach case_no $sensitive_variables($var) {
		evaluate_case $case_no
	    }
	}
    }
}

# backup_link_variables
#    Backs up any variables linked to variables on window.
# Argument
#    var: Name of variable on window

proc backup_link_variables {var} {
    global link_variables
    if [info exists link_variables($var)] {
	foreach link $link_variables($var) {
	    backup_variable $link
	}
    }
}
    
# restore_link_variables
#    Restores any variables linked to variables on window.
# Argument
#    var: Name of variable on window

proc restore_link_variables {var} {
    global link_variables
    if [info exists link_variables($var)] {
	foreach link $link_variables($var) {
	    restore_variable $link
	}
    }
}
    
