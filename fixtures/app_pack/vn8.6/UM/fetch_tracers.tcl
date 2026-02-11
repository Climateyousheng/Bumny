proc fetch_tracers {} {
  # This procedure finds out which set of UKCA tracers is available
  # 

  set doweneed [get_variable_value ATMOS_SR(34)]

  if {$doweneed=="1A"} {
  # form a subset of tracers
  
  set sel_items {}
  
  # diagnostics related to family choice
  set i_ukca_chem   [get_variable_value I_UKCA_CHEM]
  # default to turn all tracers off
  set scheme "None"   
  # set name of scheme based on i_ukca_chem 
  switch $i_ukca_chem {
      0 {
         set scheme "None"
      }
      1 {
         set scheme "AgeAir"
      }
      11 {
         set scheme "StdTrop"
      }
      13 {
         set scheme "RegAirQ"
      }
      50 {
         set scheme "TropIsop"
      }
      51 {
         set scheme "StratTrop"
      }
      52 {
         set scheme "StdStrat"
      }
      default {
         set scheme "None"
      }
  }

  if { [inactive_var L_UKCA_AERCHEM]==0 } {
     set aer_chem [get_variable_value L_UKCA_AERCHEM]
  } else {
     set aer_chem "N"
  }

  set chem_switch "${scheme}_${aer_chem}"

  switch $chem_switch {
      StdTrop_Y {
	  set family_choice [list 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0]
	  lappend family_choice 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	  lappend family_choice 0 0 0 0 0 0 0 0 0 0 1 1 1 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	  lappend family_choice 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	  lappend family_choice 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
      }
      StdTrop_N {
	  set family_choice [list 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0]
	  lappend family_choice 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	  lappend family_choice 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	  lappend family_choice 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	  lappend family_choice 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
      }
      
      RegAirQ_Y {
	  set family_choice [list 1 1 1 1 1 1 1 1 1 1 1 1 0 1 1 1 1 1 0 1 0 1 0 0 0 1 1 1 1 0]
	  lappend family_choice 0 0 0 1 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
	  lappend family_choice 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
	  lappend family_choice 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	  lappend family_choice 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
      }
      RegAirQ_N {
	  set family_choice [list 1 1 1 1 1 1 1 1 1 1 1 1 0 1 1 1 1 1 0 1 0 1 0 0 0 1 1 1 1 0]
	  lappend family_choice 0 0 0 1 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
	  lappend family_choice 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
	  lappend family_choice 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	  lappend family_choice 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
      }
      
      TropIsop_Y {
	  set family_choice [list 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 1 1 1]
	  lappend family_choice 1 1 1 1 1 1 1 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
	  lappend family_choice 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 0 1 1 1 1 1 1 1 1 1 1
	  lappend family_choice 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	  lappend family_choice 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
      }
      TropIsop_N {
	  set family_choice [list 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 1 1 1]
	  lappend family_choice 1 1 1 1 1 1 1 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
	  lappend family_choice 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1
	  lappend family_choice 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	  lappend family_choice 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
      }
      
      StdStrat_Y {    
	  set family_choice [list 1 1 1 0 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
	  lappend family_choice 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 0 1 1 1 0 1 1 1 1 1 1 1 1 1 0
	  lappend family_choice 0 0 0 0 0 0 0 0 0 1 1 1 1 1 0 0 1 1 1 1 1 1 1 0 0 0 0 0 0 0
	  lappend family_choice 0 0 0 1 0 0 0 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	  lappend family_choice 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1
      } 
      StdStrat_N {    
	  set family_choice [list 1 1 1 0 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
	  lappend family_choice 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 0 1 1 1 0 1 1 1 1 1 1 1 1 1 0
	  lappend family_choice 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 1 1 1 1 0 0 0 0 0 0 0
	  lappend family_choice 0 0 0 0 0 0 0 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	  lappend family_choice 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1
      }
      
      StratTrop_Y {    
	  set family_choice [list 1 1 1 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 1 1 1]
	  lappend family_choice 1 1 1 1 1 1 1 1 0 1 1 1 1 1 1 0 1 1 1 0 1 1 1 1 1 1 1 1 1 1
	  lappend family_choice 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
	  lappend family_choice 1 1 0 1 0 0 0 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	  lappend family_choice 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1
      } 
      StratTrop_N {    
	  set family_choice [list 1 1 1 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 1 1 1]
	  lappend family_choice 1 1 1 1 1 1 1 1 0 1 1 1 1 1 1 0 1 1 1 0 1 1 1 1 1 1 1 1 1 1
	  lappend family_choice 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1
	  lappend family_choice 0 0 0 0 0 0 0 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	  lappend family_choice 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1
      } 

      AgeAir_Y {
	  # Not currently available
	  set family_choice [list 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
	  lappend family_choice 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	  lappend family_choice 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	  lappend family_choice 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	  lappend family_choice 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
      }
      AgeAir_N {
	  set family_choice [list 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
	  lappend family_choice 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	  lappend family_choice 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	  lappend family_choice 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	  lappend family_choice 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
      }
      default {
	  set family_choice [list 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
	  lappend family_choice 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	  lappend family_choice 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	  lappend family_choice 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	  lappend family_choice 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
      }
  }
  
  set sel_items $family_choice
  
  if { [inactive_var LUKCAMODE]==0 } { 
      set mode [get_variable_value LUKCAMODE] 
      if {$mode=="Y"} {
         set imodset [get_variable_value IMODESET]
         if {$imodset =="2"} {
          # New list
	  set add_2Y [list 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
	  lappend add_2Y   0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	  lappend add_2Y   0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	  lappend add_2Y   0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 0 1 1 1 1 1 0 1 1
	  lappend add_2Y   1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
          }
#         } else {
#          # Old list
#	  set add_2Y [list 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
#	  lappend add_2Y   0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#	  lappend add_2Y   0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#	  lappend add_2Y   0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
#	  lappend add_2Y   1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#         }
 	 set arr_2(2Y) $add_2Y
      }
  }
  
  set add_schemes [array names arr_2]
  foreach x $add_schemes {
     set work $arr_2($x)
  
     for {set i 0} {$i < 150} {incr i} {
        set a [lindex $sel_items $i]  
        set b [lindex $work $i] 
        if {$a==0 && $b==1} {
           set sel_items [lreplace $sel_items $i $i 1]     
        }
     }
  }

  # extract items available to the temporary table
  set i 1
  set j 1
  
  foreach item $sel_items {
     if {$item==1} {
        set name_tmp [get_variable_value UKCA_TRACER_DEF($i)]
        set val_tmp  [get_variable_value UKCA_TCA($i)]     
        set val_tmp_lbc  [get_variable_value UKCA_LBC($i)]   
        set val_tmp_mkbc [get_variable_value MKBC34_TCA($i)]
        set_variable_value NAME_TMP($j) $name_tmp
        set_variable_value VAL_TMP($j) 1    
        set_variable_value VAL_TMP_LBC($j) $val_tmp_lbc  
        set_variable_value MKBC34_TMP($j) $val_tmp_mkbc
        incr j
     }
     incr i
  }
  incr j -1
  set_variable_value N_UKCA_TMP $j

  } ; # end of if
  
  return 0
}
   
