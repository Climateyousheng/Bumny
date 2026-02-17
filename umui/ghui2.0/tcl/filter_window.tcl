# Set up window with text, exp filter and job filter switches,
# and bind button to filter_pressed

proc draw_filter_interface {} {

    global filter_exact

    set w .filter
    toplevel $w
    wm title $w "GHUI Filter Options"

    set f $w.f
    frame $f
    pack $f -expand y -fill both
    
    pack [label $f.l1 -pady 5 -text "Select filter options"] -anchor w
    pack [label $f.l2 -text "To perform exact string, rather than substring, match check the button below."] -anchor w
    pack [checkbutton $f.cb -text "Exact string match" -variable filter_exact \
	  -onvalue 1 -offvalue 0 -relief flat] -anchor w
    pack [label $f.l3 -pady 5 -text "You may enter more than one string in the form string1,string2,..."] -anchor w
    
    # Display the questions
    create_filters $f exp_filters "Exp filters"
    pack [frame $f.gap1 -height 20]

    create_filters $f job_filters "Job filters"
    pack [frame $f.gap2 -height 20]

    # Filter and Cancel buttons
    frame $f.f2 
    button $f.f2.b1 -text Filter -command "filter_pressed"
    pack $f.f2.b1 -pady 2m -side left -expand yes -ipadx 1m -ipady 1m
    button $f.f2.b2 -text Cancel -command "destroy .filter"
    pack $f.f2.b2 -pady 2m -side left -expand yes -ipadx 1m -ipady 1m
    pack $f.f2 -fill x
}

# Build a set of filter choices with one over-all checkbutton which 
# can turn them all off

proc create_filters {f type text} {

    global filter_flag filter_defaults
    if {[info exists filter_flag($type,main)]==0} {
	# First time Filter selected so initialise to default value
	#set filter_flag($type,main) $default
    }

    pack [set p [frame $f.$type]] -fill both -expand y

    # Main question which controls whole section
    pack [frame $p.main] -fill x
    pack [checkbutton $p.main.c -text $text -command "filters_on $type" \
	    -variable filter_flag($type,main) -relief flat] -anchor w

    # Question section with indentation frame
    pack [set o [frame $p.options]] -fill both -expand y
    pack [frame $o.indent -width 60] -fill y -side left
    pack [frame $o.indent2 -width 60] -fill y -side right
    pack [frame $o.opts] -fill x
    # Add all the questions
    filter_options $o.opts $type
    # Apply the over-all switch
    filters_on $type
}

# Fill a frame with radio buttons and entry boxes
# bound to a variable name with suffix $filter_item

proc filter_options {f type} {
    global filter_items

    foreach item $filter_items($type) {
	switch [lindex $filter_items($type,$item) 0] {
	    string      {
		string_filter  $f $type $item $filter_items($type,$item)
	    }
	    option      {
		options_filter $f $type $item $filter_items($type,$item)
	    }
	    text        {text_filter $f $type $filter_items($type,$item)}
	    gap         {gap_filter $f $type}
	    separator   {separate_filter $f}
	    default     {
		error "Invalid filter type [lindex $options $arg_no]"
	    }
	}
    }
    return
}

# Entry box option

proc string_filter {f type item options} {
    global filter_value filter_flag filter_widgets

    # Get the details about the filter item
    
    # Read in list of control parameters
    set arg_no 1
    foreach var [list string flag default width] {
	set $var [lindex $options $arg_no]
	incr arg_no
    }
    
    # First time Filter selected so initialise to default values
    if {[info exists filter_value($type,$item)]==0} {
	#set filter_value($type,$item) $default
	#set filter_flag($type,$item) $flag
    }
    pack [set l [frame $f.f$item]] -fill x

    pack [checkbutton $l.c -text $string -variable filter_flag($type,$item) \
	    -command "switch_entry $l.e $type $item" -relief flat] -side left
    pack [entry $l.e -width $width -relief sunken \
	    -textvariable filter_value($type,$item)] -side right -anchor e

    lappend filter_widgets($type) "checkbutton $item $l.c" "component $item $l.e"

    # Apply current selection
    switch_entry $l.e $type $item
    return
}

# Radio box option

proc options_filter {f type item options} {
    global filter_value filter_flag filter_widgets

    # Get the details about the filter item
    set arg_no 1

    # Read in list of control parameters
    foreach var [list string flag number default] {
	set $var [lindex $options $arg_no]
	incr arg_no
    }
    # Get list of radio buttons
    for {set i 0} { $i < $number } {incr i} {
	set pair [lindex $options [expr $arg_no+$i]]
	lappend values [lindex $pair 0]
	lappend text [lindex $pair 1]
    }

    # First time Filter selected so initialise to default value
    if {[info exists filter_value($type,$item)]==0} {
	#set filter_value($type,$item) $default
	#set filter_flag($type,$item) $flag
    }

    pack [set l [frame $f.f$item]] -fill x

    pack [checkbutton $l.c -text $string -variable filter_flag($type,$item) \
	    -command "switch_radio $l.r.b $type $item $number" -relief flat] -side left

    lappend filter_widgets($type) "checkbutton $item $l.c"

    pack [frame $l.r] -side right -anchor e
    
    for {set i [expr $number-1]} { $i>=0 } {incr i -1} {
	pack [radiobutton $l.r.b$i -variable filter_value($type,$item) \
		-value [lindex $values $i] -text [lindex $text $i]\
		-relief flat] -side right
	lappend filter_widgets($type) "component $item $l.r.b$i"
    }

    # Apply current selection
    switch_radio $l.r.b $type $item $number
    return
}

proc text_filter {f type options} {

    set text $options
    text_filter_out $f $type $text
    return 
}

proc gap_filter {f type} {

    text_filter_out $f $type ""
    return 1
}

proc text_filter_out {f type text} {
    global filter_flag filter_widgets

    set i 0
    while {[info commands $f.g$i]=="$f.g$i"} {incr i}

    pack [set l [frame $f.g$i]] -fill x
    pack [label $l.l -text $text] -side left
    lappend filter_widgets($type) "text 0 $l.l"
    set filter_flag($type,0) 1
}

proc separate_filter {f} {

    set i 0
    while {[info commands $f.sep$i]=="$f.sep$i"} {incr i}
    
    pack [frame $f.sep$i -bd 2 -relief groove -height 4] -fill x -pady 2m
    return 1
}


# Called when checkbutton applying to an entry choice is toggled

proc switch_entry {f type item} {
    global filter_flag
    global col_text_normal col_text_grayed

    set flag $filter_flag($type,$item)
    if $flag {
	$f configure -state normal -foreground $col_text_normal
    } else {
	$f configure -state disabled -foreground $col_text_grayed
    }
}

# Called when checkbutton applying to a radiobutton choice is toggled

proc switch_radio {f type item number} {
    global filter_flag
    global col_text_normal col_text_grayed

    set flag $filter_flag($type,$item)

    for {set i 0} {$i<$number} {incr i} {

	if $flag {
	    $f$i configure -state normal -foreground $col_text_normal
	} else {
	    $f$i configure -state disabled -foreground $col_text_grayed
	}
    }
}

# Apply the main switch to a block of questions - greying out or activating
# as required

proc filters_on {type} {
    global filter_flag filter_widgets
    global col_text_normal col_text_grayed

    foreach widget $filter_widgets($type) {
	set widget_type [lindex $widget 0]
	set item [lindex $widget 1]
	set name [lindex $widget 2]
	if {$filter_flag($type,main) && ($filter_flag($type,$item) || $widget_type=="checkbutton")} {
	    set state normal
	    set fg $col_text_normal
	} else {
	    set state disabled
	    set fg $col_text_grayed
	}
 	switch $widget_type {
	    component {
		$name configure -state $state -fg $fg
	    }
	    text {
		$name configure -fg $fg
	    }
	    checkbutton {
		$name configure -state $state -fg $fg
	    }
	    default {
		error "Invalid widget type $name"
	    }
	}
    }
}
