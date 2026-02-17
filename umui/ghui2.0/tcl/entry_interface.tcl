# draw the interface for the entry system
#

proc draw_entry_interface {} {

    global colours fonts menus lines maxlines line_height init_lines titles icons
    global primary_server backup_server
    global backup_state
    global relative_width
    global application

    if {$backup_server == "NONE"} {
	set server_text "($primary_server=ACTIVE)"
    } else {
	set server_text "($primary_server=ACTIVE,$backup_server=$backup_state)"
    }
    # position window and add title
    wm geometry . +50+50
    wm title . "Generic Hierarchical User Interface: $application application. $server_text"
    wm iconname . "$application \n$primary_server"
    wm iconbitmap . "$icons(icon)"

    wm maxsize . 2000 [expr $maxlines+2]

    # menu bar
    set ix [expr [winfo screenwidth .] * $relative_width]
    set ix [lindex [split $ix .] 0]

    wm grid . $ix [expr $maxlines+2] 1 $line_height
    wm geometry . $ix\x[expr $init_lines+2]
    draw_menu_bar .
    # scrollbar
    scrollbar .sbar -relief sunken -command move_list
    pack .sbar -side right -fill y

    # lines, including title line
    for {set i 0} {$i <= $maxlines} {incr i} {

	# frame and icon
	frame .l$i -height $line_height -width $ix
	bind .l$i <ButtonPress> "line_pressed $i"
	pack .l$i -expand y -fill x
	label .l$i.icon -bitmap $icons(blank)
	bind .l$i.icon <ButtonPress> "icon_pressed $i"
	place .l$i.icon -in .l$i -relx $titles(relpos,icon) -relheight 1

	# columns
	foreach column $titles(display_columns) {
	    label .l$i.$column -font $fonts(lines)
	    bind .l$i.$column <ButtonPress> "line_pressed $i"
	    place .l$i.$column -in .l$i -relx $titles(relpos,$column) -relheight 1
	}
    }

    # title line
    foreach column $titles(display_columns) {
	.l0.$column configure -text $titles(title,$column) 
    }
    update idletasks
    bind . <Configure> {
	if {"%W" == "."} {
	    global lines line_height
	    set lines [expr %h/$line_height-2]
	    move_list [lindex [.sbar get] 2]
	}
    }
}

proc draw_menu_bar {win} {
    global menus fonts line_height

    if {$win=="."} {set win ""}

    #frame $win.mbar -relief raised -border 2
    #pack $win.mbar -fill x

    set mbar $win.mbar

    # Create and configure frame in two stages. Previously, a colour
    # saturation error would prevent menubar being properly configured.
    frame $mbar
    $mbar configure -relief raised -border 2 -height $line_height

    pack $mbar -fill x -expand y
    frame $mbar.2
    place $mbar.2 -relheight 1 -relx 0 -relwidth 1
    set mbar $mbar.2
    set i 0
    foreach title $menus(titles) {

	# menu item
	menubutton $mbar.$i -text $title -menu $mbar.$i.menu -font $fonts(menus) -underline 0
	if {$title == "Help"} {
	    set side right
	} else {
	    set side left
	}
	pack $mbar.$i -side $side -padx 1m

	# menu
	menu $mbar.$i.menu
	foreach item $menus(items-$title) {
	    if {$item == "GAP"} {
		$mbar.$i.menu add separator
	    } else {
		$mbar.$i.menu add command -label $menus(text-$title-$item) \
			-command menu_$item -font $fonts(menus)
	    }
	}

	incr i
    }
}

