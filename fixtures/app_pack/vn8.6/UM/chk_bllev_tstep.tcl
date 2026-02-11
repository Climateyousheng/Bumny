proc chk_bllev_tstep {value variable index} {

  # This procedure checks consistency between vertical boundary levels 
  # and time step table
  
   set var_info [get_variable_info $variable]
   set help_text [lindex $var_info 10]

   set max_bllev [get_variable_value NLEVSA]
   set tablen [get_variable_value NBLLV_BL]
   
   set levs 0
   set strtrange [get_variable_array STARTLEV_BL]
   set endrange [get_variable_array ENDLEV_BL]
   for { set i 0 } { $i < $tablen } { incr i } {
      set start [lindex $strtrange $i]
      set end [lindex $endrange $i]
      set levs [expr { $levs + $end - $start + 1 }]
   }
   
   if {($value > $max_bllev) || ($value < 1)} {
       error_message .d {Incorrect Setting} "The maximum number of '$help_text'\
       should be between 1 and $max_bllev" warning 0 {OK}
       return 1   
   }
 
   if {$value != $levs} {
       error_message .d {Incorrect Setting} "The '$help_text' $value\
       inconsistent with $tablen levels entered in the boundary layer \
       'Time Weights' table " warning 0 {OK}
       return 1   
   }
  
   return 0 
}
