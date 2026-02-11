
# var_ext

#   This procedure is a verification function for variables that could be
#   defined externally. ie. If GEN_SUITE is 1, then a value of
#   EXTERNAL can be defined.

# Comments
#   May be required to check a scalar or an element of an array, but not
#   a whole array:
# scalar: 1: $variable has no index, $index is -1
# element of array: 
#       2a: Either $variable has index (eg OFILE(4)), $index is -1 and
#       $value is of element of variable only.
#       2b: Or $variable has no index, $index is element of array and
#       $value is value of whole array

# Case 2a is when a panel that references an element of an array is
# closed. Case 2b is when Check Setup is called; the variable inactive
# routine should indicate that array should be checked element by
# element and separate calls will be made for each active element.

proc var_ext {value variable index path_var} {
 
    set var_index [lindex [split $variable "()"] 1]
    set var_info  [get_variable_info $variable]
    set help_text [lindex $var_info 10]
    set gen_suite [ get_variable_value GEN_SUITE ]

    # What type of call is this
    if {$index == -1 } {
	if {$var_index == ""} {
	    # Case 1
	    set path_val [get_variable_value $path_var]
	} else {
	    # Case 2a
	    set path_val [get_variable_value ${path_var}($var_index)]
	}
    } else {
	# Case 2b
	set path_val [ get_variable_value ${path_var}($index) ]
	set value [get_variable_value ${variable}($index)]
    }

    # Can set EXTERNAL only if suite switched on
    if { $gen_suite==0 && $value=="EXTERNAL" } {
	error_message .d {Bad Setting} "Bad value for \"$help_text\". \n\
		You do not have generalised suite control. \n\
		You cannot define EXTERNAL." warning 0 {OK}
	return 1
    } elseif {$value!="EXTERNAL"} {
	   # Must be integer
       set rc [string is integer $value]
       if {$rc==1} {
          # check if positive
          if { [expr $value <= 0]} {
	         error_message .d {Wrong variable value} \
		       "The entry `$help_text' must be positive integer, but is \"$value\"." \
		       warning 0 {OK}
	         return 1
	      }          
       } else {
          # Not integer at all
	         error_message .d {Wrong variable value} \
		       "The entry `$help_text' must be positive integer, but is \"$value\"." \
		       warning 0 {OK}
	         return 1          
          
       }
    }
    return 0
}
   
