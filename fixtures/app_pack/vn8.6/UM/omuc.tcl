proc omuc {value variable index} {
  # This procedure is a verification function for NEMOC and CICEC
  #
  if {  ($value != "1") && ($value != "2") && ($value != "3") } {
    error_message .d {Incorrect Setting} "The Compile Option must be specified." warning 0 {OK}
    return 1
  }
    
  if { $value != 1 } {
    set gensuite [ get_variable_value GEN_SUITE ]
    if {  [ get_variable_value GEN_SUITE ] != 0 } {
      error_message .d {No compilation allowed} "For runs that have external control (Generalised suite), \
        you must have an existing executable." warning 0 {OK}
      return 1
    }
  }
  return 0
}
   
