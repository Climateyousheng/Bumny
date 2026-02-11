proc chk_rpconv {value variable index} {
    # Checking min/max values of Convection parameters table (Section 35)

    set var_info [get_variable_info $variable]
    set help_text [lindex $var_info 10]
    set val [lindex $value [expr $index-1]]
    set param [get_variable_value RPCV_PARAMS($index)]
    set def [get_variable_value RPCV_DEFS($index)]
    set min 0
    set max 0
    set msg ""

    if { $index == 1 } {
       # Timescale (seconds) for CAPE closure
       set min 100
       set msg "set on the Section 5: Convection panel"
       if {$help_text=="Maximum"} { 
           set max 10000
       } else {
           set max [get_variable_value RPCV_MAXES($index)]
       }

    } elseif { $index == 2 } {
       # Entrainment rate coefficient
       set min 1
       set msg "hardwired in the code"
       if {$help_text=="Maximum"} { 
          set max 10
       } else {
          set max [get_variable_value RPCV_MAXES($index)]
       }
    }

    if {$val < $min || $val > $max } {
       error_message .d  {Invalid Value} "The entry '$param $help_text'\
       ($val) must be within \[$min $max\] interval" warning 0 {OK}
       return 1    
    }

    if {($help_text=="Maximum" && $val < $def) ||($help_text=="Minimum" && $val > $def) } {
       error_message .d  {Invalid Value} "The default value for '$param'\
       lies outside the Min-Max range. The default value is $msg."  warning 0 {OK}
       return 0    
    }

   return 0

}
