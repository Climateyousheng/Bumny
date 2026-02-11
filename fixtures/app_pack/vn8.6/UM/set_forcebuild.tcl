proc set_forcebuild {} {
# Checks and set force build option to correct value

   set lfcm_prebuild [get_variable_value LFCM_PREBUILD]
   set lfull_ext [get_variable_value LFULL_BLD]
   
   if {$lfcm_prebuild=="Y" && $lfull_ext=="Y"} {
      set_variable_value LFULL_BLD "N"
   }
}
