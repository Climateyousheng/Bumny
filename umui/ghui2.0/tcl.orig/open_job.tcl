# start up the job edit process
#
proc start_job_edit {exp_id job_id read_write} {

    global all_lines primary_server backup_server port wishExe
    global directories application remote_shell_command

    set version $all_lines($exp_id$job_id-version)

    set ghui_dir [ghui_path]
    set code_location [ghui_version_base $version]
    set app_dir [application_path]


    if {[glob -nocomplain $app_dir] == ""} {
	error "There is no job edit program for version $version."
    }
	
    exec $wishExe $code_location/tcl/edit_job.tcl \
	    $wishExe \
            $remote_shell_command \
	    $application \
	    $version \
	    $ghui_dir \
	    $code_location \
	    $port \
	    $exp_id \
	    $job_id \
	    $read_write \
	    $all_lines($exp_id$job_id-description) &
}
