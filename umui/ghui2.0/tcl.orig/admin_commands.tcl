proc check_status {} {

  global bserver mserver

  set mstatus 0
  set bstatus 1

  if {$mserver != "NONE"} {
    set mstatus [RPC $mserver server_get_status]
  } else {
    set mstatus "PAUSED"
  }

  if {$bserver != "NONE"} {
    set bstatus [RPC $bserver server_get_status]
  } else {
    set bstatus "PAUSED"
  }

  if {$mstatus == "ACTIVE" || $bstatus == "ACTIVE"} {
    # if one or more servers are active
    return 0
  } else {
    return 1
  }
}

# check_type
#   For dual-server mode: Checks that the server types are not the same
# Warning
#   Procedure should not be called when either server is reloading as
#   the RPC call seems to block the server from getting the completion
#   reply from the reload procedure. TBD: Probably the
#   check_reload_status calls should be included in this routine.

proc check_type {} {

  global bserver mserver

  set mtype 0
  set btype 1

  if {$mserver != "NONE"} {set mtype [RPC $mserver server_get_type]}
  if {$bserver != "NONE"} {set btype [RPC $bserver server_get_type]}

  if {$btype != $mtype} {
    # if types are different
    return 1
  } else {
    # if types are the same
    return 0
  }
}

proc clear_log_pressed {server window} {
  if {[check_reload_status $server]} {return}
  RPC $server clear_log
  fill_log_tail $server $window
}

proc fill_log_tail {server window} {
  if {[check_reload_status $server]} {return}
  $window configure -text [RPC $server tail_log]
}

proc toggle_server_type {server button window} {

  if {[check_reload_status $server]} {return}

  set type [RPC $server server_get_type]
  set status [RPC $server server_get_status]

  if {$status == "PAUSED"} {
    if {$type=="PRIMARY"} {
      RPC $server server_set_type "BACKUP"
      $button configure -text "Type (BACKUP )"
      fill_log_tail $server $window
    } elseif {$type=="BACKUP"} {
      RPC $server server_set_type "PRIMARY"
      $button configure -text "Type (PRIMARY)"
      fill_log_tail $server $window
    } else {
      unknown_type_dialog
    }
  } elseif {$status == "EMPTY"} {
    empty_dbse_error
  } else {
    not_paused_dialog
  }
}

proc toggle_server_status {server button window} {

    if {[check_reload_status $server]} {return}

    set status [RPC $server server_get_status]

    if {$status=="PAUSED"} {
	RPC $server server_set_status "ACTIVE"
	$button configure -text "Status (ACTIVE)"
	fill_log_tail $server $window
    } elseif {$status=="ACTIVE"} {
	RPC $server server_set_status "PAUSED"
	$button configure -text "Status (PAUSED)"
	fill_log_tail $server $window
    } elseif {$status=="EMPTY"} {
	empty_dbse_error
    } elseif {$status=="RELOAD"} {
	server_reloading_dialog
    } else {
	unknown_state_error
    }
}

proc start_server {server_name db_base_dir dbse_dir type} {

  global remote_shell_command server_started application

  if {$server_started($server_name) == 1} {
    server_running_dialog
  } else {
    exec $remote_shell_command $server_name -n $db_base_dir/bin/ghui_server \
	$db_base_dir $dbse_dir $type $application
    set server_started($server_name) 1
  }
}

proc reread_pressed {server button window} {

    global state_button reload_status

    if {[check_reload_status $server]} {return}
    
    set state_button($server) $button
  
    set status [RPC $server server_get_status]
    if {$status != "PAUSED" && $status != "EMPTY"} {
	not_paused_dialog
    } else {
	$button configure -text "Status (RELOAD)"
	update
	#set reload_status(Aserver) "RELOAD"
	set reload_status($server) "RELOAD"
	# Change buttons and status
	RPCreload $server reload_all $server

	$button configure -text "Status (PAUSED)"
	#unset reload_status(Aserver)
	
	#dp_RDO $server -callback "reload_all_callback" reload_all $server
    }
}

# Return 0 if reload status is not RELOAD
# otherwise dialog then return 1.
#
proc check_reload_status {server} {

  global reload_status 

  if {[info exists reload_status($server)]} {
    if {$reload_status($server) == "RELOAD"} {
      server_reloading_dialog
      return 1
    }
  }
  return 0
}


# reload_all_callback
#   Called on fileevent from socket when reloading indicating that 
#   reloading is complete. 
# Argument
#   sock : Server socket - used to address arrays
# Method
#   The reload function has a vwait on the reload_status($sock), so
#   when this routine sets it to PAUSED, the reload function can
#   complete its operation by reading the reply from the server.

proc reload_all_callback {sock} {

    global state_button reload_status
    # Cancel the callback
    fileevent $sock readable {}
    set reload_status($sock) "PAUSED"
}

proc copy_database {source_server source_dbse mserver mwindow\
    dest_server dest_dbse bserver bwindow button} {

  global fonts

  if {[check_reload_status $mserver]} {return}
  if {[check_reload_status $bserver]} {return}

  if {[check_status]} {
    toplevel .sure
    wm geometry .sure +900+200
    message .sure.msg -width 200 -text \
	"You have chosen to copy the database from $source_server to\
	$dest_server. ARE YOU SURE THIS IS WHAT YOU WANT?" \
	-font $fonts(help)
    button .sure.q -text "Continue" \
	-command "docopy_dbse $source_server $source_dbse $mserver $mwindow\
	$dest_server $dest_dbse $bserver $bwindow $button
    catch {destroy .sure}" 
    button .sure.a -text "Abandon" \
	-command "catch {destroy .sure}"
    pack .sure.msg -padx 2m -pady 2m
    pack .sure.q .sure.a -side left -ipadx 1m -ipady 2m -pady 2m -expand yes
  } else {
    check_status_error
  }
}

proc docopy_dbse {source_server source_dbse mserver mwindow\
    dest_server dest_dbse bserver bwindow button} {

  global remote_shell_command
# The following two will not work if there are too many directories
# in the database. This needs to be looked at.
#  exec $remote_shell_command $dest_server rm -fr $dest_dbse/*
#  exec rcp -r $source_server:$source_dbse/* $dest_server:$dest_dbse/.
# These two may work and should be tested.
  exec $remote_shell_command $dest_server rm -fr $dest_dbse
  exec rcp -r $source_server:$source_dbse $dest_server:$dest_dbse
  if {$mserver != "NONE"} {
    RPC $mserver log_database_copy $source_server $dest_server
    fill_log_tail $mserver $mwindow
  }
  if {$bserver != "NONE"} {
    RPC $bserver log_database_copy $source_server $dest_server
    if {[RPC $bserver server_get_status] != "EMPTY"} {
      RPC $bserver server_set_status "EMPTY"
      $button configure -text "Status (EMPTY)"
    }
    fill_log_tail $bserver $bwindow
  }
}


# halt_pressed
#   Kill the appropriate server and redraw the display
# Arguments
#   server : Socket name
#   server_name : hostname of server

proc halt_pressed {server server_name} {

    global server_started
    global mserver bserver

    # Minor BODGE. Cannot do the draw_admin_interface if
    # either server reloading so prevent either server 
    # being killed if other one loading.
    if {[check_reload_status $mserver]} {return}
    if {[check_reload_status $bserver]} {return}

    catch {RPC $server halt_server}
    set server_started($server_name) 0
    draw_admin_interface
}

proc fill_open_list {server window} {

  global open_list

  if {[check_reload_status $server]} {return}

  set open_list [RPC $server list_open_jobs]
  catch {$window delete 0 end}
  foreach item $open_list {
    $window insert end $item
  }
}


proc force_close_pressed {server window} {

  global open_list

  if {[check_reload_status $server]} {return}

  set item [$window  curselection]
  if {$item == ""} {
    error "Select a job to close from the list."
  }
  set spec [lindex $open_list $item]
  catch {RPC $server force_close_job [lindex $spec 0] [lindex $spec 1]}
}

proc read_clients_file {file} {

  global clients

  if {[file readable $file]==0} {
    file_unreadable_dialog $file
    return
  }

  set handle [open $file r]
  set clients [read -nonewline $handle]
  close $handle
}

proc create_server_def_file {file} {

  global mserver          bserver
  global primary_server   backup_server
  global primary_base_dir backup_base_dir
  global primary_dbse     backup_dbse
  global port

  set date [exec date]

  if {$mserver != "NONE" } {
    if {[check_reload_status $mserver]} {return}
    set mtype [RPC $mserver server_get_type]
  } else {
    set mtype DEAD
  }

  if {$bserver != "NONE" } {
    if {[check_reload_status $bserver]} {return}
    set btype [RPC $bserver server_get_type]
  } else {
    set btype DEAD
  }

  if {$mtype=="PRIMARY"} {
    set server1   $primary_server
    set base_dir1 $primary_base_dir
    set dbse1     $primary_dbse
  } elseif {$mtype=="BACKUP"} {
    set server2   $primary_server
    set base_dir2 $primary_base_dir
    set dbse2     $primary_dbse
    set ignore2   "ACTIVE"
  }
  
  if {$btype=="BACKUP"} {
    set server2   $backup_server
    set base_dir2 $backup_base_dir
    set dbse2     $backup_dbse
    set ignore2   "ACTIVE"
  } elseif {$btype=="PRIMARY"} {
    set server1   $backup_server
    set base_dir1 $backup_base_dir
    set dbse1     $backup_dbse
  }

  if {$mtype=="DEAD" && $btype=="DEAD"} {
    set server1   $primary_server
    set base_dir1 $primary_base_dir
    set dbse1     $primary_dbse
    set server2   $backup_server
    set base_dir2 $backup_base_dir
    set dbse2     $backup_dbse
    set ignore2   "ACTIVE"
  } elseif {$mtype=="DEAD" && $btype == "PRIMARY"} {
    set server2   $primary_server
    set base_dir2 $primary_base_dir
    set dbse2     $primary_dbse
    set ignore2   "IGNORE"
  } elseif {$btype=="DEAD" && $mtype == "PRIMARY"} {
    set server2   $backup_server
    set base_dir2 $backup_base_dir
    set dbse2     $backup_dbse
    set ignore2   "IGNORE"
  } elseif {$btype=="DEAD" && $mtype == "BACKUP"} {
    no_primary_dialog $primary_server
    return 0
  } elseif {$mtype=="DEAD" && $btype == "BACKUP"} {
    no_primary_dialog $backup_server
    return 0
  }
    
  set handle [open $file w]

  puts $handle "# This file is created by the ghui_admin script"
  puts $handle "# client configuration option. It is read, initially,"
  puts $handle "# by each of the scripts ghui, ghui_admin and ghui_server."
  puts $handle "\n# Created: $date"
  
  puts $handle "\n# Primary server definitions"
  puts $handle "set primary_server   \"$server1\""
  puts $handle "set primary_base_dir \"$base_dir1\""
  puts $handle "set primary_dbse     \"$dbse1\""
  
  puts $handle "\n# Backup server definitions"
  puts $handle "set backup_server    \"$server2\""
  puts $handle "set backup_base_dir  \"$base_dir2\""
  puts $handle "set backup_dbse      \"$dbse2\""    
  puts $handle "set backup_state     \"$ignore2\""
  puts $handle "set port               $port"  
  close $handle
  return 1
}

proc menu_quit_admin {} {

  global mserver bserver

  if {[check_reload_status $mserver]} {return}
  if {[check_reload_status $bserver]} {return}

  # Check for consistent configuration.
  if {[check_type]} {
    catch {CloseRPC $bserver}
    catch {CloseRPC $mserver}
    exit
  } else {
    check_type_error
  }
}

proc menu_redraw {} {
  draw_admin_interface
}

proc menu_show_clients {} {

    global fonts clients
    global primary_server backup_server
    global primary_dbse backup_dbse
    global primary_base_dir backup_base_dir
    global backup_state
    global mserver bserver
    
    if {[check_reload_status $mserver]} {return}
    if {[check_reload_status $bserver]} {return}
    if ![check_type] {
	check_type_error
	return
    }

    read_server_def
    read_clients_file [appdir_path etc]/clients.def
    
    if {$mserver != "NONE" } {
	if {[check_reload_status $mserver]} {return}
	set mtype [RPC $mserver server_get_type]
    } else {
	set mtype DEAD
    }

    if {$bserver != "NONE" } {
	if {[check_reload_status $bserver]} {return}
	set btype [RPC $bserver server_get_type]
    } else {
	set btype DEAD
    }

    if {$mtype=="PRIMARY"} {
      set server1   $primary_server
	set base_dir1 $primary_base_dir
	set dbse1     $primary_dbse
    } elseif {$mtype=="BACKUP"} {
	set server2   $primary_server
	set base_dir2 $primary_base_dir
	set dbse2     $primary_dbse
	set ignore2   "ACTIVE"
    }
  
    if {$btype=="BACKUP"} {
	set server2   $backup_server
	set base_dir2 $backup_base_dir
	set dbse2     $backup_dbse
	set ignore2   "ACTIVE"
    } elseif {$btype=="PRIMARY"} {
	set server1   $backup_server
	set base_dir1 $backup_base_dir
	set dbse1     $backup_dbse
    }

    if {$mtype=="DEAD" && $btype=="DEAD"} {
	set server1   $primary_server
	set base_dir1 $primary_base_dir
	set dbse1     $primary_dbse
	set server2   $backup_server
	set base_dir2 $backup_base_dir
	set dbse2     $backup_dbse
	set ignore2   "ACTIVE"
    } elseif {$mtype=="DEAD" && $btype == "PRIMARY"} {
	set server2   $primary_server
	set base_dir2 $primary_base_dir
	set dbse2     $primary_dbse
	set ignore2   "IGNORE"
    } elseif {$btype=="DEAD" && $mtype == "PRIMARY"} {
	set server2   $backup_server
	set base_dir2 $backup_base_dir
	set dbse2     $backup_dbse
	set ignore2   "IGNORE"
    } elseif {$btype=="DEAD" && $mtype == "BACKUP"} {
	no_primary_dialog $primary_server
	return 0
    } elseif {$mtype=="DEAD" && $btype == "BACKUP"} {
	no_primary_dialog $backup_server
	return 0
    }
  
    set win .clients_config

    toplevel $win
    wm geometry $win +100+100
    wm title $win "GHUI Client Configuration"

    frame $win.curr -borderwidth 3 -relief raised
    frame $win.curr.sub -borderwidth 1
    frame $win.new -borderwidth 3 -relief raised
    frame $win.new.sub  -borderwidth 1
    frame $win.cli -borderwidth 3 -relief raised
    frame $win.cli.sub  -borderwidth 1
    frame $win.finishd -relief raised -borderwidth 3

    pack $win.curr $win.new.sub -fill x
    pack $win.curr.sub -side bottom
    pack $win.new -fill x
    pack $win.new.sub -side bottom
    pack $win.cli -fill x
    pack $win.cli.sub -side bottom -fill both -expand y
    pack $win.finishd -fill x

    label $win.curr.space -font $fonts(lines) -text {}
    label $win.curr.label -font $fonts(buttons) \
	    -text "Current Client Configuration"

    label $win.curr.sub.text1 -font $fonts(lines) \
	    -text "Primary server is..................$primary_server"
    label $win.curr.sub.text2 -font $fonts(lines) \
	    -text "Primary base directory is..........$primary_base_dir"
    label $win.curr.sub.text3 -font $fonts(lines) \
	    -text "Primary database directory is......$primary_dbse"
    label $win.curr.sub.text4 -font $fonts(lines) \
	    -text "Backup server is...................$backup_server"
    label $win.curr.sub.text5 -font $fonts(lines) \
	    -text "Backup base directory is...........$backup_base_dir"
    label $win.curr.sub.text6 -font $fonts(lines) \
	    -text "Backup database directory is.......$backup_dbse"
    label $win.curr.sub.text7 -font $fonts(lines) \
	    -text "Backup server state is set to......$backup_state"
    label $win.curr.sub.space -font $fonts(lines) -text {}
    
    label $win.new.space -font $fonts(lines) -text {}
    label $win.new.label -font $fonts(buttons) \
	    -text "New Client Configuration"


    label $win.new.sub.text1 -font $fonts(lines) \
	    -text "Primary server is..................$server1"
    label $win.new.sub.text2 -font $fonts(lines) \
	    -text "Primary base directory is..........$base_dir1"
    label $win.new.sub.text3 -font $fonts(lines) \
	-text "Primary database directory is......$dbse1"
    label $win.new.sub.text4 -font $fonts(lines) \
	    -text "Backup server is...................$server2"
    label $win.new.sub.text5 -font $fonts(lines) \
	    -text "Backup base directory is...........$base_dir2"
    label $win.new.sub.text6 -font $fonts(lines) \
	    -text "Backup database directory is.......$dbse2"
    label $win.new.sub.text7 -font $fonts(lines) \
	    -text "Backup server state is set to......$ignore2"
    label $win.new.sub.space -font $fonts(lines) -text {}
    
    label $win.cli.space -font $fonts(lines) -text {}
    label $win.cli.label -font $fonts(buttons) \
	    -text "Known clients (clients.def)"

    # Create a listbox to contain a list of all the clients
    set cli $win.cli.sub
    listbox $cli.lb -height 10 -yscrollcommand "$cli.sb set"
    pack $cli.lb -side left -fill both -expand y
    scrollbar $cli.sb -command "$cli.lb yview"
    pack $cli.sb -side left -fill y
    for {set i 0} {$i < [llength $clients]} {incr i} {
	$cli.lb insert end "Client [expr $i+1] [lindex $clients $i]"
    }

    button $win.finishd.ok -text Ok -command "destroy $win"

    pack $win.curr.space -anchor w
    pack $win.curr.label -expand yes -side left
    pack $win.curr.sub.text1 -anchor w
    pack $win.curr.sub.text2 -anchor w
    pack $win.curr.sub.text3 -anchor w
    pack $win.curr.sub.text4 -anchor w
    pack $win.curr.sub.text5 -anchor w
    pack $win.curr.sub.text6 -anchor w
    pack $win.curr.sub.text7 -anchor w
    pack $win.curr.sub.space -anchor w

    pack $win.new.space -anchor w
    pack $win.new.label  -expand yes -side left 
    pack $win.new.sub.text1 -anchor w
    pack $win.new.sub.text2 -anchor w
    pack $win.new.sub.text3 -anchor w
    pack $win.new.sub.text4 -anchor w
    pack $win.new.sub.text5 -anchor w
    pack $win.new.sub.text6 -anchor w
    pack $win.new.sub.text7 -anchor w
    pack $win.new.sub.space -anchor w

    pack $win.cli.space -anchor w
    pack $win.cli.label -expand yes -side left

    pack $win.finishd.ok -side left -expand yes -ipadx 1m -pady 4m

}

proc menu_conf_clients {} {

  global fonts reload_status
  global mserver bserver

  if {[check_reload_status $mserver]} {return}
  if {[check_reload_status $bserver]} {return}

  if {[check_status]} {
    if {[check_type]} {
      toplevel .sure
      wm geometry .sure +400+100
      message .sure.msg -width 200 -text \
	  "This will write the current configuration to all the clients \
	  that are defined in the clients.def configuration file. Are you \
	  sure this is what you want?" \
	  -font $fonts(help)
      button .sure.q -text "Yes" -command {
	catch {destroy .sure}
	go_conf_clients
      }
      button .sure.a -text "Abandon" -command {
	catch {destroy .sure}
      }
      pack .sure.msg -padx 2m -pady 2m
      pack .sure.q .sure.a -side left -ipadx 1m -ipady 2m -pady 2m -expand yes
    } else {
      check_type_error
    }
  } else {
    check_status_error
  }
}

proc go_conf_clients {} {

  global tmpdir clients
  global bserver mserver

  set tmpfile $tmpdir/ghui_type_def.tmp

  read_clients_file [appdir_path etc]/clients.def
  
  if {[create_server_def_file $tmpfile]==0} {return}

  for {set i 0} {$i < [llength $clients]} {incr i} {
    set client [lindex $clients $i]
    regsub ":.*" $client "" uid_at_host
    regsub ".*@" $uid_at_host "" host
#    set thistest [exec $base_dir/bin/ghui_hostup $host]
    set thistest [exec [ghuidir_path bin]/ghui_hostup $host]
    if { $thistest == "yes" } {
      if {[regexp ".*@.*:.*" $client]} {
	if {[catch {exec rcp $tmpfile $client/etc/servers.def}]!=0} {
	  conf_clients_error $client
	}
      }
    } elseif { $thistest == "unknown" } {
      conf_clients_error2 $client
    } elseif { $thistest == "no" } {
      conf_clients_error3 $client
    } else {
      conf_clients_error4 $client
    }
  }
  exec rm -f $tmpfile
  if {$mserver != "NONE"} {RPC $mserver log_client_config}
  if {$bserver != "NONE"} {RPC $bserver log_client_config}
  quit_admin_dialog
}

