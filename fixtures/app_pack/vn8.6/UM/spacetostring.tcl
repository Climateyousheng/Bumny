
# spacetostring
#   Checks if string repersenting variable is numeric value within allowed interval
# Arguments
#   value: Value of input
#   variable: Name of UMUI variable
#   minval: Minimal value
#   maxval: Maxumum value

proc spacetostring {value variable index minval maxval} {

   set var_info [get_variable_info $variable] 
   set help_text [lindex $var_info 10] 

   # If numerical
   set rc [string is double $value]
   if {$rc == 0} {
      error_message .d {Variable check} "$help_text is not a numerical value" warning 0 {OK} 
     return 1 
   }

   if {$value < $minval || $value > $maxval} {
      error_message .d {Variable check} "$help_text is out of range \($minval, $maxval\)" warning 0 {OK} 
     return 1 
   }

  return 0 
}
