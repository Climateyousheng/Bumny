##############################################################################
# proc source_and_setup                                                      #
# This file should be sourced and run by all entry procedures                #
# It sources application dependent and GHUI tcl files and sets up global     #
# titles and directories information about the application                   #
# Names of new entry procedures should also be added to switch list to       #
# prevent them being recursively sourced                                     #
##############################################################################

proc source_and_setup {} {
    global application auto_path
	global tcl_platform

    source_directory .
    read_application_defs $application

    # Now we can source any application specific functions
    if [file isdirectory [directory_path functions]] {
	source_directory [directory_path functions]
    }
    # Load any application specific packages or namespaces
    if {[info procs appSpecificPackages] == "appSpecificPackages"} {
	if [catch {appSpecificPackages} a] {
	    info_message "ERROR Running application specific package load\
		    procedure: Please Report: $a\n"
	    tkwait window .ghui_error
	    exit
	}
    }

	# Platform specific packages for shared libraries
    set pkgPath [ghui_version_path]/pkg$tcl_platform(os)

    if {[lsearch $auto_path $pkgPath] == -1} {
    	lappend auto_path $pkgPath
    }

	# Packages for accessing basis database, processing
    # and the two table packages
    lappend auto_path [ghui_version_path]/pkg

    # Packages for accessing server functions
    lappend auto_path [ghui_path]/pkg
    
    package require GHUIserver 1.0
    package require ghuiDatabase
	package require GHUI_process
    package require GHUITable
    package require plb

    namespace import scrollWidget::*
    namespace import menuBar::*
    namespace import partitionInfo::*
    
    # cd to owner of process in case of core dump
    cd
}
proc source_directory {dir} {
    global code_location
    cd $dir
    foreach tcl_file [glob *.tcl] {
	# do not source any top level scripts.
	switch $tcl_file {
	    edit_job.tcl {}
	    diff_jobs.tcl {}
	    read_rc.tcl {}
	    jobsheet_entry.tcl {}
	    default {
		if [catch {source $tcl_file} error] {
		    # Error occurred so output to error window
		    catch {
			# Error might be in these two files so put in another catch
			source $code_location/tcl/errors.tcl
			source $code_location/tcl/appearance.tcl    
			set_appearances $application
		    }
		    info_message "ERROR: $error\n while sourcing tcl files\n"
		    tkwait window .ghui_error
		    exit	    
		}
	    }
	}
    }
}


