proc chk_iriver {value variable index} {
# checks irivend value

   set irivstrt [get_variable_value IRIVSTRT]
   
   if { ( $value != "-1" ) && ( $value <= $irivstrt ) } {
        error_message .d  {Invalid Value} "'Output Ending' must be either greater than $irivstrt or -1 for end of run." warning 0 {OK}
        return 1     
                
   }

   return 0
}
