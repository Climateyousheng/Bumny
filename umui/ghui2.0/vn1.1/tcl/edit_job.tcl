# This script starts up a job edit
#+
# TREE: experiment_instance
#-

# get global info from command line
# wishExe       : Name of wish executable for use by spawned routines
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
# read_write    : Flag for determining whether user tried to open job read-write
# description   : Job description

set i -1
foreach item { \
    wishExe remote_shell_command \
    application version base_dir \
    code_location port exp_id \
    job_id read_write description \
} {

set $item [lindex $argv [incr i]]

}

set user $env(LOGNAME)

# First source the GHUI directory - need to source the source procedure first
cd $code_location/tcl
source source.tcl
source_and_setup

# derived global variables
set job_file [unique_jobfile]
set job_title "Job $exp_id.$job_id: \"$description\""

# hide top level window until start up complete
wm withdraw .
update

# style related things
#source /home/hc0300/hadsm/tcl/ghuiOverride.tcl
set_appearances $application

# read job basis file from server
set writable [get_basis_file $exp_id $job_id $job_file $read_write]
set read_write [lindex $writable 0]
# Output message if not writable

if {$read_write==0} {
    job_not_writable [lindex $writable 1]
}

# load variables and values from registers and datebases
# Instances have occurred of corrupted files so use a catch
if [catch {load_variables $job_file} a] {
    info_message "ERROR Failed to load basis file: Please Report: $a\n"
    tkwait window .ghui_error
    exit
} else {
    exec rm $job_file
}

# Set all the variables that might have been changed by the entry system
set_variable_value EXPT_ID $exp_id
set_variable_value JOB_ID $job_id
set_variable_value RUN_ID $exp_id$job_id
set_variable_value JOBDESC $description

# Set up array inactive_partition with list of partition identifying letters
# and inactive status expressions, and array win_prefix which is used by set_winname
# routine for determining the name of window relating to cross-partition
# variables
partition_info inactive_partition win_prefix partition.database

# indicate that save and processing have not yet been done
set processing_done 0
set save_done 1
if [catch {navigation} a] {
    info_message "ERROR: $a\n"
    tkwait window .ghui_error
    exit
}

# For some reason, an update before the deiconify ensures much more
# rapid display on Linux
update idletasks
wm deiconify .

# Run any application specific procedures
if {[info procs appSpecificStartup] == "appSpecificStartup"} {
    if [catch {appSpecificStartup} a] {
	info_message "ERROR Running application specific startup\
		procedure: Please Report: $a\n"
	tkwait window .ghui_error
	exit
    }
}

# Call quit script if user attempts to close window from top left button
wm protocol . WM_DELETE_WINDOW {nav_quit}







