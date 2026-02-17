# handle_case.tcl
# 
#    Procedures dealing with .case .invisible and .colour panel 
#    constructions. The three types of constructs all have a similar
#    set of globals associated with them.
# Global Variables
#    in_case            : 0 if not inside a .case construct. 
#                         Otherwise, the number of enclosing .case constructs.
#    in_table           : Logical; 1 if currently parsing a .table construct.
#    in_colour          : Logical; 1 if currently in a .colour construct.
#    grayout_expressions: Lists of the expressions; one for each 
#    colour_expressions : construct that encloses the block (or just
#    invis_expressions  : one for .colour constructs).

# case_start
#    Deals with .case constructs. Called by the meta-script 
#    created by the window parser. Either calls add_case or,
#    if in a table, adds a case_start call to the table
#    meta-meta-script.
# Argument
#    expression: Argument of .case construct; GHUI logical expression

proc case_start {expression} {
    # .case command

    global in_case grayout_expressions

    # $in_case is number of case levels
    incr in_case
    lappend grayout_expressions [convert_expression $expression]
    add_case "c"
}

# colour_start
#    Deals with .colour constructs. Called by the meta-script 
#    created by the window parser. Either calls add_case or,
#    if in a table, adds a colour_start call to the table
#    meta-meta-script.
# Arguments
#    colour    : Argument of .colour construct; colour
#    expression: Argument of .colour construct; GHUI logical expression
# Comments
#    It is not clear how colour statements should be nested. Therefore
#    nesting is not allowed.

proc colour_start {colour expression} {
   
    global in_colour colour_expressions colour_list

    if {$in_colour} {
	error "Cannot nest .colour statements"
    }

    # $in_colour is number of colour levels. Currently
    # only one is allowed.
    incr in_colour
    lappend colour_list $colour
    lappend colour_expressions [convert_expression $expression]
    add_case "c"
}

# invisible_start
#    Deals with .invisible constructs. Called by the meta-script 
#    created by the window parser. Calls add_case.
# Argument
#    expression: Argument of .colour construct; GHUI logical expression
# Method
#    Invisible and block constructs cannot overlap. If in a block
#    construct, a new block is started.

proc invisible_start {expression} {
    # .invisible command

    global in_invis invis_expressions in_block

    # $in_invis is number of invisible levels
    incr in_invis
    lappend invis_expressions [convert_expression $expression]
    add_case "i"
    if {$in_block} {block_start 0 0}
}

# case_end
#    Deals with .caseend constructs. Called by the meta-script 
#    created by the window parser. If in a table, adds a case_end
#    call to the table meta-meta-script.
# Method
#    Decrements in_case and calls add_case if still in any of the
#    types of logic construct.

proc case_end {} {
    # .caseend command
    global in_case in_invis in_colour grayout_expressions

    # Drop down a case level
    incr in_case -1
    if {$in_case < 0} {
	error "Too many .caseends"
    }
    if {! $in_case} {
	# At level 0 -> not in a case
	set grayout_expressions {}
    }
    if {$in_case || $in_invis || $in_colour} {
	# create new case if still inside one
	add_case "c"
    }
}

# colour_end
#    Deals with .colourend constructs. Called by the meta-script 
#    created by the window parser. If in a table, adds a colour_end
#    call to the table meta-meta-script.
# Method
#    Decrements in_colour and calls add_case if still in any of the
#    types of logic construct.

proc colour_end {} {

    global in_case in_invis in_colour colour_expressions colour_list

    # Drop down a case level
    incr in_colour -1
    if { $in_colour < 0} {
	error "Too many .colour_ends"
    }
    if {! $in_colour} {
	# At level 0 -> not in a case
	set colour_expressions {}
	set colour_list "normal"
    } else {
	set colour_list [lrange $colour_list 0 $in_colour]
    }
    if {$in_case || $in_invis || $in_colour} {
	# create new case if still inside one
	add_case "c"
    }
}

# invisible_end
#    Deals with .invisend constructs. Called by the meta-script 
#    created by the window parser. 
# Method
#    Decrements in_invis and calls add_case if still in any of the
#    types of logic construct. 
# Method
#    Invisible and block constructs cannot overlap. If in a block
#    construct, a new block is started.

proc invisible_end {} {

    global in_case in_invis in_colour invis_expressions in_block

    # drop down a level
    incr in_invis -1
    if {$in_block} {block_start 0 0}
    if {$in_invis < 0} {
	error "Too many .invisends"
    }
    if {! $in_invis} {
	# Not inside an invisible case
	set invis_expressions {}
    }
    if {$in_case || $in_invis || $in_colour} {
	# create new case if still inside one
	add_case "i"
	if {$in_block} {block_start 0 0}
    }
}

# add_case
#    Called every time any case of any type is changed. It creates a new
#    cases structure with a new case_no. 
# Arguments
#    type: "i" for invisible, "c" for colour or case.
# Globals
#    case_no: The case number - incremented each time a new case is created
#    cases  : An array of structures indexed by case_no. Each structure is a
#             list comprising:
#        a case expression and status for .case
#        a case expression and status for .invisible
#        a case expression and status for .colour
#        an encompassing frame and marker point for frame if invisible 
#    plus the following, appended as new components are added to window
#        a list of components for each component within case
#        comprising type (eg table or text) and component name
# Method
#    The cases construct is setup, and a call to sensitise_variables adds the
#    case_no to lists; one list for each variable in the case expression. 

proc add_case {type} {
    global case_no cases win in_case in_invis in_colour cases_on_window
    global colour_list case_no_i
    incr case_no

    set cases($case_no) {}

    set exp [form_nested_exp grayout_expressions $in_case]
    lappend cases($case_no) $exp
    lappend cases($case_no) 1
    sensitise_variables $exp
    set exp [form_nested_exp invis_expressions $in_invis]
    lappend cases($case_no) $exp
    lappend cases($case_no) 1
    sensitise_variables $exp
    set exp [form_nested_exp colour_expressions $in_colour]
    lappend cases($case_no) $exp
    lappend cases($case_no) 1
    sensitise_variables $exp

    if {$in_invis && $type=="i"} {
	# Only create a new invisible frame if this is a new invisible case
	frame $win.vm$case_no -width 0 -height 0
	#puts "frame $win.vc$case_no"
	frame $win.vc$case_no
	pack $win.vm$case_no
	pack $win.vc$case_no -anchor w
	set case_no_i $case_no
	lappend cases($case_no) $win.vc$case_no
	lappend cases($case_no) $win.vm$case_no
    } else {
	lappend cases($case_no) NULL_COMPONENT
	lappend cases($case_no) NULL_COMPONENT
    }
    lappend cases_on_window($win) $case_no
    lappend cases($case_no) [lindex $colour_list $in_colour]
}

# sensitise_variables
#    Each variable in case expression is added to list. If its value
#    changes, cases are acted upon to grey out or black in as necessary
# Argument
#    exp: A GHUI logical expression
# Globals
#    sensitive_variables: A list of cases for each variable.

proc sensitise_variables {exp} {
    # Each variable in case expression is added to list
    # if its value changes, cases are acted upon to grey out or black in as necessary
    global sensitive_variables case_no
    foreach var [vars_in_expression $exp] {
	if {! [info exists sensitive_variables($var)] ||
        [lsearch -exact $sensitive_variables($var) $case_no] == -1} {
	    lappend sensitive_variables($var) $case_no
	}
    }
}

# vars_in_expression
#    Returns the list of variables in a GHUI logical expression.
# Argument
#    exp: A GHUI logical expression.

proc vars_in_expression {exp} {

    set vars {}
    foreach token [split $exp {()[]!=&|}] {
 	if {[string index $token 0] >="A" && [string index $token 0] <="Z" && $token != "ALWAYS"} {
 	    lappend vars $token
 	}
    }
    return $vars
}


proc form_nested_exp {exp_list_name level} {
    # adds or removes expressions from list for nested .case or .invisible
    global $exp_list_name
    if {$level < 0} {
	error "Invalid nesting level"
    }
    if {$level == 0} {
	return "ALWAYS"
    }
    set exp_list [eval lrange $$exp_list_name 0 [expr $level - 1]]
    set $exp_list_name $exp_list

    return [join $exp_list &&]
}


proc evaluate_case {case_no} {
    # Called when value of sensitised variable changed or when window initially opened
    # Evaluates case for each component and greys out or blacks in as appropriate
    global cases

    set grayout_exp [lindex $cases($case_no) 0]
    set grayout_result [lindex $cases($case_no) 1]
    set invis_exp [lindex $cases($case_no) 2]
    set invis_result [lindex $cases($case_no) 3]
    set colour_exp [lindex $cases($case_no) 4]
    set colour_result [lindex $cases($case_no) 5]
    set container [lindex $cases($case_no) 6]
    set marker [lindex $cases($case_no) 7]
    set colour [lindex $cases($case_no) 8]
    set comp_list [lrange $cases($case_no) 9 end]

    # Evaluate grey-out expression
    set grey_result [eval_logic $grayout_exp]
    if {$grey_result != $grayout_result} {
	# Greyout status has changed so change the variable and alter the window
	set cases($case_no) [lreplace $cases($case_no) 1 1 $grey_result]
	if $grey_result {
	    foreach pair $comp_list {
		black_in_component [lindex $pair 0] [lindex $pair 1]
	    }
	} else {
	    foreach pair $comp_list {
		gray_out_component [lindex $pair 0] [lindex $pair 1]
	    }
	}
    }

    
    # Evaluate colour expression
    set result [eval_logic $colour_exp]
    
    if {$result != $colour_result} {
	# Greyout status has changed to black so change colour if required
	set cases($case_no) [lreplace $cases($case_no) 5 5 $result]
    }
    if $grey_result {
	if $result {
	    # Colour component if statement is true.
	    foreach pair $comp_list {
		colour_component $colour [lindex $pair 0] [lindex $pair 1]
	    }
	} else {
	    foreach pair $comp_list {
		black_in_component [lindex $pair 0] [lindex $pair 1]
	    }
	}
    }
    

    # Evaluate invisible expression
    set result [eval_logic $invis_exp]
    if {$result != $invis_result } {
	# Invisible status has changed so change the variable and alter the window
	set cases($case_no) [lreplace $cases($case_no) 3 3 $result]
    }
    if { $container != "NULL_COMPONENT"} {
	if $result {
	    pack $container -after $marker -anchor w
	} else {
	    pack forget $container
	}
    }
}


proc gray_out_component {type name} {
    # Method for deactivating component depends on component type

    global col_text_grayed col_bg_normal

    switch $type {
	column {
	    # Table column so get its number and run the table command
	    # as set up by Table in create_table.
	    #puts [$name configure]
	    set tableName [lindex $name 0]
	    set colNo [lindex $name 1]
	    greyoutCol $tableName $colNo
	}
	entry {
	    $name configure -state disabled -foreground $col_text_grayed
	}
	checkbutton {
	    $name configure -state disabled -foreground $col_text_grayed \
		    -bg $col_bg_normal
	}
	label {
	    $name configure -foreground $col_text_grayed
	}
	radiobutton {
	    $name configure -state disabled -foreground $col_text_grayed
	}
	tablebutton {
	    $name configure -state disabled -foreground $col_text_grayed
	}
    }
}

proc greyoutCol {name colNo} {
    global Table
    
    set c $Table($name,TableId)
    plbMethod $c ResetColState $colNo 3 grey
}
proc colourCol {name colour colNo} {
    global Table
    
    set c $Table($name,TableId)
    plbMethod $c ResetColState $colNo "" $colour
}
proc BlackinCol {name colNo} {
    global Table
    
    set c $Table($name,TableId)

    # Set the normal state of this column
    set activeState $Table($name,State,$colNo)
    plbMethod $c ResetColState $colNo $activeState black
}
    
    

proc colour_component {colour type name} {
    global col_text_normal
    # Method for deactivating component depends on component type
    if {$colour=="normal"} {set colour $col_text_normal}

    switch $type {
	column {
	    # Table column so get its number and run the table command
	    # as set up by Table in create_table.
	    #puts [$name configure]
	    set tableName [lindex $name 0]
	    set colNo [lindex $name 1]
	    colourCol $tableName $colour $colNo
	}
	entry {
	    $name configure -foreground $colour
	}
	checkbutton {
	    $name configure -foreground $colour
	}
	label {
	    $name configure -foreground $colour
	}
	radiobutton {
	    $name configure -foreground $colour
	}
	tablebutton {
	    $name configure -foreground $colour
	}
    }
}


proc black_in_component {type name} {
    # Method for activating component depends on component type

    global col_text_normal hilit col_checkbutton_hilit
    switch $type {
	column {
	    # Table column so get its number and run the table command
	    # as set up by Table in create_table.
	    set tableName [lindex $name 0]
	    set colNo [lindex $name 1]
	    BlackinCol $tableName $colNo
	}
	entry {
	    $name configure -state normal -foreground $col_text_normal
	}
	checkbutton {
	    $name configure -state normal -foreground $col_text_normal
	    if [info exists hilit($name)] {
		# hilit array element exists so this is an unset variable
		# Therefore hilight it
		$name configure -bg $col_checkbutton_hilit
	    }
	}
	label {
	    $name configure -foreground $col_text_normal
	}
	radiobutton {
	    $name configure -state normal -foreground $col_text_normal
	}
	tablebutton {
	    $name configure -state normal -foreground $col_text_normal
	}
    }
}

proc active_component {win name} {
    # Is component $name active or greyed out/invisible
    # This is used for determining whether focus is allowed to be set on 
    # component $name
    # Return 1 for inactive and 0 for active

    global cases_on_window cases
    foreach case_no $cases_on_window($win) {
	if [component_found $case_no $name] {
	    # Component is within this case so return its active status
	    # grey and invisible are set to 1 if NOT grey/invisible
	    set grey [lindex $cases($case_no) 1]
	    set invisible [lindex $cases($case_no) 3]
	    return [expr {!($grey && $invisible)}]
	}
    }
    # Component not within a case ==> active
    return 0
}

proc component_found {case_no name} {
    # Is name within this case

    global cases
    foreach item [lrange $cases($case_no) 6 end] {
	if {$name==[lindex $item 1]} {return 1}
    }
    return 0
}


proc remove_cases {win} {
    # Window closure so unset variables relating to cases on this window
    global cases_on_window sensitive_variables cases

    foreach case_no $cases_on_window($win) {
	unset cases($case_no)
	if [info exists sensitive_variables] {
	    foreach var [array names sensitive_variables] {
		set new_list {}
		foreach element $sensitive_variables($var) {
		    if {$element != $case_no} {
			lappend new_list $element
		    }
		}
		if {$new_list == ""} {
		    unset sensitive_variables($var)
		} else {
		    set sensitive_variables($var) $new_list
		}
	    }
	}
    }
    unset cases_on_window($win)
}



