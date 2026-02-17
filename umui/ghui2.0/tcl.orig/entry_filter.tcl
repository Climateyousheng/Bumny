# handle the filter dialog
#
# create filter lists from interface state
#
proc filter_pressed {} {
    apply_filters
    destroy .filter
    menu_reload
}
proc apply_filters {} {
    global filter exp_filters job_filters colours titles

    set exp_filters [get_filter_list exp_filters]
    set job_filters [get_filter_list job_filters]

    # set up title backgrounds to indicate use of a filter

    foreach col $titles(display_columns) {
	set e [expr [lsearch $exp_filters $col]+1]
	set j [expr [lsearch $job_filters $col]+1]
	# Check both that the item is in the filter lists and that, if so, that it's not *
	if { ($e!=0 && ([lindex $exp_filters $e] != "*")) || ($j!=0 && ([lindex $job_filters $j]!="*")) } {
	    .l0.$col configure -background $colours(title_bg_filter)
	} else {
	    .l0.$col configure -background $colours(title_bg_normal)
	}
    }
}

proc get_filter_list {type} {
    global filter_items filter_value filter_flag

    foreach option $filter_items($type) {
	if { $filter_flag($type,$option) && $filter_flag($type,main) } {
	    lappend list $option [remove_end_spaces $filter_value($type,$option)] 
	} else {
	    lappend list $option *
	}
    }
    return $list
}

proc blank_filter_list {type} {
    global filter_items filter_value filter_flag

    foreach option $filter_items($type) {
	lappend list $option *
    }
    return $list
}

# Determines initial filter settings and then applies them to entry window

proc initialise_filters {} {

    global exp_filters job_filters user

    # Initialise filter options
    get_filters exp_filters [list opened]
    get_filters job_filters [list id owner access_list]

    # Set up the default values with exp_filters on and job_filters off
    set_filter_defaults exp_filters 1
    set_filter_defaults job_filters 0

    apply_filters
}

# Initialises the variables that will be bound to the components in the filter window
proc set_filter_defaults {type default} {
    global filter_items titles filter_value filter_flag
    
    foreach item $filter_items($type) {
	if {[info exists filter_value($type,$item)]==0} {
	    set filter_value($type,$item) $titles(filter_default,$item)
	    set filter_flag($type,$item) $titles(filter_switch,$item)
	}
    }
    if {[info exists filter_flag($type,main)]==0} {
	set filter_flag($type,main) $default
    }
}

# Return filter defaults as obtained from .def filee

proc get_filter_defaults {type} {
    upvar filter_defaults filter_defaults
    global titles
    foreach col $titles(display_columns) {
	set filter_defaults($type,on_state,$col) $titles(filter_switch,$col)
	set filter_defaults($type,$col) $titles(filter_default,$col)
    }
}


# Build up a list of parameters for controlling a block of filter options
# type        - name of object
# default     - default selection status for object
# ignore_list - list of GHUI selection not applicable to this object

proc get_filters {type ignore_list} {

    global titles filter_items
    
    set filter_items($type) {}
    # Get default values
    get_filter_defaults $type

    set col_list $titles(display_columns)

    foreach col $col_list {
	if {[lsearch $ignore_list $col]!=-1} {continue}
	lappend filter_items($type) $col
	set list {}

	switch $titles(type,$col) {
	    string {
		lappend list $titles(type,$col) $titles(title,$col) \
			$filter_defaults($type,on_state,$col)
		# Append default value and entry box width
		lappend list $filter_defaults($type,$col) $titles(filter_options,$col)
	    }
	    option {
		lappend list $titles(type,$col) $titles(title,$col) \
			$filter_defaults($type,on_state,$col)
		if {$titles(filter_options,$col)=="YN"} {
		    # Append No of options, default value and list of options
		    lappend list 2 $filter_defaults($type,$col) "Y Yes" "N No"
		} else {
		    # Append No of options, default value and list of options
		    lappend list [llength $titles(filter_options,$col)] $filter_defaults($type,$col)
		    foreach option $titles(filter_options,$col) {
		    lappend list "\{$option\} \{$option\}"
		    }
		}
	    }
	    separator {
		lappend list separator
	    }
	    default {
		error "Invalid option $titles(type,$col)"
	    }
	}
	set filter_items($type,$col) $list
    }
    return $list
}

