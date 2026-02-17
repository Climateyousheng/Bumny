# This script starts up a job sheet output
#+
# TREE: experiment_instance
#-

# get global info from command line
# application   : Name of application
# version       : Version of application
# base_dir      : Directory of GHUI installation. Required because it contains
#                 file apps/$application.def - the setup info for the application
# code_location : Contains directories holding tcl and C code: Needed because it 
#                 contains code for reading application definition. If this code
#                 was separate then it would no longer be needed
# download_file : File containing basis database downloaded by calling function
set i -1
foreach item {application version base_dir code_location download_file} {
    set $item [lindex $argv [incr i]]
}

cd $code_location/tcl
source source.tcl
source_and_setup

# style related things
set_appearances $application

# hide top level window
wm withdraw .
update

# Read in registers and databases
load_variables $download_file


# Read in partition database
partition_info inactive_partition win_prefix partition.database


# Set global variables for determining processed directory
set exp_id [get_variable_value EXPT_ID]
set job_id [get_variable_value JOB_ID]

# Run jobsheet procedure
if [catch {jobsheet} a] {
    info_message "ERROR: $a\n"
    tkwait window .ghui_error
}

set file $env(HOME)/[get_variable_value JOB_OUTPUT]/JOBSHEET_LOCK_$exp_id$job_id
if [file exists $file] {
    # Remove lock file
    exec rm $file
}
# Remove temporary file and exit
exec rm $download_file
exit








