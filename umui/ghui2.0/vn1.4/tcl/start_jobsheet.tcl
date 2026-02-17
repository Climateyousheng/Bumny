# start up the job sheet process
#
proc start_jobsheet {} {

    global all_lines database_server port env application version wishExe

    set exp_id [get_variable_value EXPT_ID]
    set job_id [get_variable_value JOB_ID]

    set download_file \
	    /tmp/jobsheet.$exp_id.$job_id.$env(LOGNAME).[exec date +%j%H%M%S]

    # Write database to a temporary file 
    write_database $download_file

    set code_location [ghui_version_path]
    set ghui_dir [ghui_path]
    
    # Pass filename to jobsheet_entry 
    exec $wishExe $code_location/tcl/jobsheet_entry.tcl \
	    $application \
	    $version \
	    $ghui_dir \
	    $code_location \
	    $download_file &
}
