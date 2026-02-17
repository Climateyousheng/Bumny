# This script starts up a job edit
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
# port          : Server port
# exp_id_list   : Experiment id list
# job_id_list   : Job id list 

set i -1
foreach item {application version base_dir code_location port exp_id_list job_id_list} {
    set $item [lindex $argv [incr i]]
}
set user $env(LOGNAME)

# First source the GHUI directory - need to source the source procedure first
cd $code_location/tcl
source source.tcl
source_and_setup

set exp_id1 [lindex $exp_id_list 0]
set job_id1 [lindex $job_id_list 0]
set exp_id2 [lindex $exp_id_list 1]
set job_id2 [lindex $job_id_list 1]

# style related things
set_appearances $application

# hide top level window until start up complete
wm withdraw .
update

# Main routine
if [catch {compare_jobs} a] {
    info_message "ERROR: $a\n"
    tkwait window .ghui_error
}

# Wait until diffm window closed then exit
while {[info commands .diffm]==".diffm"} {
    after 200
    update
}
exit

