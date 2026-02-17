proc file_entry_component {text_label justification variable} {

    global component_height block_indentation indent_width
    global variables_on_window win entry_boxes tab_list
    global in_case case_no cases

    set c [component_name left]
    frame $c
    frame $c.s \
	    -height $component_height \
	    -width [expr $block_indentation * $indent_width]
    label $c.l -text $text_label
    pack $c -anchor [convert_justification $justification]
    pack $c.s -side left
    pack $c.l

    if {$in_case || $in_invis} {
	lappend cases($case_no) "label $c.l"
    }

    set c [component_name right]
    frame $c
    entry $c.e  -relief sunken -width 40
    set command "filewalk $c.e"
    button $c.b -text "Filewalk" -command $command
    pack $c.b -side right -ipadx 2 -padx 5
    pack $c.e
    pack $c -anchor [convert_justification $justification]

    $c.e insert 0 [get_variable_value $variable]

    lappend tab_list($win) $c.e
    # Routine to do key bindings for moving around
    entry_binding $win $c.e 

    bind $c.e <FocusOut> "+entryboxUpdated $c.e $variable"

    lappend entry_boxes($win) "$variable $c.e"
    lappend variables_on_window($win) $variable
    set_help_text $variable $text_label

    if {$in_case || $in_invis} {
	lappend cases($case_no) "entry $c.e"
	lappend cases($case_no) "entry $c.b"
    }
}

# Need to make changes to proc table_start so it recognises a file_table
# and produces a "filewalk" button and links it to the current focus
#
# This will involve an extra argument to the routine and extra args
# to all the table tags in the windows. It may be easier to copy the
# proc table_start to file_table_start and call it explicetly.







