#
# dialogs.tcl
#  Contains procedures that are useful for building a range of
#  simple dialog style input boxes.

# Public:
# tLevelDialog : Create a uniquely named toplevel
# buttonArray: Create an array of buttons, one per command
# eDialog : Create frame with question and entrybox
# tDialog : Create frame with question
#
# Private:
# standardFrame : Create a frame with standard border.
# testGeneralDialog : Test dialog to exercise each proc

# tLevelDialog
#   Create a toplevel window with class dialog and a unique name
# Argument
#   title : Title of toplevel
# Result
#   Return name of window

proc tLevelDialog {title} {
    
    set i 1
    while {[info commands .genDialog$i] == ".genDialog$i"} {incr i}
    set t .genDialog$i

    toplevel $t -class Dialog
    wm title $t $title
    return $t
}

# buttonArray
#   Create an array of buttons in a frame with given text and bindings
# Arguments
#   t : Container frame
#   args : A list of properties for each button
# Method
#   Each button is defined by a list containing button text followed by 
#   bind command and optional arguments.
# Result
#   Returns name of first button (to allow focus to be set if required)
# Example
#   set f fVar
#   set b [buttonArray $t [list Save saveFile \$$f \; destroy $t] \
#                  [list Cancel destroy $t]
#   focus $b

#   Creates two buttons. Selecting the first calls saveFile with
#   argument $fVar, where fVar is the name of a global variable known
#   by the calling application. It also destroys the toplevel. Protect
#   the $ in \$$f it is evaluated to $fVar on making the call to
#   buttonArray, so that the value of fVar is calculated when button
#   is pressed (eg. fVar might be a textvariable for an entrybox).
#   protect the ";" between commands (such as before the destroy),
#   otherwise they are considered to be a second command rather than a
#   list item and are evaluated immediately.  Selecting the second
#   button just destroys the panel.
#      Set focus to point to first button in array

proc buttonArray {t args} {


    # Create a standard looking frame
    set f [standardFrame $t]

    set c 1
    foreach b $args {
	# Get button text and command for each button
	set text [lindex $b 0]
	set command [lrange $b 1 end]
	set but $f.b$c
	# Use eval to ensure global variables in command are evaluated 
	# at time when button pressed.
	button $but -text $text -command "eval $command"
	grid $but -padx 3m -pady 3m -row 0 -column $c
	if {$c == 1} {set firstButton $but}
	incr c
    }
    return $firstButton
}

# standardFrame
#   Create and pack a standard frame with a unique name.
# Arguments
#   t : Window in which to pack frame
#   relief : -relief option for frame (defaults to raised)
#   pad : -ipadx option for packing frame (defaults to 3m)
#   side : -side option for packing (defaults to top)

proc standardFrame {t {relief raised} {pad 3m} {side top}} {

    set i 1
    while {[info commands $t.f$i] == "$t.f$i"} {incr i}
    set f $t.f$i
    pack [frame $f -relief $relief -bd 3] -ipady $pad -side $side -expand 1 -fill both
    return $f
}

# eDialog
#   Create a question with an entrybox.
# Arguments
#   t : Container frame
#   text : Question text
#   width : Entrybox width
#   var : Name of textvariable for entrybox
# Result
#   Returns name of entrybox

proc eDialog {t text width var} {

    # Create a standard frame to hold text and entry boxes
    set f [standardFrame $t]

    pack [message $f.l -text $text -width 3i] -pady 3m -side top -fill x
    pack [entry $f.e -width $width -textvariable $var] -side top
    return $f.e
}

# tDialog
#   Create a question frame.
# Arguments
#   t : Container frame
#   text : Question text

proc tDialog {t text} {

    # Create a standard frame to hold text and entry boxes
    set f [standardFrame $t]

    pack [message $f.m -text $text -width 3i] -pady 3m -side top -fill x -expand y
}

proc testGeneralDialog {} {

    proc putr {args} {
	puts $args
	puts [llength $args]
    }
    set t [tLevelDialog Title]
    set e [eDialog $t "This is the question" 12 myVar]
    tDialog $t "This is an even longer question - how wide will window get"
    buttonArray $t \
	    [list "Puts 1" set f \$myVar \; destroy $t \; putr \$f 1 \; unset f] \
	    [list "Puts 1 & 2" putr 1 2 \$myVar] ;#\
	    [list "Puts 2 & 2" putr 2 2 \$myVar] \
	    [list "Puts 3 & 2" putr 3 2 \$myVar] \
	    [list "Puts 4 & 2" putr 4 2 \$myVar] \
	    [list Quit destroy $t]
    bind $t <Destroy> "if {\"%W\" == \"$t\"} \
	    {unset myVar}"
    focus $e
}
