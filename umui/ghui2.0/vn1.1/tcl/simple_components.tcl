proc text_component {text_label justification} {

    global component_height indent_width block_indentation
    global in_case in_invis in_colour case_no cases win fonts

    # Substitute any embedded functions
    set text_label [evalEmbeddedCommands $text_label]

    set c [component_name left]
    frame $c
    frame $c.s \
	    -height $component_height \
	    -width [expr $block_indentation * $indent_width]
    label $c.l -text $text_label

    # This would allow cut and paste - but setting the width is a problem when
    # not using a fixed font
    #text $c.l -font $fonts(normal) -relief flat -height 1 -width [string length $text_label]
    #$c.l insert end $text_label
    #$c.l configure -state disabled

    pack $c -anchor [convert_justification $justification]
    pack $c.s -side left
    pack $c.l

    if {$in_case || $in_invis || $in_colour} {
	lappend cases($case_no) "label $c.l"
    }

    set c [component_name right]
    frame $c -height $component_height
    pack $c
}


proc entry_component {text_label justification variable {width 40}} {

    global component_height block_indentation indent_width
    global variables_on_window win entry_boxes tab_list
    global in_case in_invis in_colour case_no cases

    # Substitute any embedded functions
    set text_label [evalEmbeddedCommands $text_label]

    # If UI variable, then substitute value
    set width [get_value $width]

    set c [component_name left]
    frame $c
    frame $c.s \
	    -height $component_height \
	    -width [expr $block_indentation * $indent_width]
    label $c.l -text $text_label
    pack $c -anchor [convert_justification $justification]
    pack $c.s -side left
    pack $c.l

    if {$in_case || $in_invis || $in_colour} {
	lappend cases($case_no) "label $c.l"
    }

    set c [component_name right]
    frame $c
    frame $c.s -height $component_height -width 5
    entry $c.e -relief sunken -width $width
    pack $c -anchor [convert_justification $justification]
    pack $c.s -side left
    pack $c.e

    set value [get_variable_value $variable]
    $c.e insert 0 [get_variable_value $variable]

    lappend tab_list($win) $c.e

    # Routine to do key bindings for moving around
    entry_binding $win $c.e 

    bind $c.e <FocusOut> "+entryboxUpdated $c.e $variable"

    lappend entry_boxes($win) "$variable $c.e"
    lappend variables_on_window($win) $variable
    set_help_text $variable $text_label

    if {$in_case || $in_invis || $in_colour} {
	lappend cases($case_no) "entry $c.e"
    }
}


proc gap_component {} {

    global gap_height

    set c [component_name left]
    frame $c -height $gap_height
    pack $c

    set c [component_name right]
    frame $c -height $gap_height
    pack $c
}

proc check_component {label_text justification variable on_value off_value} {

    global component_height indent_width block_indentation link
    global win variables_on_window
    global in_case in_invis in_colour case_no cases
    global hilit tab_list
    global col_checkbutton_hilit
    # Substitute any embedded functions
    set label_text [evalEmbeddedCommands $label_text]

    set c [component_name left]
    frame $c
    frame $c.s \
	    -height $component_height \
	    -width [expr $block_indentation * $indent_width]
    checkbutton $c.c -variable link($c.var) -text $label_text \
	    -onvalue $on_value -offvalue $off_value \
	    -relief flat \
	    -command "check_or_radio_pressed $variable $c.var $c.c" 
    pack $c -anchor [convert_justification $justification]
    pack $c.s -side left
    pack $c.c
    lappend tab_list($win) $c.c

    # Key binding routine
    check_binding $win $c.c

    if {([get_variable_value $variable]!=$on_value)&&([get_variable_value $variable]!=$off_value)} { 
	# Variable is unset - highlight the box if enabled and set the hilit variable
	# (if box is greyed out, highlighting is removed by handle_case routine)
 	$c.c configure -bg $col_checkbutton_hilit
 	set hilit($c.c) 1
    } else {
	if [info exists hilit($c.c)] {
	    # Variable value has been changed in another window - this widget
	    # is still flagged as being highlighted so...
	    unset hilit($c.c)
	}
    }
    

    set link($c.var) [get_variable_value $variable]

    if {$in_case || $in_invis || $in_colour} {
	lappend cases($case_no) "checkbutton $c.c"
    }

    set c [component_name right]
    frame $c -height $component_height
    pack $c

    lappend variables_on_window($win) $variable
    set_help_text $variable $label_text
}

proc basrad_component {text_label justification num_cases orientation variable case_pairs} {

    global component_height block_indentation indent_width
    global link win variables_on_window link
    global in_case  in_invis in_colour case_no cases
    global tab_list
    
    # Substitute any embedded functions
    set text_label [evalEmbeddedCommands $text_label]

    set c [component_name left]
    frame $c
    frame $c.s \
	    -height [expr {($orientation == "v") ?
    ($component_height * $num_cases) :
    $component_height}] \
	    -width [expr $block_indentation * $indent_width]
    label $c.l -text $text_label
    pack $c -anchor [convert_justification $justification]
    pack $c.s -side left
    pack $c.l -side left
    #set lab $c.l
    #puts [$c.l configure]

    if {$in_case || $in_invis || $in_colour} {
	lappend cases($case_no) "label $c.l"
    }
    if {$num_cases!=[llength $case_pairs]} {
	error "While parsing .basrad $text_label. Incorrect number of cases"
    }

    set first 1
    set link_var $c.var
    set firstc ""
    set c [component_name right]
    # This frame will contain all buttons in the set
    frame $c
    set count 0
    pack $c  -anchor w
    foreach i $case_pairs {
	incr count
	# $fb is a frame for the spacing $sb and the button $rb
	set fb $c.f$count
	set rb $fb.r
	set sb $fb.s

	frame $fb 

	frame $sb \
		-height $component_height \
		-width [expr {($first && $orientation == "h") ? $indent_width : 0}]

	# Substitute any embedded functions
	set buttonLabel [evalEmbeddedCommands [lindex $i 0]]

	radiobutton $rb -relief flat -state normal -variable link($link_var) \
		-anchor w \
		-text $buttonLabel \
		-value [lindex $i 1] \
		-command "check_or_radio_pressed $variable $link_var $rb"

	# pack it to left for horizontal buttons and to top for vertical buttons
	# -fill x to ensure it lines up exactly with other $fb's
	pack $fb -side [convert_orientation $orientation] -fill x

	# pack these left within $fb
	pack $sb -side left
	pack $rb -side left

	if {$orientation =="h"} {
	    if {$firstc==""} {
		set firstc $c
		lappend tab_list($win,lr) "END"
		lappend tab_list($win) $rb
	    }

	    lappend tab_list($win,lr) $rb
	    #puts $tab_list($win,lr)
	    
	    # Key bindings for moving around
	    basrad_binding_h $win $rb
	} else {
	    lappend tab_list($win) $rb

	    # Key bindings for moving around
	    basrad_binding_v $win $rb
	}

	if {$in_case || $in_invis || $in_colour} {
	    lappend cases($case_no) "radiobutton $rb"
	}
	
	set first 0
    }
    
    if {$orientation =="h"} {
	lappend tab_list($win,lr) "END"
    }


    set link($link_var) [get_variable_value $variable]
    
    lappend variables_on_window($win) $variable
    set_help_text $variable $text_label 
}

proc check_or_radio_pressed {variable link_var name} {

    global link hilit col_bg_normal
    # Button has been pressed - unhighlight it
    if [info exists hilit($name)] {
	unset hilit($name)
    }
    $name configure -bg $col_bg_normal

    focus $name
    set_variable_value $variable $link($link_var)

    # Apply changes to window appearance
    apply_changes $variable
}

# apply_changes
#    Applies changes to a variable to the grey status of windows
#    and to any linked variables.
# Argument
#    variable : Name of variable to change

proc apply_changes {variable} {

    global sensitive_variables link_variables

    set name [lindex [split $variable (] 0]
    # Apply case logic to window appearance
    if [info exists sensitive_variables($name)] {
	foreach case_no $sensitive_variables($name) {
	    evaluate_case $case_no
	}
    }

    # Change any linked variables
    if [info exists link_variables($variable)] {
	linked_variable_changed $link_variables($variable)
    }
}


