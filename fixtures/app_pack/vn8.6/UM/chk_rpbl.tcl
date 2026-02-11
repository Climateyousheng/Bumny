proc chk_rpbl {value variable index} {
    # Checking min/max values of BL parameters table (Section 35)

    set var_info [get_variable_info $variable]
    set help_text [lindex $var_info 10]
    set param [get_variable_value RPBL_PARAMS($index)]
    set min 0
    set max 0

    if {$help_text=="Default Value"} {
       set min [get_variable_value RPBL_MINS($index)]
       set max [get_variable_value RPBL_MAXES($index)]
    } else {

       if { $index == 1 } {
          # Neutral mixing length
          if {$help_text=="Maximum"} { 
             set min 0.01
             set max 1.0
          } else {
             set min 0.001
             set max 0.1
          }

       } elseif { $index == 2 } {
          # Flux profile parameter
          if {$help_text=="Maximum"} { 
             set min 1
             set max 50
          } else {
             set min 0.1
	     set max [get_variable_value RPBL_MAXES(2)]
          }

       } elseif { $index == 3 } {
          # Charnock Parameter
             set min 0.0
             set max 1.0

       } elseif { $index == 4 } {
          # Minimum mixing length
          set min 1.0
          set max 1000.0

       } elseif { $index == 5 } {
          # Critical Richardson number
          set min 0.1
          set max 2.0

       } elseif { $index == 6 } {
          # Entrainment parameter A1
          set min 0.01
          set max 1.0

       } elseif { $index == 7 } {
          # Parameter to control cloud-top diffusion
          set min 0.1 
          set max 10.0
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
