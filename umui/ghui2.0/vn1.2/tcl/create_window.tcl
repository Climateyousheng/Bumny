# create_window
#   Creates input window based on the window script requested.
#   Can be called from any script in the GHUI or user interface
#   code.
# Argument
#   window_name: Refers to a file. File name obtained by calling
#                window_file proc
# Method
#   parse_window creates a Tcl/Tk script which, when eval'd creates
#   an input window.

proc create_window {window_name} {

    # Get file name that holds GHUI window script
    set file [window_file $window_name]

    if {[file exists $file] == 0} {
	dialog .nowin {Panel Unavailable} \
		"The panel you have requested ($window_name) does not\
		exist. Please report to the development team\
		immediately." \
		warning 0 OK
	return
    }
    if {[file readable $file] == 0} {
	dialog .nowinread {Panel Unreadable} \
		"The panel you have requested ($window_name) exists,\
		but is not readable. Please report to the development\
		team immediately." \
		warning 0 OK
	return
    }

    # parse_window creates Tcl/Tk script to create panel
    set script [parse_window $file $window_name]
    eval $script
}




