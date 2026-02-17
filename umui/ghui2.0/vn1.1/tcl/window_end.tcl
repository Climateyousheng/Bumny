proc pushquit_component {button_text} {
  global buttons
  upvar quit_proc quit_proc
  if [info exists quit_proc] {
    set buttons(quit_proc) $quit_proc
  } else {
    set buttons(quit_proc) "NONE"
  } 
  set buttons(quit) $button_text
}

proc pushclose_component {button_text} {
  global buttons
  upvar close_proc close_proc
  if [info exists close_proc] {
    set buttons(close_proc) $close_proc
  } else {
    set buttons(close_proc) "NONE"
  } 
  set buttons(close) $button_text
}

proc pushnext_component { button_text next_window} {
  # .pushnext can be called wih an optional argument that specify a funtion
  # on entry (initproc) abandon (quitproc) and  close (closeproc), like in navspec.
  global buttons
  upvar close_proc close_proc
  if [info exists close_proc] {
    set buttons(close_proc) $close_proc
  } else {
    set buttons(close_proc) "NONE"
  } 
  lappend buttons(next) "$button_text $next_window"
}

proc pushand_component { button_text and_window} { 
    # .pushnext can be called wih an optional argument that specify a funtion
    # on entry (initproc) abandon (quitproc) and  close (closeproc), like in navspec.
    global buttons
    lappend buttons(and) "$button_text $and_window"
}

proc pushhelp_component {button_text} {
    global buttons
    # Add button called "Help", bound to proc window_help
    lappend buttons(general) "Help window_help"
}

# Generic button component for calling application specific routines
proc pushbutton_component {args} {
    global buttons
    lappend buttons(general) $args
}

proc end_of_window  {} {
    global buttons win
    global window_name close_proc quit_proc
    global tab_list
    global exp_id job_id

    set first_button ""
    set window_file [string range [toplev_name $win] 1 end]
    set c [component_name centre]
    frame $c
    pack $c -fill x
    lappend tab_list($win,lr) "END"

    if [info exists buttons(general)] {
	set i 1
	foreach item $buttons(general) {
	    button $c.g$i -relief raised -text [lindex $item 0] \
		    -command "[lindex $item 1] $window_file [lrange $item 2 end]"
	    pack $c.g$i -side left -fill x -expand yes -padx 1m -pady 1m -ipadx 1m -ipady 1m
	    
	    set command [lindex $item 1]_active_status
	    set active_status 1
	    if {[info commands $command]=="$command"} {
		set active_status  [eval "$command $window_file [lrange $item 2 end]"]
	    }

	    if {! $active_status} {
		$c.g$i configure -state disabled
	    } else {
		if {$first_button==""} {set first_button $c.g$i}
		lappend tab_list($win,lr) $c.g$i
		binding_of_buttons $win $c.g$i 
	    }
	    incr i
	}
    }
	
    if [info exists buttons(quit)] {
	button $c.q -relief raised -text $buttons(quit) \
                -command "quit_pushed $win \{$buttons(quit_proc)\}"
	pack $c.q -side left -fill x -expand yes \
		-padx 1m -pady 1m -ipadx 1m -ipady 1m

	lappend tab_list($win,lr) $c.q
	if {$first_button==""} {set first_button $c.q}
	binding_of_buttons $win $c.q
    }

    if [info exists buttons(close)] {
	button $c.c -relief raised -text $buttons(close) \
                -command "close_pushed $win $window_name \{$buttons(close_proc)\}"
	pack $c.c -side left -fill x -expand yes \
		-padx 1m -pady 1m -ipadx 1m -ipady 1m

	lappend tab_list($win,lr) $c.c
	if {$first_button==""} {set first_button $c.c}
	binding_of_buttons $win $c.c
    }

    if [info exists buttons(next)] {
	set i 1
	foreach button $buttons(next) {
	    button $c.n$i -relief raised -text [lindex $button 0] \
                    -command "next_pushed $win $window_name \{$buttons(close_proc)\} [lindex $button 1]"
                     # includes procedures like navspec:                 initproc              quitproc               closeproc
	    pack $c.n$i -side left -fill x -expand yes \
		    -padx 1m -pady 1m -ipadx 1m -ipady 1m

	    lappend tab_list($win,lr) $c.n$i
	    if {$first_button==""} {set first_button $c.n$i}
	    binding_of_buttons $win $c.n$i

	    incr i

	}
    }

    if [info exists buttons(and)] {
	set i 1
	foreach button $buttons(and) {
	    button $c.a$i -relief raised -text [lindex $button 0] \
                    -command "and_pushed $win [lindex $button 1]"
                     # includes procedures like navspec:                 initproc              quitproc               closeproc
	    pack $c.a$i -side left -fill x -expand yes \
		    -padx 1m -pady 1m -ipadx 1m -ipady 1m
	    lappend tab_list($win,lr) $c.a$i
	    if {$first_button==""} {set first_button $c.a$i}
	    binding_of_buttons $win $c.a$i
	    incr i
	}
    }
    if {$first_button!=""} {lappend tab_list($win) $first_button}
    lappend tab_list($win,lr) "END"

    set c [component_name centre]
    label $c -text "Window Name : [string range [toplev_name $win] 1 end].    Job $exp_id\.$job_id."
    pack $c
}

proc close_pushed {win window_name closeproc} {
    global save_done processing_done
    update_variables $win
    #print_window stdout 80 $window_name 0
    if [verify_variables $win $window_name] {
	set save_done 0
	set processing_done 0
	remove_cases $win
	remove_window $win
	if {$closeproc!="NONE"} {eval $closeproc}
    }
}

proc next_pushed {win window_name closeproc next_window} {

    global save_done processing_done
    update_variables $win
    if [verify_variables $win $window_name] {
	set save_done 0
	set processing_done 0
	remove_cases $win
	remove_window $win
	if {$closeproc!="NONE"} {eval $closeproc}

	create_window $next_window
    }
}

proc and_pushed {win and_window} {

    create_window $and_window

}


proc quit_pushed {win quitproc} {
    global save_done processing_done

    restore_variables $win
    remove_cases $win
    remove_window $win
    if {$quitproc!="NONE"} {
	# The quit_proc may change something so...
	set save_done 0
	set processing_done 0
	eval $quitproc
    }
}


proc update_variables {win} {

    global entry_boxes

    if [info exists entry_boxes($win)] {
	foreach box $entry_boxes($win) {
	    set variable [lindex $box 0] 
	    set varvalue [[lindex $box 1] get]
	    set_variable_value $variable $varvalue
	}
    }
    #puts "setTableVars $win"
    setTableVars $win
}


proc verify_variables {win window_name} {

    global variables_on_window
    global grey

    foreach var $variables_on_window($win) {
	set grey [grey_status $var $window_name]
	if [check_variable_value $var [get_variable_value $var] scalar -1 1] {
	    return 0
	}
    }

    set tables [getTableList $win]
    foreach n $tables {
	# Check each writable variable on the table
	set size [GHUITableLength $n]
	set nCols [GHUITableNCols $n]
	for {set i 0} {$i < $nCols} {incr i} {
	    if [GHUITableColumnActive $n $i] {
		set var [GHUITableVariable $n $i]
		set grey [grey_status $var $window_name]
		if [check_variable_value $var [get_variable_array $var] array $size 1] {
		    # Error produced so return
		    return 0
		}
	    }
	}
    }
    return 1
}


# restore_variables
#   Window abandoned, so restore values of all variables.
# Argument
#   win : Widget name and array id

proc restore_variables {win} {

    global variables_on_window

    # Restore all the scalar variables and variables linked to them
    foreach var $variables_on_window($win) {
	restore_variable $var
	restore_link_variables $var
    }

    # Restore all arrays on tables
    set tables [getTableList $win]
    foreach n $tables {
	# Check each writable variable on the table
	set indexList {}
	for {set i 0} {$i < [GHUITableNCols $n]} {incr i} {
	    if [GHUITableColumnActive $n $i] {
		# Get name of variable from a given column
		set var [GHUITableVariable $n $i]
		# There is a bug in backup_variable/restore_variable for
		# array variables so use a Tcl written version.
		restoreTableVar $var

		# Also need to backup index variables. But index variables
		# are commonly used on more than one column, so use the 
		# indexList to make sure each is restored only once
		if {[set index [GHUITableIndexVar $n $var]] != ""} {
		    if {[lsearch $indexList $index] == -1} {
			restoreTableVar $index
			lappend indexList $index
		    }
		}
	    }
	}
    }
}

# remove_window
#   Tidy up, then destroy the window

proc remove_window {win} {

    global variables_on_window tab_list entry_boxes

    # Clean up all the variables related to the window
    set tables [getTableList $win]
    #puts "Removing tables $tables"
    foreach n $tables {
	# Destroy table and related variables
	GHUIdestroyTable $n
	# Destroy link between table and the panel
	removeFromTableList $win $n
    }
    unset variables_on_window($win)
    unset entry_boxes($win)
    foreach element [array names tab_list $win,*] {
	unset tab_list($element)
    }
    unset tab_list($win)
    removeTableVarBackup $win

    # Destroy scrolling frame
    swDestroyFrame $win
    destroy_window [toplev_name $win]
}

# restoreTableVar
#   There is a bug in the C code backup_variable which truncates the
#   restored value to the length of the table on the window if shorter.
#   This function is required to partner the alternative backup function
#   below.

proc restoreTableVar {var} {
    global RestoreArray

    set_variable_array $var $RestoreArray($var)
}

# backupTableVar
#   There is a bug in the C code backup_variable which truncates the
#   restored value to the length of the table on the window if shorter.
#   This is a replacement function

proc backupTableVar {var} {
    global RestoreArray
    
    set RestoreArray($var) [get_variable_array $var]
}

