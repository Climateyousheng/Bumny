proc vi_blayvars {variable call_type index} {
    # Inactive checking of VAR_RICIN

    if {($call_type=="PRELIM")} {
	# On windows, Input boxes are never greyed out so do not evaluate on preliminary
	# call otherwise may cause a consistency_check
	# On Check Setup, elements need to be checked one by one.
	return 2
    }
    
    set atmos3 [get_variable_value ATMOS_SR(3)]
    
    set lcombi [get_variable_value LCOMBI]
    set hdiffopt [get_variable_value HDIFFOPT]
    set horiz F 
    set vert F   
    if { $lcombi=="0" && $hdiffopt=="3" } {
       set horiz [get_variable_value LSUBFILHRZ] 
       set vert [get_variable_value LSUBFILVER]
    }
    set settke [get_variable_value SETTKELEVS]
    set tkelevs [get_variable_value TKE_LEVS] 
    set bllevs [get_variable_value NBLLV] 
    set abovetke [get_variable_value LOCALABVTKE]
        
    if { $atmos3=="0A" } {
       # element is inactive
       return 1
    } elseif { $atmos3=="1A" && $horiz=="F" && $vert=="F" && ( $settke=="N" || $tkelevs==$bllevs || $abovetke=="N" ) } {
        # element is inactive
       return 1   
    }

    if { $variable=="VAR_RICIN" } {
       set lsbleq [get_variable_value LSBLEQ]
       if { $lsbleq!="1" || $lsbleq!="2" || $lsbleq!="6" || $lsbleq!="8" } { 
          # element is inactive
          return 1
       }
    } elseif { $variable=="WLOUISTL" } {
       set lsbleq [get_variable_value LSBLEQ] 
       if { $lsbleq!="8" } {
          # element is inactive
          return 1       
      }
    }
    
  return 0
}
