#######################################################################
# proc bind_ok                                                        #
# Call with name of a dialog box with one button and name of button   #
# Highlights button when window in focus and binds space key to close #
#######################################################################

proc bind_ok {window button} {     

    push_focus $window
    bind $window <Return> "$button invoke" 
    bind $window <Any-Enter> "push_focus $window" 

    # Highlighted Close button indicates focus is on canvas
    bind $window <FocusIn> "$button configure -state active"
    bind $window <FocusOut> "$button configure -state normal"

}

#######################################################################
# proc bind_button_list                                               #
# Call with list of buttons in form: bind_button_list .b1 .b2 .b3     #
# Highlights first button and binds left-right keys to move between   #
# buttons. Therefore buttons should be listed in order                #
#######################################################################

proc bind_button_list {args} {

    foreach button $args {
	bind $button <Return> "$button invoke" 
	bind $button <Left> "move_buttons -1 $args"
	bind $button <Right> "move_buttons 1 $args"
	bind $button <FocusIn> "$button configure -state active"
	bind $button <FocusOut> "$button configure -state normal"
    }
    push_focus [lindex $args 0]
}

#######################################################################
# proc move_buttons                                                   #
# procedure bound to left-right keys to move focus between buttons    #
#######################################################################

proc move_buttons {direction args} {

    set pos [lsearch $args [focus]]

    if { ($pos==[expr [llength $args]-1]) && ($direction==1) } {return}
    if { ($pos==0) && ($direction==-1) } {return}
    incr pos $direction
    focus [lindex $args $pos]
}
