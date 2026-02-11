
# set_LSPPN_TYPE.tcl
#    Contains procedures for setting linked variables relating
#    to the Large Scale precip section choices.
# Documentation
#    See the documentation on linked variables in the windows
#    directory README file.
#---------------------------------------------------------------------



proc set_LSPICE {} {
    set_variable_value LSPICE [lindex [get_LSP_TYPE] 0]
}


proc set_LSP_CHEM {} {
    set_variable_value LSP_CHEM [lindex [get_LSP_TYPE] 1]
}


# get_LSP_TYPE
#    Determines values for CON_CHEM dependent
#    on selection for section 4.

proc get_LSP_TYPE {} {
    # Procedure for setting variable LSP_TYPE
    # Index 0:  LSPICE
    # 0=No prognostic ice. 1=Prognostic ice. What basic type of LS-Rain
    # Index 1:  LSP_CHEM
    # 0 not compliant, 1 compliant with chem model
    # 
    # 
    # Designed to catch new types coming along and give an error

    set h_sr [get_variable_value ATMOS_SR(4)] 

    if { ($h_sr=="0A") } {
      set lspice 0 
      set chem 0
    } elseif { $h_sr=="3B" || $h_sr=="3C" || $h_sr=="3D" } {
      set lspice 1 
      set chem 1
    } else {
	if {[check_variable_value ATMOS_SR(4) $h_sr scalar -1 2]!=1} {
           # If set to value allowed in var register, but not in the list,
           # then we need an error.
	    error "Error in proc LSPICE. Unknown LS_Rain $h_sr"
	} else {
            # If not an allowed value, check-setup does the job.
	    set lspice 0
	    set chem 0
	}
    }

    return [list $lspice $chem]
}
