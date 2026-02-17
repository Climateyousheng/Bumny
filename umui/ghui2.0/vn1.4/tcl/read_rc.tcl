# get global info from command line
# application   : Name of application
# version       : Version of application
# base_dir      : Directory of GHUI installation. Required because it contains
#                 file apps/$application.def - the setup info for the application
# code_location : Contains directories holding tcl and C code: Needed because it 
#                 contains code for reading application definition. If this code
#                 was separate then it would no longer be needed
# port          : Server port
# exp_id        : Experiment id
# job_id        : Job id
# description   : Job description

set i -1
foreach item {application version base_dir code_location port exp_id job_id description} {
    set $item [lindex $argv [incr i]]
}
set user $env(LOGNAME)

# source all tcl files containing procedures
cd $code_location/tcl
source source.tcl
source_and_setup

# derived global variables
set job_file [unique_jobfile]
set job_title "Job $exp_id.$job_id: \"$description\""

# style related things
set_appearances $application

# hide top level window until start up complete
wm withdraw .
update
wm title . "Personal Details"
frame .info
label .info.text1 -text "Setting personal details for job $exp_id$job_id"
pack .info
pack .info.text1 -padx 2m -pady 4m -anchor w
wm deiconify .


# read job basis file from server
set writable [get_basis_file $exp_id $job_id $job_file 1]
set read_write [lindex $writable 0]

if {$read_write==0} {
    info_message "ERROR: Attempted to set user preferences for an opened job: $job_title \
	    Perhaps job was opened by you before preferences were set"
    tkwait window .ghui_error
    # Remove temporary file and exit
    exec rm $job_file
} else {

    # load variables and values from registers and datebases
    load_variables $job_file

    # Set all the variables that have been setup in the entry system
    set_variable_value EXPT_ID $exp_id
    set_variable_value JOB_ID $job_id
    set_variable_value RUN_ID $exp_id$job_id
    set_variable_value JOBDESC $description
    
    if {[set a [personal_setup $application $version]]!="ok"} {
	label .info.text2 -text "ERROR: $a" 
	label .info.text3 -text "No changes have been made to job"
	do_quit
	pack .info.text2 -padx 2m -pady 2m -anchor w
	pack .info.text3 -padx 2m -pady 2m -anchor w
	# Remove temporary file and exit
	exec rm $job_file
    } else {
	do_save
	do_quit
	label .info.text2 -text "Done"
	pack .info.text2 -padx 2m -pady 2m -anchor n
    }
    button .info.button -text "OK" -command "destroy ."
    pack .info.button -pady 2m -ipadx 2m -ipady 1m

}
