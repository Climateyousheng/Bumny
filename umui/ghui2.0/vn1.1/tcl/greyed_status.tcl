proc grey_status {var win} {
    # Return 1 if variable greyed out and zero if not
    # Returns -2 or -1 if cannot find variable or window

    set greylist 0
    set found 0
    set level 0
    set grey 0

    set win_file [window_file $win]
    if {[file exists $win_file]==0} {return -1}
    set a [open $win_file]
    set win_text [split [read $a] \n]

    set new_text {}
    foreach line $win_text {
	if {[lindex $line 0]==".include"} {
	    set new_text [concat $new_text [split [insert_include $line] \n]]
	} else {
	    lappend new_text $line
	}
    }
    set win_text $new_text


    foreach line $win_text {
	set command [lindex $line 0]
	if {[set vol [variable_on_line $line]]!="0"} {
	    # These lines contain variables.
	    if {$var==$vol} {
		# Variable is on this line so return current grey status
		set found 1
		break
	    }
	}
	if {($command==".case")||($command==".invisible")||($command==".inactive")} {
	    # need to check logic
	    set condition [lrange $line 1 end]
	    set on [convert_expression $condition]
	    if {[eval_logic $on]} {
		# Logic says 'active'. Grey status will not have changed
		lappend greylist $grey
	    } else {
		# greyed out
		lappend greylist 1
		set grey 1
	    }
	    incr level
	}
	if {($command==".caseend")||($command==".invisend")||($command==".inactiveend")} {
	    # Remove last case from list
	    set level [expr $level-1]
	    set greylist [lrange $greylist 0 $level]
	    set grey [lindex $greylist $level]
	}
    }
    close $a
    if {$found==0} {return -2}
    #puts "checking $var grey=$grey"
    return $grey
}


