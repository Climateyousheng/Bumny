proc checkadvhigh {advhigh variable index} {
  set myvalue [lindex $advhigh 0]
  if {$myvalue==4} {
     error_message .d {RANGE} "The chosen scheme is not available for theta advection" warning 0 {OK}
      return 1
  } 
  return 0
}
