# The user interface for the database admin client

proc draw_admin_interface {} {

    global mserver bserver

    if {[info exists bserver]} {
	if {[check_reload_status $bserver]} {return}
    }

    if {[info exists mserver]} {
	if {[check_reload_status $mserver]} {return}
    }  

    catch {destroy .t}
    catch {destroy .mbar}

    read_server_def
    set_shared_globals

    # Set mserver and bserver to socket numbers or NONE
    setup_server_info

    draw_interface

    if {![check_type]} {check_type_error}

    if {$mserver != "NONE" } {
	fill_log_tail $mserver .t.bd.g.msg
	fill_open_list $mserver .t.bd.l.list
    }

    if {$bserver != "NONE" } {
	fill_log_tail $bserver .t.bd.m.msg
    }
}

# setup_server_info
#   Makes or remakes client connections to servers, setting up the global
#   variables that hold the socket names.
# Result
#   Opens connection to primary and backup server, setting
#   mserver and bserver to socket names, or to NONE if server down.

proc setup_server_info {} {

    global mserver bserver port server_started
    global primary_server backup_server

    
    # Make new client RPC connection to primary server after closing any
    # existing connection
    if [info exists mserver] {
	if {$mserver != "NONE"} {CloseRPC $mserver}
	unset mserver
    }
	
    catch {unset mserver}
    if [catch {set mserver [MakeRPCClient $primary_server $port]}] {
	set mserver "NONE"
	set server_started($primary_server) 0
    }

    # Make new client RPC connection to backup server after closing any
    # existing connection
    if [info exists bserver] {
	if {$bserver != "NONE"} {CloseRPC $bserver}
	unset bserver
    }
    if [catch {set bserver [MakeRPCClient $backup_server $port]}] {
	set bserver "NONE"
	set server_started($backup_server) 0
    }
}

# statusText
#   Sets up text for status button for server. Text depends on whether
#   server is up or down (or uncontactable), and the servers' status.

proc statusText {sock} {

    set status_text ""
    if {$sock != "NONE"} {

	set status [RPC $sock server_get_status]

	if {$status=="PAUSED"} {
	    set status_text "Status (PAUSED)"
	} elseif {$status=="ACTIVE"} {
	    set status_text "Status (ACTIVE)"
	} elseif {$status=="EMPTY"} {
	    set status_text "Status (EMPTY )"
	} else {
	    set status_text "Status (UNDEF )"
	}
    }
    return $status_text
}

# typeText
#   Sets up text for status button for server. Text depends on whether
#   server is up or down (or uncontactable), and the servers' status.

proc typeText {sock} {

    set type_text ""
    if {$sock != "NONE"} {

	set type   [RPC $sock server_get_type]
	if {$type=="PRIMARY"} {
	    set type_text "Type (PRIMARY)"
	} elseif {$type=="BACKUP"} {
	    set type_text "Type (BACKUP )"
	} else {
	    set type_text "Type (UNDEF  )"
	}
    }
    return $type_text
}

proc draw_interface {} {

    global bserver mserver primary_server backup_server
    global primary_base_dir backup_base_dir
    global primary_dbse backup_dbse
    global fonts

    wm geometry . +100+300
    wm title . "GHUI server administration ($primary_server,$backup_server)"
    wm iconname . " Admin "

    admin_appearance

    build_mbar

    frame .t
    frame .t.bd

    frame .t.bd.l
    label .t.bd.l.ttle -text "Open jobs ($primary_server)" -font $fonts(help)
    listbox .t.bd.l.list -relief sunken -width 30 -height 22 -selectmode single \
	    -yscrollcommand ".t.bd.l.sb set" -font $fonts(medium_lines)

    scrollbar .t.bd.l.sb -troughcolor gray70 \
	    -background grey80 -activebackground grey70 -command ".t.bd.l.list yview"
    frame .t.bd.l.b
    button .t.bd.l.b.reload -background cyan -text "Reload list" \
	    -font $fonts(buttons) \
	    -command "fill_open_list $mserver .t.bd.l.list"
    button .t.bd.l.b.force -background cyan \
	    -text "Force close" -font $fonts(buttons) -command {
	force_close_pressed $mserver .t.bd.l.list
	force_close_pressed $bserver .t.bd.l.list
	fill_open_list $mserver .t.bd.l.list
    }

    if {$mserver != "NONE" } {
	frame .t.bd.g
	label .t.bd.g.ttle \
		-text "Last 10 lines of primary server log ($primary_server)" \
		-font $fonts(help)
	message .t.bd.g.msg -width 800 -relief sunken -font $fonts(medium_lines)
	frame .t.bd.g.b
	button .t.bd.g.b.tail -background green -text "Reload log" \
		-font $fonts(buttons) \
		-command "fill_log_tail $mserver .t.bd.g.msg"
	button .t.bd.g.b.log -background green -text "Clear log" \
		-font $fonts(buttons) \
		-command "clear_log_pressed $mserver .t.bd.g.msg"
	button .t.bd.g.b.pause  -background green -text [statusText $mserver] \
		-font $fonts(buttons) \
		-command "toggle_server_status $mserver .t.bd.g.b.pause .t.bd.g.msg"
	button .t.bd.g.b.type -background green -text [typeText $mserver]\
		-font $fonts(buttons) \
		-command "toggle_server_type $mserver .t.bd.g.b.type .t.bd.g.msg"
	button .t.bd.g.b.reread -background green -text "Read database" \
		-font $fonts(buttons) \
		-command "reread_pressed $mserver .t.bd.g.b.pause .t.bd.g.msg"
	button  .t.bd.g.b.copy -background green  -activebackground red \
		-text "Copy" -font $fonts(buttons) \
		-command "copy_database $primary_server $primary_dbse \
		$mserver .t.bd.g.msg \
		$backup_server  $backup_dbse \
		$bserver .t.bd.m.msg .t.bd.m.b.pause "
	button .t.bd.g.b.halt \
		-background green -activebackground red \
		-text "Kill" -font $fonts(buttons) \
		-command "halt_pressed $mserver $primary_server"
    } else {
	frame .t.bd.g
	frame .t.bd.g.vspace1 -height 15m
	label .t.bd.g.txt1 -text "The primary server ($primary_server) is not running." \
		-font $fonts(help)
	frame  .t.bd.g.b
	button .t.bd.g.b.start \
		-background green -activebackground red \
		-text "Start Primary Server" -font $fonts(buttons) \
		-command "start_server $primary_server $primary_base_dir \
		$primary_dbse PRIMARY"
	frame .t.bd.g.vspace2 -height 15m
    }


    if {$bserver != "NONE" } {
	frame .t.bd.m
	label .t.bd.m.ttle \
		-text "Last 10 lines of backup server log ($backup_server)" \
		-font $fonts(help)
	message .t.bd.m.msg -width 800 -relief sunken -font $fonts(medium_lines)
	frame .t.bd.m.b
	button .t.bd.m.b.tail -background yellow -text "Reload log" \
		-font $fonts(buttons) \
		-command "fill_log_tail $bserver .t.bd.m.msg"
	button .t.bd.m.b.log -background yellow -text "Clear log" \
		-font $fonts(buttons) \
		-command "clear_log_pressed $bserver .t.bd.m.msg"
	button .t.bd.m.b.pause -background yellow -text [statusText $bserver] \
		-font $fonts(buttons) \
		-command "toggle_server_status $bserver .t.bd.m.b.pause .t.bd.m.msg"
	button .t.bd.m.b.type -background yellow -text [typeText $bserver]\
		-font $fonts(buttons) \
		-command "toggle_server_type $bserver .t.bd.m.b.type .t.bd.m.msg"
	button .t.bd.m.b.reread -background yellow -text "Read database" \
		-font $fonts(buttons) \
		-command "reread_pressed $bserver .t.bd.m.b.pause .t.bd.m.msg"
	button .t.bd.m.b.copy -background yellow  -activebackground red \
		-text "Copy" -font $fonts(buttons) \
		-command "copy_database $backup_server $backup_dbse $bserver .t.bd.m.msg\
		$primary_server $primary_dbse $mserver .t.bd.g.msg .t.bd.g.b.pause"
	button .t.bd.m.b.halt -font $fonts(buttons) \
		-background yellow -activebackground red \
		-text "Kill" \
		-command "halt_pressed $bserver $backup_server"
    } else {
	frame .t.bd.m
	frame .t.bd.m.vspace1 -height 15m
	if {$backup_server != "NONE"} {
	    label .t.bd.m.txt1 -text "The backup server ($backup_server) is not running." \
		    -font $fonts(help)
	    frame .t.bd.m.b
	    button .t.bd.m.b.start -font $fonts(buttons) \
		    -background yellow -activebackground red \
		    -text "Start Backup Server" \
		    -command "start_server $backup_server $backup_base_dir \
		    $backup_dbse BACKUP"
	}
	frame .t.bd.m.vspace2 -height 15m
    }

    pack .t
    pack .t.bd -padx 4m -pady 4m
    pack .t.bd.l -padx 2m -side left 
    pack .t.bd.l.b -side bottom -anchor w
    pack .t.bd.l.ttle -anchor center
    pack .t.bd.l.list -side left -fill x
    pack .t.bd.l.sb -side right -fill y
    pack .t.bd.l.b.reload -side left -padx 1m -pady 1m
    pack .t.bd.l.b.force  -side left -padx 1m -pady 1m

    if {$mserver != "NONE" } {
	pack .t.bd.g
	pack .t.bd.g.ttle -anchor center
	pack .t.bd.g.b -side bottom -anchor w
	pack .t.bd.g.msg -side bottom -anchor w
	pack .t.bd.g.b.tail   -side left -padx 1m -pady 1m
	pack .t.bd.g.b.log    -side left -padx 1m -pady 1m
	pack .t.bd.g.b.pause  -side left -padx 1m -pady 1m
	pack .t.bd.g.b.type   -side left -padx 1m -pady 1m
	pack .t.bd.g.b.reread -side left -padx 1m -pady 1m
	pack .t.bd.g.b.copy   -side left -padx 1m -pady 1m
	pack .t.bd.g.b.halt   -side left -padx 1m -pady 1m
    } else {
	pack .t.bd.g
	pack .t.bd.g.vspace1
	pack .t.bd.g.txt1 -anchor center
	pack .t.bd.g.b
	pack .t.bd.g.b.start -side left -padx 1m -pady 1m
	pack .t.bd.g.vspace2
	.t.bd.l.b.reload configure -state disabled
	.t.bd.l.b.force configure -state disabled
    }

    if {$bserver != "NONE" } {
	pack .t.bd.m
	pack .t.bd.m.ttle -anchor center
	pack .t.bd.m.b -side bottom -anchor w
	pack .t.bd.m.msg -side bottom -anchor w
	pack .t.bd.m.b.tail   -side left -padx 1m -pady 1m
	pack .t.bd.m.b.log    -side left -padx 1m -pady 1m
	pack .t.bd.m.b.pause  -side left -padx 1m -pady 1m
	pack .t.bd.m.b.type   -side left -padx 1m -pady 1m
	pack .t.bd.m.b.reread -side left -padx 1m -pady 1m
	pack .t.bd.m.b.copy   -side left -padx 1m -pady 1m
	pack .t.bd.m.b.halt   -side left -padx 1m -pady 1m
    } else {
	pack .t.bd.m
	pack .t.bd.m.vspace1
	if {$backup_server != "NONE"} {
	    pack .t.bd.m.txt1 -anchor center
	    pack .t.bd.m.b
	    pack .t.bd.m.b.start -side left -padx 1m -pady 1m
	} else {
	    catch {destroy .t.bd.g.b.copy}
	    catch {destroy .t.bd.g.b.type}
	}
	pack .t.bd.m.vspace2
    }
    wm deiconify .
}

proc build_mbar {} {

    global menus fonts

    frame .mbar -relief raised -border 2
    pack .mbar -fill x

    set i 0
    foreach title $menus(titles) {

	# menu item
	menubutton .mbar.$i -text $title -menu .mbar.$i.menu -font $fonts(menus)
	if {$title == "Help"} {
	    set side right
	} else {
	    set side left
	}
	pack .mbar.$i -side $side -padx 1m

	# menu
	menu .mbar.$i.menu
	foreach item $menus(items-$title) {
	    if {$item == "GAP"} {
		.mbar.$i.menu add separator
	    } else {
		.mbar.$i.menu add command \
			-label $menus(text-$title-$item) \
			-command menu_$item \
			-font $fonts(menus)
	    }
	}
	incr i
    }
}
