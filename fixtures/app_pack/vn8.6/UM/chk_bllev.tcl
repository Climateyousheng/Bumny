proc chk_bllev {value variable index} {

  # This procedure checks consistency between ENDLEV_BL and NBLLV
  
   set var_info [get_variable_info $variable]
   set help_text [lindex $var_info 10]

   set nlevsa [get_variable_value NLEVSA]
   set nbllv [get_variable_value NBLLV]
   set n_range [get_variable_value NBLLV_BL]
   set arr_val [get_variable_array ENDLEV_BL]
   set last_lev [get_variable_value ENDLEV_BL($n_range)]
 
   if {($last_lev > 999) || ($last_lev < 1)} {
       error_message .d {Incorrect Setting} "The last element '$help_text'\
       in the table 'Time Weights' should be between 1 and $nlevsa" warning 0 {OK}
       return 1   
   }
 
   if {$last_lev != $nbllv} {
       error_message .d {Incorrect Setting} "The last element '$help_text'\
       in the table 'Time Weights' should be equal to the number of boundary \
       layer levels $nbllv" warning 0 {OK}
       return 1   
   }
  
   return 0 
}
