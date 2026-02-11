proc check_ioproc {value variable index} { 
    # Product of IOS_NPROC and IOS_NTASK must not exceed 20. 
     
    set var_info [get_variable_info $variable] 
    set help_text [lindex $var_info 10] 
 
    set nproc [get_variable_value IOS_NPROC] 
    if { [inactive_var IOS_NTASK]==0 } { 
        set ntask [get_variable_value IOS_NTASK] 

        if {$ntask > 32} {
            error_message .d {Bad value} "The MAX value of $help_text is 32" warning 0 {OK} 
            return 1 
        }
 
        set ns_proc [get_variable_value NMPPN] 
        if { $ntask < 1 || $ntask > $ns_proc } { 
            error_message .d {Invalid Combination} "The value of $help_text must lie between 1 and the number of ATMOS N-S processors: $ns_proc" warning 0 {OK} 
            return 1 
        } 
             
    } else { 
        set ntask 1 
        set msg "" 
    } 
 
#    set prod [expr $nproc * $ntask] 
#    if { $prod < 1 || $prod > 20 } { 
#        set ntask_info [lindex [get_variable_info IOS_NTASK] 10] 
#        set nproc_info [lindex [get_variable_info IOS_NPROC] 10] 
#       error_message .d {Invalid Combination} "The value of \ 
#              $nproc_info * $ntask_info is $nproc * $ntask,  it \nmust be between 1 and 20." \ 
#              warning 0 {OK} 
#       return 1 
#    } 
         
    return 0 
} 
