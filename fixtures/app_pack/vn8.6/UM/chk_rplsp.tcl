proc chk_rplsp {value variable index} {
    # Checking min/max values of Large Scale Precipitation parameters table (Section 35)

    set var_info [get_variable_info $variable]
    set help_text [lindex $var_info 10]
    set param [get_variable_value RPLSP_PARAMS($index)]
    set min 0
    set max 0

    if {$help_text=="Default Value"} {
       set min [get_variable_value RPLSP_MINS($index)]
       set max [get_variable_value RPLSP_MAXES($index)]

    } else {
       if { $index == 1 } {
          # Critical humidity value at level 3
          set min 0.700
          if {$help_text=="Maximum"} { 
             set max 0.975
          } else {
             set max [get_variable_value RPLSP_MAXES($index)]
          }

       } elseif { $index == 2 } {
          # Ice fall speed multiplication factor
          set min 0.1
          if {$help_text=="Maximum"} { 
             set max 5.0
          } else {
	     set max [get_variable_value RPLSP_MAXES($index)]
          }
       }
    }

    set val [lindex $value [expr $index-1] ]
    if {$val < $min || $val > $max } {
       error_message .d  {Invalid Value} "The entry '$param $help_text'\
       ($val) must be within \[$min $max\] interval" warning 0 {OK}
       return 1    
    }

   return 0

}
