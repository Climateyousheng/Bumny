#######################################################################
# proc create_status_line                                             #
# Creates a status line in window $w to which messages can be sent    #
# by calling proc status_message                                      #
#######################################################################

proc create_status_line {w {font ""}} {

    global fonts

    if {$font==""} {set font $fonts(lines)}

    set line $w.status

    if {[info commands $line]==$line} {
	error "Only one status line per widget"
    }

    label $line -text {} -anchor w -font $font -relief groove

    pack $line -fill x -side bottom 
}
#######################################################################
# proc status_message                                                 #
# Write $text to the status line in window $w                         #
# NB this routine is called from processing C routines                #
#######################################################################

proc status_message {w text} {

    global wait_$w

    set wait_$w [exec date +%S]

    $w.status configure -text $text
    
}

#######################################################################
# proc clear_message                                                  #
# Clears message after a short delay                                  #
#######################################################################

proc clear_message {w} {	

    global wait_$w

    if {[info exists wait_$w]} {
	while {[set wait_$w]==[exec date +%S]} {}
    }

    $w.status configure -text ""

}

#######################################################################
# proc append_message                                                 #
# Appends message to current status line text                         #
#######################################################################

proc append_message {w text} {

    set current [lindex [$w.status configure -text] 4]
    append current $text
    status_message $w $current
}
