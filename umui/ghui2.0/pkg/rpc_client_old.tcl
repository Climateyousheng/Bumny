
package provide GHUIserver 1.0

# Remote Procedure Call client.
#


# Start the RPCclient 
#
proc start_rpc_client {server_name server_port server_type} {

    global server RPCErrorFlag

    set RPCErrorFlag 0
    catch {destroy .nc}
    catch {destroy .snr}

    if [catch {set server [MakeRPCClient $server_name $server_port]} errmsg] {
	wm withdraw .
	toplevel .nc
	wm title .nc "No connection"
	wm geometry .nc +200+200
	if {$server_type == "PRIMARY"} {
	    set server "NONE"
	    message .nc.m -width 500 -text "\
		    Could not connect to the $server_type server ($server_name).\
		    The $server_type server ($server_name) may be down.\
		    The $server_type server ($server_name) may not be running.\
		    There may be a network failure. \n \n\
		    \nSelect 'Quit' to quit the application or, if appropriate\
		    select 'Cancel' to cancel the command and the system will \
                    attempt to continue as though the command had not been tried.\
		    \nOtherwise, if there have been no announcements of outages then \
		    \nPLEASE report to Server Administrators as they may be unaware of the failure.\
		    \n \nError: $errmsg"

	} elseif {$server_type == "BACKUP"} {
	    set server "NONE"
	    message .nc.m -width 500 -text \
		    "Could not connect to the $server_type server ($server_name. \
		    The $server_type server ($server_name) may be down. \
		    The $server_type server ($server_name) may not be running. \n \n\
		    PLEASE report to Server Administrators as they may be unaware of the failure. \
		    Select 'Cancel' to cancel the command - the system will attempt \
                    to continue as though the command had not been attempted.\
		    \n You may still continue the command by selecting Continue, but \
		    the command will only take effect on the Primary Server \
                    Therefore, you should ensure that the Server Administrators \
		    are aware if you are making changes as the changes will not be mirrored on the \
		    backup server. Server Admin will resolve differences \
		    when the backup server is back in operation. \n \nError: $errmsg"
	    lappend bList [button .nc.r -text Continue -command {
		global backup_server
		set backup_server "NONE"
		destroy .nc
	    }]
	}
	lappend bList [button .nc.q -text Quit -command exit]
	lappend bList [button .nc.c -text Cancel -command {
	    global RPCErrorFlag
	    destroy .nc
	    wm deiconify .
	    set RPCErrorFlag 1
	}]
	pack .nc.m -padx 2m -pady 2m
	eval pack $bList -side left -ipadx 2m -ipady 1m -pady 2m -expand yes
	tkwait window .nc
	wm deiconify .
	if {$RPCErrorFlag == 1} {error "Command cancelled following server error. \
		\nWill attempt to continue as though command was not requested"}
    } else {
	set server_status [RPC $server server_get_status]
	if {$server_status != "ACTIVE"} {
	    CloseRPC $server
	    set server $server_status
	    wm withdraw .
	    toplevel .snr
	    wm geometry .snr +200+200
	    wm title .snr "$server_type server ($server_name) is $server_status"
	    message .snr.m -width 500 -text \
		    "The $server_type server ($server_name) is running normally, \
		    but is $server_status.\
		    It is probably undergoing maintenance. \
		    \"Retry\" will attempt to re-connect to the server. \
		    \"Continue\" will return you back to the previous panel. \
		    \"Quit\" will exit the application. \
		    Pressing \"Continue\" may leave the application in a state where \
		    the information shown is wrong. It is best to \"Quit\" if \
		    this occurs. \
		    Please contact Server administrators if you require more information."
	    pack .snr.m -padx 2m -pady 2m
	    button .snr.q -text "Quit"     -command "exit"
	    button .snr.c -text "Continue" -command "destroy .snr"
	    button .snr.r -text "Retry" \
		    -command "start_rpc_client $server_name $server_port $server_type"
	    pack .snr.q .snr.c .snr.r -side left -ipadx 2m -ipady 1m -pady 2m \
		    -expand yes
	    tkwait window .snr
	    wm deiconify .
	}
    }
    return $server
}

# The rpc connection has closed :-( Bogus.
#
proc rpc_client_closed {} {

    global port primary_server backup_server server mserver bserver

    if { $server == $mserver } {
	set server_name $primary_server
	set server_type "PRIMARY"
    } else {
	set server_name $backup_server
	set server_type "BACKUP"
    }

    wm withdraw .
    toplevel .sc
    wm title .sc "Database server connection closed"
    wm geometry .sc +200+200
    message .sc.m -font -width 500 -text \
	    "The connection to the $server_type server has been severed. The machine\
	    $server_name may be down. The $server_type server may have been killed.\
	    There may be a network failure."
    pack .sc.m -padx 2m -pady 2m
    button .sc.q -text Quit -command exit
    button .sc.r -text Reconnect -command {
	destroy .sc
	start_rpc_client $server_name $port $server_type
    }
    pack .sc.q .sc.r -side left -ipadx 2m -ipady 1m -pady 2m -expand yes
    tkwait window .sc
    wm deiconify .
}


# Check the state of the server
#

proc check_server {server type} {

    global primary_server backup_server
    global backup_state
    
    if {$server == "NONE"} {return 0}

    set server_type [RPC $server server_get_type]
    if {$server_type != $type} {
	wm iconify .
	catch {destroy .error}
	toplevel .error
	wm geometry .error +200+200
	message .error.msg -width 400 -text\
		"The operation required access to a server. The operation\
		failed because the $type server has been reconfigured, by the \
		admin team, to be $server_type. \
		This client expects the server to be of type $type. You \
		should quit now and restart the client. If you get this warning \
		more than once, you should contact the admin team, as your  \
		client is incorrectly configured." 
	button .error.q -text "Quit"     -command "exit"
	button .error.c -text "Continue" -command "destroy .error"
	button .error.r -text "Retry"    -command "check_server $server $type"
	pack .error.msg -padx 2m -pady 2m
	pack .error.q .error.c .error.r \
		-side left -ipadx 2m -ipady 1m -pady 2m -expand yes
	tkwait window .error
	wm deiconify .
	return 1
    } else {
	return 0
    }
}


# Read server definitions file from client base dir
#

proc read_server_def {} {
    
    global primary_dbse backup_dbse
    global primary_server backup_server
    global primary_base_dir backup_base_dir
    global backup_state
    global port

    set file [serverdef_file]

    if {![file readable $file]} {
	puts "ERROR: file \"$file\" unreadable"
	exit
    }

    set handle [open $file r]

    while {[eof $handle] == 0} {

	set line [gets $handle]
	if {[regexp "^set.*" $line]} {
	    eval $line
	}
    }
    close $handle
}

# This proc is here for development purposes only
#

proc print_server_def  {} {

    set file [appdir_path etc]/servers.def

    if {![file readable $file]} {
	puts "ERROR: file \"$file\" unreadable"
	exit
    }

    set handle [open $file r]
    while {[eof $handle] == 0} {
	set line [gets $handle]
	puts "  $line"
    }
    close $handle
}
