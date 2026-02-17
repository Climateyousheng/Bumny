# Tidied up version of compare_jobs
# In process of reformatting output to be ordered as specified in nav.spec
# and to treat tables more clearly.
# Steve Mullerworth
proc compare_jobs {} {


    global var_list diffs 
    global run_id1 job_id1 exp_id1
    global run_id2 job_id2 exp_id2
    global env
    global inactive_partition win_prefix

    set var_list() {}

    # Set up array inactive_partition with list of partition identifying letters
    # and inactive status, and array win_prefix which is used by set_winname
    # routine for determining the name of window relating to cross-partition
    # variables
    partition_info inactive_partition win_prefix partition.database

    # list_type will be set to 1 for short and 0 for long list
    # Short lists ignore cases when variable is active in one job only
    set help_file [ghui_version_dir help]/diff_help.help
    set list_type \
	    [dialog_with_help .diff "Type of Output" "Do you want a long list or a short list" $help_file Long Short]

    # Load the two jobs into separate trees in memory
    loadup_job $exp_id1 $job_id1
    set jobdesc1 [get_variable_value JOBDESC]
    swap_roots
    # Job 2 now in memory
    loadup_job $exp_id2 $job_id2
    set jobdesc2 [get_variable_value JOBDESC]
    
    # Get a list of variables whose values differ between jobs
    set diff_list [get_job_diff]

    set run_id1 $exp_id1$job_id1
    set run_id2 $exp_id2$job_id2

    # Initialise the difference message to be output at the end
    diff_message "Job $run_id1 Title $jobdesc1"
    diff_message "Job $run_id2 Title $jobdesc2"
    if {$diff_list==""} {
	diff_message "Identical jobs"
	textToWindow .diffm $diffs(output) "Identical"
	update
	return
    }
    
    # Set up lists for each job, of variables that are active and different
    # And sets up a status window - to be destroyed once comparison complete
    set top [diff_get_sublists $diff_list]

    # var_list($run_id) now contains a list of active variable
    # var_list($run_id,$variable) is variable value for each active variable
    # If variable is 
    #   scalar:    values will be different
    #   1D array:  at least one value may be different
    #   2D array:  may be identical

    # Create a list of comparisons in global array diffs
    create_comparisons $list_type

    destroy $top

    output_differences $jobdesc1 $jobdesc2
}


# create_comparisons
#    Creates a set of difference messages from lists of variables
# Argument
#    list_type:  1 for long or 0 for short
# Globals
#    var_list:        An array containing two variable lists; 1 for each job
#    run_id1,run_id2: Run ids of the two jobs
# Method
#    Produces comparison message for each of the differing variables
#    only if both variables are active, or if one is active and a
#    "long" list is requested.

proc create_comparisons {list_type} {
    global var_list
    global run_id1 run_id2

    foreach variable $var_list($run_id1) {
	update
	# Loop through active variables in first job

	# Ignore JOB_ID and RUN_ID
	if {($variable=="JOB_ID") || ($variable=="RUN_ID") || ($variable=="EXPT_ID") || ($variable=="JOBDESC")} {continue}
	set var_info [get_variable_info $variable]
	set max_length [lindex $var_info 2]
	set val1 $var_list($run_id1,$variable)

	# Get value of variable in second job
	if [info exists var_list($run_id2,$variable)] {
	    # If it exists it is active, use active value which for arrays will be active length
	    set val2 $var_list($run_id2,$variable)
	    set active2 1
	} else {
	    # Variable is inactive in second job
	    if {$list_type} {
		# Short list - not interested when variable inactive in one of the jobs
		continue
	    }
	    set active2 0
	    set val2 {}
	}
	# Produce message which will be output at end
	comparison_message $variable $val1 $val2 1 $active2 
    }

    # Now loop through variables in second job, but if this is a "short" list
    # then only variables active in both jobs are output and therefore, all
    # variables will already have been dealt with in the above loop
    if {([info exists var_list($run_id2)]) && ($list_type==0)} {
	# A list must exist and a long list_type requested
	foreach variable $var_list($run_id2) {
	    update
	    # Loop through active variables in second job
	    if {[info exists var_list($run_id1,$variable)]==0} {
		# Only consider variables inactive in job1

		set val2 $var_list($run_id2,$variable)

		# Produce message which will be output at end
		comparison_message $variable {} $val2 0 $active2 
	    }
	}
    }
}


# comparison_message
#     Create a message describing comparison between val1 and val2.
#     Computes "location" of the variable and stores message in an
#     array indexed by location.
# Arguments
#     variable:        Variable name, possibly with index
#     val1, val2:      Values in the respective jobs
#     active1 active2: Respective active status
# Globals
#     diffs: An array. $diffs(messages) contains a list of locations.
#            For each location L, there is a message $diffs(L).
#     fv_variable_name : Globals required by set_winname function
#     fv_index         : 

proc comparison_message {variable val1 val2 active1 active2} {
    # Set diffs($winname) to this message, or append if already created

    global diffs
    global fv_variable_name fv_index
    global run_id1 run_id2 job_id1 job_id2

    #puts "Message for $variable $val1 $val2 Active ? $active1 $active2"
    if {( $val1==$val2 ) && ( $active1==$active2 )} {
	# Values and active status identical so no message...
	return
    }
    if {( $active1==0 ) && ( $active2==0 )} {
	# Inactive in both jobs so no message...
	return
    }

    # Set the global variables required for use in proc set_winname
    set fv_variable_name $variable
    set fv_index 0

    set var_index -1
    if [regexp {\(} $variable] {
	set var_index [lindex [split $variable "()"] 1]
	regsub {\*,} $var_index {} var_index
	set fv_index $var_index
    } 

    # Get a window name and a descriptive location
    set win_info [set_winname]
    set location [lindex $win_info 0]
    set window [lindex $win_info 1]

    # Group all messages for one location together:
    if {[info exists diffs($location)]==0} {
	# First difference in this location so give it a title and a path
	lappend diffs(messages) $location
	#puts "Diff at location $location"
	set diffs($location) "Difference in $location\n"
	set path [navigation_path $window]
	if {$path==0} {
	    set path "Path to $window not in navigation tree\n"
	    set window "NONE"
	}
	append diffs($location) $path
	#puts "Initialise difference at $location"
    }
    
    # Make a list of locations relating to the same window name
    # This is because some windows are reused with different indices
    # The version for each index should have same $window but
    # different $location
    if [info exists diffs($window)] {
	if {[lsearch $diffs($window) $location]==-1} {
	    lappend diffs($window) $location
	}
    } else {
	lappend diffs($window) $location
    }

    # Specification file for panel
    set file [window_file $window]
    if {[file exists $file]} {
	# Read window definition into win_text
	set win_text [get_window_text $window]
	
	# Set line_no to line of $win_text which contains $variable
	set line_no [get_window_line $win_text $variable]
	
	if {$line_no!=""} {
	    # Line has been found so build up message
	    
	    # General help message - Table and column names etc 
	    # and type of entry
	    set help_text [general_help_text $win_text $line_no]
	    if {$help_text=="Table"} {
		set table_diff [table_difference $window $win_text $line_no $variable]
		if {$table_diff!=""} {
		    set help_text [table_help_text $win_text $line_no]
		    set help_text "$help_text $table_diff"
		} else {
		    set help_text ""
		}
		set help1 -1
		set help2 -1
	    } else {
		# Specific help, dependent on $variable. eg for radio buttons
		# will return appropriate line of text
		set help1 [value_help_text $win_text $line_no $val1]
		set help2 [value_help_text $win_text $line_no $val2]

	    }
	    if { $help_text!=0 } {
		append diffs($location) "$help_text\n"
	    } else {
		# This should not be called
		append diffs($location) "Error [lindex $win_text $line_no]\n"
	    }
	    if { ($help1==0) || ($help2==0) } {
		append diffs($location) "Error in value_help [lindex $win_text $line_no]\n"
	    }
	} else {
	    append diffs($location) "Could not find $variable in window $window\n"
	    set help1 $val1
	    set help2 $val2

	}
    }  else {
	# Window spec file does not exist
	append diffs($location) "Difference in variable $variable\n"
	set help1 $val1
	set help2 $val2
    }

    # For each job, output value if active or "Entry is inactive" if inactive
    if {$help1!=-1} {
	if {$active1==1} {
	    append diffs($location) " Job $run_id1: $help1\n"
	} else {
	    append diffs($location) " Job $run_id1: Entry is inactive\n"
	}
	
	if {$active2==1} {
	    append diffs($location) " Job $run_id2: $help2\n"
	} else {
	    append diffs($location) " Job $run_id2: Entry is inactive\n"
	}
    }
}

proc output_differences {jobdesc1 jobdesc2} {

    global diffs
    global run_id1 run_id2

    if {[info exists diffs(messages)]==0} {
	diff_message "No differences"
	textToWindow .diffm $diffs(output) "No differences"
	update
    } else {
	# Output difference messages which will be grouped in locations
	difference_messages diff_message

	# difference is set by means of a two level upvar from diff_message
	# procedure
	textToWindow .diffm $diffs(output) "Differences"
	update
	set path [set_output_dir]
	set file $path/diff.$run_id1.$run_id2
	if [multioption_dialog .output "Output File" "Do you want to output list to file \n$file" No Yes] {
	    # Optional output to file

	    # make standard output sub-directory if none exists
	    if {! [file exists $path]} {
		exec mkdir $path
	    }
	    set fn [open $file w]
	    puts $fn "Job $run_id1 Title $jobdesc1"
	    puts $fn "Job $run_id2 Title $jobdesc2"
	    difference_messages "puts" "$fn"
	    close $fn
	}	
    }
}

proc difference_messages {args} {
    global diffs
    #puts "difference_messages $args called"
    set pan_list [navigation_list]
    foreach window $pan_list {
	if [info exists diffs($window)] {
	    #puts "Locations for window $window exist"
	    foreach location $diffs($window) {
		eval "$args [list $diffs($location)]"
	    }
	}
    }
    # If window was not found in navigation tree, then a basic message 
    # would have been sent to a NONE location
    if [info exists diffs(NONE)] {
	foreach location $diffs(NONE) {
	    eval "$args [list $diffs($location)]"
	}
    }
}

proc diff_message {message} {
    global diffs

    # Output messages to window.
    append diffs(output) "$message\n"
}

proc loadup_job {exp_id job_id} {
    # Load job into database then load registers and databases into memory

    # Load and read in job database
    set job_file [unique_jobfile]
    get_basis_file $exp_id $job_id $job_file 0

    # Read in registers and databases
    load_variables $job_file
    exec rm $job_file
}

proc diff_get_sublists {diff_list} {
    
    global run_id1 run_id2

    toplevel .verify
    wm minsize .verify 300 100
    wm geometry .verify +10+20
    wm title .verify "Progress of active list generation"
    message .verify.job -text "" -anchor n -width 1500
    message .verify.text -text "Number of variables checked:-" -anchor n -width 1500
    message .verify.num -text {} -anchor n -width 1500
    frame .verify.q -bd 2 -relief groove
    button .verify.q.quit -text "Quit" -command {
	destroy .
	exit
    }
    pack .verify.job -anchor n -padx 2m 
    pack .verify.text -anchor n -padx 2m -pady 4m
    pack .verify.num
    pack .verify.q -fill x 
    pack .verify.q.quit -pady 2m
    
    # Get two sublists of those variables that are active in their own job
    # but whose values differ from the same variable in the other job
    # This also produces lists with the appropriate indices for lists
    .verify.job configure -text "Checking job $run_id2"
    create_active_list $run_id2 .verify.num $diff_list
    swap_roots
    # Job 1 now in memory
    .verify.job configure -text "Checking job $run_id1"
    create_active_list $run_id1 .verify.num $diff_list
    .verify.job configure -text "Comparing jobs"
    .verify.text configure -text "Please Wait"
    .verify.num configure -text {}
    update
    return .verify
}

