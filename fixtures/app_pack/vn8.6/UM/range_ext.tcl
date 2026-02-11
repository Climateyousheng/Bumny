
# range_ext
#   Verification funtion for for scalar variables that could be
#   defined externally, and hence EXTERNAL is sometimes a valid input
# Arguments
#   value: Value of input
#   variable: Name of UMUI object
#   index: Index if in an array or -1
#   lower: Lower limit to input
#   upper: Upper limit to input

proc range_ext {value variable index lower upper} {

  if {$index != -1} { set value [get_variable_value $variable\($index\) ] }

  set var_info [get_variable_info $variable]
  set help_text [lindex $var_info 10]
  set gen_suite [get_variable_value GEN_SUITE]

  if { $gen_suite==0 && $value=="EXTERNAL" } {
      error_message .d {Bad Setting} "Bad value for \"$help_text\". \n\
            You do not have generalized suite control. \n\
            You cannot define EXTERNAL." warning 0 {OK}
      return 1
  }

  if {$value==""} {
      error_message .d {No Value Given} "No value for \"$help_text\". \n\
	      This is not an optional setting" warning 0 {OK}
      return 1
  }

  if {$value!="EXTERNAL" && $value!="" } {
      if {($value>$upper)||($value<$lower)} {
	  error_message .d {Range Check Error} "The entry `$help_text' \
		  should lie between $lower and $upper" warning 0 {OK}
	  return 1
      }
  }

  return 0
}
