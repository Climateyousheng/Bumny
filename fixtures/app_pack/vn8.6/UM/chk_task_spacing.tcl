proc chk_task_spacing {value variable index} {
    # This function check coupling task spacing is correct
    # should be 0 or 2 to maximum number of processors
    
    set nmppe [get_variable_value NMPPE]
    set nmppn [get_variable_value NMPPN]
    set nemo_iproc [get_variable_value NEMO_IPROC]
    set nemo_jproc [get_variable_value NEMO_JPROC]
    
    set pe_tot [expr $nmppe*$nmppn + $nemo_iproc*$nemo_jproc] 
    
    if {$value == 1} {
        error_message .d {Invalid Value } " Task spacing cannot \
        be 1" warning 0 {OK}
        return 1
    } elseif {$value > $pe_tot} {
      error_message .d {Invalid Value } " Task spacing cannot \
        be greater than Total PEs. For the current job this should \
        <=$pe_tot" warning 0 {OK}
        return 1  
    }

    return 0
}