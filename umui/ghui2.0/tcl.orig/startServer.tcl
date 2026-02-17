#==============================================================================
# RCS Header:
#   File         [$Source: /home/hc0300/umui/srce_code/GHUI_archive/ghui2.0/tcl/startServer.tcl,v $]
#   Revision     [$Revision: 1.2 $]     Named [$Name: head#main $]
#   Last checkin [$Date: 2003/01/30 11:25:08 $]
#   Author       [$Author: hadsm $]
#==============================================================================

# This is the server for GHUI experiments and jobs. It works both as a
# server for the entry and job edit systems and as a peer with other
# servers in order to distribute the database

# This script differs from server.tcl in that it also reads the
# database and unpauses the server. It is designed to be used in an
# automatic server startup process.

# get base location of GHUI software and database from argument list
set i -1
foreach item {base_dir server_type database_dir application} {
    set $item [lindex $argv [incr i]]
}
# source all tcl files containing procedures
source $base_dir/tcl/source.tcl
source_and_setup

# set globals
set serverProgram 1 ;# Tells bgerror not to send error to tk window
set expts {}

# Test whether gzip packing is possible
pfTestPacking

# set information shared by server and clients
read_server_def
set_shared_globals

# read field information
read_field_info

# set up RPC server
start_rpc_server $port

set host [exec hostname]
server_log "##### Server started on $host #####"

# set the server type
server_log "Server current type  is: \"$server_type\""

# pause the server
set server_status "EMPTY"
server_log "Server current state is: \"EMPTY\""

# Load the job and experiment metadata (the info in the .exp and .job
# files) into memory.
reload_all {}

# Set server as active so it can be used
server_set_status ACTIVE

vwait forever
