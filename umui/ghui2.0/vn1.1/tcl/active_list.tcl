# Procedure to produce a list of all the active variables
# in an experiment.
# PROCEDURE: Outputs a two windows: a variable output window and a progress window
# Updates information on which partitions are active (call to partition_info)
# Loops through all variables in var.register.
# For each variable: If in inactive partition, ceases check. Then makes one or more 
# call to check_activity depending on variable type:
# Scalar VARX : Makes one call with VARX
# 1D list VARY : if single partition makes one call with VARY
#              : if cross-partition makes call for each partition with VARY(1), VARY(2),...
#                        only if particular partition is active.
# 2D list VARZ : if single partition makes calls with VARZ(*,1), VARZ(*,2),...
#              :  if cross-partition makes calls as above, but only if partition is active


proc create_active_list {run_id win diff_list} {
    
    global fv_variable_name fv_index fv_error_list
    global verify_flag

    # Verify flag is used in some inactive checking functions
    set verify_flag 0

    # Window to output progress of check

    set number 0

    # Number of variables in list
    set nvar [llength $diff_list]

    # open variable register:
    foreach var $diff_list {

	# Update progress. If quit pressed and window destroyed then end.
	set number [expr $number+1]
	set proportion [expr ($number*100)/$nvar]
	$win configure -text "$proportion \%"
	update idletasks
	update
	#if {[info commands .verify]!=".verify"} {break}

	set var_info [get_variable_info $var]
	set start_index   [lindex $var_info 13]

	# dim2 - size of 2nd array dimension; could be variable or number
	set dim2 [lindex $var_info 12]
	if {[regexp {[A-Z]} $dim2]} {set dim2 [get_variable_value $dim2]}

	# length - maximum length of list allowed
	set length [expr [lindex $var_info 2]/$dim2]

	# get code number (eg a2323) and use it to determine which partition
	set code [lindex $var_info 6]
	set subm [string index $code 0]
	
	set inactive [partition_status $code -1]
	if {$inactive==1} {
	    # This partition is not active - do not need to check
	    continue
	}
	# If $inactive=0, variable should be checked
	# Otherwise $inactive is a list, 1st element X and remaining elements
	# are 1 or 0 depending on whether associated element of variable is inactive or not
	if {[lindex $inactive 0]=="X"} {set cross_partition 1} else {set cross_partition 0}

	# var_inactive may contain list length information 
	set var_inactive [lindex $var_info 7]

	# The following determines how variable needs to be checked - verification
	# is different depending on whether a scalar, a 1D or 2D array, or whether
	# variable is cross partition or not.

	# Distinguish array variables from scalars using $length
	if {$length==0} {
	    # Scalar: One call only required
	    set val [get_variable_value $var]
	    set fv_variable_name "$var"
	    check_activity $var $val "scalar" 0 $run_id
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
		if {[set size [sum_parse $length]]==""} {set size 0}
		# If array is not being used, then the variable defining its size
		# may be undefined. If so, sum_parse will return "".Assume size is 0

		if {$cross_partition==0} {
		    # Variable applicable to one subsection so check whole list
		    set val [get_variable_array $var]
		    set fv_variable_name "$var"
		    check_activity $var $val "array" $size $run_id
		} else {
		    # Variable crosses subsections - check only appropriate elements
		    for {set i 1} {$i<=$length} {incr i} {
			if {[lindex $inactive $i]!=1} {
			    # Check only those elements applicable to partitions in use
			    # calling with index appended - ie as a scalar
			    set varname "$var\($i\)"
			    set val [get_variable_value $varname]
			    set fv_variable_name "$varname"
			    check_activity $varname $val "scalar" 0 $run_id
			}
		    }
		}    
	    } else {
		# 2D array - loop $dim2 times, checking each list in array
		for {set i 1} {$i<=$dim2} {incr i} {
		    # Calculate size of list $i which is likely to be a function of $i
		    regsub -all {\(N\)} $length "($i)" sum
		    if {[set size [sum_parse $sum]]==""} {set size 0}
		    # If array is not being used, then the variable defining its size
		    # may be undefined. If so sum_parse will return "" - assume 0
		    
		    if {($cross_partition!=1)||([lindex $inactive $i]!=1)} {
			# Either variable is not cross-partition or,if it is, this element
			# is in an active partition
			set varname "$var\(\*,$i\)"
			set val [get_variable_array $varname]
			set fv_variable_name "$varname"
			check_activity $varname $val "array" $size $run_id
		    }
		}
	    }
	}
    }
}

# Call check routine but catch Tcl errors caused by calling functions
# zero at end of arg list means errors are not output to dialog boxes 
proc check_activity {variable value type size run_id} {
    
    global fv_index
    global var_list

    set var_info      [get_variable_info $variable]
    set var_index     [lindex [split $variable "()"] 1]
    set start_index   [lindex $var_info 13]
    
    regsub {\*,} $var_index {} var_index
    set fv_index $var_index
    set vi_expr [active_status $variable]
    # vi_expr will be  - 0 for active
    #                  - 1 for variable is inactive 
    #                  - 0 for NEVER inactive 
    #                  - 2 for FN: which is dependent on index
    #                  - 1 for ALWAYS inactive
    #                  - 3 for an expression which requires an index


    if {$type=="array"} {
	if {$vi_expr==1} {
	    # Variable is inactive
	} elseif {$vi_expr==0} {
	    # Variable is active
	    set var_list($run_id,$variable) [lrange $value 0 [expr $size-1]]
	    lappend var_list($run_id) $variable
	} else {
	    for {set i 0} {$i < $size} {incr i} {
		set val [lindex $value $i]
		if {[regexp {^ *$} $value]} {set blank 1} else {set blank 0}

		if {$var_index==""} {set vindex [expr $i+$start_index]} else {set vindex $var_index}
		set fv_index $vindex
		set inactive [active_element $variable $blank $vi_expr [expr $i>0] $vindex]
		#         0 active   - must not be blank
		# returns 1 inactive - go to next element
		
		# Otherwise variable is active 
		if {$inactive==0} {
		    # Active
		    set var_list($run_id,$variable\($vindex\)) $val
		    lappend var_list($run_id) $variable\($vindex\)
		}
	    }
	}
    } else {
	# Checking scalar variable
	if {[regexp {^ *$} $value]} {set blank 1} else {set blank 0}

	set inactive [active_element $variable $blank $vi_expr 0 $var_index]
	#         0 active   - must not be blank
	# returns 1 inactive - go to next element
	# Otherwise variable is active 

	if {$inactive==0} {
	    # Active
	    set var_list($run_id,$variable) $value
	    lappend var_list($run_id) $variable
	}
    }
}





