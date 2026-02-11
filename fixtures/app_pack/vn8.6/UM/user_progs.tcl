proc user_progs { sub_model } {
  set model_id [ get_variable_value MODEL_ID($sub_model) ] ; # A,O,S,W
  set switch   [ get_variable_value USERPRE_$model_id ]
  set files    [ get_variable_array USERLST_$model_id ]
  set n_usrp   [ get_variable_value N_USRP ]
  set prog_count 0
  set item_list {}
  set name_list {}
  if { $switch == "Y" } {
    foreach file $files {
      set icode [ file readable $file ]
      if { $icode == 0 } {
          # unexpected EOF found
          error "Stopping: STASHmaster file <$file> does not exists or is not readable"
          set item 0
          return 0
      }
      set item 1
      set file_id [ open $file r ]
      while { $item > 0 } {
        set rcode [ read_sm_rec $file_id nocheck ]   ; # sets variables called sm_rec_*
        if { $rcode != "OK" } {
          # unexpected EOF found
          error "Unexpected error in STASHmaster file: $file. Message is: $rcode "
          set item -1
        } else {
           set mmm $sm_rec_model
           set sec $sm_rec_sec
           set item $sm_rec_item
           set name $sm_rec_name
           set sp  $sm_rec_space
           if { $mmm != $sub_model  &&  $item>0  } {
               error "Unexpected sub-model ID <$mmm> found in preSTASmaster \
                      file <$file> for record <$mmm,$sec,$item,$name> "
           }
           
           # Check and add prognostics from Section 0
           
           if { $sec==0 && $item>0  &&  ($sp != 9) && ($sp != 10) } {
             # prognostic that needs to be innitialised.
             # Space code of 9 is for stuff like PExner & so is excluded as not in recon.
             # Space code of 10 is for stuff like ICE-edge & so is excluded as not in recon.
             if {$sp == 0 && $item < 341 && $item > 300} {
                # ILP To allow records with space code == 0 for items 301-340
                # then OK
             } elseif { $sp != 2    &&   $sp != 3   &&  $sp != 8  } {
                  error "Unexpected space code <$sp> in preSTASHmaster file \
                         <$file> for record <$mmm,$sec,$item,$name> "
                  set item -1
             }
             if { [ lsearch $item_list $item ] == -1 } {
                lappend item_list $item  
                lappend name_list $name  
             } else {
                error "Item <$item> repeated in <$file> for record <$mmm,$sec,$item,$name>. "
                set item 0 
             }
             incr prog_count 
             if { $prog_count > $n_usrp } {
                  error "Too many user prognostics, Maximum number is $n_usrp "
                  set item 0
             }
             if { $item > 0 } {
               set_variable_value USRP_ITEM($prog_count) $item  
               set_variable_value USRP_NAME($prog_count) $name  
             }           
           } ; # end of if prognostic for Section 0
           
           # Check and add prognostics from Section 33
                    
             if { $sec==33 && $item>0 } {

             set concat_item 33000
             set len [string length $item]
             set start [expr 5 - $len]
             set concat_item [string replace $concat_item $start 4 $item]
                    
             if { [ lsearch $item_list $concat_item ] == -1 } {
                lappend item_list $concat_item  
                lappend name_list $name  
             } else {
                error "Item <$item> repeated in <$file> for record <$mmm,$sec,$item,$name>. "
                set item 0 
             }
             incr prog_count 
          
             if { $prog_count > $n_usrp } {
                  error "Too many user prognostics, Maximum number is $n_usrp "
                  set item 0
             }
             if { $item > 0 } {
               set_variable_value USRP_ITEM($prog_count) $item  
               set_variable_value USRP_NAME($prog_count) $name  
             }           
           } ; # end of if prognostic for Section 33
           
           # Check and add prognostics from Section 34

             if { $sec==34 && $item>0 } {

             set concat_item 34000
             set len [string length $item]
             set start [expr 5 - $len]
             set concat_item [string replace $concat_item $start 4 $item]
                    
             if { [ lsearch $item_list $concat_item ] == -1 } {
                lappend item_list $concat_item  
                lappend name_list $name  
             } else {
                error "Item <$item> repeated in <$file> for record <$mmm,$sec,$item,$name>. "
                set item 0 
             }
             incr prog_count 
             if { $prog_count > $n_usrp } {
                  error "Too many user prognostics, Maximum number is $n_usrp "
                  set item 0
             }
             if { $item > 0 } {
               set_variable_value USRP_ITEM($prog_count) $item  
               set_variable_value USRP_NAME($prog_count) $name  
             }           
           } ; # end of if prognostic for Section 34
        } ; # end of else, not end of file
      } ; # end of while line to read for this file.
      close $file_id
    } ; # end of foreach file 
  } ; # end if  for "switch "
   set_variable_value USRP_COUNT($sub_model) $prog_count 
   set_variable_array USRP_ITEM $item_list 
   set_variable_array USRP_NAME $name_list  
}
