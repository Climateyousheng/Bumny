# set_BL_TYPE.tcl
#    Contains procedures for setting linked variables relating
#    to the Boundary Layer section choices.
# Documentation
#    See the documentation on linked variables in the windows
#    directory README file.
#---------------------------------------------------------------------

proc set_BL_TYPE {} {
    set_variable_value BL_TYPE [lindex [get_BL_TYPE] 0]
}

proc set_BL_CHEM {} {
    set_variable_value BL_CHEM [lindex [get_BL_TYPE] 1]
}

proc set_BL_SPICE {} {
    set_variable_value BL_SPICE [lindex [get_BL_TYPE] 2]
}

# get_BL_TYPE
#  Determines values for BL_TYPE, BL_SPICE and BL_CHEM dependent
#  on selection for section 3.
# Comments
#  Version options other than 0A and 6A removed for vn5.0


proc get_BL_TYPE {} {
    # Procedure for setting variable BL_TYPE
    #
    # Also BL_CHEM
    # 0 not compliant, 1 compliant with chem model
    # 
    # Also BL_SPICE
    # 0 not supporting spice option. 1 supporting spice option
    # 
    # Designed to catch net types coming along and give an error
    # Mode is used to say if the routine sets the value (set) eg on
    # exit from the window, or returns the results (retrun) without setting.


    set h_sr [get_variable_value ATMOS_SR(3)] 

    if { ($h_sr=="0A") } {
      set type 0 
      set chem 0
      set spice 0
    } elseif { $h_sr=="6A" || $h_sr=="6B" } {
      set type 3
      set chem 1
      set spice 0
    } elseif { $h_sr=="1A" || $h_sr=="9B" || $h_sr=="9C"} {
      set type 4
      set chem 1
      set spice 0
    } else {
	if {[check_variable_value ATMOS_SR(3) $h_sr scalar -1 2]!=1} {
           # If set to value allowed in var register, but not in the list,
           # then we need an error.
	    error "Error in proc set_BL_TYPE. Unknown BL-version $h_sr"
	} else {
            # If not an allowed value, check-setup does the job.
	    set type 0
	    set chem 0
	    set spice 0
	}
    }

    return [list $type $chem $spice]
}
