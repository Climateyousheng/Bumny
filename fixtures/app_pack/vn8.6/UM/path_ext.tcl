proc path_ext {value variable index optional } {
  # This procedure is a verification function for directory paths for files
  # that could be defined externally.
 
  if {$index != -1} {set value [get_variable_value $variable\($index\) ] }
  set var_info [get_variable_info $variable]
  set help_text [lindex $var_info 10]
  set gen_suite [ get_variable_value GEN_SUITE ]
  if { $gen_suite==0 && $value=="EXTERNAL" } {
    error_message .d {Bad Setting} "Bad value for \"$help_text\". \n\
           You do not have generalised suite control. \n\
           You cannot define EXTERNAL." warning 0 {OK}
    return 1
  }

  if {$value=="" && $optional!="OPT" } { 
    error_message .d {No Value Given} "No value for \"$help_text\". \n\
           This is not an optional setting" warning 0 {OK}
    return 1
  }

  if {$value!="EXTERNAL" && $value!=""} {
	# Must start with ~ / or $. Must not contain spaces
	if {([regexp {[\/\$\~]} [string index $value 0]]==0)||([llength $value]>1)} {
	    error_message .d {Path Name Error} "The entry `$help_text' must contain a valid path, but is \"$value\"" warning 0 {OK}
	    return 1
	}
  }
    
  return 0
}
   
