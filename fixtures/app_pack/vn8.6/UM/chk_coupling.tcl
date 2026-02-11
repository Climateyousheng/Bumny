proc chk_coupling {value variable index} {
  # This procedure checks coupling between Atmos NEMO and CICE

  if {$variable == "ATMOS"} {
     set atm  $value
     set nemo [get_variable_value NEMO]
     set cice [get_variable_value CICE]
     set jules [get_variable_value JULES]
  } elseif {$variable == "JULES"} {
     set atm [get_variable_value ATMOS]
     set nemo [get_variable_value NEMO]
     set cice [get_variable_value CICE]
     set jules $value
  } elseif {$variable == "NEMO"} {
     set atm [get_variable_value ATMOS]
     set nemo $value
     set cice [get_variable_value CICE]
     set jules [get_variable_value JULES]
  } else {
     set atm  [get_variable_value ATMOS] 
     set nemo [get_variable_value NEMO] 
     set cice $value
     set jules [get_variable_value JULES]
  }
  
  set mask $atm$nemo$cice$jules
  foreach item {FFFF FFFT TFTF TFTT TTFF TTFT FTTT FFTT FTFT} {
     if {$item == $mask} {
        error_message .d {Invalid Choice } "Only shown choices are \
        available" warning 0 {OK}
        return 1     
     }
  }
  
  # If the ATMOSPHERE model is not in use then Reconfiguration is redundant.
  # This process switches ARECON in order to prevent problems in NEM/CICE 
  # only models
  set recon [ get_variable_value ARECON ]
   
  if { $recon=="Y" && $atm!="T" } {
   set_variable_value ARECON N
   error_message .d {Reconfiguration} "Reconfiguration is not required \
   when the ATMOSPHERE model is not in use.  The reconfiguration has been switched \
   off."  warning 0 {OK}
  }

  return 0
}
