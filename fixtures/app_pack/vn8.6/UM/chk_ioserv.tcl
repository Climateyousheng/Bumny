proc chk_ioserv {value variable index} {
    # Checking to make sure IO_RBUFFER_PREFETCH < IO_RBUFFER_COUNT if IO_RBUFFER_COUNT > 0
    # else IO_RBUFFER_PREFETCH == 0

    set rbuff_count [get_variable_value IO_RBUFFER_COUNT]
    
    if {$rbuff_count == 0 && $value != 0} {
        error_message .d {Out of range} "\"Number of read buffers helper thread prefetch...\" \
        must be equal to 0."  warning 0 {OK}
        return 1
    } elseif {$rbuff_count > 0 && $value > $rbuff_count} {
        error_message .d {Out of range} "\"Number of read buffers helper thread prefetch...\" \
        must be less than \"Number of read buffers per IO stream\"" warning 0 {OK}
        return 1
    } else {
        return 0
    }
}