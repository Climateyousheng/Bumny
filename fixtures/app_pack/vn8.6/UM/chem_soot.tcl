proc chem_soot {value variable index} {
# This procedure is a verification function for chem_soot.
#
#  set chem_sulphc [ get_variable_value CHEM_SULPC ]
#  set var_info [get_variable_info $variable]
#  set help_text [lindex $var_info 10]
#
#  if { $value!= "Y" && $value!= "N" } {
#    error_message .d {Invalid Choice} "The entry '$help_text'\
#    does not have a valid value." warning 0 {OK}
#    return 1
#  }
#
#  if { $value!="Y"  && $chem_sulphc=="N" } { 
#    error_message .d {Inconsistent} "When using the chemistry section,\
#    you must select at least one of the model options - Sulphur Cycle\
#    or Soot modelling." warning 0 {OK}
#    return 1
# }
#
#  return 0
# ================= ILP ==========================

    # Check if switches are unset
	foreach item {"CHEM_BIOM" "CHEM_NITR"} {
		set a [get_variable_value $item]
		if {$a != "Y" && $a != "N"}	 {
		    set_variable_value $item N    	
		}
	}
	
	set flag 0

	foreach item {"CHEM_SULPC" "CHEM_SOOT" "CHEM_BIOM" "CHEM_OCFF" "CHEM_NITR"} {
		set a [get_variable_value $item]
		set valitem($item) $a
		if {$a=="Y"}  {
			set flag 1
		}
	}

        set i_dust [get_variable_value I_DUST] 

	if {$flag==0 && $i_dust==0} {
		error_message .d {Inconsistent} "When using the aerosol section,\
  		you must select at least one of the model options - Sulphur Cycle, Nitrate modelling, \
		Soot modelling, Biomass modelling,  Mineral Dust or OCFF scheme." warning 0 {OK}
   	 return 1	
	}

	foreach item {"CHEM_SULPC" "CHEM_SOOT" "CHEM_BIOM" "CHEM_OCFF" "CHEM_NITR"} {
		if {$valitem($item)!="Y" &&$valitem($item)!="N"} {
			error_message .d {Invalid Choice} "Value should be Yes or No\
   		 	but not unset" warning 0 {OK}
    		return 1
		}
	}

    # Consistency check for nitrate scheme
       if { $item == "CHEM_NITR" } {
          set sulphur [get_variable_value CHEM_SULPC]
          set nitrate [get_variable_value CHEM_NITR]

          if {$nitrate=="Y" && $sulphur=="Y"} {
             set atmos17 [get_variable_value ATMOS_SR(17)]
             set oxi2b [get_variable_value OXIOZ2B]
	     set sulozone [get_variable_value SULOZONE]

             if { $sulozone=="N" || $atmos17=="2B" && $oxi2b=="0"} { 
                if { $sulozone=="N"} {
                   error_message .d {Cross Check} "You must include ozone in the DMS scheme \
                   when using the nitrate scheme. Please check this option and select oxidation \
	           of SO2 with/without buffering on the sulphur (SULP) panel" warning 0 {OK}
		   return 0
                } else {
                   error_message .d {Cross Check} "You must include ozone in the DMS scheme \
                   when using the nitrate scheme. Please select oxidation of SO2 with/without \
	           buffering on the sulphur (SULP) panel" warning 0 {OK}
		   return 0 
                }
             } 
          }
       }
    
       return 0
}


   
