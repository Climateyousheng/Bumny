proc chk_rpgwd {value variable index} {
    # Checking min/max values of Gravity Wave Drag parameters table (Section 35)

    set var_info [get_variable_info $variable]
    set help_text [lindex $var_info 10]
    set val [lindex $value [expr $index-1]]
    set param [get_variable_value RPGWD_PARAMS($index)]
    set def [get_variable_value RPGWD_DEFS($index)]
    set min 0
    set max 0
    set msg ""

    if { $index == 1 } {
       # Critical Froude number
       set min 1.0
       set msg "set on the Section 6: Gravity Wave Drag panel"
       if {$help_text=="Maximum"} { 
          set max 10.0
       } else {
          set max [get_variable_value RPGWD_MAXES($index)]
       }

    } elseif { $index == 2 } {
       # Gravity Wave constant
       set min 1.0
       set msg "set on the Section 6: Gravity Wave Drag panel"
       if {$help_text=="Maximum"} { 
          set max 999999.0
       } else {
          set max [get_variable_value RPGWD_MAXES($index)]
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
