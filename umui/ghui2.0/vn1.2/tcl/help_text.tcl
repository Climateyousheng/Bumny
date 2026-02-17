proc get_window_line {win_text variable} {
    # Searches win_text for line number containing $variable
    #
    # win_text should be a list of lines from a window panel.
    # variable should be a variable name with or without an index.
    # 
    # Returns line number of line which contains variable or "" if
    # variable cannot be found
    # For elements of array such as VAR(3) do a search for VAR(3) and store
    # in line_no, but also do a search for VAR( in case VAR appears on window
    # in the form VAR(INDEX) where INDEX is another user interface variable
    # Return the best match

    set var "[lindex [split $variable "()"] 0]\\("
    set var2 "[lindex [split $variable "()"] 0]"
    regsub {\(} $variable {\\(} vname
    regsub {\)} $vname {\\)} vname

    set line_no ""
    set line_no2 ""
    set line_no3 ""

    for {set i 0} { $i < [ llength $win_text] } {incr i} {
	set line [lindex $win_text $i]

	# Get the variable from the line if there is one
	set vmatch [variable_on_line $line]
	if {$vmatch != "0"} {
	    set vmatch1 "[lindex [split $vmatch "()"] 0]\\("
	    set vmatch2 "[lindex [split $vmatch "()"] 0]"
	    regsub {\(} $vmatch {\\(} vmatch
	    regsub {\)} $vmatch {\\)} vmatch
	    
	    if {$vname == $vmatch} {
		# Exact match
		set line_no $i
	    } elseif {$var == $vmatch1} {
		# Both contain variable with index
		set line_no2 $i
	    } elseif {$var2 == $vmatch2} {
		# Both contain variable without index
		set line_no3 $i
	    }
	}
    }
    # Return closest match
    if {$line_no==""} {set line_no $line_no2}
    if {$line_no==""} {set line_no $line_no3}
    return $line_no
		
}

# general_help_text
#   Takes a line from an input panel control file and returns its type
#   and its text component in the format of a descriptive string
# Arguments
#   win_text: Full text from the panel
#   line_no: Line of a valid component type

proc general_help_text {win_text line_no} {

    set line [lindex $win_text $line_no]
    set type [lindex $line 0]
    set text ""
    switch $type {
	".entry"          {set text "Entry box: [lindex $line 1]"}
	".file_entry"          {set text "Entry box: [lindex $line 1]"}
	".check"          {set text "Check box: [lindex $line 1]"}
	".basrad"         {set text "Radio button: [lindex $line 1]"}
	".set_on_closure" {set text "Hidden variable: [lindex $line 1]"}
	".element"        {set text "Table"}
	".entry_active"   {set text "[lindex $line 1]"}
	default {error "Invalid component $type"}
    }
    return [evalEmbeddedCommands $text]
}

proc table_help_text {win_text line_no} {
    # Setting up help text for tables
    # Starting from line_no, works up the list finding names of appropriate 
    # headings and subheadings and returns a list of these.
    #
    # win_text should be a list of lines from a window panel.
    # line_no  is list item number of line about which help will be returned.
    #
    # May eventually put tables into separate variable so that output format is better

    set line [lindex $win_text $line_no]
    set column [lindex $line 1]
    set sub_heads "None"
    
    set levels 0
    for {set i [incr line_no -1]} { ([lindex $line 0]!=".table")&&($i>0) } {incr i -1} {
	# Search up $win_text till start of table found
	# Keep a note of any appropriate .super sub-headings
	
	set line [lindex $win_text $i]
	
	if {[lindex $line 0]==".superend"} {incr levels -1}
	if {[lindex $line 0]==".super"} {
	    lappend sub_heads [lindex $line 1]
	    incr levels
	    set sub_heads [lrange $sub_heads 0 $levels]
	}
    }
    if {$i<=0} {
	# This means a system error
	error "table title not found while searching window"
	return 0
    }
    
    set table [lindex $line 1]

    append help_text "Differences in Table [lindex $line 2]\n"
#    if {$levels != 0} {
#	# There is one or more .super sub-heading
#	if {$levels==1} {
#	    append help_text "Sub-heading  [lindex $sub_heads 1]\n"
#	} else {
#	    append help_text "Sub-headings [lindex $sub_heads $levels]\n"
#	    for {set i [incr sub_heads -1]} {$i>0} {incr i -1} {
#		append help_text "             [lindex $sub_heads $i]\n"
#	    }
#	}
#    }
#    append help_text "Column       $column"	    
    return $help_text
}


proc value_help_text {win_text line_no value} {
    # Returns help which depends on value of variable
    # For entry boxes, table columns, and hidden variables just returns value.
    # For check boxes, returns on or off.
    # For radio buttons, returns text associated with value
    # Returns "Entry is unset" if variable is not set
    #
    # win_text should be a list of lines from a window panel.
    # line_no  is list item number of line about which help will be returned.
    # value is value of variable

    if {$value==""} {return "Entry is unset"}

    set line [lindex $win_text $line_no]
    set type [lindex $line 0]

    # Return just the value for the following
    if { $type==".entry" } {return "Entry is set to '$value'"}
    if { $type==".entry_active" } {return "Entry is set to '$value'"}
    if { $type==".element" } {return "Entry is set to '$value'"}
    if { $type==".set_on_closure" } {return "Variable is set to '$value'"}


    # Return ON or OFF for check boxes
    if { $type==".check" } {
	set line [lindex $win_text $line_no]
	if {$value==[lindex $line 4]} {return "Entry is set to 'ON'"}
	if {$value==[lindex $line 5]} {return "Entry is set to 'OFF'"}
	return "Entry is unset"
    }

    # Search for text which matches value for radio buttons
    if { $type==".basrad"} {
	set current_line [expr $line_no+1]
	set opts 0
	set options ""
	while { ($opts<[expr [lindex $line 3]*2])&&($current_line<=[llength $win_text]) } {
	    set options [concat $options [lindex $win_text $current_line]]
	    set opts [llength $options]
	    incr current_line
	}

	for {set i 0} {$i<[llength $options]} {incr i 2} {
	    if {$value==[lindex $options [expr $i+1]]} {return "Entry is set to '[lindex $options $i]'"}
	}

	return "Entry is unset"
    }
    return 0
}
	

