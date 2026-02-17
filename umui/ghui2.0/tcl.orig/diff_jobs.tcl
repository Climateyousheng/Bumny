# For calling entry procedure to compare two jobs

proc start_job_diff {exp_id_list job_id_list} {

    global base_dir all_lines port application wishExe
    set exp_id1 [lindex $exp_id_list 0]
    set job_id1 [lindex $job_id_list 0]
    set exp_id2 [lindex $exp_id_list 1]
    set job_id2 [lindex $job_id_list 1]

    set version $all_lines($exp_id1$job_id1-version)
    set version2 $all_lines($exp_id2$job_id2-version)

    if {$version != $version2} {
	error "Comparison between jobs of different versions is not possible"
    }

    set ghui_dir [ghui_path]
    set code_location [ghui_version_base $version]

    exec $wishExe $code_location/tcl/diff_jobs.tcl \
	    $application \
	    $version \
	    $ghui_dir \
	    $code_location \
	    $port \
	    $exp_id_list \
	    $job_id_list &
}

