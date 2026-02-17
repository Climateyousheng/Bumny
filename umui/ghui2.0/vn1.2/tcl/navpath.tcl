# navigation_list
#    Returns an ordered list of all windows, ignoring duplicate windows.

proc navigation_list {} {
    set level 0
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
	set type [string index $i0 [expr [string length $i0]-1]]
	if {$type=="p"||$type==">"} {
	    lappend panel_list [lindex $line 1]
	}
	gets $a line
    }
    close $a
    return $panel_list
}




proc navigation_path {window} {
    # Searches through nav.spec and compiles path to the window listed in 
    # global variable $fv_name_of_window
    # Returns a neatly Formatted text string or 0 if $window not in nav.spec
    
    set level 0
    set failed 1
    set path {}
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
	set type [string index $i0 [expr [string length $i0]-1]]
	if {$type=="t"} {
	    gets $a line
	    while {[regexp {n} [lindex $line 0]]==0} {
		gets $a line
		if {$line==""} {
		    # End of file reached while looking for next node
		    break
		}
	    }
	    set i0 [lindex $line 0]
	    set type [string index $i0 [expr [string length $i0]-1]]
	}

	#puts "[lrange $line 0 1]  $level $path"

	set winname [lindex $line 1]
	
	set level [string length $i0]
	set path [lrange $path 0 [expr $level-3]]
        # puts $line
	lappend path [lindex $line 2]
	#puts $path
	if {($winname==$window)&&($type!="s")} {
	    # Window found
	    set failed 0
	    break
	}

	gets $a line
    }
    close $a
    if {$failed} {
	return 0
    } else {
	return [format_nav_path $path]
    }
}
	

proc format_nav_path {path} {
    # Returns a formatted string containing path to window

    set space "                                "
    for {set i 0} {$i<[llength $path]} {incr i} {
	append form_path "[string range $space 0 [expr $i+$i]]-> [lindex $path $i]\n"
    }
    return $form_path
}

	



