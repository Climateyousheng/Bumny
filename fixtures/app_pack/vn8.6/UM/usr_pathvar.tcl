proc usr_pathvar {value variable index } {
  # This procedure ensures that user defined path override variables begin with "%" 

  if {$index != -1} {set value [get_variable_value $variable\($index\) ] }
  set var_info [get_variable_info $variable]
  set help_text [lindex $var_info 10]

  if {$value!=""} {
	# Must start with %. Must not contain spaces
	if {([regexp {[\%]} [string index $value 0]]==0)||([llength $value]>1)} {
	    error_message .d {Path Name Error} "The entry `$help_text' must begin \"\%...\", but is \"$value\"" warning 0 {OK}
	    return 1
	}
  }
    
  return 0
}
   
