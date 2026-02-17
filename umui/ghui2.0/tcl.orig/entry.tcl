# The top level tcl script for the entry system.
#

# wish executable name software location, name of machine running
# server and inital letter for new experiments from argument list

set i -1
foreach item {wishExe remote_shell_command base_dir exp_initial application} {
    set $item [lindex $argv [incr i]]
}
if {$argc != [incr i]} {
    error "entry.tcl: Wrong number of arguments $argc"
}

# set user name
set user $env(LOGNAME)

# set exp_initial to blank if it is not set correctly. User will
# be asked for a correct selection if an experiment is to be created
if {[regexp {^[a-z]$} $exp_initial] == 0} {
    set exp_initial ""
}

source $base_dir/tcl/source.tcl
source_and_setup

# Set default filter value
if { [info exists titles(filter_default,owner)] } {
    set titles(filter_default,owner) $user
}

# read shared globals, including port number
set_shared_globals

# read appearance related globals
entry_appearance

# draw interface
read_server_def
draw_entry_interface

initialise_filters
update idletasks
menu_reload
