proc check_cloud-conv {args} {
    # If ATMOS_SR(5)==4A in convection then ATMOS_SR(9) must
    # equal 2A - Standard scheme with triangular probability density function
    # cld is ATMOS_SR(9)
    # conv is ATMOS_SR(5)
    set cld [ get_variable_value ATMOS_SR(9) ]
    set conv [ get_variable_value ATMOS_SR(5) ]
    
    if {$conv == "4A"} {
        if { $cld != "2A" } {
	    error_message .d  {Invalid Choice} "The selection of 4A \
            (convection scheme) must be used  \
            with the 2A cloud scheme." warning 0 {OK}
            return
            }
      }
}
