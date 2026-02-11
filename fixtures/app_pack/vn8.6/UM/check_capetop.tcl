proc check_capetop {value variable index} {
# cape_top must be greater than cape_bottom

    set var_info [get_variable_info $variable]
	set help_text [lindex $var_info 10]
    set bottom [ get_variable_value CAPE_BOTTOM ]
    
    if {$value <= $bottom} {
	    error_message .d  {Invalid Value} "The entry '$help_text'\
            $value must be > $bottom" warning 0 {OK}
            return 1
    }
    return 0
}
