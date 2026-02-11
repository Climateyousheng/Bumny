# diagInstance :
#   Array dimensioned by model number: diagInstance($model_number,<Object>)
#   where <Object> can be:
#  SecRoot  : Root name of the "Sections" Plb table
#  DiagRoot : Root name of the "Diagnostics" Plb table
#  Window : Name of the window holding the main STASH table
#  Frame : Outer frame (used for identifying status_line)
#  CurrentSection : Section number currently selected from Section 
#                   table, whose diagnostics are displayed in 
#                   diagnostic table.

# loadNewDiags
#   Create panel that allows new diagnostics to be added to selection
# Arguments
#   mNumber : Model id number

proc loadNewDiags {mNumber} {

    global fonts
    global st_sec_name st_sections
    global diagInstance

    set w .add_diags_$mNumber
    if [winfo exists $w] { 
	wm iconify $w 
	wm deiconify $w 
	return
    }

    toplevel $w   
    wm withdraw $w 
    wm title $w "Available Diagnostics."

    # Put the panel onto a scrolling canvas
    set parent $w.f
    
    # Make max size fractionally smaller than screen size
    # If same size is set, large windows get an extra resized 
    # causes unneeded scrollbar
    set maxX [int [expr .99* [winfo screenwidth .]]] 
    set maxY [int [expr .99*[winfo screenheight .]]]
    set win [swSetFrame $parent $maxX $maxY]

    label $win.t -text "New Diagnostics." -foreground black
    pack $win.t -side top

    frame $win.buttons
    button $win.buttons.cancel \
	    -text "Cancel" \
	    -command "quitDiag $mNumber" 
    pack $win.buttons.cancel -side right -padx 25 -pady 5
    pack $win.buttons -side top -padx 5 -pady 5	

    # Fill in the table from the section array.
    foreach sec $st_sections($mNumber) {
	lappend secs $sec
	lappend names $st_sec_name($mNumber,$sec)
    }

    # Section Selection Table 
    set s sec$mNumber

    pack [frame $win.$s]

    set sTable $win.$s.t
    set diagInstance($mNumber,SecRoot) $sTable

    Plb_Make $sTable -numcols 2 -showrows 10 \
	    -title "Select Section Number (Double Click)" -returnedit 0 \
	    -columnheadings [list "Section Number" "Section Name"] \
	    -columnwidths [list 20 50] \
	    -columnlists [list $secs $names] \
	    -font $fonts(STASHTable)

    pack $sTable

    # Add bindings which get diagnostic list relating to a section
    # $mNumber will be one of the arguments to the procedure
    plbMethod $sTable BindColumn 1 getSection space $mNumber
    plbMethod $sTable BindColumn 1 getSection Double-1 $mNumber
    set d diag$mNumber
    # This is a permanent "placer" for the diagnostic table
    pack [frame $win.$d]

    # Save the names of the various widgets relating to the 
    # diagnostic window
    set diagInstance($mNumber,DiagRoot) $win.$d.t
    set diagInstance($mNumber,Frame) $win.$d
    set diagInstance($mNumber,Window) $w

    # Add a status line to the window
    create_status_line $win.$d $fonts(lines)
    PlbSetSelectedItem $sTable 1

    # Initialise the diagnostic table with items relating to the
    # section listed on the first line of the sections table
    # (ie "prognostics at the end of timestep")
    getSection $sTable 0 0 $mNumber

    # To resise window    
    update idletasks
    wm deiconify $w
    
}

# getSection
#   Gets a list of diagnostics relating to a particular section and
#   displays them on a table. Initialises table if not already created
# Arguments
#   sRoot : Root name of STASH sections table object
#   colNo,rowNo : Location of current selected position
#   mNumber : 1 for atmos, 2 for ocean etc
# Method
#   Procedure is bound to the STASH sections table, so it is called 
#   with all the listed arguments

proc getSection {sRoot colNo rowNo mNumber} {
    global st_sections st_items diagInstance
    global stmsta fonts
    global lst_data flag_mod_sec

    set dTable $diagInstance($mNumber,DiagRoot)

    # Set up Diagnostic Selection Table 
    if {[info commands $dTable] == "$dTable"} {
	# Clear table if it already exists
	plbMethod $dTable ClearTable
    } else {
	# Otherwise create it

	Plb_Make $dTable -numcols 6 -showrows 12 \
		-title "Select Diagnostic to Add." -returnedit 0 \
		-columnheadings [list "Section" "Item" \
		"Diagnostic Name. Double click to add" "Help Available ?" \
		"Available" "User/System"] \
		-columnwidths [list 7 7 40 15 12 12] \
		-font $fonts(STASHTable)

	pack $dTable
	# Bind to callback commands
	plbMethod $dTable BindColumn 3 helpDiag Double-1 $mNumber
	plbMethod $dTable BindColumn 3 helpDiag space    $mNumber
	plbMethod $dTable BindColumn 2 addDiag Double-1 $mNumber
	plbMethod $dTable BindColumn 2 addDiag space    $mNumber
    }

    # Create a list of column contents. One row per diagnostic
    set section [lindex $st_sections($mNumber) $rowNo]
    set diagInstance($mNumber,CurrentSection) $section
    
    # ILP Read concatenated diagnostics help file for selected section
    set flag_mod_sec 0
    set fl_patch [format "diag_STASH_M%3.3d_S%3.3d" $mNumber $section ]
    set fl_name [directory_path help]/diag_help/$fl_patch.help
    if {[file exists $fl_name]==1} {
       set fp [open $fl_name]
       set data [read $fp] 
       close $fp    
       set flag_mod_sec 1
       set lst_data [split $data \n]
    }

    set secs ""
    foreach item $st_items($mNumber,$section) {
	# From a user or system STASHmaster ?
	if {$stmsta($mNumber,$section,$item,srce)==2} {
	    set srce "USER"
	} else {
	    set srce "SYSTEM"
	}
	lappend source $srce

	# This call sets the "avail" logic
	check_stash $section $item $mNumber
	lappend avail $stmsta($mNumber,$section,$item,avail)

	# Section, item and name
	lappend secs $section
	lappend items $item

    # ILP use one of methods depending on flag_mod_sec
    if {$flag_mod_sec == 1} {
       # Use data from concatenated file
       set ls_patch [format "<M%3.3d_S%3.3d_I%3.3d>" $mNumber $section $item]
       set found [lsearch $lst_data $ls_patch]
       if {$found != -1} {
          lappend help Help
       } else {
          lappend help "No help"
       }
       
    } else {
       # Use the old method
	set helpFile [format "diag_STASH_M%3.3d_S%3.3d_I%3.3d" \
		$mNumber $section $item ]
	set helpPath [directory_path help]/diag_help/$helpFile\.help
	if [file readable $helpPath] {
	    lappend help Help
	} else {
	    lappend help "No help"
	}
    }
    
	lappend names $stmsta($mNumber,$section,$item,name)
    }

    # Add rows to table
    set nRows [llength $secs]
    if { $nRows != 0} {
	plbMethod $dTable AddRows 0 $nRows $secs $items $names $help $avail $source
    }
}

# addDiag
#   Adds a diagnostic line to the main STASH diagnostic table. Called
#   when item in diagnostics list is pressed. Comments in the following
#   distinguish the "main" table - the list of diagnostics/profiles 
#   selected by the user - from the "diagnostic" table - the table
#   showing the choice of diagnostics from the selected section.
# Arguments
#   d : Root of diagnostic table
#   colNo,rowNo : Location of selection in diagnostic table
#   mNumber : 1,2,3,4 for atmos, ocean etc

proc addDiag {d colNo rowNo mNumber} {
    global stmsta st_items
    global diagInstance stInstance diagTags

    # Frame holding status line
    set f $diagInstance($mNumber,Frame)

    # Check that STASH table is there first
    if ![info exists stInstance($mNumber,Root)] {
	status_message $f "STASH for this submodel has been closed - reopen it first"
	return
    }
    
    # Root of table to which line is to be added
    set r $stInstance($mNumber,Root)

    # Return if table at maximum length
    if [tableFull $r [get_variable_value N_STASH_R]] {
	status_message $f "Table Full - No more diagnostics can be added"
	return
    } else {
	clear_message $f
    }

    # If no diags in this section, rowNo will be blank
    if {$rowNo == ""} {
	status_message $f "No diagnostics in this section"
	return
    }

    # Need to know current contents of diagnostic table
    set section $diagInstance($mNumber,CurrentSection)
    set item [lindex $st_items($mNumber,$section) $rowNo]

    # Once section and item obtained, the rest is available from globals

    # From a user or system STASHmaster ?
    if {$stmsta($mNumber,$section,$item,srce)==2} {
	set source "USER"
    } else {
	set source "SYSTEM"
    }
    # This call sets the "avail" logic
    check_stash $section $item $mNumber
    set avail $stmsta($mNumber,$section,$item,avail)
    set name $stmsta($mNumber,$section,$item,name)
    
    # Add the row to an appropriate postion
    set currRow [plbMethod $r GetActiveRow]
    # After the current row
    incr currRow
#     plbMethod $r AddRows $currRow 1 $section $item [list $name] "" "" "" "Y" $diagTags(inChar) $avail $source
    plbMethod $r AddRows $currRow 1 $section $item [list $name] "" "" "" "Y" $diagTags(inChar) $avail "" $source    
    # Move display if new diag is off screen
    if {[plbMethod $r CheckDisplayed $currRow] != 0} {
	plbMethod $r MoveDisplayTo [expr $currRow - 3]
    }
    updateDiagNumber $mNumber

}

# cloneDiag
#   Make a copy of the currently selected diagnostic

proc cloneDiag {mNumber} {
    global stInstance

    # Root of table to which line is to be added
    set r $stInstance($mNumber,Root)
   
    # Return if table at maximum length
    if [tableFull $r [get_variable_value N_STASH_R]] {return}

    set rowNo [plbMethod $r GetSelectedRow]
    if {$rowNo != "" && $rowNo < [plbMethod $r GetLength]} {
	set rowContents [plbMethod $r GetRowContents $rowNo]
	incr rowNo
	eval plbMethod $r AddRows $rowNo 1 $rowContents
	# Move display if new diag is off screen
	if {[plbMethod $r CheckDisplayed $rowNo] != 0} {
	    plbMethod $r MoveDisplayTo [expr $rowNo - 3]
	}
    }
    updateDiagNumber $mNumber
}
    
# updateDiagNumber
#  Updates status line to display number of diagnostics in table
# Argument
#  mNumber : Model id

proc updateDiagNumber {mNumber} {
    global stInstance

    # Root of table to which line is to be added
    set r $stInstance($mNumber,Root)
    
    set stashWin $stInstance($mNumber,Window)

    set nRows [plbMethod $r GetLength]
    status_message $stashWin "Number of Diagnostics: $nRows"
    if [tableFull $r [get_variable_value N_STASH_R]] {
	append_message $stashWin " Table Full - No more diagnostics can be added"
    }
}

# tableFull
#   Returns 1 if length of table $r is >= $maxLength
# r : Table id
# maxLength : Maximum length of table

proc tableFull {r maxLength} {
    
    set length [plbMethod $r GetLength]
    if {$length >= $maxLength} {
	return 1
    }
    return 0
}

# quitDiag
#   Destroy instance of "Add Diagnostics" window
# Argument
#   m : 1,2,3,4 for atmos ocean etc.

proc quitDiag {m} {
    global diagInstance

    set s $diagInstance($m,SecRoot)
    set d $diagInstance($m,DiagRoot)

    plbMethod $s DestroyPlb
    plbMethod $d DestroyPlb

    set w $diagInstance($m,Window)

    # Tidy diagInstance array
    foreach index [array names diagInstance $m,*] {
	unset diagInstance($index)
    }
    destroy $w
}

# helpDiag
#   A binding from the 'available diagnostics' table to
#   show diagnostic specific help.
# Arguments
#   d : Table id. Unused, but is required because it is a BindColumn
#       proc of table, so table id is automatically sent by Plb proc
#   colNo : Column of table. Also unused
#   rowNo : Row of table
#   mNumber : Model id

proc helpDiag {d colNo rowNo mNumber} {
    global st_items stmsta diagInstance
    global lst_data flag_mod_sec

    set sec $diagInstance($mNumber,CurrentSection)
    set item [lindex $st_items($mNumber,$sec) $rowNo]
    set name $stmsta($mNumber,$sec,$item,name)

    # ILP use one of methods depending on flag_mod_sec
    if {[info exists lst_data] && ($flag_mod_sec==1)} {
    # Use the new method
       
       set w_title "Stash Diagnostic Help for Section $sec Item $item"
       set ls_text "Help for $mNumber:$sec:$item does not exist. Sorry..."
       
       set ls_patch [format "<M%3.3d_S%3.3d_I%3.3d>" $mNumber $sec $item]
       set bg_ind [lsearch $lst_data $ls_patch] 
       if {$bg_ind != -1} {
          set ls_patch [format "</M%3.3d_S%3.3d_I%3.3d>" $mNumber $sec $item]       
          set end_ind [lsearch -start $bg_ind $lst_data $ls_patch]  
          
          if {$end_ind != -1 && [expr $end_ind > $bg_ind]} {
             # Extract related part of the text
             set tmp_lst [lrange $lst_data [expr $bg_ind + 1] \
                         [expr $end_ind - 1]]
             # Add includes if necessary
             set ls_inc_path [directory_path help]/diag_help
             set tmp_lst [include_help_text $tmp_lst $ls_inc_path]  
             # Convert to text
             set ls_text ""
             foreach w_item $tmp_lst {
                append ls_text "\n" $w_item
             } 
          } 
       }  
       # Show the text
       set w_name .wdiag$item
       display_help_text $ls_text $w_name $w_title
       
    } else {
    # Use the old method    

    set help_file [format "diag_STASH_M%3.3d_S%3.3d_I%3.3d" \
                   $mNumber $sec $item ]
    set help_path [directory_path help]/diag_help/$help_file\.help
    if {! [file readable $help_path]} {
	dialog .warning "Help file does not exist" "There is no help for:\n\
        ( $mNumber, $sec, $item ) $name. \n\
        File $help_path not found
        Sorry."  {} 0 {OK}
    } else {
      application_help $help_file "Stash Diagnostic Help for Section $sec Item $item" [directory_path help]/diag_help
    }
    }
}

proc display_help_text {text win title} {

    global font_help font_butons
    
    if { $text == "" } {
	   dialog .warning "Help text does not exist" \
           "The help does not exist." {} 0 {OK}
	   return
    }

    if {[info commands $win] == $win} {
	# Help has already been opened - bring to top
	   wm iconify $win
	   wm deiconify $win
	   return
    }

    textToWindow $win $text $title

}     

