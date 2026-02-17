##############################################################################
# proc source_and_setup                                                      #
# This file should be sourced and run by all entry procedures                #
# It sources application dependent and GHUI tcl files and sets up global     #
# titles and directories information about the application                   #
# Names of new entry procedures should also be added to switch list to       #
# prevent them being recursively sourced                                     #
##############################################################################

proc source_and_setup {} {
    global base_dir application auto_path

    lappend auto_path $base_dir/pkg

    package require GHUIserver 1.0

    source_directory $base_dir/tcl
    namespace import fileNameDialog::*
    namespace import packFiles::*
    read_application_defs $application
    # Current directory should be owned by owner in case
    # a core dump occurs
    cd
}
proc source_directory {dir} {
    global code_location
    cd $dir
    foreach tcl_file [glob *.tcl *.itcl] {
	# do not source any top level scripts.
	switch $tcl_file {
	    server.tcl {}
	    startServer.tcl {}
	    haltServer.tcl {}
	    entry.tcl {}
	    admin.tcl {}
	    default {
		if [catch {source $tcl_file} error] {
		    # Error occurred so output to error window
		    puts "Error $error while sourcing $tcl_file"
		}
	    }
	}
    }
}


