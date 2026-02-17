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
                     # includes procedures like navspec: initproc quitproc closeproc
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

################################################

proc close_pushed {win window_name closeproc} {
    global save_done processing_done
	global variables_on_window history_var
	global env exp_id job_id 
	global createhistflag
	
	update_variables $win

	
	#	ILP procedure BG
	if {$createhistflag == 1} {
		set path [get_variable_value JOB_OUTPUT]

		if {$path == ""} {
			set histflag 0
		} else {
			set histflag 1
			set histdir $env(HOME)/$path/job_hist
			file mkdir $histdir
#			set filename $histdir/HIST_$exp_id$job_id
			set filename $histdir/SESSION_$exp_id$job_id            
		}
	
		if {$histflag == 1} {
			compare_vars $win $window_name $filename
		}
	}
#	ILP procedure END
	

    #print_window stdout 80 $window_name 0
    if [verify_variables $win $window_name] {
	set save_done 0
	set processing_done 0
	remove_cases $win
	remove_window $win
	if {$closeproc!="NONE"} {eval $closeproc}
    }
}

# ===============
# ILP procedures 
# ===============

# tcl::compare_vars --
#
#	Compares values of variables which window has during
#	open and close events. If there is a difference, than
#	record with differences is creating and writing to
#	HIST_<experiment_ID>,job_ID file in umui_jobs directory.
#
# Arguments:
#	win		 the name of window checked	
#	filename full pathname for history file
#
# Results:
# 	No return value

proc compare_vars {win window_name filename} {
	global variables_on_window
	global history_var
	global row_diff

	set n [llength $variables_on_window($win)]
	set j 0

# puts $variables_on_window($win)

	for {set i 0} {$i<$n} {incr i} {
		set varname [lindex $variables_on_window($win) $i]
		set old_value [lindex $history_var($win) $i]
		set new_value [get_variable_value $varname]
			
		if {$new_value != $old_value} {
			set var_info [get_variable_info $varname]
			set var_txt [lindex $var_info 10]
			incr j
			set row_diff($j-txt) $var_txt
			set row_diff($j-old) $old_value
			set row_diff($j-new) $new_value
		}
	}
	
	if {$j > 0} {
		write_diff_record $j $window_name $filename
	}
	if {[array exists row_diff]} {
		unset row_diff
	}
}


# tcl::write_diff_record --
#
#	Formated writing into HIST_<exp_ID><job_ID> file.
#
# Arguments:
#	n		number of differences
#	win		the name of window checked	
#	fileame	file name for writing into
#
# Results:
# 	No return value

proc write_diff_record {n win_name filename} {
	global row_diff
	
	set sep_line "========================================================="
	set empty "                                         "
	set sep_field " "
	set date_stamp  [clock format [clock seconds] \
			-format Date:%t%d/%h/%y%tTime:%t%H:%M]
	
	set w1 "Window: "
	set wintitle $w1$win_name
	set fileid [open $filename "a"]

	puts $fileid $sep_line
	puts $fileid $date_stamp
	puts $fileid $wintitle
	puts $fileid $sep_line
	
	for {set i 1} {$i<=$n} {incr i} {

		set lntxt [format_string $row_diff($i-txt) 40 L]
		set lnold [format_string $row_diff($i-old) 30 L]
		set lnnew [format_string $row_diff($i-new) 30 L]
		
		puts -nonewline $fileid $lntxt
		puts -nonewline $fileid $sep_field
		puts $fileid $lnold
		puts -nonewline $fileid $empty
		puts $fileid $lnnew
		puts $fileid $empty

	}
	close $fileid
}

# tcl::format_string --
#
#	Cuts or extends with spaces passed string 
#	to the length desired
#
# Arguments:
#	str		 string passed
#	width	 the desired length 	
#	position orientation L/R left/right
#
# Results:
# 	No return value

proc format_string {str width position} {

	set b " "
	set len [string length $str]
	
	if {$len > $width} {
		set res [expr $len - $width]
		set a [string replace $str $width [expr $len - 1]]
	} elseif {$width > $len} {
		set res [expr $width - $len]
		set c [string repeat $b $res]
		if {$position == "L"} {
			set a $str$c	
		} elseif {$position == "R"} {
			set a $c$str
		}
	} else {
		set a $str
	}
	
	return $a
}

# =================================================
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

	set returnvalue 1

    foreach var $variables_on_window($win) {
	set grey [grey_status $var $window_name]
	if [check_variable_value $var [get_variable_value $var] scalar -1 1] {
		set returnvalue 0
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
			set returnvalue 0
		}
	    }
	}
    }
    return $returnvalue
	
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
	global history_var

    # Clean up all the variables related to the window
    set tables [getTableList $win]
    #puts "Removing tables $tables"
    foreach n $tables {
	# Destroy table and related variables

	GHUIdestroyTable $n
	# Destroy link between table and the panel
	removeFromTableList $win $n
    }
	
	unset history_var($win)
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

