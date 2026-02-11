proc check_cloud-rain {args} {
    # If PC2 is TRUE 3D large scale precip must be selected too.
    # PC2 is P_CLD_PC2
    # LSP scheme is ATMOS_SR(4)=="3D"
    set pc2 [ get_variable_value P_CLD_PC2 ]
    set LSP [ get_variable_value ATMOS_SR(4) ]
    
    if {$pc2 == "Y"} {
        if { $LSP != "3D" } {
	    error_message .d  {Invalid Choice} "If the PC2 scheme \
            is selected then the 3D large-scale precipitation scheme must \
	    be selected as well." warning 0 {OK}
	    return
	    }
      }
}
