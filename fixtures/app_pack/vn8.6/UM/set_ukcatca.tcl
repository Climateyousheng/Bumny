proc set_ukcatca {} {
  # This procedure copies values from temporary table to UKCA_TCA array
  # and from VAL_TMP_LBC to UKCA_LBC array


  set arr_len [get_variable_value N_UKCATRAC]
  set list {}
  for {set i 0} {$i < $arr_len} {incr i} {
     lappend list 0
  } 

  # Initialise arrays before copying tmp values into them
  set doweneed_tca [get_variable_value ATMOS_SR(34)]
  if {$doweneed_tca=="1A"} {
     set_variable_array UKCA_TCA $list
  }

  set atm37 [get_variable_value ATMOS_SR(37)]
  set ocaaa [get_variable_value OCAAA]
  if {$atm37=="1A" && $ocaaa=="2"} {
     set doweneed_lbc 1
     set_variable_array UKCA_LBC $list
  } else {
     set doweneed_lbc ""
  }
  set doweneed_mkbc [get_variable_value IMKBC]
  if {$doweneed_mkbc=="1"} {
     set_variable_array MKBC34_TCA $list
  }
 
  set tab_len [get_variable_value N_UKCA_TMP]
  for {set i 1} {$i <= $tab_len} {incr i} {
     set name_tmp [get_variable_value NAME_TMP($i)]
     set pos [string first ( $name_tmp]
     set number [string range $name_tmp 0 [expr $pos-1]]
     # UKCA_TCA
     if { $doweneed_tca=="1A" } {
       set val_tmp  [get_variable_value VAL_TMP($i)]
       set_variable_value UKCA_TCA($number) $val_tmp
     }
     if { $doweneed_lbc==1 } {
     # UKCA_LBC
        set val_tmp  [get_variable_value VAL_TMP_LBC($i)]
        set_variable_value UKCA_LBC($number) $val_tmp
     }
     if { $doweneed_mkbc=="1" } {
     #UKCA_MKBC
        set val_tmp  [get_variable_value MKBC34_TMP($i)]
        set_variable_value MKBC34_TCA($number) $val_tmp
     }
  }
   
  # Additional warning that LBC tracers cannot be used with the global model
    set gmodel [get_variable_value OCAAA]
    set lbc [get_variable_value ATMOS_SR(37)]
    
    if {$gmodel!=2 && $lbc=="1A"} {
        # Warning to switch off LBC tracers
	error_message .d {Invalid choice} "LBC tracers cannot be used with the global model. \
	              Please switch off UKCA LBC tracers (Section 37)" warning 0 {OK}
        return 1
    }
      
  return 0
}
   
