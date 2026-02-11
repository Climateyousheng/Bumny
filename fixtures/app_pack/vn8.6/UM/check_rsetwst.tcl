proc check_rsetwst {value variable index} {
  #This check RSETWST in atmos_InFiles_Start
  #It must be less than or equal RSETWEND
  set rsetwend [get_variable_value RSETWEND]

  if {$value > $rsetwend} {
  error_message .d {Out of range} "The start level must be lower \
    than the end level (reset w-component)." warning 0 {OK}
    return 1
  }

  return 0
}
