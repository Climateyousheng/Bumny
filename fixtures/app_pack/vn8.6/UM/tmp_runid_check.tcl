proc temp_runid_check {value variable index} {
# Anthony
    
    # Value should contain the string temp_$RUNID
    set var_info [get_variable_info $variable]
    set help_text [lindex $var_info 10]
    
    set subst {temp_$RUNID}

    if {$value==""} {
      error_message .d {Empty string} "The entry $help_text must include the directory \
      to override, but it is empty" warning 0 {OK}
	  return 1
    }
     
    if {[string last $subst $value]==-1} {
        error_message .d {Wrong Directory Name} "The entry $help_text MUST include the string \
        $subst to ensure the name is unique to the job." warning 0 {OK}
	    return 1
    }
    return 0
}
