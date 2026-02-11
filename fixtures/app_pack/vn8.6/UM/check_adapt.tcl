proc check_adapt {value variable index} {

# check detrainment scheme

   set msg "Invalid detrainment scheme options for chosen version of convection scheme. \nPlease check detrainment scheme choice" 
   set atm5 [get_variable_value ATMOS_SR(5)]
   if {$atm5=="6A" && !($value =="0" || $value =="7" || $value =="8")} {
       error_message .d  {Invalid Value} $msg warning 0 {OK}
            return 1
   }
 
   return 0
} 
