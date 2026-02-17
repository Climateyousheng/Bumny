# The top level tcl script for the server admin program.
#

# software location and name of machine running server from argument list
set i -1
foreach item {base_dir remote_shell_command tmpdir application} {
    set $item [lindex $argv [incr i]]
}

# source all tcl files containing procedures
cd $base_dir/tcl
source source.tcl
source_and_setup

draw_admin_interface


