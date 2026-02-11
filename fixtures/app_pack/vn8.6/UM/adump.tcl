proc adump {value variable index} {
  # This procedure is a verification function for ADUMP.
  #
  if { ($value != "") && ($value != 0) && ($value != 1) && ($value != 2)& ($value != 3) } {
    error_message .d {Incorrect Setting} "Select a valid dumping and meaning option." warning 0 {OK}
    return 1
  }
    
  set cal360 [get_variable_value CAL360 ]
  if { ($value == 3) && ($cal360 == "Y") } {
    error_message .d {Cross Check} "You have chosen \
      'Regular frequency dumps for Gregorian-calendar Meaning'.\
      Elsewhere, you have specified a 360-day calendar. \
      Not consistent." warning 0 {OK}
    return 1
  }
  set nint [ get_variable_value NINT ]

  for { set i 1 } { $i <= $nint } {incr i } {
    set model_on  [ get_variable_value [ get_variable_value MODEL_NAME($i) ] ]
    set partition [ get_variable_value MODEL_PARTITION($i) ]
    if { $model_on=="T" && $partition==$i } {
      set check($i) 1
    } else {
      set check($i) 0
    }
  }
  scan $variable "ADUMP(%d)" i  ; # this sub-model ID.
  if { $check($i) } {
    for { set j 1 } {$j <= $nint } { incr j } {
      if { ($i!=$j) && $check($j) } {
         if { [get_variable_value ADUMP($j)] != $value } {
           error_message .d {Cross Check} "You have chosen \
             'Dumping and meaning options' that are not consistent across\
              active submodels. Correct this." warning 0 {OK}
           return 0
         }
      }
    }
  }


  return 0
}
   
