#########################################################################
# proc read_rcfile                                                      #
# Calls routine to set user's preferences as listed in .***rc file      #
# Checks for existence of rc file and for existence of entry proc in    #
# application directory and returns if not there                        #
#########################################################################

proc read_rcfile {exp_id job_id description version} {

    global all_lines env port primary_server application wishExe

    if {[file readable $env(HOME)/.$application${version}rc]==1} {
	# rc file exists
	set code_location [ghui_version_base $version]
	set file $code_location/tcl/read_rc.tcl
	if {[file exists $file]==0} {
	    error "You cannot use a preference file for version $version. \
		    Please delete file $env(HOME)/.$application${version}rc \
		    NB New job has been created successfully"
	}
	exec $wishExe $file \
		$application \
		$version \
		[ghui_path] \
		$code_location \
		$port \
		$exp_id \
		$job_id \
		$description &
    }
}
