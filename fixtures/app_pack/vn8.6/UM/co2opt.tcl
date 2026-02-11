proc co2opt {value variable index} {
  # This procedure is a verification function for CO2OPT.
  #


  set var_info [get_variable_info $variable]
  set help_text [lindex $var_info 10]
  if {  ($value != "1") && ($value != "2") && ($value != "3") } {
    error_message .d {Incorrect Setting} "The value associated with $help_text is invalid. Specify valid value." warning 0 {OK}
    return 1
  }
    
  if { $value == "3" } {
    set atmos [ get_variable_value ATMOS ]
    set bl_type [ get_variable_value BL_TYPE ]
    set veg_type [ get_variable_value VEG_TYPE ]
    set tracers [ get_variable_value ATMOS_SR(11) ]
    if { $atmos != "T" } {
      error_message .d {Cross Check} "$help_text: \n\
      Must be running the atmospheric model for Interactive Carbon Cycle." warning 0 {OK}
      return 1
    }
    if { $bl_type != 4 } {
      error_message .d {Cross Check} "$help_text: \n\
      Must be using Boundary Layer for Interactive Carbon Cycle." warning 0 {OK}
      return 1
    }
    if { $veg_type != 2 } {
      error_message .d {Cross Check} "$help_text: \n\
      Must be using Triffid Vegetation for Interactive Carbon Cycle." warning 0 {OK}
      return 1
    }
    if { $tracers == "0A" } {
      error_message .d {Cross Check} "$help_text: \n\
      Must be using Tracer Advection for Interactive Carbon Cycle." warning 0 {OK}
      return 1
    }
  }
  return 0
}
   
