# This file contains functions to read items from the STASH master file,
# and profile definitions from the Basis database.
# 

# Proc : read the STASH_Master file and load it up into array stmsta.
#        Load the section table into st_sec_name with a list on sects in st_sections.
# 

proc read_stash {warning_flag mNumber} {

    #+
    # TREE: experiment_instance navigation create_window stash read_stash
    #-

    global stmsta st_sections st_sec_name st_items

    set mLetter [modnumber_to_letter $mNumber]    


    # First check the userSTASH files
    if {[get_variable_value USERPRE_$mLetter]=="Y"} {
        # puts "Yes, reading"
        foreach file [get_variable_array USERLST_$mLetter] {
            # puts "file $file"
	    if {[file readable $file]==0} {
                # unexpected EOF found
		dialog .error "File error" "preSTASHmaster file \"$file\" does not exist or is unreadable." {} 0 {OK}
	        return 1
	     }
	 }
     }
    #--------------------------------------------------------------------------
    # Set STASH SECTIONS ARRAY
    #
    set file "[directory_path variables]/STASHsections_$mLetter"
    if {[file readable $file]==0} {
	# unexpected EOF found
	dialog .error "STASH section file error" "The system file \"STASHsections_$mLetter\" does not exist or is unreadable." {} 0 {OK}
	return 1
    }
    set t [open $file r ]
    set_stmsec_info $t $mNumber

    #--------------------------------------------------------------------------
    # Set STASH MASTER array
    #
    set last_sec -1

    set file "[directory_path variables]/STASHmaster_$mLetter"
    if {[ file readable $file ]==0} {
	# unexpected EOF found
	dialog .error "File error" "The system file \"STASHmaster_$mLetter\" does not exist or is unreadable." {} 0 {OK}
	return 1
    }
    set f [open $file r]

    set retc1 [ gets $f line1 ]
    set retc2 [ gets $f line2 ]
    set retc3 [ gets $f line3 ]
    if { $retc1==-1 || $retc2==-1 || $retc3==-1 } {
       # unexpected EOF found
       error "Stopping: unexpected end of file on STASHmaster file reading\
              header of file <STASHmaster_$mLetter>."
       return -1
    }

    set retc [ scan $line1 "H1| SUBMODEL_NUMBER=%d" subm_file ]
    if { $retc != 1 } {
       # unexpected EOF found
       error "Stopping: unable to scan header of STASHmaster file\
       <STASHmaster_$mLetter> on line <$line1>."
       return -1
    }

    set isubm_file [get_variable_value MODEL_ID($subm_file)]
    if { $isubm_file != $mLetter } {
       # unexpected EOF found
       error "Stopping: wrong submodel in STASHmaster file\
       <STASHmaster_$mLetter>."
       return -1
    }

    set retc [ scan $line3 "H3| UM_VERSION=%s" um_version ]
    if { $retc != 1 } {
       # unexpected EOF found
       error "Stopping: unable to scan header of STASHmaster file\
       <STASHmaster_$mLetter> on line <$line3>."
       return -1
    }
    set version [get_variable_value VERSION ]
    if { $um_version != $version } {
       # unexpected EOF found
       error "Stopping: wrong version <$um_version>  in STASHmaster file\
       <STASHmaster_$mLetter>."
       return -1
    }

    # loop over reading records
    set item 1
    while { ($retc >= 0) && ($item > 0) } {
        set retc [ read_sm_rec $f nocheck ] ; # read the next record. Set vars sm_rec_*
        if { $retc != "OK" } { 
           error "Error reading STASHmaster file <STASHmaster_$mLetter>.\
           message <$retc>."
           return -1 
        }
	set sec $sm_rec_sec
	set item $sm_rec_item
	set mmm $sm_rec_model
	# Read the STASH Master file into the stmsta array. Cast types as 
	# appropriate.
        if { ($item <= 0) || ($sec < 0) } { break }
	# if we have a new section...
	lappend st_items($mNumber,$sec) $item
        if { $mmm != $mNumber } {
                 error "Stopping: Inconsistent model number in system-STASHmaster file \
                 <STASHmaster_$mLetter>. \
                 <$mmm,$sec,$item,$sm_rec_name>"
                 return -1
        }
        if { [lsearch $st_sections($mNumber) $sec] == -1 } {
                 error "Stopping: Unknown section number <$sec> in system-STASHmaster file <STASHmaster_$mLetter>."
                 return -1
        }
	if {[array names stmsta $mmm,$sec,$item,srce] == "$mmm,$sec,$item,srce"} {
	    error "Stopping: Duplicate item in <STASHmaster_$mLetter> Model $mmm Section $sec Item $item"
	}
        set stmsta($mmm,$sec,$item,srce) 1
        set stmsta($mmm,$sec,$item,mmm) $sm_rec_model
        set stmsta($mmm,$sec,$item,sec) $sm_rec_sec
        set stmsta($mmm,$sec,$item,item) $sm_rec_item
        set stmsta($mmm,$sec,$item,name) $sm_rec_name
        set stmsta($mmm,$sec,$item,sp) $sm_rec_space
        set stmsta($mmm,$sec,$item,ptr) $sm_rec_point
        set stmsta($mmm,$sec,$item,ti) $sm_rec_time
        set stmsta($mmm,$sec,$item,gr) $sm_rec_grid
        set stmsta($mmm,$sec,$item,lv) $sm_rec_levT
        set stmsta($mmm,$sec,$item,lb) $sm_rec_levF
        set stmsta($mmm,$sec,$item,lt) $sm_rec_levL
        set stmsta($mmm,$sec,$item,pt) $sm_rec_pseudT
        set stmsta($mmm,$sec,$item,pf) $sm_rec_pseudF
        set stmsta($mmm,$sec,$item,pl) $sm_rec_pseudL
        set stmsta($mmm,$sec,$item,lf) $sm_rec_levcom
        set stmsta($mmm,$sec,$item,mask) $sm_rec_version
        set stmsta($mmm,$sec,$item,op_code) $sm_rec_option
        set stmsta($mmm,$sec,$item,halo) $sm_rec_halo
    }
    #--------------------------------------------------------------------------
    # Set USER diagnostics in stmsta array.
    #
}

proc readUserStash {mNumber warning_flag} {
    global stmsta st_sections st_sec_name st_items
    
    set mLetter [modnumber_to_letter $mNumber]    

    if {[get_variable_value USERPRE_$mLetter]=="Y"} {
        # puts "Yes, reading"
        foreach file [get_variable_array USERLST_$mLetter] {
            # puts "file $file"
	     set f [open "$file" r]
             set retc OK
             set sm_rec_item 1000
	     while { ($retc == "OK") && ($sm_rec_item > 0) } {
                 set retc [ read_sm_rec $f nocheck ] ; # read the next record. Set vars sm_rec_*
                 if { $retc != "OK" } { 
                    error "Error reading user-STASHmaster file <$file>.\
                    message <$retc>."
                    return -1 
                 }
	         set sec $sm_rec_sec
	         set item $sm_rec_item
	         set mmm $sm_rec_model
                 # puts "record $mmm,$sec,$item"
                 if { ($item <= 0) || ($sec < 0) } { break }  ; # END OF FILE REACHED
                 if { $mmm != $mNumber } {
                    error "Stopping: Inconsistent model number in user-STASHmaster file, $file.\
                    <$mmm,$sec,$item,$sm_rec_name>"
                    return -1
                 }
	         if { [info exists stmsta($mmm,$sec,$item,srce)] } {
                    # puts "Already exisis"
                    set source $stmsta($mmm,$sec,$item,srce)
                 } else {
                    # puts "New"
                    set source 0
                 }
                 if { $source == 2 } {
                      # error, in previous stashmaster
		      dialog .error "Multiple user diagnostics/prognostics" "You have more than one entry in your preSTASH files for user diagnostic /prognostic ($sec,$item). The first instance of the diagnostic is now being used. You should exit from this job and edit your preSTASH files to remove duplicate entries." {} 0 {OK}
                 } else {
                     # puts "Adding record"
                     # no error, add the record.
	             if {$source==1} {
                        # warning, was in stash master
		        lappend warnings "($mmm,$sec,$item) from preSTASH file: \"$file\""
                     } elseif {$source==0} {
                        # brand new record
                        if { [lsearch $st_sections($mNumber) $sec] == -1 } {
                           # new section
                           lappend st_sections($mNumber) $sec
                            set st_sec_name($mNumber,$sec) "Undefined section <$sec> from user-STASHmaster"
                        }
		        lappend st_items($mNumber,$sec) $item
                        # puts "Adding record st_items($mNumber,$sec)=$st_items($mNumber,$sec)"
                     }
                     set stmsta($mmm,$sec,$item,srce) 2
                     set stmsta($mmm,$sec,$item,mmm) $sm_rec_model
                     set stmsta($mmm,$sec,$item,sec) $sm_rec_sec
                     set stmsta($mmm,$sec,$item,item) $sm_rec_item
                     set stmsta($mmm,$sec,$item,name) $sm_rec_name
                     set stmsta($mmm,$sec,$item,sp) $sm_rec_space
                     set stmsta($mmm,$sec,$item,ptr) $sm_rec_point
                     set stmsta($mmm,$sec,$item,ti) $sm_rec_time
                     set stmsta($mmm,$sec,$item,gr) $sm_rec_grid
                     set stmsta($mmm,$sec,$item,lv) $sm_rec_levT
                     set stmsta($mmm,$sec,$item,lb) $sm_rec_levF
                     set stmsta($mmm,$sec,$item,lt) $sm_rec_levL
                     set stmsta($mmm,$sec,$item,pt) $sm_rec_pseudT
                     set stmsta($mmm,$sec,$item,pf) $sm_rec_pseudF
                     set stmsta($mmm,$sec,$item,pl) $sm_rec_pseudL
                     set stmsta($mmm,$sec,$item,lf) $sm_rec_levcom
                     set stmsta($mmm,$sec,$item,mask) $sm_rec_version
                     set stmsta($mmm,$sec,$item,op_code) $sm_rec_option
		     set stmsta($mmm,$sec,$item,halo) $sm_rec_halo
                 }
             }
	}
    }
    if {([info exists warnings]) && ($warning_flag == 1)} {print_warnings $warnings}
    return 0
}

proc read_first_line {f} {
    # This ignores any leading comments that have "#" as the first char
    # and returns the first none comment line.
    set line "#"
    while {[regexp "^#.*" $line]==1} {
	if {[gets $f line]==-1} {
            # unexpected EOF found
            dialog .error "File error" "Unexpected EOF in file: \"$file\"" {} 0 {OK}
	    return 1
	}
    }
    return $line
}

proc read_next_line1 {f file} {
    gets $f xx
    gets $f line1
    return $line1
}



proc set_stmsec_info {t mNumber} {
    
    global st_sec_name st_sections st_items
    
    set st_sections($mNumber) {}
    # read in the section titles.
    while { [gets $t line] >= 0 } {
      	set sec [expr [string range $line 0 2] ]
        set st_sec_name($mNumber,$sec) [string range $line 3 end]
        lappend st_sections($mNumber) $sec
        set st_items($mNumber,$sec) {}
    }
    set st_sections($mNumber) [ lsort -integer  $st_sections($mNumber) ]

}

proc print_warnings {messages} {

    global font_butons

    catch {destroy .warnings}
    toplevel .warnings
    wm title .warnings "Warnings for user diagnostics"

# Messages
    label .warnings.msg1 -foreground red \
	    -text "The following user diagnostics have overwritten system diagnostics:" \
        -font $font_butons
    label .warnings.msg2 \
	    -text "If you change the user diagnostics/prognostics while editing this job, you will need to reload" \
        -font $font_butons
    label .warnings.msg3 \
	    -text "the stash master list in the stash window for the changes to take effect. The complete stash master" \
        -font $font_butons
    label .warnings.msg4 \
	    -text "list is usually only loaded once during each job edit when the stash window is first entered. \n" \
        -font $font_butons
        
    pack .warnings.msg1 -side top -padx 5 -pady 10 -anchor w
    pack .warnings.msg2 -side top -padx 5 -anchor w
    pack .warnings.msg3 -side top -padx 5 -anchor w
    pack .warnings.msg4 -side top -padx 5 -anchor w

# Listbox and scrollbars
   listbox .warnings.lb -height 20  -width 100 -relief groove \
      -xscrollcommand ".warnings.hscroll_1 set" \
      -yscrollcommand ".warnings.vscroll_1 set"

    set len [llength $messages]
    for  {set i 0} {$i < $len} {incr i} {
       set u_row "         [lindex $messages $i]        " 
      .warnings.lb insert end $u_row
    }
    
# Pack listbox
   scrollbar .warnings.hscroll_1 -command ".warnings.lb xview" -orient horizontal
   scrollbar .warnings.vscroll_1 -command ".warnings.lb yview" -orient vertical

   pack .warnings.hscroll_1 -side bottom -fill x
   pack .warnings.vscroll_1 -side right  -fill y

   pack .warnings.lb 
   
# OK button       
    # Button OK
    button .warnings.ok -text "Continue" -command {set okflag "ok"} \
	    -font $font_butons
    pack .warnings.ok -side bottom -padx 5 -pady 10
    bind_ok .warnings .warnings.ok

    tkwait variable okflag
    catch {destroy .warnings}
}
