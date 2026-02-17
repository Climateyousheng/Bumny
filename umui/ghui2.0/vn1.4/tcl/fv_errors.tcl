# error_message
#    Creates error message for input validation. Generally called from
#    check_variable_value routines but reacts differently depending on
#    what called check_variable_value (which is indicated by the global
#    verify_flag
# Arguments
#    w       : toplevel widget for dialog box
#    title   : title of error
#    text    : error message
#    bitmap  : icon for dialog box
#    default : 
#    args    : there should only be 1 - "OK" for dialog box
# Method
#    check_variable_value sets verify_flag depending on flag argument.
#    verify_flag = 0 : Check Setup error
#                = 1 : Error on panel closure
#                = 2 : Checking internal variables - calling routine 
#                      produces appropriate error

proc error_message {w title text bitmap default args} {

    global verify_flag

    if {$verify_flag==0} {
	# Error during a full_verify (equiv to Check Setup)
	full_verify_error $title
    } elseif {$verify_flag==1} {
	# Error following window closure - just pass args to the dialog function
	dialog $w $title $text $bitmap $default $args
    } elseif {$verify_flag != 2} {
	# Internal check
	error "Invalid value for verify_flag variable of $verify_flag"
    }
}

# full_verify_error
#    Create an informative error message for output to full_verify 
#    error window.
# Argument
#    title : Broad description of error
# Globals
#    fv_variable_name : Name of variable
#    fv_index         : Index of array variables
#    fv_error_list    : Keeps list to ensure duplicate errors not produced
#                       for every line of a table.

proc full_verify_error {title} {
    global fv_variable_name fv_index fv_error_list

    # proc set_winname returns two strings.
    set wininfo [set_winname]
    
    # First string is descriptive - usually of the form eg
    #      "window [window_name]"
    set location [lindex $wininfo 0]
    
    # Second string is window name which should be listed in nav.spec
    set window [lindex $wininfo 1]
    
    # This will be first line of error message
    set message "$title in $location \nVariable: $fv_variable_name\n"

    # Do not output repeat messages
    if [compare_list $message $fv_error_list 0] {return}

    # Add message to list
    # NB list is reset at start of proc full_verify
    lappend fv_error_list $message

    # Output message to window.
    fv_errors $message

    # proc navigation_path searches nav.spec and returns path to $window
    set path [navigation_path $window]
    if {$path==0} {set path "Path to $window is not listed in navigation tree\n"}
    fv_errors $path
}

# fv_errors
#     Outputs message to a window. Creates window if it does not already exist
# Arguments
#     message    : One or more line message
#     win_title  : Optional title
    
proc fv_errors {message {win_title {"Errors and Warnings"}}} {
    # Output messages to window with optional title.

    addTextToWindow .fv_error $message $win_title 100

}
