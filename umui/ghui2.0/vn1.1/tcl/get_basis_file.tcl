###########################################################################
# proc get_basis_file                                                     #
# Get the basis file from the server and store in $job_file               #
# read_write is 1 or 0                                                    #
###########################################################################
 
proc get_basis_file {exp_id job_id job_file read_write} {

    global primary_server backup_server
    global env

    # window to say what's happening
    toplevel .connect
    wm geometry .connect +100+100
    wm title .connect "GHUI job edit"
    message .connect.msg -width 600
    pack .connect.msg -padx 2m -pady 2m
    update

    # Call to set server names for text output
    read_server_def

    if {$read_write} {
	# Signal to both servers that the job will be loaded read-write
	.connect.msg configure -text \
		"Connecting to backup ($backup_server) and primary ($primary_server) server..."
	update
	set load_result [OnBothServers load_job [list $exp_id $job_id $env(LOGNAME) \
			    [expr ! $read_write]]]
    } else {
	# Readonly - only need to access primary server
	.connect.msg configure -text \
		"Connecting to primary ($primary_server) server..."
	update
	set load_result [OnPrimaryServer load_job [list $exp_id $job_id $env(LOGNAME) \
			    [expr ! $read_write]]]
    }

    # Get the database and save it to temporary file
    set basis [lindex $load_result 0]
    set fp [open $job_file w]
    puts -nonewline $fp $basis
    close $fp

    destroy .connect

    # Return read_write flag and info text
    return [lrange $load_result 1 2]
}

#############################################################################
# proc job_not_writable                                                     #
# Called with reason why job not writable - outputs info box.               #
#############################################################################

proc job_not_writable {reason} {
    
    # put up dialog for read-only jobs
    toplevel .nowrite
    wm geometry .nowrite +10+200
    wm title .nowrite "Read Only"
    message .nowrite.msg -width 600 -text \
	    "This job has been opened read only for the following\
	    reason:\n$reason\nYou will not be able to save any changes you make."
    button .nowrite.ok -text "Okay" -command {destroy_window .nowrite}
    bind_ok .no_write .nowrite.ok
    pack .nowrite.msg -padx 2m -pady 2m
    pack .nowrite.ok -pady 2m -ipadx 1m
}

#########################################################################
# proc load_variables                                                   #
# Called by all functions (eg edit_job) to load variables and databases #
# job_file is name of a local file containing a job basis database      #
#########################################################################

proc load_variables {job_file} {

    # Read in registers and databases
    set variables [directory_path variables]
    read_variable_register $variables/parameter.register
    read_basis_database $variables/parameter.database
    read_variable_register $variables/system.register
    read_basis_database $variables/system.database
    read_variable_register $variables/var.register
    read_basis_database $job_file

    # Read and set/reset linked variables
    read_linked_variables
}
    
