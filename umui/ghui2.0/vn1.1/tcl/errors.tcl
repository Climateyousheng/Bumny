# info_message
#    An output for error messages and their stack-traces. Allows
#    users to cut messages and paste into bug-reports.
# Argument
#    message : Error message
# Global
#    errorInfo : The Tcl stack-trace global

proc info_message message {
    global errorInfo

    set t .ghui_error

    # create dialog, or bring to top.
    if {[info commands $t] == "$t"} {
	wm withdraw $t
	wm deiconify $t
    } else {
	toplevel $t
	wm geometry $t +10+200
	wm title $t "GHUI errors and warnings"
	frame $t.f
	text $t.f.msg -relief raised -bd 2 -yscrollcommand "$t.f.sbar set"

	# Copy selection to clipboard to allow pasting into ved editor
	bind $t.f.msg <ButtonRelease-1> "setClipboard"
	scrollbar $t.f.sbar -relief sunken -command "$t.f.msg yview"
	frame $t.b
	button $t.b.ok -text Okay -command "destroy $t"
	button $t.b.st -text "s.t." -command " \
		global errorInfo; \
		$t.f.msg configure -state normal; \
		$t.f.msg insert end \"STACK-TRACE:\n\$errorInfo\n\"; \
		$t.f.msg configure -state disabled \
		"
	pack $t.b -side bottom -fill x
	pack $t.f -fill both -expand true
	pack $t.f.sbar -side right -fill y -expand true
	pack $t.f.msg -side left  -fill both -expand true
	pack $t.b.ok -side left -expand true -pady 2m -ipadx 1m
	pack $t.b.st -side left -expand true -pady 2m -ipadx 1m
    }
    $t.f.msg insert end $message
    $t.f.msg configure -state disabled
}

# errors
proc bgerror message {
    info_message "ERROR: $message\n"
}

# warnings
proc warning_message message {
    info_message "WARNINGS:\n$message\n"
}
