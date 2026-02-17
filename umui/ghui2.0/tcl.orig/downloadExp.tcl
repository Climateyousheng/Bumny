# downloadExp.tcl
#   Procedures for automatically downloading jobs and experiments to 
#   local files

# downloadExperiment
#   Gets name of directory and downloads all jobs in exp_id to it.
# Arguments
#   exp_id: 4-letter identity of experiment
#   user: user identity

proc downloadExperiment {exp_id user} {
    global experiments jobs env downloadExpDir download_cancel download_file

    set jobList [job_id_list $exp_id]
    if {[llength $jobList] == 0} {
	error "Experiment $exp_id does not contain any jobs"
    } else {
	set title "Download Experiment $exp_id"
	set text \
	    "This function takes a copy of the basis files\
	    of all the jobs in experiment $exp_id and stores them in\
	    a locally held directory. Enter the\
	    full pathname for the directory below."
	set toplevel .download_$exp_id

	set downloadDir [getFileName $toplevel $env(HOME) download_$exp_id $title $text]
	if {$downloadDir != 0} {
	    file mkdir $downloadDir
	    foreach job_id $jobList {
		downloadJob $exp_id $job_id $user $downloadDir/basis_$exp_id$job_id
	    }
	    createExpReadme $exp_id $downloadDir
	}
	
    }
}

# downloadJob
#  Reads job basis file from database and then downloads it to a given file
# Arguments
#  exp_id: 4-letter experiment identity of job
#  job_id: 1-letter job identity of job
#  user:   Username
#  file:   Full pathname of file to download to

proc downloadJob {exp_id job_id user file} {
    
    # Get basis file from primary server
    set job_spec [OnPrimaryServer readJob [list $exp_id $job_id $user]]

    # Save to local file
    set f [open $file w]
    puts $f $job_spec
    close $f
}

# createExpReadme
#   Creates a README file to describe the jobs in an experiment
# Arguments
#   exp_id : 4-letter experiment identity
#   dir : Directory in which to create the README file.

proc createExpReadme {exp_id dir} {
    global all_lines

    set f [open $dir/README w]
    puts $f "    Contents of Download directory relating to experiment $exp_id"
    puts $f "    Experiment title: $all_lines($exp_id-description)"
    puts $f "    Archive created on [exec date]"
    puts $f ""

    # Get information list for all jobs
    set jobList [OnPrimaryServer send_job_list [concat $exp_id [blank_filter_list job_filters] ]]
    foreach spec $jobList {
	puts $f "Job [lindex $spec 0]:"
	for {set i 1} {$i < [llength $spec]} {incr i 2} {
	    set type [lindex $spec $i]
	    set value [lindex $spec [expr $i+1]]
	    # Ignore anything that is unset
	    if {$value != "Unset"} {
		set string [format "%12s: %s" $type $value]
		puts $f $string
	    }
	}
    }
    close $f
}

# Dialog box for obtaining a filename

namespace eval fileNameDialog {
    namespace export getFileName
}

# ::fileNameDialog::getFileName
#  Dialog box for selecting a file name on the local system
# Arguments
#  t : Name of toplevel window to create
#  dir : Default directory name
#  file: Default file name
#  title: Title of dialog box
#  text: Text of question
# Externals
#  filewalk : Filewalk dialog box
#  get_env : Routine to translate environment variables

proc ::fileNameDialog::getFileName {t dir file title text} {
    variable dirName

    if {[info commands $t] == $t} {
	wm withdraw $t
	wm deiconify $t
	return 0
    }

    toplevel $t
    wm geometry $t +10+100
    wm title $t $title
    
    message $t.m -width 800 -text $text

    entry $t.e -relief sunken -width 80 -textvariable ::fileNameDialog::dirName($t,variable)
    set command "filewalk $t.e $dir $file"
    set dirName($t,variable) $dir/$file
    button $t.f -text "Filewalk" -command $command

    set yesCommand "variable dirName; set dirName($t,cancel) 0"
    set cancelCommand "variable dirName; set dirName($t,cancel) 1"

    button $t.d -text Download -command [namespace code $yesCommand]
    button $t.c -text Cancel -command [namespace code $cancelCommand]
    bind $t.e <Return> [namespace code $yesCommand]
    focus $t.e
    pack $t.m -padx 2m -pady 2m
    pack $t.e -padx 2m -pady 2m -anchor w
    pack $t.d $t.f $t.c -side left -ipadx 1m -pady 2m -expand yes
    set dirName($t,cancel) -1
    vwait ::fileNameDialog::dirName($t,cancel)
    destroy $t
    if {$dirName($t,cancel) == 1} {
	return 0
    }
    
    # save job to file specified
    set download_file [get_env $dirName($t,variable)]
    unset dirName($t,variable) dirName($t,cancel)
    return $download_file
}

