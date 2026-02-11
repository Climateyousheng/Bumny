proc check_3d_cca {value variable index} {
  # This procedure is a verification function for 3DCCA.
  #
  set var_info [get_variable_info $variable] 
  set help_text [lindex $var_info 10] 
	
  if { ($value != "Y") && ($value != "N") } {
    error_message .d {Incorrect Setting} "Specify a valid value for Radiative Rep of  Anvils" warning 0 {OK}
    return 1
  }
  
  if { $variable=="LANVIL"} { 
  if { ($value == "Y") && ([get_variable_value ES_RAD] != 3 ) } {
      error_message .d {Cross Check} "You are asking for $help_text. \n\
You must also be using a General 2-Stream radiation (SW & LW)." warning 0 {OK}
      return 1
  }
  }
  
  if { $variable=="L3DCCA" } { 
     if { ($value != "Y") && ([get_variable_value LCCRAD] == "Y" ) } { 
        error_message .d {Cross Check} "You are using CCRAD. \n\
You must also select 3D CCA cloud field." warning 0 {OK} 
     return 1 
     } 
  } 

  if { $variable=="LCCRAD" } { 
     if { ($value == "Y") && ([get_variable_value L3DCCA] != "Y" ) } { 
        error_message .d {Cross Check} "You are using CCRAD. \n\ 
	You must also select 3D CCA cloud field (see previous panel)." warning 0 {OK} 
	return 1 
     } 
  } 
  return 0
}
   
