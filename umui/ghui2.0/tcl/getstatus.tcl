set i -1
foreach item {base_dir application} {
    set $item [lindex $argv [incr i]]
}

# source all tcl files containing procedures
cd $base_dir/tcl
source source.tcl
source_and_setup

read_server_def
# Set mserver and bserver to socket numbers or NONE
setup_server_info

set exit_code 0

if { $backup_server == "NONE" } {
   if { $mserver == "NONE" } {
      puts "The UMUI server on $primary_server is DOWN"
      set exit_code 3
   } else {
      puts "The UMUI server on $primary_server is RUNNING"
      puts "The status is [ RPC $mserver server_get_status ]"
   }
} else {
   if { $mserver == "NONE" } {
      puts "The primary UMUI server on $primary_server is DOWN"
   } else {
      puts "The primary UMUI server on $primary_server is RUNNING"
      puts "The status is [ RPC $mserver server_get_status ]"
   }
   if { $bserver == "NONE" } {
      puts "The backup UMUI server on $backup_server is DOWN"
   } else {
      puts "The backup UMUI server on $backup_server is RUNNING"
      puts "The status is [ RPC $bserver server_get_status ]"
   }
   if { $mserver == "NONE" && $bserver == "NONE" } {set exit_code 3}
}

exit $exit_code
