#==============================================================================
# RCS Header:
#   File         [$Source: /home/hc0300/umui/srce_code/GHUI_archive/ghui2.0/vn1.2/tcl/activeEntryComponent.tcl,v $]
#   Revision     [$Revision: 1.2 $]     Named [$Name: head#main $]
#   Last checkin [$Date: 2000/10/10 16:13:05 $]
#   Author       [$Author: hadsm $]
#==============================================================================

# activeEntryComponent.tcl
#   Contains procedures relating to an input panel widget comprising an
#   entry box and a text label that displays a conversion of the entry
#   box input. eg
#     .entry_active "Input value" L convertValueVAR VAR
#   convertValueVAR is an application specific procedure that converts
#   the input in some way and displays the result in a text label next 
#   to the entry box. The text label is updated on a KeyRelease binding.


# activeEntryComponent
#   Create an input panel component comprising a text description on the
#   left and on the right a two component widget comprising an entry box
#   and another text label. The text label will contain some conversion
#   of the entry input as defined by convCommand. The text label will
#   update whenever the entry is changed.
# Comments
#   Procedure is based very closely on entry_component
# Arguments
#   textLabel: Text description of entry
#   justification: Usually L for left justify
#   convCommand: Defines conversion of entry input to label output
#   variable: Application variable being modified
#   width: Width of entry box and label. Default to 40

proc activeEntryComponent {textLabel justification convCommand variable {width 40}} {
    global component_height block_indentation indent_width
    global variables_on_window win entry_boxes tab_list
    global in_case in_invis in_colour case_no cases

    # Substitute any embedded functions
    set textLabel [evalEmbeddedCommands $textLabel]

    # If UI variable, then substitute value
    set width [get_value $width]

    # Set up component on left of panel
    set c [component_name left]
    frame $c
    frame $c.s \
	    -height $component_height \
	    -width [expr $block_indentation * $indent_width]
    label $c.l -text $textLabel

    pack $c -anchor [convert_justification $justification]
    pack $c.s -side left
    pack $c.l

    # Add to list for greying out etc. if required
    if {$in_case || $in_invis || $in_colour} {
	lappend cases($case_no) "label $c.l"
    }

    # Set up components on right of panel
    set c [component_name right]
    frame $c    
    frame $c.s -height $component_height -width 5
    set f [frame $c.f]
    entry $f.e -relief sunken -width $width
    label $f.l -anchor w -padx 20p -width $width
    #button $f.b -text "h" -command "$convCommand dummy help"
    pack $c -anchor [convert_justification $justification]
    pack $c.s -side left
    pack $f
    grid $f.e $f.l

    # Input initial value into entry box and converted value into label
    set value [get_variable_value $variable]
    $f.e insert 0 [get_variable_value $variable]
    bind $f.e <KeyRelease> "convertInput $convCommand $f.e $f.l"
    bind $f.e <Motion> "convertInput $convCommand $f.e $f.l"
    convertInput $convCommand $f.e $f.l

    # List for items that user can keyboard tab to
    lappend tab_list($win) $f.e

    # Routine to do key bindings for moving around
    entry_binding $win $f.e

    # Allow any updating of table sizes etc.
    bind $f.e <FocusOut> "+entryboxUpdated $f.e $variable"

    lappend entry_boxes($win) "$variable $f.e"
    lappend variables_on_window($win) $variable
    set_help_text $variable $textLabel

    # Add to list for greying out etc. if required
    if {$in_case || $in_invis || $in_colour} {
	lappend cases($case_no) "entry $f.e"
	lappend cases($case_no) "label $f.l"
    }
}

# convertInput
#   Calls command that calculates a converted value based on the entry
#   input and displays it in the label widget.
# Arguments
#   command: Name of an application specific command
#   inEntry: Name of entry widget
#   outLabel: Name of text label

proc convertInput {command inEntry outLabel} {

    set input [$inEntry get]

    set output [$command $input]

    $outLabel configure -text "Converts to: $output"
}
