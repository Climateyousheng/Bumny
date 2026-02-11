# set_CON_TYPE.tcl
#    Contains procedures for setting linked variables relating
#    to the Concection section choices.
# Documentation
#    See the documentation on linked variables in the windows
#    directory README file.
#---------------------------------------------------------------------



proc set_CON_CHEM {} {
    set_variable_value CON_CHEM [lindex [get_CON_TYPE] 0]
}


# get_CON_TYPE
#    Determines values for CON_CHEM dependent
#    on selection for section 5.

proc get_CON_TYPE {} {
    # Procedure for setting variable BL_TYPE
    # 0 not compliant, 1 compliant with chem model
    # 
    # 
    # Designed to catch new types coming along and give an error


    set h_sr [get_variable_value ATMOS_SR(5)] 

    if { ($h_sr=="0A") } {
      set chem 0
    } elseif { $h_sr=="2A" } {
      set chem 0
    } elseif { $h_sr=="2C" } {
      set chem 0
    } elseif { $h_sr=="3B" } {
      set chem 1
    } elseif { $h_sr=="3C" } {
      set chem 1
    } elseif { $h_sr=="4A" } {
      set chem 1
    } elseif { $h_sr=="4B" } {
      set chem 1
    } elseif { $h_sr=="5A" } {
      set chem 1    
    } elseif { $h_sr=="6A" } {
      set chem 1  
    } else {
	if {[check_variable_value ATMOS_SR(5) $h_sr scalar -1 2]!=1} {
           # If set to value allowed in var register, but not in the list,
           # then we need an error.
	    error "Error in proc set_BL_TYPE. Unknown Convection-version $h_sr"
	} else {
            # If not an allowed value, check-setup does the job.
	    set chem 0
	}
    }

    return [list  $chem ]
}
