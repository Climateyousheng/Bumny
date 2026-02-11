proc verify_memory_limit {value variable index} {

# Checks on which machine it is going to be run
# and put a memory limit 0-50 GB

    set var_info [get_variable_info $variable]
    set help_text [lindex $var_info 10]
    set sbm_method [get_variable_value SUBMIT_METHOD]

    if {[catch {expr $value}]} {
	error_message .d {Memory Limit} "The entry '$help_text' must be a valid number" warning 0 {OK}
	return 1
    }

   if {$sbm_method==3} {
        # when submitting to the LoadLeveler we have restricted memory
        # size 0-50 Gbytes
       
        if {$value > 50} {
            error_message .d {Memory Limit} "When submitting via LoadLeveler '$help_text' must be <= 50" warning 0 {OK}
            return 1   
        }
    }
    return 0
}
