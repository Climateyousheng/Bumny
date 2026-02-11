proc check_user_stash { value var index } {

    #+
    # NAME: check_user_stash 
    # SYNOPSIS: Verification function to check that
    # user-STASHmaster files are in the correct format and the
    # values in the right range. 
    # AUTHOR: MC
    #-
    
    # If there is a blank value, then let inactive checking catch it.
    if [regexp \{\} $value] {return 0}

    # set up a warning index to allow several warning windows.
    set dindex 0

    # Check whole array at one go 
    if {$index!=1} {return 0}

    set splitvar [split $var "_"]
    set model_letter [ lindex $splitvar 1 ] ; # A,O,S,W
    set switch   [ get_variable_value USERPRE_$model_letter ]
    if { $switch != "Y" } {return 0}

    set files    [ get_variable_array USERLST_$model_letter ]
    set id_list  [ get_variable_array MODEL_ID  ]


    set file "[directory_path variables]/STASHsections_$model_letter"
    if {[file readable $file]==0} {
	# unexpected EOF found
	dialog .error "STASH section file error" "The system file \"STASHsections_$model_letter\" does not exist or is unreadable." {} 0 {OK}
	return 1
    }
    set t [open $file r ] 
    set sec_list {}
    while { [gets $t line] >= 0 } {
      set sec [expr [string range $line 0 2] ]
      lappend sec_list $sec
    }
    close $t 
    
    set num_recs 0 ; # count on the total number of records.
    set rec_list {} ; # list of all records

    foreach file $files {
      set icode [ file readable $file ]
      if { $icode == 0 } {
          # unexpected EOF found
          error_message .d {Bad File} "STASHmaster file <$file> does not exists or is not readable " warning 0 {OK}
          return 1
      }
      set sm_rec_item 1000
      set file_id [ open $file r ]
      while { $sm_rec_item > 0 } {
        set rcode [ read_sm_rec $file_id check ]   ; # sets variables called sm_rec_*
        if { $rcode != "OK" } {
          # error reading record.
          set sm_rec_item -1
          error_message .d {Bad File} "user-STASHmaster file <$file> generates the error: $rcode" warning 0 {OK}
          return 1
        } elseif {$sm_rec_item > 0 }  {
           
           incr num_recs
           set rec_element [ format "%d,%d,%d" \
                           $sm_rec_model $sm_rec_sec $sm_rec_item  ] 
           if { [lsearch $rec_list $rec_element ] != -1  } {
              error_message .d {Wrong Model} "user-STASHmaster file <$file> includes an item that has\
              already appeared. $rec_element. \
              See record $sm_rec_name" warning 0 {OK}
              return 1
           }
           lappend rec_list $rec_element

           # is this the right model?
           set model_letter_read [ lindex $id_list [ expr $sm_rec_model - 1 ] ]
           if { $model_letter_read != $model_letter } {
              set right_model [ expr 1 + [lsearch $id_list $model_letter ] ]
              error_message .d {Wrong Model} "user-STASHmaster file <$file> includes items in the wrong\
              model. Model ID is $sm_rec_model. Should be $right_model. See record $sm_rec_name" warning 0 {OK}
              return 1
           }
           
           # is this a valid section?
           if { [lsearch $sec_list $sm_rec_sec ] == -1  } {
              error_message .d {Unknown section} "user-STASHmaster file <$file> includes items in the wrong\
              section: $sm_rec_sec. Available sections are $sec_list.\
              See record $sm_rec_name" warning 0 {OK}
              return 1
           }
          
           # is this a valid item?
           if { $sm_rec_item >  999 } {
              error_message .d {Bad Item} "user-STASHmaster file <$file> includes items with\
              too large an item number: $sm_rec_item. Maximum value is 999.\
              See record $sm_rec_name" warning 0 {OK}
              return 1
           } 
         
           # is this a valid space code
           set list { 0 2 3 4 7 8 9 10 }
           if { [lsearch $list $sm_rec_space ] == -1 } {
              error_message .d {Bad Code} "user-STASHmaster file <$file> includes items with\
              the wrong space code: $sm_rec_space. Valid codes are $list .\
              See record $sm_rec_name" warning 0 {OK}
              return 1
           }
          
           # is the pointer code used correctly.
           if { ( $sm_rec_space  == 7 ) && ( $sm_rec_point  == 0 ) } {
              error_message .d {Bad Code} "user-STASHmaster file <$file> includes  inconsistent\
              items with a space code of 7 and no section-zero-pointer set.\
              See record $sm_rec_name" warning 0 {OK}
              return 1
           }
           if { ( $sm_rec_space  != 7 ) && ( $sm_rec_point  != 0 ) } {
              error_message .d {Bad Code} "user-STASHmaster file <$file> includes  inconsistent\
              items with a space code of other than 7 when the section-zero-pointer is \
              set to $sm_rec_point.\
              See record $sm_rec_name" warning 0 {OK}
              return 1
           }
           if { $sm_rec_point >  999 } {
              error_message .d {Bad Code} "user-STASHmaster file <$file> includes a pointer with\
              too large an item number: $sm_rec_point. Maximum value is 999.\
              See record $sm_rec_name" warning 0 {OK}
              return 1
           } 
          
           # is this a valid time code
           set list { 1 2 3 5 6 7 8 9 10 11 12 13 14 15 16}
           if { [lsearch $list $sm_rec_time ] == -1 } {
              error_message .d {Bad Code} "user-STASHmaster file <$file> includes items with\
              the wrong time code: $sm_rec_time. Valid codes are $list .\
              See record $sm_rec_name" warning 0 {OK}
              return 1
           }
          
           # is this a valid grid code
           set list {  1  2  3  4  5 11 12 13 14 15 17 18 19 21 22 23 25 26 27 28 29 \
                      31 32 36 37 38 39 41 42 43 44 45 46 47 51 \
                      60 62 65 }
           if { [lsearch $list $sm_rec_grid ] == -1 } {
              error_message .d {Bad Code} "user-STASHmaster file <$file> includes items with\
              the wrong grid code: $sm_rec_grid. Valid codes are $list .\
              See record $sm_rec_name" warning 0 {OK}
              return 1
           }
           if { $sm_rec_grid==4 } {
              incr dindex
              error_message .d$dindex {Broken Code} "user-STASHmaster file <$file> includes items with\
              a broken grid code: $sm_rec_grid. This is not supported without first providing a fix to the UM.\
              See record $sm_rec_name" warning 0 {OK}
           }
          
           # is this a valid level code
           set list {  0  1  2  3 4  5  6  7  8  9 10 }
           if { [lsearch $list $sm_rec_levT ] == -1 } {
              error_message .d {Bad Code} "user-STASHmaster file <$file> includes items with\
              the wrong level-type code: $sm_rec_levT. Valid codes are $list .\
              See record $sm_rec_name" warning 0 {OK}
              return 1
           }
          
           # is this a valid first-level code
           set list { -1 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 \
                      21 22 23 30 34 35 36 37 38 39 \
                      40 41 42 43 44 45 46 }
           lappend list  [ expr ( $sm_rec_model * 100) + 1 ]
           lappend list  [ expr ( $sm_rec_model * 100) + 2 ]
           lappend list  [ expr ( $sm_rec_model * 100) + 3 ]
           if { [lsearch $list $sm_rec_levF ] == -1 } {
              error_message .d {Bad Code} "user-STASHmaster file <$file> includes items with\
              the wrong first-level code: $sm_rec_levF. Valid codes are $list .\
              See record $sm_rec_name" warning 0 {OK}
              return 1
           }
          
           # is this a valid last-level code
           if { [lsearch $list $sm_rec_levL ] == -1 } {
              error_message .d {Bad Code} "user-STASHmaster file <$file> includes items with\
              the wrong last-level code: $sm_rec_levL. Valid codes are $list .\
              See record $sm_rec_name" warning 0 {OK}
              return 1
           }
          
           # are level codes consistent.
           if {($sm_rec_levT!=5)&&($sm_rec_levF==-1 || $sm_rec_levL==-1) } {
              error_message .d {Bad Code} "user-STASHmaster file <$file> includes items with\
              a first/last-level codes of -1 but a level type of $sm_rec_levT. Inconsistent.\
              See record $sm_rec_name" warning 0 {OK}
              return 1
           }
           # are level codes consistent.
           if {($sm_rec_levT==5)&&($sm_rec_levF!=-1 || $sm_rec_levL!=-1) } {
              error_message .d {Bad Code} "user-STASHmaster file <$file> includes items with\
              a first/last-level codes not -1 when level type is 5. Inconsistent.\
              See record $sm_rec_name" warning 0 {OK}
              return 1
           }
                     
           # is this a valid pseudo-level code
           set list { 0  1  2  3  4  5  6  7  8  9 10 11}           
           lappend list  [ expr ( $sm_rec_model * 100) + 1 ]
           lappend list  [ expr ( $sm_rec_model * 100) + 2 ]
           lappend list  [ expr ( $sm_rec_model * 100) + 3 ]
           if { [lsearch $list $sm_rec_pseudT ] == -1 } {
              error_message .d {Bad Code} "user-STASHmaster file <$file> includes items with\
              the wrong pseudo-level-type code: $sm_rec_pseudT. Valid codes are $list .\
              See record $sm_rec_name" warning 0 {OK}
              return 1
           }
                     
           # is this a valid first-pseudo-level code
           set list { 0 1 21 22 23 24 25 29 }
           lappend list  [ expr ( $sm_rec_model * 100) + 1 ]
           lappend list  [ expr ( $sm_rec_model * 100) + 2 ]
           lappend list  [ expr ( $sm_rec_model * 100) + 3 ]
           if { [lsearch $list $sm_rec_pseudF ] == -1 } {
              error_message .d {Bad Code} "user-STASHmaster file <$file> includes items with\
              the wrong first-pseudo-level code: $sm_rec_pseudF. Valid codes are $list .\
              See record $sm_rec_name" warning 0 {OK}
              return 1
           }
                     
           # is this a valid last-pseudo-level code
           set list { 0 1 2 3 4 5 6 7 8 9 21 22 23 24 25 29 }
           lappend list  [ expr ( $sm_rec_model * 100) + 1 ]
           lappend list  [ expr ( $sm_rec_model * 100) + 2 ]
           lappend list  [ expr ( $sm_rec_model * 100) + 3 ]
           if { [lsearch $list $sm_rec_pseudF ] == -1 } {
              error_message .d {Bad Code} "user-STASHmaster file <$file> includes items with\
              the wrong last-pseudo-level code: $sm_rec_pseudL. Valid codes are $list .\
              See record $sm_rec_name" warning 0 {OK}
              return 1
           }

           # are pseudo-level codes consistent.
           if {($sm_rec_pseudT!=0)&&($sm_rec_pseudF==0 || $sm_rec_pseudL==0) } {
              error_message .d {Bad Code} "user-STASHmaster file <$file> includes items with\
              a first/last-level codes of 0 but a pseudo-level type of $sm_rec_pseudT. Inconsistent.\
              See record $sm_rec_name" warning 0 {OK}
              return 1
           }
           # are pseudo-level codes consistent.
           if {($sm_rec_pseudT==0)&&($sm_rec_pseudF!=0 || $sm_rec_pseudL!=0) } {
              error_message .d {Bad Code} "user-STASHmaster file <$file> includes items with\
              a first/last-level codes of other than 0 but a pseudo-level type of 0. Inconsistent.\
              See record $sm_rec_name" warning 0 {OK}
              return 1
           }
                     
           # is this a valid levels compression  flag
           set list { 0 1 }
           if { [lsearch $list $sm_rec_levcom ] == -1 } {
              error_message .d {Bad Code} "user-STASHmaster file <$file> includes items with\
              the wrong levels-compression-flag code:$sm_rec_levcom . Valid codes are $list .\
              See record $sm_rec_name" warning 0 {OK}
              return 1
           }

           # is the levels compression flag consistent
           if { ($sm_rec_levcom == 0) &&\
                ( $sm_rec_levT==3 ||  $sm_rec_levT==4 || \
                  $sm_rec_levT==7 ||  $sm_rec_levT==8 ) } {
              error_message .d {Bad Code} "user-STASHmaster file <$file> includes items with\
              levels-compression-flag off for level type $sm_rec_levT. Inconsistent .\
              See record $sm_rec_name" warning 0 {OK}
              return 1
           }

           # is this a valid rotate
           set list { 0 1 }
           if { [lsearch $list $sm_rec_r ] == -1 } {
              error_message .d {Bad Code} "user-STASHmaster file <$file> includes items with\
              the wrong rotate code:$sm_rec_r . Valid codes are $list .\
              See record $sm_rec_name" warning 0 {OK}
              return 1
           }

           # is this a valid data-type
           set list { 1 2 3 }
           if { [lsearch $list $sm_rec_t ] == -1 } {
              error_message .d {Bad Code} "user-STASHmaster file <$file> includes items with\
              the wrong data-type code:$sm_rec_t . Valid codes are $list .\
              See record $sm_rec_name" warning 0 {OK}
              return 1
           }

        } ; # end of else, not end of file
      } ; # end of while line to read for this file.
      close $file_id
    } ; # end of foreach file 
    
    if { $num_recs > 1800 } {
        error_message .d {Too Many} "You have a total of $num_recs records\
        in all the files. The absolute limit is 1800 but this depends
        on how many are replacements." warning 0 {OK}
        return 1
    }

    return 0
}
