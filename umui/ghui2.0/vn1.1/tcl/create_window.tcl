proc create_window {window_name} {

    global block_indentation parser_script submodel

    set file [window_file $window_name]

    if {[file exists $file] == 0} {
	dialog .nowin {Panel Unavailable} \
		"The panel you have requested ($window_name) does not exist. \
		Please report to the development team immediately." \
		warning 0 OK
	return
    }
    if {[file readable $file] == 0} {
	dialog .nowinread {Panel Unreadable} \
		"The panel you have requested ($window_name) exists, but is not \
		readable. Please report to the development team immediately." \
		warning 0 OK
	return
    }


    # Need to protect $quit_proc etc in case they have args
    parse_window $file $window_name
    eval $parser_script
}




