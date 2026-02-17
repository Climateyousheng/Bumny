package provide GHUIserver 1.0

# run_on_servers.tcl
#
#   Contain the procedures that developer would use when adding
#   functionality that uses the database servers.  
#
#   This file is partnered with rpc_client.tcl but procedures in here
#   are a bit more generic. They make calls to GHUI-specific routines
#   in rpc_client.tcl such as start_rpc_client which contain GHUI/Tk
#   error dialogs. The rpc_client.tcl routines could perhaps be
#   written in a more generic way.
#
#   S.D.Mullerworth


###########################################################################
#                       Running Server Commands                           #
###########################################################################

# These routines open up sockets to primary server and backup server,
# if used, passing commands down them to be executed on the
# server/s. Result from primary server is then returned and sockets
# are closed
# Should be called with the following format:
#
#   OnBothServers command1 [list arg11 arg12 ...arg1n] command2 [list\
#                      arg21 arg22 ...arg2n] ... commandn \
#                      [list argn1 argn2 ...argnn]
#
# If a problem occurs when trying to connect to server, routine returns;
# errors are handled by other routines in rpc_client.
# For commands which return info without changing database, use procedure
#   OnPrimaryServer
# in the same way as OnBothServers. This executes the command on the
# primary server only, thus saving time.



# OnBothServers
#   Entry procedure. NB mserver and bserver are local to this routine
#   through use of upvar. They are setup by servers_ok.
# Arguments
#   args : A list comprising a command and optional arguments
# Method
#   After testing that the servers are working, command and arguments
#   are sent to be evaluated by server. If no error, result is returned
#   Invalid commands need to be picked up by the server.

proc OnBothServers {args} {

    # Open sockets - set 
    if {[servers_ok 1]==-1} {return}
    
    for {set i 0} {$i<[llength $args]} {incr i} {
	set command [lindex $args $i]
	incr i
	set vals [lindex $args $i]

	set result [RunOnServer 1 $command $vals]
    }
    close_clients 1
    return $result
}


# proc OnPrimaryServer
# Entry procedure for when only information is required: THIS SHOULD NOT
# BE USED FOR ANY COMMANDS WHICH ALTER THE DATABASE

proc OnPrimaryServer {args} {

    # Open sockets
    if {[servers_ok 0]==-1} {return}
    
    for {set i 0} {$i<[llength $args]} {incr i} {
	set command [lindex $args $i]
	incr i
	set vals [lindex $args $i]

	set result [RunOnServer 0 $command $vals]
    }
    close_clients 0
    return $result
}

# servers_ok
#   Checks servers and opens sockets - returns -1 for failure

proc servers_ok {backup} {
    global primary_server backup_server backup_state
    global port
    upvar mserver mserver
    upvar bserver bserver

    read_server_def
    set mserver [start_rpc_client $primary_server $port PRIMARY]
    if {($mserver == "PAUSED") || ($mserver == "EMPTY") || ($mserver == "NONE")} {return -1}
    if {[check_server $mserver PRIMARY]!=0} {return -1}

    if {$backup==0} {
	# Not running this command on backup server
	return 0
    }

    if {($backup_server != "NONE") && ($backup_state != "IGNORE") } {
	# open socket to backup server and check that it is ok
	set bserver [start_rpc_client $backup_server $port BACKUP]
	if {($bserver == "PAUSED") || ($bserver == "EMPTY")} {
	    return -1
	} elseif {$bserver != "NONE"} {
	    if {[check_server $bserver BACKUP]!=0} {return -1} 
	}
    }
    return 0
}

# close_clients
#   Closes connection to servers

proc close_clients {backup} {

    global primary_server backup_server backup_state

    upvar mserver mserver
    upvar bserver bserver

    # Close connection to the Primary server
    CloseRPC $mserver

    if {$backup==0} {
	# Not running this command on backup server
	return 0
    }

    if {($backup_server != "NONE") && \
	    ($backup_state != "IGNORE") } {
	if {($bserver != "NONE")} {
	    # Close connection to the backup server if configured
	    CloseRPC $bserver
	}
    }
}

# proc RunOnServer
#    Calls server routine to run command with arguments $vals


proc RunOnServer {backup command vals} {
    global primary_server backup_server backup_state
    global errorInfo

    upvar mserver mserver
    upvar bserver bserver

    # Run command on primary server and save the result
    set result [eval "RPC $mserver $command $vals"]

    if {$backup==0} {
	# Not running this command on backup server
	return $result
    }
    if {($backup_server != "NONE") && ($backup_state != "IGNORE") } {
	if {$bserver != "NONE"} {
	    # Also run the command on the backup server if configured
	    if [catch {eval "RPC $bserver $command $vals"} err] {

		# This catches the hopefully rare event when the backup server 
		# fails between the time that the servers are checked
		# and this point.

		error "Operation has worked on Primary server, but not \
			on Backup server. It is important that this \
			error is reported along with the run id of \
			the job, as it implies that the \
			databases are now out of synchronisation\n \
			$err\n$errorInfo"
	    }
	}
    }
    return $result
}

# MakeRPCClient
#    Opens socket to server. If no connection is made there will
#    be an error which should be caught by calling routine.
# Arguments
#    host: Name of server host
#    port: Port number of server
# Result
#    Returns a socket number

proc MakeRPCClient {host port} {
    set s [socket $host $port]
    fconfigure $s -buffering none
    #puts "Socket $s Connect to $host port $port"
    return $s
}

# RPC
#    Send a command to the server. Wait for result and return it.
# Arguments
#    sock : Socket stream
#    command : Command and arguments
# Result
#    The answer obtained from the server

proc RPC {sock args} {
    
    # First send the length of the string so that the server knows to wait
    # until all characters received.
    puts $sock [string length $args]
    # Then send the string
    puts -nonewline $sock $args

    # Now we get a reply
    set num_bytes [gets $sock]
    if {$num_bytes == ""} {
	# Probably shutting down server so no result
	set answer ""
    } elseif {$num_bytes < 0} {
	# Negative reply implies command was unsuccessful
	set error [gets $sock]
	#error "Server error while executing $args"
	error "Server error $error"
    } else {
	# Otherwise read the appropriate number of characters
	set answer [read $sock $num_bytes]
    }
    return $answer
}
   
# RPCreload
#    Send a command to the server to reread database. Wait for result
#    and return it. While waiting, ensure display is updated - 
# Arguments
#    sock : Socket stream
#    command : Command and arguments
# Method
#    1. Procedure is a special case of the RPC call that allows for a
#    callback. Attempting to do the same for other functions ran into
#    race-hazard difficulties with double clicking on buttons, but it
#    should be possible - I did not spend much time on it as
#    functionality was non-essential. SDM
#    2. This should perhaps be done in two procedures, in which the vwait
#    is not required and the bit after the vwait goes into the callback
#    procedure. This way though, the form of the RPC command is mirrored,
#    hopefully resulting in easier maintenance.
# Result
#    The answer obtained from the server

proc RPCreload {sock args} {
    
    global reload_status

    # First send the length of the string so that the server knows to wait
    # until all characters received.
    puts $sock [string length $args]
    # Then send the string
    puts -nonewline $sock $args

    # Set up a callback which will alter the reload_status($sock) variable
    fileevent $sock readable [list reload_all_callback $sock]
    # Now wait for the variable to be changed by the callback procedure -
    # allowing other events to be processed all the while
    vwait reload_status($sock)

    # Callback should be removed by the callback routine itself. This is because,
    # if the above vwait command is immediately followed by an
    # "update" (related to the reloading of the other database) there is a continuous
    # string of fileevents on this sock and the callback routine ends
    # up being called ad infinitum. ie if both databases are reloaded at the same
    # time, it is possible that the admin interface will hang

    # fileevent $sock readable {}

    # Now we get the reply
    if {[set num_bytes [gets $sock]] < 0} {
	# Negative reply implies command was unsuccessful
	set error [gets $sock]
	#error "Server error while executing $args"
	error "Server error $error"
    } else {
	# Otherwise read the appropriate number of characters
	set answer [read $sock $num_bytes]
    }
    return $answer
}

# CloseRPC
#    Close connection to server
# Arguments
#    sock : Socket stream

proc CloseRPC {sock} {
    close $sock
}
