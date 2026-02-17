# Procedure to run a full sweep verify of all variables 
# in an experiment.
# PROCEDURE: Outputs a two windows: an error output window and a progress window
# Loops through all variables in var.register.
# For each variable: If in inactive partition, ceases check. Then makes one or more 
# call to call_check depending on variable type:
# Scalar VARX : Makes one call with VARX
# 1D list VARY : if single partition makes one call with VARY
#              : if cross-partition makes call for each partition with VARY(1), VARY(2),...
#                        only if particular partition is active.
# 2D list VARZ : if single partition makes calls with VARZ(*,1), VARZ(*,2),...
#              :  if cross-partition makes calls as above, but only if partition is active


proc nav_full_verify {} {
    
    global env
    global fv_variable_name fv_index fv_error_list
    global grey verify_flag

    # Tell fv_errors.tcl to send errors to .fv_error window
    set verify_flag 0

    # reset list of errors (used in proc error_message)
    set fv_error_list {}

    # Message to the navigation window
    status_message "" "Check Setup in progress"

    # Window to output progress of verification
    if {[info commands .verify] == ".verify"} {
	# Process already in progress so bring window to top and return
	wm withdraw .verify
	wm deiconify .verify
	return
    }
    toplevel .verify
    wm geometry .verify +10+20
    wm title .verify "Progress of full verification"
    message .verify.text -text "Proportion of variables checked:-" -anchor w -width 1500
    message .verify.num -text {} -anchor w -width 1500
    set quit 0

    # Quit just destroys the window - the checking loop checks for this window
    # each time around and closes down if the window has gone.
    button .verify.quit -text "Quit" -command {
	destroy_window .verify
    }
    pack .verify.text -anchor w -padx 2m -pady 4m
    pack .verify.num
    pack .verify.quit

    bind_ok .verify .verify.quit

    # Initialise number of variables checked
    set number 1
    set var_dir [directory_path variables]
    set a [open $var_dir/var.register]
    set b [read $a]
    # $nVars is roughly the total number of variables
    set nVars [expr [llength [split $b \n]] - [llength [split $b #]]]
    close $a

    # Create the output window
    fv_errors "Errors will be output in this window\n"

    # Loop over all lines in variable register
    foreach line [split $b \n] {
	# var - variable name
	set var [lindex $line 0]
	# Ignore commented out lines
	if {[string index $var 0]=="#"} {continue}

	# Update progress. If quit pressed and window destroyed then end.
	set number [expr $number+1]
	set proportion [expr ($number*100)/$nVars]
	.verify.num configure -text "$proportion \%"
	update

	# If the .verify window has gone, then stop checking now.
	if {[info commands .verify]!=".verify"} {break}

	# Ignore blank lines
	if {$var==""} {continue}

	#puts "Checking $var"

	set var_info [get_variable_info $var]

	# var_inactive may contain list length information 
	set var_inactive  [lindex $var_info 7]

	set start_index   [lindex $var_info 13]

	# dim2 - size of 2nd array dimension; could be variable or number
	set dim2 [lindex $var_info 12]
	if {[regexp {[A-Z]} $dim2]} {set dim2 [get_variable_value $dim2]}

	# length - maximum length of list allowed
	set length [expr [lindex $var_info 2]/$dim2]

	# get code number (eg a2323) and use it to determine which partition
	set code [lindex $var_info 6]

	
	# Check whether partition is active
	set inactive [partition_status $code -1]
	if {$inactive==1} {
	    # This partition is not active - do not need to check
	    continue
	}

	# If $inactive=0, variable should be checked
	# Otherwise $inactive is a list, 1st element X and remaining elements
	# are 1 or 0 depending on whether associated element of variable is inactive or not
	if {[lindex $inactive 0]=="X"} {set cross_partition 1} else {set cross_partition 0}


	set vi_expr [active_status $var]
	# vi_expr will be  - 0 for active
	#                  - 1 for variable is inactive 
	#                  - 0 for NEVER inactive 
	#                  - 2 for FN: which is dependent on index
	#                  - 3 for expression which is a function of index
	#                  - 1 for ALWAYS inactive
	if {$vi_expr==1} {continue}

	# The following determines how variable needs to be checked - verification
	# is different depending on whether a scalar, a 1D or 2D array, or whether
	# variable is cross partition or not.

	# Distinguish array variables from scalars using $length
	if {$length==0} {
	    # Scalar: One call only required
	    set val [get_variable_value $var]
	    set fv_variable_name "$var"
	    call_check $var $val "scalar" 0
	} else {
	    # A 1D or 2D array

	    # If there is a size function in Variable Inactive column then use it
	    # Size function always comes first in expression
	    # Otherwise use given length
	    set element [lindex [split $var_inactive ":"] 0]
	    if {($element!="FN")&&($element!="GT1")&&([regexp : $var_inactive])} {
		set length $element
	    } elseif {[regexp {[A-Z]} $length]} {
		# length is a variable
		set length [get_variable_value $length]
	    }
	    if {$dim2==1} {
		# 1D array so $length won't be a function of N
		if [catch {set size [expr $length]}] {
		    if [catch {set size [get_variable_value $length]} ] {
			set size [sum_parse $length]
		    }
		}
		if {$size==""} {set size 0}
		# If array is not being used, then the variable defining its size
		# may be undefined. If so, sum_parse will return "".Assume size is 0

		if {$cross_partition==0} {
		    # Variable applicable to one subsection so check whole list
		    set val [get_variable_array $var]
		    set fv_variable_name "$var"
		    call_check $var $val "array" $size
		} else {
		    # Variable crosses subsections - check only appropriate elements
		    for {set i 1} {$i<=$length} {incr i} {
			if {[lindex $inactive $i]!=1} {
			    # Check only those elements applicable to partitions in use
			    # calling with index appended - ie as a scalar
			    set varname "$var\($i\)"
			    set val [get_variable_value $varname]
			    set fv_variable_name "$varname"
			    call_check $varname $val "scalar" 0
			}
		    }
		}    
	    } else {
		# 2D array - loop $dim2 times, checking each list in array
		for {set i 1} {$i<=$dim2} {incr i} {
		    # Calculate size of list $i which is likely to be a function of $i
		    regsub -all {\(N\)} $length "($i)" sum
		    if [catch {set size [get_variable_value $sum]} ] {
			set size [sum_parse $sum]
		    }
		    if {$size==""} {set size 0}
		    # If array is not being used, then the variable defining its size
		    # may be undefined. If so sum_parse will return "" - assume 0
		    
		    if {($cross_partition!=1)||([lindex $inactive $i]!=1)} {
			# Either variable is not cross-partition or,if it is, this element
			# is in an active partition
			set varname "$var\(\*,$i\)"
			set val [get_variable_array $varname]
			set fv_variable_name "$varname"
			call_check $varname $val "array" $size

		    }
		}
	    }
	}   
    }
    catch {destroy .verify}
    fv_errors "Verification is complete. \
	    \nIf an error was detected then find the window, enter and close it.\
	    \nThis will either generate a more informative error message or it will\
	    \nresult in the setting of a previously unset hidden variable."
    clear_message ""
}

# call_check
#   Interface to check_variabke_value routine. Appends zero at end of
#   arg list so errors are output to fv_errors window instead
#   of dialog boxes.
# Arguments
#   var : Variable name including optional index
#   val : Value
#   type: array or scalar
#   size: Max size of array, or 0 for scalar
# Comments
#   Includes code for a catch for Tcl errors in checking procedure
#   which is not currently in use.

proc call_check {var val type size} {
    check_variable_value $var $val $type $size 0
    return

    # Error catch currently not in use

    if [catch {set err [check_variable_value $var $val $type $size 0]} \
	    result] {
	puts "Tcl error $result while checking $var=$val"
    } else {
	if {$err==1} {
	    #puts "Error during checking of $var=$val in window $name_of_window"
	}
    }
}



