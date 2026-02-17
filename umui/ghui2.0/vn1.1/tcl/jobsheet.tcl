proc jobsheet {} {

    global verify_flag
    global js_inactive_partition
    global env exp_id job_id
    partition_info js_inactive_partition dummy js_partition.database
    
    set page_width 79

    if [catch {set path [get_variable_value JOB_OUTPUT]}] {
	error "To use the jobsheet procedure as it stands you need to define a \
		variable JOB_OUTPUT in one of the registers. Set it to a pathname \
		relative to the home directory environment variable \$env(HOME). \
		You may subsequently move this file by including a exec rm command \
		in the jobsheet_title procedure."
	return
    }
    set file $env(HOME)/$path/JS_$exp_id$job_id

    set output_file [open $file w]

    if {[info procs "jobsheet_title"]=="jobsheet_title"} {
	puts $output_file [jobsheet_title $page_width]
	#diff_message [jobsheet_title $page_width]
    } else {
	error "System error: Jobsheet function could not find a title function.\
		You need a procedure called jobsheet_title in the application \
		directory in the /tcl directory - it should return ascii text \
		to be inserted at the beginning of the jobsheet output"
    }

    set win_list [list_of_panels]
    set verify_flag 0
    #print_window $output_file $page_width atmos_Control_OutputData_LBC1
    #return

    # Window to output progress of verification
    toplevel .jsheet
    wm geometry .jsheet +10+20
    wm title .jsheet "Progress of Job Sheet Function"
    message .jsheet.text -text "You may proceed with your job edit" -anchor w -width 1500
    message .jsheet.text2 -text "while the jobsheet is created" -anchor w -width 1500
    message .jsheet.text3 -text "Proportion of windows read:-" -anchor w -width 1500
    message .jsheet.num -text {} -anchor w -width 1500
    set quit 0
    button .jsheet.quit -text "Quit" -command {
	destroy .jsheet
    }
    pack .jsheet.text -anchor w -padx 2m 
    pack .jsheet.text2 -anchor w -padx 2m 
    pack .jsheet.text3 -anchor w -padx 2m -pady 4m
    pack .jsheet.num
    pack .jsheet.quit

    # Initialise number of variables checked
    set number 1
    set nvar [llength $win_list]

    foreach window $win_list {
	# Update progress. If quit pressed and window destroyed then end.
	incr number
	set proportion [expr ($number*100)/$nvar]
	.jsheet.num configure -text "$proportion \%"
	update idletasks
	update
	if {[info commands .jsheet]!=".jsheet"} {break}
	print_window $output_file $page_width $window
    }
    close $output_file
    return
}

