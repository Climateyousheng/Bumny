proc chk_icvdiag {value variable index} {
# checks icvdiag value

   set conv_sec [get_variable_value ATMOS_SR(5)]
   set max_v 10
   set min_v 0
   
   if {$conv_sec == "5A" || $conv_sec == "6A"} {
      set min_v 1
   }

   if {$conv_sec == "5A" || $conv_sec == "6A"} {
      set max_v 20
   }
   
   if { ($conv_sec=="4A"||$conv_sec=="5A"||$conv_sec=="6A")&&($value > $max_v||$value < $min_v)} {
        set var_info [get_variable_info $variable] 
        set help_text [lindex $var_info 10] 
        
        error_message .d  {Invalid Value} "'$help_text' must be within interval\
        $min_v,$max_v" warning 0 {OK}
        return 1     
                
   }

   return 0
}
