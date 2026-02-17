#==============================================================================
# RCS Header:
#   File         [$Source: /home/hc0300/umui/srce_code/GHUI_archive/ghui2.0/tcl/haltServer.tcl,v $]
#   Revision     [$Revision: 1.2 $]     Named [$Name: head#main $]
#   Last checkin [$Date: 2003/01/30 11:22:59 $]
#   Author       [$Author: hadsm $]
#==============================================================================

set i -1
foreach item {base_dir application} {
    set $item [lindex $argv [incr i]]
}

# source all tcl files containing procedures
cd $base_dir/tcl
source source.tcl
source_and_setup

read_server_def
set_shared_globals
# Set mserver and bserver to socket numbers or NONE
setup_server_info

# Send request to primary server to shut down itself
RPC $mserver halt_server

