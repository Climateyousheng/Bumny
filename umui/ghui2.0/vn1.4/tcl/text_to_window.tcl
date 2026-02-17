# text_to_window.tcl
#
# Takes a page of text delimited with \n characters and puts it on a
# toplevel with scrollbars and a close button.
#
# External Routines:
#  push_focus : Adds button to application's focus stack

# text_to_window
#   Interface to textToWindow to provide backwards compatibility for 
#   UMUI calls

proc text_to_window {win text c_height title} {
    set text [join $text \n]
    textToWindow $win $text $title
}

# proc textToWindow
#   Output text list to a neat window with scroll bars and close button
# Arguments
#   win : Name of toplevel to create
#   text : Text to display
#   title : Title of toplevel

proc textToWindow {win text {title ""} {width 80}} {
    global fonts TWindow

    # Create the window
    set t [text_window $win $title $width]
    set TWindow($win,name) $t

    # Send the text to the window
    $t insert end "$title \n\n$text"
    $t configure -state disabled
    wm deiconify $win

    # Bind scroll bars to keyboard and for resizing of window
    bind_text_window $win

}

# addTextToWindow
#  Add more text to an existing TWindow
# Arguments
#  win : Window name and id
#  text : More \n delimited text

proc addTextToWindow {win text {title ""} {width 80}} {
    global TWindow

    if {[info commands $win] != $win} {
	textToWindow $win $text $title $width
    } else {

	set t $TWindow($win,name)

	# Send the text to the window
	$t configure -state normal
	$t insert end "$text"
	$t configure -state disabled
    }
}    

# text_window
#  Creates toplevel with scrollbar and empty text widget
# Arguments
#  win : Name of toplevel
#  title : Title for toplevel
# Result
#  Returns name of text widget

proc text_window {win title width} {
    global fonts TWindow

    # Create a resizeable toplevel
    toplevel $win
    wm withdraw $win
    wm minsize $win 10 10
    if {$title != ""} {
	wm title $win $title
    }

    # Text widget and scrollbars
    text $win.t  -width $width -height 40 -wrap none -font $fonts(textOutput)\
	    -yscrollc "$win.vscroll set" -xscrollc "$win.hscroll set" 
    scrollbar $win.vscroll  -relief sunken -command "$win.t yview"
    scrollbar $win.hscroll  -orient horiz -relief sunken -command "$win.t xview"

    # Copy selection to clipboard to allow pasting into ved editor
    bind $win.t <ButtonRelease-1> "setClipboard"

    # Close button widgets
    frame $win.b -relief groove -bd 2
    button $win.b.b -text Close -command "destroy_window $win"

    # Pack button
    pack $win.b -fill both -side bottom
    pack $win.b.b -side bottom -padx 1m -pady 1m -ipadx 1m -ipady 1m

    set TWindow($win,button) $win.b.b

    # Pack text widget and scrollbars
    pack $win.t -fill both -expand yes -padx 3 -pady 3
    pack $win.vscroll -side right -before $win.t -fill y
    pack $win.hscroll -side bottom -before $win.t -fill x

    return $win.t
}

# setClipboard
#  Copies selection to clipboard. Required in order to allow pasting into
#  ved windows which otherwise doesn't work.

proc setClipboard {} {
    clipboard clear
    catch {clipboard append [selection get]}
}

# bind_text_window
#  Set up bindings to allow keyboard control of scrolling.
# Arguments
#  win : Name of toplevel
# Comments
#  Names of buttons and text widget assumed.

proc bind_text_window {win} {
    global TWindow

    set w $TWindow($win,name)
    set b $TWindow($win,button)


    # Highlighted Close button indicates focus is on canvas
    bind $b <FocusIn> "$b configure -state active"
    bind $b <FocusOut> "$b configure -state normal"

    # For keyboard scrolling of window
    bind $b <Up> "$w yview scroll -1 units"
    bind $b <Down> "$w yview scroll 1 units"
    bind $b <Left> "$w xview scroll -1 units"
    bind $b <Right> "$w xview scroll 1 units"

    # Add button to application's focus stack
    push_focus $b
}
