# stash.tcl
#   Toplevel routine to set up STASH window for a given submodel

# Global arrays:
# stInstance :
#   Array dimensioned by model number: stInstance($mNumber,<Object>)
#   where <Object> can be:
#  Root : Root name of the main STASH Plb table
#  Window : Name of the window holding the main STASH table
#  nDiags : Number of rows of diagnostics in table
#   Also used to store contents of table when readSTASHWindow called 
#   where <Object> can be:
#
# isec,$i   : Section number of row $i
# item,$i   : Item number of row $i
# inam,$i   : Diagnostic name of row $i
# time,$i   : time profile attached to row $i
# domain,$i : domain profile attached to row $i
# usage,$i  : usage profile attached to row $i
# iinc,$i   : Is row $i to be included in output Y or N
#
# prof :
#  Array dimensioned by model number and profile type which stores
#  information relating to the names, numbers and status of profiles.
#   prof($m,$pType,<Object>)
#  m: Model number 1 for atmos, 2 for ocean, 3 for SLAB 4 for wave
#  pType: profile type: time, domain or usage
#  <Object> can be:
#   profile: List of profile names
#   nProfMax: Maximum number of profiles allowed
#   nProfs: Number of profiles currently set up
#   active: Number of profile currently selected, or -1 if none.
#   $n: where $n is between 1 and nProfMax: Name of each profile
#   entryWidget,$n: where $n is between 1 and nProfMax: Name of entry widget
#   scalars: List of scalar variables that define this profile
#   arrays: List of array variables that define this profile

#   st_sec_name(M,S)   -- stash section name  array by model and section number
#   st_sections(M)     -- stash section list by model number
#   st_items(M,S)      -- list of items in a section by model, section
#   stmsta(M,S,I,rec)  -- stash master info for each item by model,section,item and record

# stash
#   Toplevel procedure for creating an instance of STASH
# Arguments
#   mNumber: Model number: atmos=1 ocean=2 slab=3 wave=4
# Method
#   1. Setup basic local variables relating to this instance of STASH
#   2. Check whether STASH already open
#   3. Read in diagnostics and profiles settings for this submodel
#   4. Create window: Title, profiles section, diagnostics table
#      and buttons sections

proc stash {mNumber} {
    global font_heads font_tabhed

    # Check that all record files such as STASHmasters and Ancil masters
    # have been read. Otherwise command sets up a callback that recalls 
    # processing once they have been read in
    if {[checkAllFilesRead "stash $mNumber"] == 0} {return}

    # prof is an array holding all the global data relating to the profiles.
    # name, item and titles arrays should really be one.

    global prof exp_id job_id stash_read
    global stash_open
    global stInstance

    #-------------------------------
    # Section 1: Set local variables
    #-------------------------------

    set mLetter [modnumber_to_letter $mNumber ] ; # A,O,S,W
    set mName [modnumber_to_name $mNumber] ; # ATMOS, OCEAN  etc

    # Toplevel window for instance of STASH
    set w .stash_$mLetter
    # Save name of window in stInstance - for use by callbacks from add diags routine
    set stInstance($mNumber,Window) $w

    set font_heads $font_tabhed
    
    #---------------------------------------
    # Section 2: Check for existing instance
    #---------------------------------------

    # We may have used stash previously, if so we can get it back
    
    if {[info commands $w]==$w} {
	wm deiconify $w
	raise $w
	return
    }

    #-------------------------
    # Section 3: Read settings
    #-------------------------

    # Initialise characters for tag column
    initTags

    # read in the stash master file.

    if {[info exists stash_read($mNumber)]==0} {
	if {[read_stash 1 $mNumber] == 1} {
	    return 1
	}
        set stash_read($mNumber) 1
	if {[readUserStash $mNumber 1] == 1} {
	    return 1
	}
	checkRemovedDiags $mNumber
    }

    # read profile definitions.

    readProfiles $mNumber

    #------------------------
    # Section 4: Create panel
    #------------------------

    # TODO these colours and fonts should be set by sourcing 'appearance.tcl'
    #set prof($mNumber,highlight) red
	set prof($mNumber,highlight) cornsilk
    set prof($mNumber,normal) gray80

    toplevel $w
    # Call quit script if user attempts to close window from top left button
    wm protocol $w WM_DELETE_WINDOW "abandonSTASH $mNumber"

    wm title $w "STASH Panel $mName. Experiment $exp_id, Job $job_id"
    wm iconname $w "   $exp_id$job_id:   STASH ($mLetter)."
    wm iconbitmap $w "@[directory_path icons]/nav.xbm"

    # Create the main active sections
    # First the profiles
    createProfiles $w $mNumber
    # ILP block diagnostic table
    block_diag_table $w $mNumber    
    # Then create the diagnostics
    diagnosticsTable $w $mNumber
    # Then the menubar
    stashMenu $w $mNumber
    # Create status line and output number of diagnostics to it
    create_status_line $w
    updateDiagNumber $mNumber
    set stash_open($mNumber) Yes

    # Check for unused streams
    verifyStreams $mNumber
}


# verifyStreams 
#   Checks if streams were requested but diagnostics do not use profiles
#   creates a descriptive error message if required
# Argument
#   m : Model number

proc verifyStreams {mNumber} {
   global prof

   set mLetter [modnumber_to_letter $mNumber ] ; # A,O,S,W  

   # 1 From subindep_PostProc_PPInit window table create list of records
   # which use archiving:
   # ffpu(stream name) - ppa(arch) - status(NN by default) - i(index)
   # streams which do not have model letter will set to N by force
   
   set ppfu [get_variable_array PPFU]
   set ppm  [get_variable_array PPM]
   set ppa  [get_variable_array PPA]

   set i 0   
   set list_ppfu {}
   
   foreach ppfu_i $ppfu {
      set ppm_i [lindex $ppm $i] 
      set ppa_i [lindex $ppa $i]
      
      # set to N streams without model letter
      if {$ppm_i=="" && $ppa_i=="Y"} {
         set ppa [lreplace $ppa $i $i N]
      }   
      
      # 2 Add to check list_2 for particular model
      if {$ppm_i==$mLetter && $ppa_i=="Y"} {  
         lappend list_ppfu "$ppfu_i $ppa_i NN $i"
      }
      
      incr i
   }
   # reset ppa column by force
   set_variable_array PPA $ppa
   
   # 3 From 1st part of STASHmaster_model window create a list of records, 
   # which use pp streams: 
   # profile name) - index - sream name - status(N default)  
  
   set n_usage [get_variable_value NUPROF_$mLetter]
   set usg_list [get_variable_array USEPRO_$mLetter]
   set var_list $prof($mNumber,usage,scalars)
   set locn_val [get_variable_array LOCN\_$mLetter] 
   set iunt_val [get_variable_array IUNT\_$mLetter] 
   set var_i 0

   # Select only domains which use pp-files and put them into pp_list
   set pp_list {}
   
   foreach item $usg_list {
      set locn_i [lindex $locn_val $var_i]
      if {$locn_i=="3"} {
         # index stars with 0
         set iunt_i [lindex $iunt_val $var_i]
         lappend pp_list "$item $var_i $iunt_i N"
      }
      incr var_i      
   }

   # 4 Find all profile names which use particular stream and
   # check diagnostic table for: 
   #    at least one diagnostic uses this profile name
   #    diagnostic is available
   
   set rec1_count 0
   foreach rec_i $list_ppfu {
      
      set pp_str [lindex $rec_i 0]
      set pos [string last / $pp_str]
      set pp_num [string range $pp_str [expr $pos + 1] end]
      
      foreach rec_2 $pp_list {
         set str_num [lindex $rec_2 2]
         if {$str_num==$pp_num} {
            # get frofile name and check in diagnostic table
            set prof_name [lindex $rec_2 0]

            # get list of all diagnostics, containing this profile name
            set w_list [diagsWithProfile $mNumber usage $prof_name]
            if {[llength $w_list] == 0} continue;       
            
            # Check if profile is used with at least one diagnostic 
            set rc [checkProfileUsage $w_list $mNumber]
            
            # Change status of stream in the list_ppfu from NN to Y 
            if {$rc==1} {
               set rec_i [lreplace $rec_i 2 2 "YY"]
               set list_ppfu [lreplace $list_ppfu $rec1_count $rec1_count $rec_i]
            }
         }
      }
      incr rec1_count
   }
}


# checkProfileUsage 
# Checks if profile is used with at least one diagnostic
# Arguments
#   w_list : list of all diagnostics, containing this profile name
#   m      : Model number

proc checkProfileUsage {w_list mNumber} {
   global stmsta
    
   set mLetter [modnumber_to_letter $mNumber ] ; # A,O,S,W
   set tags [setupTagList $mNumber]
   
   foreach rec $w_list {
      set i [lindex $rec 1]
      
      set isec [get_variable_value ISEC_$mLetter\($i\)]
      set item [get_variable_value ITEM_$mLetter\($i\)]
      set iinc [get_variable_value IINC_$mLetter\($i\)]
	  set itag [lindex $tags [expr $i-1]]
      set ipck [string match "+*" $itag]
    
	  if { $iinc == "" } { set iinc Y }
      set iipa "X"
      if {$iinc == "Y" && $ipck == "1" && \
          $stmsta($mNumber,$isec,$item,avail) == "Y"} {
         set iipa " "
         return 1
      } 
   }
   return 0
}


# readProfiles
#   Reads profile settings into prof array
# Argument
#   mNumber : Model id number

proc readProfiles {mNumber} {
    global prof 
   
    set mLetter [modnumber_to_letter $mNumber ] ; # A,O,S,W

    # Variable in database that stores profile list
    set prof($mNumber,time,variable) TIMPRO_$mLetter
    set prof($mNumber,domain,variable) DOMPRO_$mLetter
    set prof($mNumber,usage,variable) USEPRO_$mLetter

    # Variable in database that stores profile count
    set prof($mNumber,time,countVar) NTPROF_$mLetter
    set prof($mNumber,domain,countVar) NDPROF_$mLetter
    set prof($mNumber,usage,countVar) NUPROF_$mLetter

    # Match profile type to columns in diagnostic table
    set prof($mNumber,all,diagCol) 2
    set prof($mNumber,time,diagCol) 3
    set prof($mNumber,domain,diagCol) 4
    set prof($mNumber,usage,diagCol) 5

    # Initialise some variables.

    # These create lists of UMUI variables that define a profile
    defineProfileVars $mNumber

    # Transfer profile names from database to prof array
    # and store count of number of profiles set up.
    foreach type [list time domain usage] {

	# Maximum number of profile names on each row
	set prof($mNumber,$type,editList) ""
	# Maximum number of profile names on each row
	set prof($mNumber,$type,nPerRow) 12
	# Initialise variable for selected profile
	set prof($mNumber,$type,active) -1
	# Database variable name
	set var $prof($mNumber,$type,variable)

	# Compute name of variable that stores max number of profiles...
	set pLetter [string toupper [string index $type 0]]
	# ...and get its value
	set nProfMax [get_variable_value MAX_N$pLetter\PROF_$mLetter]
	set prof($mNumber,$type,nProfMax) $nProfMax

	set nProfs 0
	for {set i 1} {$i <= $nProfMax} {incr i} {
	    set prof($mNumber,$type,$i) [get_variable_value $var\($i\)]
	    if {$prof($mNumber,$type,$i) != ""} {incr nProfs}
	}
	set prof($mNumber,$type,nProfs) $nProfs
	set_variable_value $prof($mNumber,$type,countVar) $nProfs
    }
}

# defineProfileVars
#   Setup list of UMUI variables contained in each profile
# Arguments
#   mNumber : Model id number

proc defineProfileVars {mNumber} {
    global prof

    set mLetter [modnumber_to_letter $mNumber ] ; # A,O,S,W    

    # Initialise the lists
    foreach type [list time domain usage] {
	set prof($mNumber,$type,scalars) ""
	set prof($mNumber,$type,arrays) ""
    }

    # Create list of time profile variables...
    foreach var [list ITYP INTV UNT1 UNT2 UNT3 ISAM \
	    IOFF IOPT ISTR IEND IFRE ITIMES] {
	lappend prof($mNumber,time,scalars) $var\_$mLetter
    }
    # ...and time profile arrays
    foreach array [list ISER ISDTY ISDTM ISDTD ISDTH \
                  IEDTY IEDTM IEDTD IEDTH] {
	lappend prof($mNumber,time,arrays) $array\_$mLetter
    }

    # Create list of domain profile variables...
    foreach var [list IOPL LEVB LEVT PLT IOPA INTH ISTH IWST IEST GNTH\
	    GSTH GWST GEST IMSK IMN IWT ILEVS DDOMTS NDOMTS TDOMTS ISCCP] {
	lappend prof($mNumber,domain,scalars) $var\_$mLetter
    }
    # ...and domain profile arrays
    foreach array [list LEVLST RLEVLST PLEVLST PSLIST \
	    DOMTS_N DOMTS_S DOMTS_E DOMTS_W \
	    DOMTS_LL DOMTS_LF DOMTS_RL DOMTS_RF \
	    DOMTSR_NS DOMTSR_EW \
	    DOMTSR_LL DOMTSR_LF DOMTSR_RL DOMTSR_RF] {
	lappend prof($mNumber,domain,arrays) $array\_$mLetter
    }
    # Create list of usage profile variables - there are no arrays
    foreach var [list LOCN IUNT TAG TAGCM1 TAGCM2 TAGCM3 TAGCM4] {
	lappend prof($mNumber,usage,scalars) $var\_$mLetter
    }
}

# createProfiles
#   Create section containing profile names for all profile types
# Arguments 
#   w : Parent widget
#   mNumber : Model id number

proc createProfiles {w mNumber} {
    global prof 

    set f $w.profiles
    pack [frame $f] -side top -ipadx 10 -ipady 10

    # Create a block of profile entries for each type.
    foreach type [list time domain usage] {
	createProfileBlock $f $mNumber $type
	# Select the first one
	setProfCell $mNumber $type 1
    }

    # Key bindings to select profiles
    bind $w <Key-w> "incrementProfCell $mNumber   time  1"
    bind $w <Key-q> "incrementProfCell $mNumber   time -1"
    bind $w <Key-s> "incrementProfCell $mNumber domain  1"
    bind $w <Key-a> "incrementProfCell $mNumber domain -1"
    bind $w <Key-x> "incrementProfCell $mNumber  usage  1"
    bind $w <Key-z> "incrementProfCell $mNumber  usage -1"

    return
}

# createProfileBlock
#   Create a block of profile name entries for given profile type.
# Arguments
#   w : id of parent widget
#   mNumber : Model number
#   type : Profile type: time, domain or usage

proc createProfileBlock {w mNumber type} {
    global prof font_heads

    set f $w.$type
    # Frame to hold subtitle all rows of profiles of this type
    pack [frame $f] -side top

    set Type [capitalise $type]
    label $f.l -text "$Type Profiles available"  -font $font_heads
    pack $f.l -side top -anchor w

    set nProfMax $prof($mNumber,$type,nProfMax)
    set nPerRow $prof($mNumber,$type,nPerRow)
    set nFullRows [expr $nProfMax/$nPerRow]
    set nLastRow [expr $nProfMax - $nFullRows*$nPerRow]

    set n 1
    # Create a complete row of $nPerRow blocks
    for {set row 1} {$row <= $nFullRows} {incr row} {
	createProfileRow $f $mNumber $type $row $nPerRow
    }
    # Create a partially full row for remainder of blocks
    if {$nLastRow != 0} {
	createProfileRow $f $mNumber $type $row $nLastRow
    }
}

# createProfileRow
#   Create a row of profile entries, each bound to an element of the
#   prof($mNumber,$type,*) array
# Arguments
#   f : container frame
#   mNumber : Model id number
#   type : time, domain or usage
#   row : Row number
#   nEntries : Number of entries to put in this row

proc createProfileRow {f mNumber type row nEntries} {
    global prof font_tables
    
    # ILP Configure entry state according to Tk version
    if {[expr [info tclversion] < 8.4]} {
        set entry_state disabled  
    } else {
        set entry_state readonly 
    }
    
    set nPerRow $prof($mNumber,$type,nPerRow)

    set r $f.r$row
    pack [frame $r] -side top -fill x
    set n [expr $nPerRow * ($row - 1) + 1]
    for {set i 1} {$i <= $nEntries} {incr i} {
	entry $r.e$i \
		-width 10 \
		-relief sunken \
		-state $entry_state \
		-font $font_tables \
		-border 2 \
		-takefocus 0 \
		-textvariable prof($mNumber,$type,$n)
	pack $r.e$i -side left
	bind $r.e$i <Button-1> "setProfCell $mNumber $type $n"

	set prof($mNumber,$type,entryWidget,$n) $r.e$i
	incr n
    }
}

# diagnosticsTable
#   Create diagnostics table
# Arguments
#   w : parent widget
#   mNumber : Model id number

proc diagnosticsTable {w mNumber} {
    global fonts
    global stInstance

    if ![info exists fonts(STASHTable)] {
	set fonts(STASHTable) "helvetica 10"
    }

    # Read routine to fill out the table
    # Currently have 10 columns
    set diagList [getDiagList $mNumber 11]

    pack [frame $w.main] -ipadx 10 -ipady 10
    set mTable $w.main.t

    Plb_Make $mTable -numcols 11 -showrows 10 \
	    -title "STASH" -returnedit 0 \
	    -columnheadings \
	    [list "Sec" "Item" "Diagnostic Name" Time \
	    Domain Usage Incl Pckg Avail "I+P+A" User/System] \
	    -columnwidths [list 4 5 40 9 9 9 5 5 5 6 12] \
	    -columnlists $diagList \
	    -font $fonts(STASHTable)

    set stInstance($mNumber,Root) $mTable
    for {set i 2} {$i <= 5} {incr i} {
	# attachProfile will be called with args: \
		table id, row, column, $mNumber
	plbMethod $mTable BindColumn $i \
		[list attachProfiles $mNumber] space
	plbMethod $mTable BindColumn $i \
		[list attachProfiles $mNumber] Double-1
    }
    plbMethod $mTable BindColumn 6 toggleIncludeColumn space
    plbMethod $mTable BindColumn 6 toggleIncludeColumn Double-1
    plbMethod $mTable BindColumn 7 changeTag Any-Key %K $mNumber
    plbMethod $mTable BindColumn 7 displayTagDescription ButtonPress $mNumber
    pack $mTable
}


# ILP ===============
proc block_diag_table { w mNumber } {

    set mLetter [modnumber_to_letter $mNumber ] ; # A,O,S,W
    set ndiag [get_variable_value NDIAG_$mLetter]
    set diag_block [get_variable_value DIAGBLOCK]
# puts "ILP reading ndiag $ndiag DIAGBLOCK $diag_block"
    if { $diag_block == "" } {
       set_variable_value DIAGBLOCK $mLetter
    }
    
    pack [frame $w.add] -padx 10 -pady 5 -fill x

    set radio1 $w.add.rad1
    set radio2 $w.add.rad2

    radiobutton $radio1 -text "Use diagnostics" -variable radio -value 1 \
                        -command { diag_table_switch DIAGBLOCK "s_up" }
      
    radiobutton $radio2 -text "Deactivate diagnostics" -variable radio -value 0 \
                        -command { diag_table_switch DIAGBLOCK "s_low" }
                        
    pack $radio1 $radio2 -side left  

    set diag_block [get_variable_value DIAGBLOCK]
    if {$diag_block == "A" || $diag_block == "O" || $diag_block == "S"} {
       $radio1 select
    } else {
       $radio2 select  
    }     
}


proc diag_table_switch { varname str_val } {

   set tmp_val [get_variable_value $varname]
   
   if {$str_val == "s_up"} {
      set tmp_val [string toupper $tmp_val]
      set_variable_value $varname $tmp_val  

   } elseif {$str_val == "s_low"} {
      set tmp_val [string tolower $tmp_val]
      set_variable_value $varname $tmp_val
   }

#    set new_val [get_variable_value $varname]   
#    puts "ILP str_val $str_val value $new_val"

}
# ILP ===============

# stashMenu
#   Create menubar for STASH panel
# Arguments
#   w : Parent frame
#   mNumber : Model id number

proc stashMenu {w mNumber} {

    set m [mbMenuSetup $w.menubar]

    foreach header [list STASH Profiles Diagnostics Help] {
	mbMenu $m $header
    }
    # STASH
    mbMenuCommand $m STASH Close   "closeSTASH $mNumber"
    mbMenuSeparator $m STASH
    mbMenuCommand $m STASH Abandon "abandonSTASH $mNumber"
    # Profiles
    # Create cascade menus for each type of profile operation
    foreach operation [list edit delete copy] {
	set title "[capitalise $operation] Profile"
	mbMenuCascade $m Profiles $title
	foreach type [list time domain usage] {
	    mbMenuCommand $m $title "[capitalise $operation] $type" \
		    "$operation\Profile $mNumber $type"
	}
    }
    # Diagnostics
    set menuList [list \
	    [list "Load New Diagnostics" loadNewDiags l] \
	    [list "Remove Diagnostic" removeDiag r] \
	    [list "Clone Diagnostic" cloneDiag c] \
	    [list "Output Table to File" outputToFile] \
            [list "Set Package Switches" setTags t] \
	    [list "Clear Table" clearTable] \
	    [list "Verify Diagnostics" verifySTASH v] \
	    [list "Re-check Availability" checkAvailability] \
	    [list "Sort Diagnostics" sortDiags ] \
	    [list "Change Sort Order" orderedSortDiags ] \
	    ]
    foreach item $menuList {
	set label [lindex $item 0]
	set command [lindex $item 1]
	set key [lindex $item 2]
	mbMenuCommand $m Diagnostics $label "$command $mNumber"
	if {$key != ""} {
	    mbMenuBind $m $w <Control-$key> Diagnostics $label
	}
    }

    # Help menu
    set list [list \
	    [list General stash "Help for STASH"] \
	    [list Profiles stash_profiles Profiles] \
	    [list Diagnostics stash_diagnostics Diagnostics] \
	    [list "Key bindings" stash_bindings "STASH keyboard bindings"] \
	    ]
    foreach topic $list {
	set label [lindex $topic 0]
	set file  [lindex $topic 1]
	set title [lindex $topic 2]
	mbMenuCommand $m Help $label [list application_help $file $title]
    }
}
# clearTable
#   Delete all rows from main diagnostic table and update diagnostic
#   number
# Arguments
#   mNumber : Model id number

proc clearTable {mNumber} {
    global stInstance
    
    set t $stInstance($mNumber,Root)

    plbMethod $t ClearTable
    updateDiagNumber $mNumber
}

# removeDiag
#   Remove currently selected diagnostic from table.
# Argument
#   mNumber : Model id number

proc removeDiag {mNumber} {
    global stInstance

    set t $stInstance($mNumber,Root)

    plbMethod $t DeleteRows active active
    updateDiagNumber $mNumber

}

# checkAvailability
#   Checks availability of diagnostics and sets appropriate column
# Arguments
#   mNumber : Model id number

proc checkAvailability {mNumber} {
    global stmsta
    global stInstance

    set r $stInstance($mNumber,Root)

    set nDiags [plbMethod $r GetLength]
    if {$nDiags > 0} {
	set secList [plbMethod $r ColumnValue 0]
	set itemList [plbMethod $r ColumnValue 1]
    
	for {set i 0} {$i < $nDiags} {incr i} {
	    set isec [lindex $secList $i]
	    set item [lindex $itemList $i]
	    
	    # This call rechecks availablity of this item
	    check_stash $isec $item $mNumber
	    lappend newAvail $stmsta($mNumber,$isec,$item,avail)
	}
	plbMethod $r ChangeColumn 8 $newAvail
    }
}

# closeSTASH
#   Close stash after sorting table and profiles and saving list of 
#   selected diagnostics
# Arguments
#   mNumber : 1,2,3,4 for atmos, ocean,...etc.
# Method
#   If any profiles are being edited, create dialog with button bound
#   to forceCloseSTASH proc, and exits.

proc closeSTASH {mNumber} {

    # Post a warning if still in process of editing a profile
    set f [checkProfsOpen $mNumber Close]
    if {$f == 1} {
	forceCloseSTASH $mNumber
    }
}

# forceCloseSTASH
#   Immediately close STASH after checking it's still open
# Argument
#   mNumber : 1,2,3,4 for atmos, ocean,...etc.
# Method
#   Called directly from closeSTASH, or from dialog created by 
#   checkProfsOpen.

proc forceCloseSTASH {mNumber} {
    global stInstance stash_open

    if {[info exists stash_open($mNumber)] == 1} {

	set mLetter [modnumber_to_letter $mNumber ] ; # A,O,S,W
	
	set s $stInstance($mNumber,Root)
    
	set nDiags [plbMethod $s GetLength]
    
	if {$nDiags != 0 } {sortDiags $mNumber}
	set_variable_value NDIAG_$mLetter $nDiags
	
	set i 0
	# Column numbers relating to the variables in the list below
	set colNos [list 0 1 3 4 5 6]
	foreach var [list ISEC ITEM ITIM IDOM IUSE IINC] {
	    set colNo [lindex $colNos $i]
	    set_variable_array $var\_$mLetter \
		    [plbMethod $s ColumnValue $colNo]
	    incr i
	}
	# Remove the > or < in the column that indicates include status
	set tags [plbMethod $s ColumnValue 7]
	set itag ""
	foreach tag $tags {
	    lappend itag [string index $tag 1]
	}
	set_variable_array ITAG_$mLetter $itag

	# destroy window and tables, and unset variables
	destroySTASH $mNumber
    }
}

# abandonSTASH 
#   Abandon STASH table - don't update diagnostics requests with
#   table settings.
# Argument
#   mNumber : 1,2,3,4 for atmos, ocean,...etc.
# Method
#   If any profiles are being edited, create dialog with button bound
#   to forceAbandonSTASH proc, and exits.

proc abandonSTASH {mNumber} {

    # Post a warning if still in process of editing a profile
    set f [checkProfsOpen $mNumber Abandon]
    if {$f == 1} {
	forceAbandonSTASH $mNumber
    }
}

# forceAbandonSTASH
#   Immediately abandon STASH after checking it's still open
# Argument
#   mNumber : 1,2,3,4 for atmos, ocean,...etc.
# Method
#   Called directly from abandonSTASH, or from dialog created by 
#   checkProfsOpen.

proc forceAbandonSTASH {mNumber} {
    global stash_open
    if {[info exists stash_open($mNumber)] == 1} {
	destroySTASH $mNumber
    }
}

# checkProfsOpen
#   Gives warning on leaving STASH if profiles are currently being edited.
#   Allows user option to cancel closure.
# Arguments
#   mNumber : 1,2,3,4 for atmos, ocean,...etc.
#   operation : Abandon, or Close.
# Result
#   Return 1 if no profiles open; calling routine should continue with
#   closure. Otherwise create dialog with button binding to closure 
#   procedure and return 0; calling routine should exit.

proc checkProfsOpen {mNumber operation} {
    global prof

    # Post a warning if still in process of editing a profile
    set profsOpen 0
    foreach type [list time domain usage] {
	if {[llength $prof($mNumber,$type,editList)] != 0} {
	    set profsOpen 1
	}
    }
    if {$profsOpen == 1} {
	set t .leaveSTASH$mNumber$operation
	toplevel $t
	wm title $t "Close Profiles first"
	tDialog $t "It appears that some profiles are still being edited. \
		You are advised to close these before leaving STASH" 
	set b [buttonArray $t [list Cancel destroy $t] \
		[list "$operation STASH" "force$operation\STASH $mNumber" \; \
		destroy $t]]
	focus $b
	return 0
    }
    return 1
}

# destroySTASH
#   Close down an instance of STASH
# Arguments
#   mNumber : Model id number

proc destroySTASH {mNumber} {
    global stash_open stInstance prof

    set s $stInstance($mNumber,Root)
    set w $stInstance($mNumber,Window)

    # Destroy the window
    destroy $w

    # Tidy stInstance array
    foreach index [array names stInstance $mNumber,*] {
	unset stInstance($index)
    }
    # Tidy prof array
    foreach index [array names prof $mNumber,*] {
	unset prof($index)
    }

    # Destroy the Plb table widgets and data
    plbMethod $s DestroyPlb

    unset stash_open($mNumber)
}

proc orderedSortDiags {mNumber} {

    set t .sort$mNumber
    set var sortOrder_$mNumber
    if {[info commands $t] == "$t"} {
	raise $t
    } else {
	toplevel $t
	wm title $t "Diagnostics Table Sort Order"
	focus [eDialog $t "Input priority of columns for sorting (eg. \"1 3 2\")" 12 $var]
	buttonArray $t [list Sort sortDiags $mNumber \$$var] [list Quit destroy $t]
    }
    bind $t <Destroy> "if {\"%W\" == \"$t\"} \
	    \{unset $var\}"
}

# sortDiags
#   Sort diagnostic table in order of section and item number
# Arguments
#   mNumber : 1,2,3,4 for atmos, ocean,...etc.
#   order : Sort order - first column is column 1

proc sortDiags {mNumber {order ""}} {
    global stInstance

    set list ""
    foreach item $order {
	if {[catch {incr item -1}]} {
	    dialog .d "Invalid input" "Invalid input item $item" warning 0 OK
	    return
	}
	if {$item < 0 || $item > 9} {
	    dialog .d "Invalid input" "There is no column [incr item]" warning 0 OK
	    return
	}
	lappend list $item
    }

    set s $stInstance($mNumber,Root)

    set nDiag [plbMethod $s GetLength]
    # ie table is empty
    if {$nDiag==0} {return}
    eval plbMethod $s OrderedSort INCR $list

}

# attachProfile
#   Attaches currently selected profile/s to selected diagnostic.
#   Affects all three columns if column 2 selected, but only the
#   selected column if columns 3, 4 or 5 selected.
#   Check we have the required profiles selected first.
# Arguments
#   t : Table id
#   col : Column number
#   row : Row number
#   mNumber : Model id; passed from binding via table method.

proc attachProfiles {t col row mNumber} {
    global prof

    if {$row == ""} {return}

    if {$col == $prof($mNumber,all,diagCol)} {
	foreach type [list time domain usage] {
	    if {$prof($mNumber,$type,active) == -1} {
		dialog .imp "Set Line." "Select $type profile first" \
			{} 0 {OK}
		return
	    }
	}

	# If diagnostic name column clicked, set all three profiles.
	foreach type [list time domain usage] {
	    set name $prof($mNumber,$type,$prof($mNumber,$type,active))
	    set column $prof($mNumber,$type,diagCol)
	    plbMethod $t ChangeEntry $column $row $name
	}
    } else {
	foreach type [list time domain usage] {
	    if {$col == $prof($mNumber,$type,diagCol)} {
		set active $prof($mNumber,$type,active)
		if {$active == -1} {
		    dialog .imp "Set Line." "Select $type profile first" \
			    {} 0 {OK}
		    return
		}
		set name $prof($mNumber,$type,$active)
		plbMethod $t ChangeEntry $col $row $name
	    }
	}
    }
}

# toggleIncludeColumn
#   Toggle the Y/N Include column of the selected diagnostic.
# Arguments
#   t : Table id
#   col : Column number
#   row : Row number

proc toggleIncludeColumn {t col row} {
    if  {$col == 6} {
	# Column 6 is Include column. Toggle Y/N
	set includeVal [plbMethod $t GetEntry 6 $row]
        if { $includeVal != "Y" } {
          set newVal Y
        } else {
          set newVal N
        }
	plbMethod $t ChangeEntry 6 $row $newVal
    }
}

	

# setProfCell
#   Highlight selected profile cell and remove highlight from previous
#   selection
# Arguments
#   mNumber : Model id number
#   type : Profile type
#   cell : Profile number to highlight

proc setProfCell {mNumber type cell} {
    global prof

    # Get previous selection
    set active $prof($mNumber,$type,active)
    # If cell is blank, direct choice to first blank cell
    set nProfs $prof($mNumber,$type,nProfs)
    if {$cell > $nProfs} {set cell [expr $nProfs + 1]}

    if {$active != $cell} {
	if {$active != -1} {
	    # A previous selection exists
        # ILP Configure entry widget according to Tk version
        if {[expr [info tclversion] < 8.4]} {
            $prof($mNumber,$type,entryWidget,$active) configure \
		    -bg $prof($mNumber,normal)
        } else {
        	$prof($mNumber,$type,entryWidget,$active) configure \
            -readonlybackground $prof($mNumber,normal)
        }
	}
	# Save number of new cell and highlight it
	set prof($mNumber,$type,active) $cell
    
    # ILP Configure entry widget according Tk version
    if {[expr [info tclversion] < 8.4]} {
    	$prof($mNumber,$type,entryWidget,$cell) configure \
		-bg $prof($mNumber,highlight)
    } else {
    	$prof($mNumber,$type,entryWidget,$cell) configure \
		-readonlybackground $prof($mNumber,highlight)
    }
    }
}

# incrementProfCell
#   Change profile selection in requested direction
# Arguments
#   mNumber : Model id number
#   type : Profile type
#   change : Direction and size of step

proc incrementProfCell {mNumber type change} {
    global prof

    set active $prof($mNumber,$type,active)
    if {$active != -1} {
	# Calculate number of new cell. 
	# Maximum value is number of profiles + 1
	set max [expr $prof($mNumber,$type,nProfs) + 1]
	if {$max > $prof($mNumber,$type,nProfMax)} {
	    set max $prof($mNumber,$type,nProfMax)
	}
	set newCell [expr $active + $change]
	# Loop around if at start or end
	if {$newCell > $max} {
	    set newCell [expr $newCell - $max]
	} elseif {$newCell < 1} {
	    set newCell [expr $newCell + $max]
	}
	# Apply change
	setProfCell $mNumber $type $newCell
    }
}
	    
# copyProfile
#   Copy selected profile to end of list. Requires input of new name
# Arguments
#   mNumber : Model id number
#   type : Profile type: time, domain or usage
# Globals
#   verify_flag : A UMUI verification function is used to verify the new
#                 profile name. verify_flag is set to tell the function
#                 that the calling routine will handle the error

proc copyProfile {mNumber type} {
    global prof

    if {[llength $prof($mNumber,$type,editList)] != 0} {
	dialog .nocopy "Close profiles first" "Unsafe to copy $type profiles while some of them are being edited" \
		{} 0 {OK}
	return
    }

    set nProfs $prof($mNumber,$type,nProfs)
    set oldProf $prof($mNumber,$type,active)

    # Check that a suitable, non-blank profile selected
    if {$oldProf == -1 || $oldProf > $nProfs} {
	dialog .emp "Copy Profile" "Choose a $type profile \
		to copy first !" {} 0 {OK}
	return
    }

    # Check that there is space for new profile
    if {$nProfs == $prof($mNumber,$type,nProfMax)} {
   	dialog .emp "Copy Profile" \
		"No empty $type profiles to copy to. Delete \
		one first!" {} 0 {OK}
	return
    }

    newProfileName $mNumber $type $oldProf copy
}

proc copyProfileConfirm {w mNumber type oldProf newProfName} {
    global prof verify_flag

    set mLetter [modnumber_to_letter $mNumber ] ; # A,O,S,W

    # Copy profile to first empty box. Get nProfs again because other 
    # operations could have been done while newProfileName was running...
    set nProfs $prof($mNumber,$type,nProfs)
    set variable $prof($mNumber,$type,variable)
    set target [expr $nProfs + 1]

    # ... also, check again that there is still space for new profile
    if {$target > $prof($mNumber,$type,nProfMax)} {
   	dialog .emp "Copy Profile" \
		"No empty $type profiles to copy to. Delete \
		one first!" {} 0 {OK}
	return
    }

    # Profile should be empty but check anyway and tidy if not.
    if {$prof($mNumber,$type,$target) != ""} {
	tidyProfiles $mNumber $type
    }

    set verify_flag 1

    if {[chk_prof_nm $newProfName $variable $target $mLetter]!=1} {
	# Selected profile name is acceptable
	# Copy the profile data object
	copyProfileVals $mNumber $type $oldProf $target $newProfName
	destroy $w
    } else {
	# Error dialogue will have been output by chk_prof_nm
	# Allow user to input new value by making recursive call
	# copyProfile $mNumber $type
	# Exit immediately
	return
    }
}

# copyProfileVals
#   Copy values that define a profile to a new location
# Arguments
#   mNumber : Model id number
#   type : Profile type: time, domain or usage
#   old : Number of original profile
#   new : Number of new profile
#   name : Name of new profile

proc copyProfileVals {mNumber type old new name} {
    global prof

    # Get name of name array (eg TIMPRO_A) and set new name
    set varName $prof($mNumber,$type,variable)
    set_variable_value $varName\($new\) $name
    set currName $prof($mNumber,$type,$new)
    if {$currName == ""} {
	# New profile, so increment profile counts
	incr prof($mNumber,$type,nProfs)
	set_variable_value $prof($mNumber,$type,countVar) $prof($mNumber,$type,nProfs)
    }
    set prof($mNumber,$type,$new) $name

    # Copy list of scalar variables to new profile
    foreach var $prof($mNumber,$type,scalars) {
	set_variable_value $var\($new\) [get_variable_value $var\($old\)]
    }
    # Copy list of array variables to new profile
    foreach var $prof($mNumber,$type,arrays) {
	set_variable_array $var\(*,$new\) [get_variable_array $var\(*,$old\)]
    }
}

# deleteProfileInstance
#   Delete values that define a profile, and reduce the profile count
# Arguments
#   mNumber : Model id number
#   type : Profile type: time, domain or usage
#   nProf : Number of profile

proc deleteProfileInstance {mNumber type nProf} {
    global prof

    # Get name of name array (eg TIMPRO_A) and unset name
    set varName $prof($mNumber,$type,variable)
    set_variable_value $varName\($nProf\) ""
    # Unset element in prof global
    set prof($mNumber,$type,$nProf) ""

    # Unset list of scalar variables in profile
    foreach var $prof($mNumber,$type,scalars) {
	set blank [lindex [get_variable_info $var] 1]
	set_variable_value $var\($nProf\) $blank
    }
    # Unset list of array variables in profile
    foreach var $prof($mNumber,$type,arrays) {
	set blank [lindex [get_variable_info $var] 1]
	set_variable_array $var\(*,$nProf\) $blank
    }
    # Reduce profile count
    incr prof($mNumber,$type,nProfs) -1
    set_variable_value $prof($mNumber,$type,countVar) $prof($mNumber,$type,nProfs)
}

# deleteProfile
#   Delete selected profile after confirmation. Then tidy profile
#   table by removing blanks
# Arguments
#   mNumber : Model id number
#   type : Profile type: time, domain or usage

proc deleteProfile {mNumber type} {
    global prof
    global stInstance

    if {[llength $prof($mNumber,$type,editList)] != 0} {
	dialog .nodel "Close profiles first" \
		"Unsafe to delete $type profiles while \
		some of them are being edited" \
		{} 0 {OK}
	return
    }

    set delProf $prof($mNumber,$type,active)

    # Check that a suitable, non-blank profile selected
    set nProfs $prof($mNumber,$type,nProfs)
    if {$delProf == -1 || $delProf > $nProfs} {
	dialog .emp "Delete Profile" "Choose a $type profile \
		to delete first !" {} 0 {OK}
	return
    }

    set profName $prof($mNumber,$type,$delProf)

    # Get response from "Are you sure" dialog
    set delflag [checkDelProfile $mNumber $type $profName]

    if {$delflag == 1} {
	# Delete this instance of a profile
	deleteProfileInstance $mNumber $type $delProf
	# Tidy list to remove any gap left by empty profile
	tidyProfiles $mNumber $type
	set col $prof($mNumber,$type,diagCol)
	
	# Now search the table for occurrances of the profile, and set them 
	# blank. The verification routine will pick up on the blanks.
	set s $stInstance($mNumber,Root)
	plbMethod $s SearchAndRep $col $profName ""
    }
}

# newProfileName
#   Dialog box to input new profile name.
# Arguments
#   mNumber : Model id number
#   type : Profile type: time, domain or usage
#   oldProf : Number of selected profile
#   action : Type of operation - currently only "copy" allowed
# Result
#   Returns new name, or "cancelled" if cancel pressed.

proc newProfileName {mNumber type oldProf action} {
    global prof font_butons

    set active $prof($mNumber,$type,active)
    set currName $prof($mNumber,$type,$active)

    set e .edit$mNumber$type$active

    if {[info commands $e]==$e} {
	# Window to copy this profile already opened so bring to top
	wm deiconify $e
	raise $e
    } else {
    
	# Create global variables for entry box and event loop
	set newNameVar "newProfName_$mNumber$type$oldProf"
	global $newNameVar
	set $newNameVar $currName
	
	# Create input dialog
	toplevel $e
	wm title $e "[capitalise $action] $type profile."
	focus [eDialog $e \
		"Enter new $type profile name to $action $currName to:" \
		12 $newNameVar]
	buttonArray $e \
		[list Accept $action\ProfileConfirm $e $mNumber $type $oldProf \$$newNameVar] \
		[list Cancel destroy $e]
	bind $e <Destroy> "if {\"%W\" == \"$e\"} \
	    \{unset $newNameVar\}"
    }
}

# tidyProfiles
#  Tidies profile list by closing up empty spaces in list.
# Arguments
#   mNumber : Model id number
#   type : Profile type: time, domain or usage

proc tidyProfiles {mNumber type} {
    global prof
  
    # Get name of UMUI variable
    set var $prof($mNumber,$type,variable)

    set list [get_variable_array $var]
    set len [llength $list]

    if {[lsearch $list ""] == -1} {
	# No blanks in list so return
	return
    }

    # Store amount by which profiles need to be shifted left
    set diff 0
    for {set i 1} {$i <= $len} {incr i} {
	set profName $prof($mNumber,$type,$i)
	if {$profName == ""} {
	    # Blank profile implies subsequent profiles need shifting
	    # one more space left
	    incr diff
	} elseif {$diff > 0} {
	    # Not blank. So if $diff is > 1, implies profile needs to
	    # be shifted to fill gap.
	    # Calculate where profile is to be moved to
	    set overwriteProf [expr $i - $diff]
	    # Move it, then delete original
	    # This could be made more efficient by only deleting profiles
	    # that are not going to be overwritten.
	    copyProfileVals $mNumber $type $i $overwriteProf $profName
	    deleteProfileInstance $mNumber $type $i
	}
    }
}

# checkDelProfile
#   Dialog box to confirm profile to be deleted - provides a list
#   of diagnostics attached
# Arguments
#   mNumber : Model number
#   type : Profile type: time, domain or usage
#   profName : Name of profile
# Result
#   Return 1 if profile to be delete, 0 otherwise.

proc checkDelProfile {mNumber type profName} {
    global prof font_butons font_tables

    # Unique window name and global flag variable 
    # Must be global to work with -command binding
    set d ".dprofs$profName$type$mNumber"
    
    # Deal with situation in which we are already waiting for 
    # confirmation on an earlier delete request. This code
    # no longer used as further down we do a local grab that
    # prevents interaction with other windows till dialog closed
    if {[info commands $d]==$d} {
	# Confirmation window already open so bring to top.
	wm iconify $d
	wm deiconify $d
	# Do nothing for this instance since a previous tkwait command 
	# is still waiting
	return 0
    } 

    # Get list of any diagnostics containing this profile
    set list [diagsWithProfile $mNumber $type $profName]

    # and if there are any, warn and request confirmation of deletion
    if {[llength $list] != 0} {

	set delflag flag_$profName$type$mNumber
	global $delflag

	toplevel $d

	wm title $d "Delete profile and update diagnostics."
	frame $d.label -relief raised
	frame $d.confirm
	button $d.confirm.accept -text "Delete anyway" \
		-command  "set $delflag 1; destroy $d" \
		-font $font_butons
	button $d.confirm.cancel -text "Cancel" \
		-command "set $delflag 0; destroy $d"\
		-font $font_butons
	pack $d.confirm.accept -side left -padx 25 -pady 5
	pack $d.confirm.cancel -side right -padx 25 -pady 5
	bind_button_list $d.confirm.accept $d.confirm.cancel
	
	pack $d.confirm -side top -padx 5 -pady 5	
	label $d.msg1 \
		-text "The $type profile \"$profName\" exists in the " \
		-font $font_butons
	label $d.msg2 \
		-text "following diagnostics:"  -font $font_butons
	
	pack $d.label -side top -padx 5 -pady 1
	pack $d.msg1 -side top -padx 5 -anchor w
	pack $d.msg2 -side top -padx 5 -anchor w
	frame $d.diags -relief raised
	pack $d.diags -side top -padx 5 -pady 1

	# This rough bit of code displays list of profiles. The font
	# size and lay out depend on the number of profiles to show.
	# Should be replaced with a scrollable panel

	# Font and number of rows list length dependent
	set use_font $font_butons
	set length [llength $list]
	# Divide up into columns with max length 30
	set cols [expr $length/30 + 1]
	if {$length > 180} {
	    # Divide up into columns with max length 40 and use smaller font
	    set cols [expr $length/40 + 1]
	    set use_font $font_tables
	}
    
	for {set i 0} {$i <= $length} {set i [expr $i+$cols]} {
	    set list3 {}
	    for {set j 0} {$j < $cols} {incr j} {
		lappend list3 "[lindex $list [expr $i + $j]]  "
	    }
	    regsub -all \{ $list3 {} list3
	    regsub -all \} $list3 {} list3
	    lappend list2 $list3
	}
	for {set i 0} {$i < [llength $list2]} {incr i} {
	    label $d.diags.$i -text [lindex $list2 $i] \
		    -font $use_font
	    pack $d.diags.$i -side top -padx 5 -anchor w
	}	
    
	set $delflag 0

	# Wait till button selected; button sets global variable 
	# $delflag and destroys window
	grab set $d
	bind $d <Visibility> "
	    if \{\[string match %W $d\] &&
	    \[string compare %s VisibilityUnobscured\]\} \{
		raise %W
		update
	    \}
	"


	tkwait window $d

	# Clean up global variable
	set flag [set $delflag]
	unset $delflag

	return $flag
    }
    return 1
}

# diagsWithProfile
#   Returns a list of diagnostics to which profile $profName has been
#   attached
# Arguments
#   m : Model number
#   type : Profile type: time, domain, or usage
#   profName : Name of profile

proc diagsWithProfile {m type profName} {
    global stInstance

    # Read current settings of STASH window
    readSTASHWindow $m

    set nDiags $stInstance($m,nDiags)

    set list {}
    for {set i 0} { $i < $nDiags} {incr i} {
	if {$profName == $stInstance($m,$type,$i)} {
	    set isec $stInstance($m,isec,$i)
	    set item $stInstance($m,item,$i)
	    lappend list "Diagnostic [expr $i+1] ($isec,$item)"
	}
    }
    return $list
}

# load_stash

proc load_stash {warning_flag mNumber} {
    
    global stmsta
    
    set mLetter [modnumber_to_letter $mNumber]

    # puts "reading stash for $mLetter "
    if {[read_stash $warning_flag $mNumber]==1} {
	return 1
    }
    readUserStash $mNumber $warning_flag
}
proc checkRemovedDiags {mNumber} {
    global stmsta

    set mLetter [modnumber_to_letter $mNumber]

    set ndiag [get_variable_value NDIAG_$mLetter]
    set removedDiags ""
    for {set i 1 } { $i <= $ndiag } { incr i} {
	set isec [get_variable_value ISEC_$mLetter\($i\)]
	set item [get_variable_value ITEM_$mLetter\($i\)]
	if {[info exists stmsta($mNumber,$isec,$item,srce)]==0} {
	    lappend removedDiags "Section $isec Item $item"
	}
    }
    if {$removedDiags != ""} {
	set errWin .removedDiags
	addTextToWindow $errWin " \
		\nThe following diagnostics were found in the basis library. \
		\nThey have been removed as you have either set \"user diagnostics off\" \
		\nin window \
		\n  \"[lindex [get_variable_info USERPRE_$mLetter] 5]\" \
		\nor changed the entry in a preSTASHmaster file. If you save this job now, \
		\nyou will lose these diagnostics from the basis database. \
		\nThe preSTASHmaster file will remain intact.\n" \
		"Warning: Diagnostics removed"
	foreach item $removedDiags {
	    addTextToWindow $errWin "\n$item" ""
	}
    }
    return 0
}

# getDiagList
#   Returns a list of contents for the STASH diagnostic window.
# Arguments
#   mNumber : 1,2,3,4 for atmos, ocean etc
#   varNo : Number of items required by calling routine
# Method
#   varNo is a rough cross-check to keep routines in line

proc getDiagList {mNumber varNo} {
    global stmsta

    set mLetter [modnumber_to_letter $mNumber]

    set ndiag [get_variable_value NDIAG_$mLetter]
    set tags [setupTagList $mNumber]
    if {$ndiag > 0 && $ndiag != ""} {
	# Table is not empty
	for {set i 1 } { $i <= $ndiag } { incr i} {
	    set isec [get_variable_value ISEC_$mLetter\($i\)]
	    set item [get_variable_value ITEM_$mLetter\($i\)]
	    if {[info exists stmsta($mNumber,$isec,$item,srce)]==1} {
		if {$stmsta($mNumber,$isec,$item,srce)==2} {
		    set srce "USER"
		} else {
		    set srce "SYSTEM"		
		}
		check_stash $isec $item $mNumber
		set itim [get_variable_value ITIM_$mLetter\($i\)]
		set idom [get_variable_value IDOM_$mLetter\($i\)]
		set iuse [get_variable_value IUSE_$mLetter\($i\)]
		set iinc [get_variable_value IINC_$mLetter\($i\)]
		set itag [lindex $tags [expr $i-1]]
        set ipck [string match "+*" $itag]
        
		if { $iinc == "" } { set iinc Y }
        set iipa "X"
        if {$iinc == "Y" && $ipck == "1" && \
            $stmsta($mNumber,$isec,$item,avail) == "Y"} {
           set iipa " "
        } 
		set colNo 0

		# Create one list for each column
		foreach var [list isec item stmsta($mNumber,$isec,$item,name) \
			itim idom iuse iinc itag stmsta($mNumber,$isec,$item,avail) iipa srce] {
		    lappend col$colNo [set $var]
		    incr colNo
		}
	    }
	}
	if [info exists colNo] {
	    # At least one diagnostic exists

	    # Consistency check if new columns added
	    if {$colNo != $varNo} {error "fill_diag_table: Mismatch in column numbers"}
	
	    for {set i 0} {$i < $varNo} {incr i} {
		lappend colVals [set col$i]
	    }
	    return $colVals
	}
    }
    # Table is empty so return a list of blanks
    for {set i 0} {$i < $varNo} {incr i} {
	lappend colVals ""
    }
    return $colVals
}

# outputToFile
#   Output summary of diagnostic table to a file in umui_jobs directory
#   Use string range to ensure neat format.
# Argument
#   mNumber : 1,2,3,4 for atmos, ocean etc

proc outputToFile {mNumber} {
    global env

    set mLetter [modnumber_to_letter $mNumber]
    set exp_id [get_variable_value EXPT_ID]
    set job_id [get_variable_value JOB_ID]
    set run_id $exp_id$job_id
    set file $env(HOME)/umui_jobs/$run_id.$mLetter.diags
    set text "Output diagnostics table to file $file ?"

    # Change message if user has no umui_jobs directory
    if {! [file exists $env(HOME)/umui_jobs]} {
	set text "Create directory $env(HOME)/umui_jobs and $text"
    }

    if {[multioption_dialog .output_diag_table_$mLetter "Are You Sure" $text "OK" "Cancel"]==0} { 

	# make standard output sub-directory if none exists
	if {! [file exists $env(HOME)/umui_jobs]} {
	    exec mkdir $env(HOME)/umui_jobs
	}
	set fn [open $file w]
	printDiagTable $fn $mNumber
	close $fn
    }
}

# printDiagTable
#   Output summary of current diagnostic selection to given stream.
# Arguments
#   fn : Stream
#   mNumber : 1,2,3,4 for atmos, ocean etc
# Comments
#   Takes selections from the currently open STASH table, or if STASH
#   not open (when called from jobsheet), reads from database.

proc printDiagTable {fn mNumber} {
    global stInstance stash_open stmsta diagTags

    initTags

    puts $fn "Key:"
    puts $fn "  I: Included or excluded"
    puts $fn "  P:  Package and include status $diagTags(inChar)A for include"
    puts $fn "  A: Available"
    puts $fn "  US: User or system diagnostic"
    puts $fn ""
    puts $fn "Sec Itm Diagnostic Name                     Time     Domain   Usage   I P  A US"
    puts $fn "-------------------------------------------------------------------------------"
    set mLetter [modnumber_to_letter $mNumber]
    if {[info exists stash_open($mNumber)] == 1} {
	set s $stInstance($mNumber,Root)
    
	set nDiags [plbMethod $s GetLength]

	set i 0
	# Column numbers relating to the variables in the list below
	foreach var [list sec itm desc tim dom use inc tag ava usr] {
	    set $var [plbMethod $s ColumnValue $i]
	    incr i
	}
	for {set i 0} {$i < $nDiags} {incr i} {
	    foreach var [list sec itm desc tim dom use tag inc ava usr] {
		set i$var [lindex [set $var] $i]
	    }
	    printOneDiag $fn $isec $iitm $idesc $itim $idom $iuse $iinc $itag $iava $iusr
	}
    } else {
	set nDiags [get_variable_value NDIAG_$mLetter]
	set sec [get_variable_array ISEC_$mLetter]
	set itm [get_variable_array ITEM_$mLetter]
	set tim [get_variable_array ITIM_$mLetter]
	set dom [get_variable_array IDOM_$mLetter]
	set use [get_variable_array IUSE_$mLetter]
	set tags [get_variable_array ITAG_$mLetter]
	set inc [get_variable_array IINC_$mLetter]

	set dTag [get_variable_array D_TAG]
	set dTagF [get_variable_array D_TAGF_$mLetter]
	set tagFlag() "Y"
	for {set i 0} {$i < [llength $dTag]} {incr i} {
	    set tagFlag([lindex $dTag $i]) [lindex $dTagF $i]
	}
	set tag ""
	for {set i 0} {$i < $nDiags} {incr i} {
	    if {$tagFlag([lindex $tags $i]) == "Y"} {
		lappend tag "$diagTags(inChar)[lindex $tags $i]"
	    } else {
		lappend tag "$diagTags(outChar)[lindex $tags $i]"
	    }
	}
	for {set i 0} {$i < $nDiags} {incr i} {
	    foreach var [list sec itm tim dom use tag inc] {
		set i$var [lindex [set $var] $i]
	    }
	    if {[info exists stmsta($mNumber,$isec,$iitm,srce)]==1} {
		if {$stmsta($mNumber,$isec,$iitm,srce)==2} {
		    set srce "USR"
		} else {
		    set srce "SYS"		
		}
		check_stash $isec $iitm $mNumber
		set diag $stmsta($mNumber,$isec,$iitm,name)
		set iava $stmsta($mNumber,$isec,$iitm,avail)
		printOneDiag $fn $isec $iitm $diag $itim $idom $iuse $iinc $itag $iava $srce
	    }
	}
    }
}

# printOneDiag
#   Print one line of the diagnostic table to a file.
# Arguments
#   fn : Stream for file
#   sec : Section no.
#   item : Item no.
#   diag : Diagnostic text description - from STASHmaster
#   tim,dom,use : Names of profiles
#   inc : Include status
#   tag : Tag. Including < or > indicator
#   ava : Availability status
#   srce : User or system 

proc printOneDiag {fn sec item diag tim dom use inc tag ava srce} {
    set desc [string range $diag 0 34]
    set usr [string index $srce 0]
    set string [format "%2s %3s %35s %-8s %-8s %-8s %1s %-2s %1s %1s" \
	    $sec $item $desc $tim $dom $use $inc $tag $ava $usr]
    puts $fn $string
}

# editProfile
#   Edit selected profile of appropriate type
# Arguments
#   mNumber : Model number
#   type : Profile type: time, domain or usage

proc editProfile {mNumber type} {
    global prof
    
    set mName [modnumber_to_name $mNumber] ; # ATMOS, OCEAN  etc

    set profNum $prof($mNumber,$type,active)

    # Maintain a list of profiles that are currently being edited
    if {[lsearch $prof($mNumber,$type,editList) $profNum] == -1} {
	lappend prof($mNumber,$type,editList) $profNum
    }

    set prefix [string tolower $mName]
    set Type [capitalise $type]
    set_variable_value PROFILE $profNum
    create_window $prefix\_STASH_$Type
}

# abandonSTASHProfile
#   Update information on which profiles are currently being edited
# Arguments
#   args : Needs to hold submodel id, profile type and profile number.

proc abandonProfile {args} {
    global prof stInstance stash_open

    set mLetter [lindex $args 0]
    set type [lindex $args 1]
    set profNum [get_value [lindex $args 2]]
    
    set mNumber [modletter_to_number $mLetter]

    if {$profNum == ""} {
	error "Need to update STASH window functions to pass in PROFILE to update_STASH"
    }
    # If STASH still open, update list of open profiles
    if {[info exists stash_open($mNumber)] == 1} {
	set editList $prof($mNumber,$type,editList)
	set i [lsearch $editList $profNum]
	set prof($mNumber,$type,editList) [lreplace $editList $i $i]
    }
}

# update_STASH
#   Update information on profile name after a profile input panel
#   is closed. Change profile names in diagnostics table to match.
# Arguments
#   args : Needs to hold submodel id, profile type and profile number.

proc update_STASH {args} {
    global prof stInstance stash_open

    set mLetter [lindex $args 0]
    set type [lindex $args 1]
    set profNum [get_value [lindex $args 2]]

    set mNumber [modletter_to_number $mLetter]

    if {$profNum == ""} {
	error "Need to update STASH window functions to pass in PROFILE to update_STASH"
    }

    # If STASH still open, update panel if appropriat
    if {[info exists stash_open($mNumber)] == 1} {
	# Get name of UMUI variable holding profile names
	set variable $prof($mNumber,$type,variable)

	# Get new profile name and original profile name
	set profName [get_variable_value $variable\($profNum\)]
	set origName $prof($mNumber,$type,$profNum)
	if {$origName != $profName} {
	    # Profile name has changed so modify profile entry...
	    set prof($mNumber,$type,$profNum) $profName
	    if {$origName != ""} {
		# ...and change name of profile wherever it appears in diag table
		set col $prof($mNumber,$type,diagCol)
		set s $stInstance($mNumber,Root)
		plbMethod $s SearchAndRep $col $origName $profName
	    }
	}
	# If this is a new profile, increment profile count
	if {$profNum > $prof($mNumber,$type,nProfs)} {
	    incr prof($mNumber,$type,nProfs)
	    set_variable_value $prof($mNumber,$type,countVar) $prof($mNumber,$type,nProfs)
	}
	# Unsets variable indicating this profile is being edited now
	abandonProfile $mLetter $type $profNum
    }
}

# readSTASHWindow
#   Reads contents of STASH diagnostics and profiles into stInstance 
#   structure
# Arguments
#   m : Model number

proc readSTASHWindow {m} {
    global stInstance diagTags

    set s $stInstance($m,Root)

    set nDiags [plbMethod $s GetLength]

    # Put contents of table into stInstance array
    set i 0
    foreach var [list isec item inam time domain usage iinc] {
	set col [plbMethod $s ColumnValue $i]
	for {set j 0} {$j < $nDiags} {incr j} {
	    set stInstance($m,$var,$j) [lindex $col $j]
	}
	incr i
    }
    # Set the tag to Y or N based on the STASH table column contents
    set tags [plbMethod $s ColumnValue 7]
    for {set j 0} {$j < $nDiags} {incr j} {
	if {[string index [lindex $tags $j] 0] == "$diagTags(inChar)"} {
	    set stInstance($m,itag,$j) "Y"
	} else {
	    set stInstance($m,itag,$j) "N"
	}
    }
    set stInstance($m,nDiags) $nDiags

    # Put list of profile names into stInstance array
    set l [modnumber_to_letter $m ] ; # A,O,S,W
    set stInstance($m,time)     [get_variable_array TIMPRO_$l]
    set stInstance($m,domain)   [get_variable_array DOMPRO_$l]
    set stInstance($m,usage)    [get_variable_array USEPRO_$l]

}

proc capitalise {word} {
    return "[string toupper [string index $word 0]][string range $word 1 end]"
}
