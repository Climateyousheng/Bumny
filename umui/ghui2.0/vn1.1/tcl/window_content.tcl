# window_content.tcl
#
#    Tcl procedures that return lists of information parsed from control 
#    files.
#
#----------------------------------------------------------------------

# window_content
#    Adds a list of variables contained in a window to the window_content
#    array and returns list.
#
# Argument
#    pan : Name of window to be read.
#
# Result 
#    A list of variables used in window.
# 
# Method
#    When called, stores result in global array so that if called a 
#    second time with the same panel name the work is not repeated
#
proc window_content {pan win_text} {
    global window_content

    if [info exists window_content($pan)] {
	# Window has already been read in a previous execution
	return $window_content($pan)
    }

    set var_list ""

    foreach line $win_text {
	if {[component_text $line [list .entry .check .element .set_on_closure .basrad]]!=0} {
	    lappend var_list [variable_on_line $line]
	}
    }
    
    set window_content($pan) $var_list
    return $var_list
}

# get_window_text
#    Returns list of text contained within a panel definition file
#    once any .include text has been added
# 
# Argument
#    pan: Name of panel
# Result
#    Returns a tcl list of lines in .pan file after substituting
#    any .include lines

proc get_window_text {pan} {
    set f [open [window_file $pan]]
    set win_text [split [read $f] \n]
    close $f
    foreach line $win_text {
	if {[lindex $line 0]==".include"} {
	    set new_text [concat $new_text [split [insert_include $line] \n]]
	} else {
	    lappend new_text $line
	}
    }
    return $new_text
}

# list_of_panels
#     Returns a list of all ...p panels in nav.spec

proc list_of_panels {} {

    set win_list {}
    set a [open [navspec_file]]

    gets $a line
    while {$line!=""} {
	# Ignore commented lines
	if  {[string index $line 0]=="#"} {
	    gets $a line
	    continue
	}

	# Ignore ..t branches: If one found, look for next node
	set i0 [lindex $line 0]
	if [regexp "t" $i0] {
	    gets $a line
	    while {[regexp {n} [lindex $line 0]]==0} {
		gets $a line
		if {$line==""} {
		    # End of file reached while looking for next node
		    break
		}
	    }
	    set i0 [lindex $line 0]
	}
	
	set level [string length $i0]
	set type [string index $i0 [expr $level-1]]
	if {$type=="p"} {
	    lappend win_list [lindex $line 1]
	}
	gets $a line
    }
    close $a
    return $win_list

}
