proc active_prof_nm {variable call_type index} {
    # If called from a window, blank not allowed
    # If full verify do not check - indicate inactive
    
    global verify_flag

    if {$verify_flag} {return 0}
    return 1
}
