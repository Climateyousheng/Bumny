proc compileOpt {value variable index} {
  # This procedure is a verification function for COMP_ATM and COMP_RCF
  #
  if { $variable == "COMP_ATM" || $variable == "RUN_ATM" } {
     set exec "Model"
  } elseif { $variable == "COMP_RCF" || $variable == "ARECON" } {
     set exec "Reconfiguration"
  } else {
     set exec ""
     error_message .d {Unknown Variable} "ERROR: Unknown variable $variable in compileSCS routine." warning 0 {OK}
     return 1
  }

  set func [lindex [split $variable "_"] 0]
  if { $func == "COMP" } { set func "COMPILE" }
 
  if {  ($value != "Y") && ($value != "N") } {
    error_message .d {Incorrect Setting} "$exec $func Option must be specified." warning 0 {OK}
    return 1
  }
    
  if { $func=="COMPILE" && $value == "Y" } {
    set gensuite [ get_variable_value GEN_SUITE ]
    if {  [ get_variable_value GEN_SUITE ] != 0 } {
      error_message .d {No compilation allowed} "For runs that have external control (Generalised suite), \
        you must have an existing $exec executable." warning 0 {OK}
      return 1
    }
  }

  set compatm [get_variable_value COMP_ATM]
  set comprcf [get_variable_value COMP_RCF]
  set runatm [get_variable_value RUN_ATM]
  set runrcf [get_variable_value ARECON]
  set mask $compatm$comprcf$runatm$runrcf
  if { $mask == "NNNN" } {
     dialog .d "Compile/Run Options" \
"WARNING: Selected options will result in neither Atmosphere Model \
nor Reconfiguration being compiled or run" warning 0 {OK}
  }

  return 0
}
