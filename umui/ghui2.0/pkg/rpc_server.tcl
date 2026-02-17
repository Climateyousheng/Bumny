package provide GHUIserver 1.0

# Remote Procedure Call server, for the server.
#

# Start the RPC server
#
proc start_rpc_server {port} {
    
    global ghui_server

    # make RPC server
    set ghui_server(main) [socket -server acceptConnection $port]
}

# acceptConnection
#   Accepts connections from clients. Configures the socket and sets
#   up a fileevent to call server_action

proc acceptConnection {sock addr port} {
    global ghui_server
    #server_log "Accept $sock from $addr port $port"
    set ghui_server(addr,$sock) [list $addr $port]
    fconfigure $sock -buffering none
    fileevent $sock readable [list serverAction $sock]
}

# serverAction
#   Called on fileevent on socket. Takes requests from and replies to client. 
# Argument
#   sock : Socket

proc serverAction {sock} {
    global ghui_server

    if {[eof $sock] || [catch {gets $sock numChars}]} {
	# Client has gone away
	close $sock
	#server_log "Close $ghui_server(addr,$sock)"
	unset ghui_server(addr,$sock)
    } else {
	# Expecting an instruction of length $numChars
	if {$numChars != ""} {

	    # Read $numChars characters. This will wait until $numChars
	    # characters received or until client breaks connection
	    set line [read $sock $numChars]

	    if [catch {set command [lindex $line 0]} a] {
		# I think this occurs if $line is not a valid list
         
		puts $sock -3
		puts $sock "Server error -3 $a"
	    } else {

		if [testCommand $command] {
		    # Valid command, so run it
		    if {[catch {set result [runCommand $line]} a]} {
			server_log "COMMAND error $a"
			# Error in command
			puts $sock -1
			puts $sock $a
		    } else {
			# Return result
			#server_log "COMMAND success return [string length $result] bytes"
			# Send back length of the result, then the result itself
			puts $sock [string length $result]
			puts -nonewline $sock $result
		    }
		} else {
		    server_log "Invalid command: $command"
		    puts $sock -2
		    puts $sock "Invalid command: $command"
		}
	    }
	}
    }
}

# testCommand
# Check client commands are valid

proc testCommand {command} {

    # check first argument for a valid command and return normally if present
    case $command in {
	catch {}
	if {}
	log_client_config {}
	log_database_copy {}
	server_set_type {}
	server_get_type {}
	server_set_status {}
	server_get_status {}
	ssc {}
	send_experiment_list {}
	send_job_list {}
	create_new_experiment {}
	create_new_job {}
	delete_experiment {}
	delete_job {}
	copy_experiment {}
	copy_job {}
	change_experiment_description {}
	changeExperimentOwner {}
	change_job_description {}
	change_job_id {}
        change_experiment_privacy {}
	change_access_list {}
	close_connection {}
	load_job {}
	readJob {}
	save_job {}
	close_job {}
	updates_available {}
	update_load_job {}
	update_save_job {}
	halt_server {}
	force_close_job {}
	reload_all {}
	clear_log {}
	list_open_jobs {}
	tail_log {}
	make_experiment_operational {}
    send_client_msg {}
    sc_get_job_desc {}
    sc_check_job_status {}
    sc_lock_job {}
    sc_unlock_job {}
    sc_import_job {}
	default {return 0}
    }
    return 1
}

# runCommand
#   Evaluates the command received from the client.

proc runCommand {line} {
    #server_log "eval $line"
    set a [eval $line]
    #server_log $a
    return $a
}

proc ssc {} {
    global base_dir

    source_directory $base_dir/tcl
    server_log "Sourced"
    return "Sourced"
}

