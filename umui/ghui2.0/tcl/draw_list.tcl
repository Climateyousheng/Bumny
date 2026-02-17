# draw the list of experiments and jobs in the entry system.
#

# redraw list from the given position
#
proc move_list first {

    global lines all_lines vis_lines num_lines icons colours titles

    # keep the window full (if possible)
    if {$first > [expr $num_lines - $lines]} {
	set first [expr $num_lines - $lines]
    }
    if {$first < 0} {
	set first 0
    }

    # loop through lines on screen and corresponding index into list of
    # visible lines.
    for {
	set l 1
	set i $first
    } {
	$l <= $lines
    } {
	incr l
	incr i
    } {

	# if past end of visible lines, then blank out line
	if {$i >= $num_lines} {
	    .l$l configure -background $colours(unselect_bg)
	    .l$l.icon configure -bitmap $icons(blank)
	    foreach column $titles(display_columns) {
		.l$l.$column configure -text {} -background $colours(unselect_bg)
	    }
	} else {

	    # find id of line
	    set id $vis_lines($i)
	   
	    # mark as selected or unselected
	    if $all_lines($id-selected) {
		set bg_col $colours(select_bg)
	    } else {
		set bg_col $colours(unselect_bg)
	    }
	    .l$l configure -background $bg_col

	    # fill in fields that are the same for experiments and jobs
	    foreach column $titles(app_columns) {
		set text [format_mix $all_lines($id-$column)]
		.l$l.$column configure -text $text -background $bg_col
	    }
	    
	    foreach column $titles(ghui_columns) {
		switch $column {
		    description {
			.l$l.description configure -text $all_lines($id-description) -background $bg_col
		    }
		    version {
			.l$l.version configure -text $all_lines($id-version) -background $bg_col
		    }
		    id {
			if {[string length $id] == 4} {
			    .l$l.id configure -text $id -background $bg_col
			} else {
			    # just take last letter of job id
			    .l$l.id configure -text [string index $id 4] -background $bg_col
			}
		    }
		    owner {
			if {[string length $id] == 4} {
			    .l$l.owner configure -text $all_lines($id-owner) -background $bg_col
			} else {
			    .l$l.owner configure -text {} -background $bg_col
			}
		    }
		    access_list {
			if {[string length $id] == 4 && $all_lines($id-access_list) != ""} {
			    # put Yes or blank for access list
			    .l$l.access_list configure -text Yes -background $bg_col
			} else {
			    .l$l.access_list configure -text {} -background $bg_col
			}
		    }
		    opened {
			if {[string length $id] != 4} {
			    if {$all_lines($id-opened) != ""} {
			    # put whether opened
			    .l$l.opened configure -text [set_open_text $all_lines($id-opened)]  \
				    -background $bg_col
			    }
			} else {
			  .l$l.opened configure -text "" \
				  -background $bg_col
			}
		    }
		}
	    }
	    
	    # test to see if job or experiment by looking at length of id
	    if {[string length $id] == 4} {

		# Experiment
		# open or closed icon.
		if $all_lines($id-open) {
		    # Ros (March 07)
                    if {$all_lines($id-privacy) == "Y"} {
			# Experiment is marked as private
			.l$l.icon configure -bitmap $icons(open_private)
		    } else {
			.l$l.icon configure -bitmap $icons(open)
		    }
		} else {
		    if {$all_lines($id-privacy) == "Y"} {
			# Experiment is marked as private
		        .l$l.icon configure -bitmap $icons(closed_private)
		    } else {
		        .l$l.icon configure -bitmap $icons(closed)
		    }
		}
	    } else {
		# Job
		# blank icon and text fields
		.l$l.icon configure -bitmap $icons(blank)
	    }
	}
    }
    
    # reset scroll bar
    set last [expr $first + $lines - 1]
    if {$last >= $num_lines} {
	set last [expr $num_lines - 1]
    }
    if {$last < 0} {
	set last 0
    }
    .sbar set $num_lines $lines $first $last
}

proc set_open_text {text} {
    if {$text=="" || $text=="N"} {
	return "No"
    } else {
	return "By $text"
    }
}

# format the logicals
#
proc format_mix str {

    switch $str {
	N {return {}}
	Y {return Yes}
	M {return Mixed}
	default {return $str}
    }
}


# user clicked on a line
#
proc line_pressed line {

    global vis_lines num_lines all_lines

    # ignore clicks on title line
    if {$line == 0} {
	return
    }

    # find corresponding index using info from scroll bar
    set first [lindex [.sbar get] 2]
    set vis_index [expr $first + $line - 1]

    # ignore a click on a blank line
    if {$vis_index >= $num_lines} {
	return
    }

    # find experiment or job id
    set id $vis_lines($vis_index)

    # change to selected or unselected as appropriate
    set all_lines($id-selected) [expr ! $all_lines($id-selected)]

    # redraw list in same position
    move_list $first
}


# user clicked on an icon
#
proc icon_pressed line {

    global vis_lines num_lines all_lines

    # ignore clicks on title line
    if {$line == 0} {
	return
    }

    # find corresponding index using info from scroll bar
    set first [lindex [.sbar get] 2]
    set vis_index [expr $first + $line - 1]

    # ignore a click on a blank line
    if {$vis_index >= $num_lines} {
	return
    }

    # find experiment or job id
    set id $vis_lines($vis_index)

    # ignore a click on a job
    if {[string length $id] != 4} {
	return
    }

    # change experiment to open or closed as appropriate and insert or
    # delete job lines.
    set all_lines($id-open) [expr ! $all_lines($id-open)]
    if $all_lines($id-open) {
	insert_job_lines $id $vis_index
    } else {
	delete_job_lines $vis_index
    }

    # redraw list in same position
    move_list $first
}


# add lines for jobs when an experiment is opened
#
proc insert_job_lines {exp_id after} {

    global all_lines num_lines vis_lines job_filters titles application filter_exact
    global primary_server port

    # read server defs and open a socket
    read_server_def
    set server [start_rpc_client $primary_server $port PRIMARY]
    # check that the server is ok
    if {$server != "PAUSED"} {
	check_server $server PRIMARY
	# read job list for experiment
	set job_list [eval RPC $server send_job_list [concat $exp_id $filter_exact $job_filters]]
	# close the socket
	CloseRPC $server
	
	# make a space in the list of visible lines
	set num_jobs [llength $job_list]
	for {set i [expr $num_lines - 1]} {$i > $after} {incr i -1} {
	    set vis_lines([expr $i + $num_jobs]) $vis_lines($i)
	}
	incr num_lines $num_jobs
	
	# loop through jobs, saving specs
	set i [expr $after + 1]
	foreach spec $job_list {
	    set job_id [lindex $spec 0]
	    
	    # retain selected if line exists already
	    if {! [info exists all_lines($exp_id$job_id-selected)]} {
		set all_lines($exp_id$job_id-selected) 0
	    }
	    
	    # set details
	    foreach column $titles(app_columns) {
		set j [lsearch $spec $column]
		set all_lines($exp_id$job_id-$column) [lindex $spec [expr $j+1]]
	    }

	    set j [lsearch $spec description]
	    set all_lines($exp_id$job_id-description) [lindex $spec [expr $j+1]]
	    set j [lsearch $spec version]
	    set all_lines($exp_id$job_id-version) [lindex $spec [expr $j+1]]
	    set j [lsearch $spec opened]
	    set all_lines($exp_id$job_id-opened) [lindex $spec [expr $j+1]]

	    # add to list of lines
	    set vis_lines($i) $exp_id$job_id
	    incr i
	}
    }
}


# delete any job lines following an experiment that has just been closed
#
proc delete_job_lines after {

    global num_lines vis_lines

    # find next experiment in list
    set i [expr $after + 1]
    while {$i < $num_lines && [string length $vis_lines($i)] != 4} {
	incr i
    }
    set num_jobs [expr $i - $after - 1]

    # move list down to cover jobs
    while {$i < $num_lines} {
	set vis_lines([expr $i - $num_jobs]) $vis_lines($i)
	incr i
    }
    incr num_lines [expr -$num_jobs]
}


# provide lists of selected jobs and experiments
#
proc find_selections {} {

    global vis_lines num_lines all_lines selected_expts selected_jobs

    set selected_expts {}
    set selected_jobs(experiments) {}

    # loop through all visible lines
    for {set i 0} {$i < $num_lines} {incr i} {
	# experiment or job?
	set id $vis_lines($i)
	if {[string length $id] == 4} {

	    # clear job list for each experiment
	    set selected_jobs($id) {}

	    # add if selected
	    if $all_lines($id-selected) {
		lappend selected_expts $id
	    }
	} else {

	    # only add to list if coresponding experiment is open
	    if $all_lines($id-selected) {
		set exp_id [string range $id 0 3]
		set job_id [string index $id 4]
		if $all_lines($exp_id-open) {
		    if {[lsearch $selected_jobs(experiments) $exp_id] == -1} {
			lappend selected_jobs(experiments) $exp_id
		    }
		    lappend selected_jobs($exp_id) $job_id
		}
	    }
	}
    }
}
