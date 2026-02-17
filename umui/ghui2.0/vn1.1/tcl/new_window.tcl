proc new_window {winid title component_script} {
    # component script contains all commands as concatenated by parse_window
    # This routine sets up all the variables for controlling the window,
    # creates the window, backs up variables, greys out appropriate parts
    # and finally sets the focus to the top-most active component of the window

    global win block_indentation block_nest component_count in_block tab_list
    global block_count buttons variables_on_window entry_boxes cases_on_window
    global in_case in_invis case_no grayout_expressions invis_expressions
    global in_colour colour_list job_title
    global in_table tables_on_window table_columns exp_id job_id

    set toplevelWin .$winid
    if {[info commands $toplevelWin] == "$toplevelWin"} {
	wm iconify $toplevelWin
	wm deiconify $toplevelWin
	return
    }
    toplevel $toplevelWin
    wm withdraw $toplevelWin
    wm title $toplevelWin "$title : $job_title"
    wm iconname $toplevelWin "   $exp_id$job_id:    $title"
    wm iconbitmap $toplevelWin "@[ghui_version_path]/icons/nav.xbm"

    # The next few lines put the panel onto a scrolling canvas
    set parent $toplevelWin.f
    # Make max size fractionally smaller than screen size
    # If same size is set, large windows get an extra resized 
    # causes unneeded scrollbar
    set maxX [int [expr .99* [winfo screenwidth .]]] 
    set maxY [int [expr .99*[winfo screenheight .]]]
    set win [swSetFrame $parent $maxX $maxY]

    # The next four lines are the alternative old method
    #pack [canvas $win.c] -expand y -fill both
    #set toplevelWin $win
    #pack [frame $win.c.f]  -expand y -fill both
    #set win $win.c.f

    set block_indentation 0
    set block_nest 0
    set component_count 0
    set block_count 0
    set in_block 0
    if [info exists buttons] {unset buttons}
    set variables_on_window($win) {}
    set entry_boxes($win) {}
    set cases_on_window($win) {}
    set in_case 0
    set in_invis 0
    set in_colour 0
    if {! [info exists case_no]} {
	set case_no 0
    }
    set tab_list($win) {}
    set tab_list($win,lr) {}
    set grayout_expressions {}
    set invis_expressions {}
    set colour_list "normal"
    set in_table 0
    set tables_on_window($win) {}
    set table_columns($win) {}

    eval $component_script
    # update ensures tk knows how big the table is before it is displayed
    #update idletasks
    backup_variables
    invoke_all_cases
    # update ensures invoking of invisibles is done before the deiconify
    update idletasks
    # Gridded geometry causes minor problems with scrollWidget so turn it off
    wm grid $toplevelWin "" "" "" ""
    wm deiconify $toplevelWin
    focus_on_pan $win

}

proc focus_on_pan {window} {
    # Set focus on to uppermost active component
    # If there aren't any active components set focus on panel
    # and bind close,abandon etc keys to it

    if {[set_focus $window]==0} {
	push_focus $window
	button_bindings $window $window
    }
}


proc set_focus {window} {
    # Set focus to uppermost active component of window
    # or return 0 if there aren't any
    global tab_list

    foreach item $tab_list($window) {
	#puts "item $item, activity [active_component $window $item]"
	if {[active_component $window $item]==0} {
	    #puts "initial focus setting $item ? set the focus ?"
	    if {[set focus [focus_component $window $item]]!=0} {
		push_focus $focus
		return 1
	    }
	}
    }
    return 0
}

proc component_name {side} {
    # Creates a unique descriptive component name

    global win component_count in_block block_count in_invis cases case_no_i

    if {! $in_block && $side != "right"} {
	block_start 0 0
    }
    if $in_invis {
	set c [lindex $cases($case_no_i) 6].$block_count
    } else {
	set c $win.$block_count
    }
    switch $side {
	left {set c $c.l}
	right {set c $c.r}
	centre {set c $c}
	default {error "Invalid argument to component_name"}
    }
    incr component_count
    return $c.$component_count
}


proc invoke_all_cases {} {
    # Call routines to grey out or invisible any inactive parts of the window

    global cases_on_window win

    foreach i $cases_on_window($win) {
	evaluate_case $i
    }
}

####################################################################
# The following routines are concerned with moving around a window #
# panel using the keyboard                                         #
####################################################################

proc tab {win} {
    # Moves focus down the window panel
    focus [next_component $win [focus] 1]
}

proc tab_up {win} {
    # Moves focus up the window panel
    focus [next_component $win [focus] -1]
}

# leaveWidget
#   Called when Tab pressed while focus in a complex widget such as 
#   a table. Here $component identifies the widget but is not necessarily
#   a tk widget name. All subcomponents are given a binding to call 
#   this routine on a particular action.

proc leaveWidget {win component} {
    
    global tab_list
    focus [next_component $win $component 1]
}

proc next_component {win component direction} {
    # Finds next component on window after $component in direction $direction
    # (1 for down and -1 for up). If the component is inactive it recursively
    # calls itself to find the next one again.
    # If the component is a table, it finds an active column on the table.
    # If all columns inactive it does a recursive call to find next component.
    # NB If, somehow, this is called when there are no active components it
    # will go into an endless recursive loop.
    global tab_list
  
    set i [lsearch $tab_list($win) $component]

    incr i $direction

    # At end/beginning of list ?
    if {$i >= [llength $tab_list($win)]} {
	set i 0
    } elseif {$i < 0} {
	set i [expr [llength $tab_list($win)]-1]
    }

    set new_component [lindex $tab_list($win) $i]
  
    # If next component is invisible or greyed out then move down again
    if [active_component $win $new_component] {
	set new_component [next_component $win $new_component $direction]
    }

    # focus_component will return a widget name for where to set focus
    # (the same name for entry, radio and check boxes)
    # or will return 0 if it fails (ie if a table is active but all
    # columns in the table are inactive
    if {[set focus [focus_component $win $new_component]]==0} {
	set focus [next_component $win $new_component $direction]
    }

    # Return name of active component
    return $focus
}

proc focus_component {win component} {

    if [is_this_a_table $win $component] {
	# This component is a table - find a point to focus on
	# Or return 0 if all columns inactive
	return [getActiveColumn $component]
    } else {
	# Normal component so return the same name
	return $component
    }
}

proc is_this_a_table {win component} {
    # Checks whether component is a table or not

    set tables [getTableList $win]

    if {[lsearch $tables $component] >= 0} {
	return 1
    }

    return 0
}

proc tab_lr {win direction} {
    # For radio buttons laid out horizontally
    # $direction is l r u or d for left right up or down
    # Moves focus in appropriate direction

    global tab_list

    # Lists of components stored in a separate array list delimited by "END"
    set i [lsearch $tab_list($win,lr) [focus]]

    #puts "tab list is $tab_list($win,lr) direction is $direction"
    #puts "Focus currently on index $i: [lindex $tab_list($win,lr) $i]"

    if {($direction=="l")||($direction=="r")} {
	# Move left or right unless already at edge
	if {$direction=="l"} {set d -1} else {set d 1}

	incr i $d
	if {[lindex $tab_list($win,lr) $i]!="END"} {
	    focus [lindex $tab_list($win,lr) $i]
	}
    } else {
	# Move up or down
	# Left-most component is also in tab_list($win) so set focus to
	# this component, then call next_component with appropriate direction
	while {[lindex $tab_list($win,lr) [expr $i-1]]!="END"} {
	    incr i -1
	}
	set focus [lindex $tab_list($win,lr) $i]
	if {$direction=="u"} {
	    focus [next_component $win $focus -1]
	} else {
	    focus [next_component $win $focus 1]
	}
    }
}



proc backup_variables {} {
    # Saves variable names in case Abandon is selected by user
    global win variables_on_window

    foreach var $variables_on_window($win) {
	backup_variable $var
	backup_link_variables $var
    }

    set tables [getTableList $win]
    foreach n $tables {
	# Check each writable variable on the table
	for {set i 0} {$i < [GHUITableNCols $n]} {incr i} {
	    if [GHUITableColumnActive $n $i] {
		set var [GHUITableVariable $n $i]
		# There is a bug in backup_variable/restore_variable for
		# array variables so use a Tcl written version
		backupTableVar $var
		# NB: In creation of new window, index variables also
		# need to be backed up. These are modified on the 
		# creation of the table so they have to be backed 
		# up by the tableSetup code.
	    }
	}
    }
}
