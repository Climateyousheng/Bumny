package provide plb 1.0

# mplb.tcl
#
# Create a table comprised of listboxes. Advantages are speed. Disadvantages
# are that entries are not directly editable - Tk events are used to change
# contents.

proc Plb_Make {r args} {
    # This procedure adds a number of parallel scrolling listboxes
    # to an existing window.
    # This is an exported procedure for public use.
    #
    # See also the following exported procedures:

    # For public use:
    #   procs with _ characters are directly callable
    #   procs without _ are called via proc plbMethod
    #   Eventually all procs will be called via plbMethod

    #   PlbColumnValue, PlbGetRowContents, PlbGetEntry,
    #   PlbAddRows, PlbDeleteRows,
    #   PlbChangeColumn, Plb_Change_Row, PlbChangeEntry
    #   Plb_Select_Item, Plb_Selected_Item
    #   PlbGetLength
    #   PlbBlackInCol, PlbGreyOutCol
    #
    # The rows can1 be filled on entry and events bound to the boxes.
    # Some columns are editable. However, do not make columns both
    # editable and double-clickable.
    # argument:
    #  r                    is the root name for the listbox
    # options:
    #  -numcols             is the number of boxes
    #  -showrows            is number of rows to display
    #  -title               is the title above all the list boxes.
    #  -footnote            is the footnote at the bottom of the table
    #  -returnedit          a logical. If true a return is necessary on edits
    #  -superheadings       list of headings spanning more than one column
    #  -superheadingcols    list of list of columns the super headings span. One
    #                       list for each column.
    #  -columnheadings      is a list of all column headings
    #  -columnwidths        is a list containing the column widths
    #  -columnlists         is initial values, a list of lists for each column
    #  -columnbindings      is a list of bindings to the columns
    #  -columnedits         is a list of edit types. 0 for not editable.
    #                       1 for editable (via EntryBox). 2 for editable (via MouseClicks). 
    #  -sortbutton          is an integer to say if the list should be sorted
    #                       0: no sort.   1 sort ascending.  -1 sort descending 2 Tidy
    #  -sortorder           is a list of columns defining the sort heirachy
    #                       with the most important first
    #  -columnactive        0 is inactive         1 is active
    #  -columtypes          c:Character    i:Integer     r:Real   Used for sorting.   

    global PlbVals                 ; # hash table indexed

    global paste
    set paste "mouse"
    #set paste "cursor"

    # PlbVals($r,activeRow)    ; # active row for this table
    # PlbVals($r,activeCol)    ; # active column for this table
    # PlbVals($r,nRows)         ; # number of rows for this table
    # PlbVals($r,nCols)         ; # number of columns for this table
    # PlbVals($r,title)         ; # The title for the table.
    # PlbVals($r,Width,$col) ; # The width of a column.
    # PlbVals($r,columnActive,$col) ; # Is the column currently activated.
    # PlbVals($r,ColType,$col) ; # Is the column type.
    # PlbVals($master,lb_edit_in_prog)    ; # 1 if an edit is in progess and not
    # complete.
    
    set opt_list {}
    lappend opt_list {numcols 0}
    lappend opt_list {showrows 10}
    lappend opt_list {title {}}
    lappend opt_list {footnote {}}
    lappend opt_list {returnedit 0}
    lappend opt_list {superheadings {}}
    lappend opt_list {superheadingcols {}}
    lappend opt_list {font {helvetica 10}}
    #lappend opt_list {font {courier 9}}
    lappend opt_list {columnheadings {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19} }
    lappend opt_list {columnwidths {10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10} }
    lappend opt_list {columnlists {{} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {}} }
    lappend opt_list {columnbindings {{} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {}} }
    lappend opt_list {columnedits {{} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {}} }
    lappend opt_list {columnactive {1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1}}
    lappend opt_list {columntype   {c c c c c c c c c c c c c c c c c c c c} }
    lappend opt_list {sortbutton 0 }
    #lappend opt_list {sortorder {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19} }
    lappend opt_list {sortorder {0 1 2} }
    lappend opt_list {tablelength -1}

    # Check for invalid options
    PlbArgCheck $opt_list $args
    
    # Extract the no. of columns
    set index [lsearch -exact $args -numcols]
    if {$index == -1} {
	set numcols 0
    } else {
	set numcols [lindex $args [expr $index +1]]
    }
 
    # Initialise all the option variables using either the above defaults
    # or the user specified options
    foreach opt_element $opt_list {
        set [lindex $opt_element 0] \
		[PlbGetOpt -[lindex $opt_element 0] [lindex $opt_element 1] $numcols $args]
    }

    if [info exists PlbVals($r,activeRow)] {
	error "Plb_Make: Instance of table $r already exists"
    }
    
    set PlbVals($r,DisplayRow) 0
    set PlbVals($r,activeRow) 0
    set PlbVals($r,nCols) $numcols
    set PlbVals($r,MaxDisplay) $showrows
    set PlbVals($r,Super) $superheadings
    set PlbVals($r,SuperRange) $superheadingcols
    set PlbVals($r,Footnote) $footnote
    for {set i 0} {$i < $numcols} {incr i} {
        set PlbVals($r,Width,$i)        [lindex $columnwidths $i]
        set PlbVals($r,Heading,$i)      [lindex $columnheadings $i]
        set PlbVals($r,columnActive,$i) [lindex $columnactive $i]
        set PlbVals($r,ColType,$i)      [lindex $columntype $i]
	set PlbVals($r,Binding,$i)      [lindex $columnbindings $i]
	set PlbVals($r,ColEdit,$i)      [lindex $columnedits $i]
	set PlbVals($r,BoxName,$i) $r.list$i
    }
    if {$title == ""} {
	if {[set title [lindex $PlbVals($r,Super) 0]] == ""} {
	    set title $PlbVals($r,Heading,0)
	}
    }
    if {$title == ""} {
	set PlbVals($r,title) "Untitled"
    } else {
	set  PlbVals($r,title) $title
    }	    

    # standard settings   

    set fontStyle [lindex $font 0]
    set fontSizeMain [lindex $font 1]
    set fontSizeHead [expr $fontSizeMain]
    set fontSizeFoot [expr $fontSizeMain - 1]

    # Table headings level-1
    set PlbVals($r,fontH1) "$fontStyle $fontSizeHead bold"
    # Table col heading.
    set PlbVals($r,fontH2) "$fontStyle $fontSizeHead bold"
    # Table col footers.
    set PlbVals($r,fontFoot) "$fontStyle $fontSizeFoot"
    # Table data inactive
    set PlbVals($r,ColFontBold) "$fontStyle $fontSizeMain bold"
    # Table data active
    set PlbVals($r,ColFontMedium) "$fontStyle $fontSizeMain" 

    #set borderw_te  2 ; # borderwidth around a table element.
    set PlbVals($r,borderw_te) 2
    # Must be at least 1.
    #set borderw_col 1 ; # borderwidth around a column
    set PlbVals($r,borderw_col) 1
    set borderw_ch  1 ; # borderwidth for column headings
    #set hl_t        1 ; # highlight thickness for selected box.
    set PlbVals($r,hl_t) 1
    # 0 or 1 is OK.
    set borderw_tb  4 ; # borderwidth for groove on box round table
    # colour for selected background
    set PlbVals($r,selBgActive) RoyalBlue4
    # colour for selected background
    set PlbVals($r,selFgActive) white 
    # inactive columns stay same colour.
    set PlbVals($r,selBgInactive)  gray80     
    # inactive columns stay same colour.
    set PlbVals($r,selFgInactive)  black
    # set values for deactivated cols, those that no longer interact.
    set PlbVals($r,selFgDeactivated)  gray50
    set PlbVals($r,selBgDeactivated)  gray80
    #
    set PlbVals($r,normalFg) black
    set PlbVals($r,activeBg) $PlbVals($r,selBgActive)
    set PlbVals($r,tableBg) gray70
    set PlbVals($r,tableAbg) gray60

    set editbackground gray85
    set PlbVals($r,normalFg) $PlbVals($r,normalFg)
    set hl_b $PlbVals($r,selBgInactive)
    set hl_c $PlbVals($r,selFgInactive)
    set table_bg gray70 
    set table_abg gray60 
    set bright_col red

    # Delete default bindings
    bind Listbox <B2-Motion> {}

    # Make a frame for the headings, lists and footers.
    frame $r -borderwidth $borderw_tb -relief raised\
	    -background $table_bg
 
    set master [winfo toplevel $r]

    set PlbVals($master,lb_edit_in_prog) 0
    set PlbVals($master,prevTable) ""
    set PlbVals($master,prevListi)  ""

    # Ensure that selected items take the focus in the master
    bind $master   <ButtonPress-1>  {focus %W}

    # Make the title, super headings and column headings
    PlbMakeHeadings $r

    # Loop over number of columns and build up the lists.
    set nbm1 [expr $numcols -1]
    set list_last $PlbVals($r,BoxName,$nbm1)
    for {set i 0} {$i < $numcols} {incr i} {
        set listi $PlbVals($r,BoxName,$i)

        # make the list
        if {($PlbVals($r,Binding,$i) != "" && $PlbVals($r,Binding,$i) != "NONE" ) \
		|| ($PlbVals($r,ColEdit,$i) != 0 && $PlbVals($r,ColEdit,$i) != "")} {
	    PlbSetInteractive $r $i
        } else {
	    PlbSetInert $r $i
        }
        
        if {$PlbVals($r,columnActive,$i)} {
	    set sbg   $PlbVals($r,sbg_a,$i)
	    set sfg   $PlbVals($r,sfg_a,$i)
	    set sfont $PlbVals($r,sfont_a,$i)
	    set fg    $PlbVals($r,fg_a,$i) 
        } else {
	    set sbg   $PlbVals($r,sbg_d,$i)
	    set sfg   $PlbVals($r,sfg_d,$i)
	    set sfont $PlbVals($r,sfont_d,$i)
	    set fg    $PlbVals($r,fg_d,$i) 
        } 

        listbox $listi \
		-yscrollcommand "PlbDragAll $r $i" \
		-height $showrows -setgrid 1 -relief sunken \
		-width [lindex $columnwidths $i]\
		-selectbackground $sbg -selectforeground $sfg \
		-background $editbackground -foreground $fg\
		-font $sfont -selectborderwidth $PlbVals($r,borderw_te) \
		-highlightthickness $PlbVals($r,hl_t) -highlightcolor $hl_c \
		-highlightbackground $hl_b\
		-borderwidth $PlbVals($r,borderw_col) \
		-takefocus $PlbVals($r,takeFocus,$i)
	
	if { $PlbVals($r,ColEdit,$i) != 0 &&  $PlbVals($r,ColEdit,$i) != ""} {
	    # Listbox is editable
	    $listi config -exportselection false
	}

        grid $listi -in $r -row 3 -rowspan 1 \
		-column $i -columnspan 1 -sticky {ew}
        
	bindtags $listi [list Listbox all $listi plb$r plb$r\Col$i $master]

	# NOTE: Why is this calculated for each column...??
        # fill the list
        set PlbVals($r,nRows) 0
	# Has the number or rows been specified in the arguments
	if {$tablelength == "-1"} {
	    # tablelength not specified, take the length of the longest column
	    foreach column $columnlists {
		if {[llength $column] > $PlbVals($r,nRows)} {
		    set PlbVals($r,nRows) [llength $column] 
		}
	    }
	} else {
	    # tablelength was specified
	    set PlbVals($r,nRows) $tablelength
	}

        set column [lindex $columnlists $i]
	eval "$listi insert end $column"
	for {set j 0} {$j < [expr $PlbVals($r,nRows)-[llength $column]]} {incr j} {
	    $listi insert end ""
	}
	
        $listi activate 0
	
        # bind focus in to active the active row from previous.
        bind $listi <FocusOut> "+PlbSetActiveRow $r $i"

        bind $listi <FocusIn>   "+PlbSetSelectedItem $r $i"
        bind $listi <ButtonPress> "+PlbSetSelectedItem $r $i"

        # Bind movement up and down to changing selection
        bind $listi <KeyRelease-Down> "+PlbSetActiveRow $r $i"
        bind $listi <KeyRelease-Up>   "+PlbSetActiveRow $r $i"

	bind $listi <Right> "PlbMoveRow $r $i 1"
	bind $listi <Left>  "PlbMoveRow $r $i -1"
        
        # bind the double-click and space bar action defined on calling.
	
        bind $listi <space> "+PlbBindCommands $r $i"
        bind $listi <Double-1> "+PlbBindCommands $r $i"
	
	# RSH - Added up to the ; end for
	# add the "scrollable" tag to the list: bt_lb_scr_$r.
        # This is used to reposition repwin 
	set lbt [bindtags $listi]
        bindtags $listi $lbt

        # Make editable cols editable
        set edit_type $PlbVals($r,ColEdit,$i) 
        if { $edit_type != 0 && $edit_type != "" } {
	    bind $listi <Button-1> "[list PlbBindEdit $r $columnwidths \
		    $listi $edit_type $master $i %x]"
	   
	    bind $listi <space> [list PlbBindEdit $r $columnwidths \
		    $listi $edit_type $master $i %x]
      
	    bind $listi <B1-Motion> "PlbB1Motion $r %x $listi"

	    bind $listi <ButtonRelease-1> [list PlbListB1Release $r $listi $i]

	    bind $listi <Button-2> [list PlbListB2 $r $listi %x %y $master ]
	}
 
    } ; # endfor {set i 0} {$i < $numcols} {incr i}

    # Return the list of columns to the higher level
    # for actions defined at that level

    # Add the scroll bar and tag it as scrollable.
    scrollbar $r.scroll -command "PlbScrollAll $r" \
	    -highlightthickness $PlbVals($r,hl_t) -troughcolor $editbackground\
	    -background $table_bg -activebackground $table_abg
    grid  $r.scroll -in $r -row 3 -rowspan 1 \
	    -column $numcols -columnspan 1 -sticky ns
    grid columnconfigure $r $numcols -weight 0 
    
    set lbt [concat [bindtags $r.scroll] bt_lb_scr_$r]
    bindtags $r.scroll $lbt
    
    # RSH - PlbSetVisibleSelection equivalent to PlbButtonRelease1
    # Requires more arguments
    bind $r.scroll <ButtonRelease> "PlbSetVisibleSelection $r"
    bind $r.scroll <KeyRelease> "PlbSetVisibleSelection $r"

    # RSH Addition Buttonpress-1
    # Reposition repwin during scrolling
    bind  bt_lb_scr_$r <ButtonPress-1>  "PlbButtonPress1 $r $master"

    set PlbVals($r,ScrollBar) $r.scroll
    
    if {$sortbutton != 0} {
	set text "Sort"
	if {$sortbutton == 1} {
	    set sorttype "INCR"
	} elseif {$sortbutton == 2} {
	    set sorttype "TIDY"
	    set text "Remove Blank Lines"
	} else {
	    set sorttype "DESC"
	}
	button $r.sort -text $text -padx 0 -pady 0 \
		-font $PlbVals($r,fontH2) -foreground $PlbVals($r,normalFg) -relief raised \
		-highlightbackground $table_bg \
		-background $table_bg -activebackground $bright_col \
		-command "PlbSortColumns $r $sorttype"
	grid $r.sort -in $r -row 5 -rowspan 1 \
		-column 0 -columnspan $numcols -sticky {ew}

	# Allows user to change focus among widgets (up or down the window from the sort button)
	bind $r.sort <Down> "tab $PlbVals($r,win)"
	bind $r.sort <Up> "tab_up $PlbVals($r,win)"
    } 
    set PlbVals($r,activeRow) -1
    set PlbVals($r,activeCol) -1

} ; # endproc Plb_Make

proc setupTest {r} {

    for {set i 0} {[info commands .test$i]==".test$i"} {} {incr i}
    set w .test$i
    toplevel $w
    label $w.l -text "Commands for $r"
    entry $w.e -textvariable command($r)
    button $w.b -text "Eval" -command "eval plbMethod $r \$command($r)"
    pack $w.l $w.e $w.b
}

# PlbMakeHeadings
#   Create the various headings and footings for the table

proc PlbMakeHeadings {r} {
    global PlbVals

    set superHeadings $PlbVals($r,Super)

    # Loop over super headings and attach headings and columns.
    # Note that the scroll bar has its own super heading.
    set tableBg  $PlbVals($r,tableBg)
    set normalFg $PlbVals($r,normalFg)
    set fontHead $PlbVals($r,fontH1)
    set fontHead2 $PlbVals($r,fontH2)
    set fontFoot $PlbVals($r,fontFoot)
    set nCols    $PlbVals($r,nCols)

    set title $PlbVals($r,title)

    # Add the heading and footnote given in the argument.
    label $r.heading -anchor n -text $title -font $fontHead \
	    -foreground $normalFg -relief groove -background $tableBg
    grid $r.heading -in $r -row 0 -rowspan 1 \
	    -column 0 -columnspan $nCols -sticky {ew}

    if {$PlbVals($r,Footnote) != ""} {
	label $r.footnote -text $PlbVals($r,Footnote) \
		-font $fontFoot -foreground $normalFg -relief groove\
		-background $tableBg -justify left
	grid $r.footnote -in $r -row 5 -rowspan 1 \
		-column 0 -columnspan [expr $nCols +1] -sticky {ew}
    }

    set first_head 0
    set nsup [llength $superHeadings]
    for {set i 0} {$i < $nsup} {incr i} {
	# make super headings
	lappend list_supcol $r.sup$i ; # list of headings
	set num_heads [llength [lindex $PlbVals($r,SuperRange) $i]]
	set superHeading [lindex $superHeadings $i]

	# Determine what the actual width of the columns below a
	# superheading will be. (Column width is incr'd so that they
	# fit under the superheading with no gaps)
	set suplen [string length $superHeading]
	set totalheadlen 0
	set totalwidth 0
	foreach col [lindex $PlbVals($r,SuperRange) $i] {
	    set colheadlen [string length $PlbVals($r,Heading,$col)]
	    set totalheadlen [expr $totalheadlen + $colheadlen]
	    set totalwidth [expr $totalwidth + $PlbVals($r,Width,$col)]
	}
	if {($totalheadlen < $suplen) && ($totalwidth < $suplen)} {
	    for {set k 0} {$totalwidth < $suplen} {incr k} {
		set totalwidth [expr $totalwidth + $num_heads]
	    }
	    foreach col [lindex $PlbVals($r,SuperRange) $i] {
		set PlbVals($r,Width,$col) [expr $PlbVals($r,Width,$col) + $k]
	    }
	}

        if {$num_heads == 1} {
	    set supanchor w
        } else {
	    set supanchor center
        }
        label $r.sup$i -relief sunken \
		-text $superHeading -background $tableBg \
		-foreground $normalFg -font $fontHead -anchor $supanchor 
        grid $r.sup$i -in $r -row 1 -rowspan 1 \
		-column $first_head -columnspan $num_heads -sticky {ew}
        incr first_head $num_heads
    }

    # loop over columns and make the headers and footers
    for {set j 0} {$j < $nCols} {incr j} {
	
        # make the column header
        set width $PlbVals($r,Width,$j)
        set text  $PlbVals($r,Heading,$j)

	if {$width <= [string length $text]} {
	    set width [expr [string length $text] + 1]
	    set PlbVals($r,Width,$j) $width
	}

        set relief sunken
        label $r.ch$j -relief $relief \
		-background $tableBg \
		-width $width  -text $text\
		-foreground $normalFg -font $fontHead -anchor w
        grid $r.ch$j  -in $r -row 2 -rowspan 1 \
		-column $j -columnspan 1 -sticky {ew}
	
        # make column footer
        if {$PlbVals($r,Binding,$j) != "" && $PlbVals($r,Binding,$j) != "NONE"} {
	    set action "Active"
        } elseif {$PlbVals($r,ColEdit,$j) != "" && $PlbVals($r,ColEdit,$j) != 0} {
	    set action "Edit"
	} else {
	    set action "Inert"
        }
        label $r.cf$j -relief $relief -width $width\
		-foreground $normalFg -font $fontFoot \
		-text $action -background $tableBg
        grid $r.cf$j -in $r -row 4 -rowspan 1 \
		-column $j -columnspan 1 -sticky {ew}
	
    } ; # endfor {set j 0} {$j < $nCols}
    
} ; # end proc PlbMakeHeadings

####################################################################
# PlbListB2
#
# Description: Called when event <Button-2> generated on a Listbox.
#              The user is pasting directly into a listbox cell.
#              The entry box is created and the paste action invoked
#              on the entry box.
#
# Arguments: root      - root name for the listbox.
#            listi     - name of the listbox the user has clicked on.
#            x         - X coordinate relative to the listbox listi
#            y         - Y coordinate relative to the listbox listi
#            master    - pathname of the toplevel that contains root
####################################################################
proc PlbListB2 {r listi x y master} {
    global PlbVals paste
   
    set colNo [string range $listi end end]
    # Is table / column active
    if {$PlbVals($r,columnActive,$colNo)} {
	if {$paste == "mouse"} {
	    if {[winfo exists $r.repwin]} {
		PlbFlushEditBox $r
		PlbKillRepw $master $r
		update idletasks
	    }
	    event generate $listi <Button-1> -x $x -y $y
	    event generate $r.repwin.entry <ButtonRelease-2>
	}
	$listi selection clear 0 end
    }
} ; # endproc PlbListB2

################################################################
# PlbListB1Release
#
# Description: Causes the entry box to be drawn on the selected
#              listbox cell after drag scrolling.
#
# Arguments: root - root name for the listbox.
#            listi - name of the listbox the user has clicked on
################################################################
proc PlbListB1Release {r listi colNo} {
    global live_col val old_val PlbVals

    if {[winfo exists $r.repwin.entry] && $PlbVals($r,ColEdit,$colNo) == 1} {
	# Bring the entry box back into view after drag scrolling
	raise $r.repwin
	$r.repwin.entry configure -background white
	# Determine position of the selected cell.
	set pos [ lindex [$live_col($r) curselection ] 0 ]
	# RSH - 060199
	set PlbVals($r,pos) $pos

	# Table currently being shortened, selection is off the end of the table.
	if {$pos == ""} {return}
	$live_col($r) see $pos
	set val($r) [ $listi get $pos ]
	set old_val($r) $val($r)
	# Determine the position to place the entry box.
	set repwin_yhome [ PlbGetRepwY $r $live_col($r) ]
	place $r.repwin -in $live_col($r) \
                -anchor n -relx 0.5\
                -y $repwin_yhome
	update idletasks

	# Allows the user to draw out a selection in the entry box immediately
	event generate $r.repwin.entry <ButtonRelease-1>
    }
} ; # endproc PlbListB1Release

################################################################
# PlbB1Motion
#
# Description: Marks a selection out in the entry box and
#              synchronizes the view of the contents of the
#              entry box and the listbox.
#
# Arguments: root - root name for the listbox.
#            x - starting position for the selection.
#            listi - name of the listbox the user has clicked on
################################################################
proc PlbB1Motion {r x listi} {

    if {[winfo exists $r.repwin.entry]} {

	# Mark out selection
	set tkPriv(x) $x

	# At tk8.4 this needs to be:
	#  ::tk::EntryMouseSelect $r.repwin.entry $x
	# But better is to find an option that is supported at tk8.3 as well

	tkEntryMouseSelect $r.repwin.entry $x
    }
} ; # endproc PlbB1Motion

#################################################################
# PlbButtonPress1
#
# Description: <Button-1> has been pressed on the listbox or
#               scrollbar.  If the entry window exists, flush the
#               contents of the entry box into the listbox (if
#               necessary) and destroy the entry box.
#
# Arguments: root - root name for the listbox.
#            master - pathname of the toplevel that contains root
#################################################################
proc PlbButtonPress1 {r master} {
 
    if { [winfo exists $r.repwin ] } {
	PlbFlushEditBox $r
	PlbKillRepw $master $r
    }
} ; # endproc PlbButtonPress1

#################################################################
# PlbButtonRelease1
#
# Description: Button-1 has been released on the listbox/scrollbar
#              If the entry box exists destroy it - Why????
#
# Arguments: r      - root name for the listbox.
#            master - pathname of the toplevel that contains root
#################################################################
proc PlbButtonRelease1 {r master} {

    if { [winfo exists $r.repwin ] } {
	PlbKillRepw $master $r
    } 
} ; # endproc PlbButtonRelease1

# PlbSetSelectedItem 
#   Called when selection in a table is made, eg with the mouse or
#   Tab. Item is highlighted, underlined and brought into view
# Arguments
#   r : Table id
#   colNo : Column to highlight
# Method
#   When the column (listbox) is selected, an internal curselection is 
#   set. This is used to determine which row to highlight.

proc PlbSetSelectedItem {r colNo} {
    global PlbVals
    set listi $PlbVals($r,BoxName,$colNo)

    set PlbVals($r,activeCol) $colNo
    set row [$listi curselection]
 
    if {$row == ""} {
	if {$PlbVals($r,activeRow)==-1} {set PlbVals($r,activeRow) 0}
	$listi see $PlbVals($r,activeRow)
	$listi select set $PlbVals($r,activeRow) $PlbVals($r,activeRow)
	$listi activate $PlbVals($r,activeRow)
    } else {
	set PlbVals($r,activeRow) $row
    }
}

proc PlbScrollAll {r a1 a2 {a3 NULL} } {
    #
    # This procedure is for working with parallel scrolling list boxes.
    # This is a private procedure.
    #
    # It is the -command option in the scrollbar widget.
    # It allows both pull and click scrolling of the scrollbar to scroll all
    # the listboxes.
    # The command needs to be called as
    #   -command "PlbScrollAll $r"
    # where
    #  r is the root name of the table
    # The extra arguments (a1,a2,a3) are supplied by the scroll action by Tk. 
    # There may be two or three depending on the scroll action: pull or click.

    global PlbVals
    #puts "PlbScrollAll $a1 $a2 $a3"
    for {set i 0} {$i < $PlbVals($r,nCols)} {incr i} {
	set listbox $PlbVals($r,BoxName,$i)
	if {$a3 == "NULL"} {
	    # Third argument does not exist, just use the two
	    $listbox yview $a1 $a2
	} else {
	    $listbox yview $a1 $a2 $a3
	}
    }
} ; # end proc PlbScrollAll


proc PlbDragAll {r colNo a1 a2 } {
    #
    # This procedure is for working with parallel scrolling list boxes.
    # This is a provate procedure
    #
    # It is the -yscrollcommand option in the listbox widget.
    # It allows "drag" scrolling in one list box to also scroll the other list
    # boxes and reset the scroll bar 
    # The command needs to be called as
    #   -yscrollcommand " PlbDragAll $r $currColNo"
    # where
    #    r             is the root of the table
    #    currColNo     the name of the column whose scrolling has to be
    #                  matched by the scrolling of others
    # The extra arguments (a1,a2) are supplied by the scroll action by Tk. 
    global PlbVals
    
    # Reset the scrollbar so that it agrees with the list
    $PlbVals($r,ScrollBar) set $a1 $a2 

    # Obscure the Entry box while scrolling (needed to allow drag scrolling)
    #raise $PlbVals($r,BoxName,$colNo)
    if {[winfo exists $r.repwin]} {
	#lower $r.repwin
	raise $PlbVals($r,BoxName,$colNo)
    }

    set PlbVals($r,DisplayRow) [PlbNint [expr $a1*$PlbVals($r,nRows)]]
    for {set i 0} {$i < $PlbVals($r,nCols)} {incr i} {
	# Scroll all but the current column (which has already scrolled)
	if {$i != $colNo} {
	    $PlbVals($r,BoxName,$i) yview moveto $a1
	}
    }
} ; # end proc PlbDragAll

##############################################################################
# PlbBindEdit
#
# Description:
#
# Arguments: r            - root name for the listbox.
#            columnwidths - list containing the column widths
#            listi        - pathname of the selected listbox (column)
#            edit_type    - Flag to indicate whether the column is editable,
#                           not editable or replaceable.
#            master       - pathname of the toplevel that contains root
#            i            - column number
#            x            - X coordinate widget relative of the Button-1 click
##############################################################################
proc PlbBindEdit {r columnwidths listi edit_type master i x} {
  
    # This is a private procedure
    # The procedure binds for edit in the listbox
    global PlbVals live_col live_foot val old_val paste 
  
    if {$PlbVals($r,ColEdit,$i) == 1} {
	# Column can be edited
	set prevTable $PlbVals($master,prevTable)
	
	if {$r == $prevTable} {
	    # User has selected a cell in the same table.
	    if {[winfo exists $r.repwin.entry]} {
		PlbFlushEditBox $r
		PlbKillRepw $master $r
	    }
	} elseif {$prevTable != ""} {
	    # Changed tables
	    # Destroy entry box in previous table
	    if {[winfo exists $prevTable.repwin.entry]} {
		PlbFlushEditBox $prevTable
		PlbKillRepw $master $prevTable
	    }
	}
   
	set PlbVals($master,prevTable) $r
	set PlbVals($r,activeCol) $i

	if { (! [winfo exists $r.repwin]) && \
		(! $PlbVals($master,lb_edit_in_prog) ) &&\
		($PlbVals($r,nRows) > 0 )  &&\
		( $PlbVals($r,columnActive,$i) )}   {
	    # edit is NOT in progress   
	    set PlbVals($master,lb_edit_in_prog) 1
	    # Defines which column is active now.
	    set live_col($r) $listi
	    # and the footer                  
	    set live_foot($r) $r.cf$i  
	    $live_foot($r) configure -foreground $PlbVals($r,selBgActive)
	    #set lbWidth [winfo width $live_col($r)]
	    frame $r.repwin -borderwidth $PlbVals($r,borderw_te) -relief groove
	    catch " unset val($r) old_val($r) "
	    
	    set pos [ lindex [$listi curselection ] 0 ]
	    # RSH - 060199
	    set PlbVals($r,pos) $pos

	    $listi see $pos
	    set PlbVals($r,activeRow) $pos
	    $listi activate $pos
	    set val($r) [ $listi  get $pos ]
	    set old_val($r) $val($r)
	
	    if {($PlbVals($master,prevListi) != "") && ($PlbVals($master,prevListi) != $listi)} {
		$PlbVals($master,prevListi) selection clear 0 end
	    }

	    set PlbVals($master,prevListi) $listi
	    entry $r.repwin.entry -textvariable val($r) \
		    -width $PlbVals($r,Width,$i) \
		    -relief sunken -font $PlbVals($r,ColFontBold) \
		    -selectbackground $PlbVals($r,selBgActive)\
		    -selectforeground white\
		    -borderwidth $PlbVals($r,borderw_te) -background white\
		    -foreground $PlbVals($r,normalFg)
	    focus -force $r.repwin.entry
	    pack $r.repwin.entry -side left
	
	    set repwin_yhome [ PlbGetRepwY  $r $live_col($r) ]
	    place $r.repwin -in $live_col($r) \
		    -anchor n -relx 0.5\
		    -y $repwin_yhome 

	    if {$paste == "mouse"} {
		# paste into entry box where the mouse is.
		bind $r.repwin.entry <Button-2> "event generate $r.repwin.entry <Button-1> -x %x"
	    }

	    bind $r.repwin.entry <ButtonRelease-2> "PlbPaste $r"
	    bind $r.repwin.entry <ButtonRelease-1> "PlbTextSelect $r"

	    bind $r.repwin.entry <Return>  [list PlbReturnEntry $r]

	    # Make entry box visible
	    bind $r.repwin.entry <KeyRelease-Return> "raise $r.repwin"

	    bind $r.repwin.entry <Up> [list PlbEntryMoveRow $r -1]
	    bind $r.repwin.entry <KeyRelease-Up> "raise $r.repwin"

	    bind $r.repwin.entry <Down> [list PlbEntryMoveRow $r 1]
	    bind $r.repwin.entry <KeyRelease-Down> "raise $r.repwin"

	    bind $r.repwin.entry <Tab> [list PlbEntryMoveCol $r 1 $master]
	    bind $r.repwin.entry <KeyRelease-Tab> "raise $r.repwin"
	    bind $r.repwin.entry <Control-Key-Tab> [list PlbEntryMoveCol $r -1 $master]
	    bind $r.repwin.entry <Control-i> [list PlbAddLine $r 0]
	    bind $r.repwin.entry <Control-r> [list PlbRemoveLine $r active]

	    # Allow user to leave the table on pressing escape.
	    bind $r.repwin.entry <KeyPress-Escape> "eval \[list leaveOnEscape %K $PlbVals($r,win) $PlbVals($r,name)\]"
	    update idletasks
	   
	    # Sets the cursor position in the entry box
	    event generate $r.repwin.entry <Button-1> -x $x
	    raise $r.repwin
	    
    } else {
        # edit IS in progress. Forget any selections. 
        $listi selection clear 0 end
    } ; # endif { ! \[winfo exists $r.repwin\] } 
    }
} ; # endproc PlbBindEdit

##################################################################
# PlbEntryMoveCol
#
# Description:
#
# Arguments:
##################################################################
proc PlbEntryMoveCol {r direction master} {
    global PlbVals live_col live_foot old_val val

    # Flush contents of entry box inot listbox
    PlbFlushEditBox $r

    set colNo $PlbVals($r,activeCol)
    set nCols $PlbVals($r,nCols)
    set nFocusCols 0
    # Obtain a list of all the active columns
    for {set i 0} {$i < $nCols} {incr i} {
	if {$PlbVals($r,ColEdit,$i) != 0 && $PlbVals($r,columnActive,$i) != 0} {
	    lappend focusCols $i
	    incr nFocusCols
	}
    }
    if {$nFocusCols != 0} {
	# Find pos of colNo in the focusCols list
	set colId [lsearch $focusCols $colNo]
	incr colId $direction
	
	if {$colId == $nFocusCols} {
	    # At RH end of table
	    # Move to next row
	    set colNo [lindex $focusCols 0]
	    # Are we at end of table
	    if {[expr $PlbVals($r,pos) + 1] >= $PlbVals($r,nRows)} {return -code break}
	    incr PlbVals($r,pos)
	} elseif {$colId == -1} {
	    set colNo [lindex $focusCols [expr $nFocusCols - 1]]
	    # Are we at the beginning of table
	    if {[expr $PlbVals($r,pos) - 1] < 0} {return -code break}
	    incr PlbVals($r,pos) -1
	} else {
	    set colNo [lindex $focusCols $colId]
	}
    }
    set PlbVals($r,activeCol) $colNo
    # Clear selection on current column
    $live_col($r) selection clear 0 end
    # Get pathname of next/prev column
    set listBox $r.list$colNo
    set live_col($r) $r.list$colNo
    focus -force $r.repwin.entry
    # Set the entry box to the correct column width
    $r.repwin.entry configure -width $PlbVals($r,Width,$colNo)
    set PlbVals($master,prevListi) $r.list$colNo
    $live_foot($r) configure -fg $PlbVals($r,normalFg)
    set live_foot($r) $r.cf$colNo
    $live_foot($r) configure -fg $PlbVals($r,selBgActive)
    
    PlbRepositionEntry $r $listBox
    return -code break
} ; # end proc PlbEntryMoveCol

############################################################
# PlbRepositionEntry
#
# Description: Repositions Entry Box over another
#              listbox cell. Called from PlbEntryMoveCol and
#              PlbEntryMoveRow.
#
# Arguments: r - root name for the listbox
#            listi - the listbox over which to place repwin.
############################################################
proc PlbRepositionEntry {r listi} {
    global PlbVals live_col val old_val

    set pos $PlbVals($r,pos)
    
    $live_col($r) see $pos
    # Get the contents of the new cell
    set val($r) [$listi get $pos]
    set old_val($r) $val($r)

    # Obtain new position for the entry box and move it to there
    set repwin_yhome [PlbGetRepwY $r $live_col($r)]
    place $r.repwin -in $listi \
	    -anchor n -relx 0.5 \
	    -y $repwin_yhome
    # Update the active Row
    set PlbVals($r,activeRow) $pos
    $live_col($r) activate $pos
    $live_col($r) selection clear 0 end
    $live_col($r) selection set $pos $pos

    update idletasks
} ; # end proc PlbRepositionEntry

##################################################################
# PlbEntryMoveRow
#
# Description: Used by the keyboard bindings.  Moves the entry
#              box up or down a row.
#
# Arguments: r            - root name for the listbox.
#            direction    - Indicates addition (1) or removal (-1)
#                           of a row/column
##################################################################
proc PlbEntryMoveRow {r direction} {
    global live_col PlbVals
   
    # Flush contents of entry box inot listbox
    PlbFlushEditBox $r
    # RSH - 060199
    set pos $PlbVals($r,pos)
    
    # Ensure the next move would not take us off the ends of the table
    #if {[expr $pos + $direction] >= 0 \
	    #&& [expr $pos + $direction] < $PlbVals($r,nRows)} 
    if {[expr $pos + $direction] < 0 \
	    || [expr $pos + $direction] >= $PlbVals($r,nRows)} {
	# At an end of the table so do nothing
	return
    }
    incr PlbVals($r,pos) $direction   
    PlbRepositionEntry $r $live_col($r)

} ; # endproc PlbEntryMoveRow

proc PlbReturnEntry {r} {
    global PlbVals live_col old_val val

    # Flush contents of entry box inot listbox
    PlbFlushEditBox $r
    # BODGE - to prevent edit box being flushed twice
    # when PlbAddLine is called.
    set old_val($r) $val($r)

    if {$PlbVals($r,CloseGaps)} {
	# Add line after current row
	if {$PlbVals($r,pos) == [expr $PlbVals($r,nRows) - 1]} {
	    # Append line to end of table
	    set append 1
	} else {
	    incr PlbVals($r,pos)
	    set PlbVals($r,activeRow) $PlbVals($r,pos)
	    set append 0
	}
	PlbAddLine $r $append
	PlbRepositionEntry $r $live_col($r)
    } else {
	# Insertion not allowed just move down a row.
	PlbEntryMoveRow $r 1
    }
} ; # end proc PlbReturnEntry

##################################################################
# PlbAddLine
#
# Description: Called from the keyboard binding <Ctrl-i> to insert
#              a line at the current position. If the table is at
#              its max length, if there are blank lines at the end
#              of the table insert the last one at the current 
#              position. If the table is full do nothing. Otherwise
#              just insert a new row.
#
# Arguments: r            - root name for the listbox.
##################################################################
proc PlbAddLine {r append} {
    global PlbVals live_col

    set activeRow $PlbVals($r,activeRow)
    set nCols $PlbVals($r,nCols)
    set nRows $PlbVals($r,nRows)
    set MaxLength $PlbVals($r,MaxLength)
  
    # Flush contents of entry box inot listbox
    PlbFlushEditBox $r

    # Is the table already at its maximum length...?
    if {$nRows < $MaxLength} {
	# ...No, so insert row into each column
	if {$append} {
	    # Append a new line
	    for {set i 0} {$i < $nCols} {incr i} {
		# Does the table have an enumerated column...?
		if {$PlbVals($r,numbered) && $i == 0} {
		    # ...yes, Add row to bottom of enumerated col
		    eval "$PlbVals($r,BoxName,$i) insert end \
			    [expr [$PlbVals($r,BoxName,$i) get end] + 1]"
		} else {
		    # Add a row to the end of this column
		    eval "$PlbVals($r,BoxName,$i) insert end {}"
		}
	    }
	    incr PlbVals($r,pos)
	    set PlbVals($r,activeRow) $nRows
	} else {
	    # Insert a row before current row
	    for {set i 0} {$i < $nCols} {incr i} {

		# Add a blank row before activeRow
		# Does the table have an enumerated column...?
		if {$PlbVals($r,numbered) && $i == 0} {
		    # ...yes, Add row to bottom of enumerated col
		    eval "$PlbVals($r,BoxName,$i) insert end \
			    [expr [$PlbVals($r,BoxName,$i) get end] + 1]"
		} else {
		    # This column is not enumerated so insert a row
		    eval "$PlbVals($r,BoxName,$i) insert $activeRow {}"
		}
	    }
	}
	update idletasks
	# Update table length
	incr PlbVals($r,nRows)
    } else {
	# ...Yes, Table at maximum length so ...
	# no point in trying to create new line if all following lines are blank
	set blankList [PlbGetBlankLines $r]
	if {[lsearch $blankList $activeRow] >= 0} {return}

	# no room in table if last line is not blank
	set lastLine [expr $nRows - 1]
	if {[lsearch $blankList $lastLine] < 0} {return}
	# Cannot append line to a constant length table
	if {$activeRow != [expr $nRows - 1]} {
	    # Not inserting before the last row
	    # Move last row to line before activeRow
	    for {set i 0} {$i < $nCols} {incr i} {
		if {!$PlbVals($r,numbered) || $i != 0} {
		    eval "$PlbVals($r,BoxName,$i) insert $activeRow {}"
		    eval "$PlbVals($r,BoxName,$i) delete end"
		}
	    }
	    update idletasks
	}
    }
    # Move the edit box to the newly inserted line
    raise $r.repwin
    PlbRepositionEntry $r $live_col($r)

} ; # endproc PlbAddLine

################################################################
# PlbRemoveLine
#
# Description: Called by the keyboard binding <Ctrl-r> to remove
#              the current line. 
#
# Arguments: r            - root name for the listbox.
################################################################
proc PlbRemoveLine {r line } {
    global PlbVals live_col val old_val

    if {$line == "active"} {
	set activeRow $PlbVals($r,activeRow)
    } else {
	set activeRow $line
    }
    set nCols $PlbVals($r,nCols)
    set nRows $PlbVals($r,nRows)
    set MinLength $PlbVals($r,MinLength)

    PlbFlushEditBox $r

    # Get a list of the blank rows at the end of the table
    set blankList [PlbGetBlankLines $r]

    # Is the table at its minimum length...?
    if {$nRows == $MinLength} {
	# ...Yes, reset the row to blanks
	# and place at end of table to give the impression
	# of deleting a row.

	# No point deleting if row already blank and all following rows are blank
	if {[lsearch $blankList $activeRow] >= 0} {return}

	for {set i 0} {$i < $nCols} {incr i} {
	    # If column is enumerated don't do anything to it
	    if {!$PlbVals($r,numbered) || $i != 0} {
		# This column is not enumerated
	
		if {$PlbVals($r,CloseGaps) != 0} {
		    # Insert blank row at end of table then delete current row
		    eval "$PlbVals($r,BoxName,$i) insert end {}"
		    eval "$PlbVals($r,BoxName,$i) delete $activeRow"
		} else {
		    # Is column Editable? ...if so then blank this row do not move to end
		    if {$PlbVals($r,ColEdit,$i) != 0} {
			eval "$PlbVals($r,BoxName,$i) insert $activeRow {}"
			eval "$PlbVals($r,BoxName,$i) delete [expr $activeRow + 1]"
		    }
		}
	    }
	}
    } else {
	# ...No, Destroy row, unset the entries and reset display and scrollbars.
	incr PlbVals($r,nRows) -1

	for {set i 0} {$i < $nCols} {incr i} {
	    # Is this column enumerated...?
	    if {$PlbVals($r,numbered) && $i == 0} {
		# Delete the last row of the enumerated column
		eval "$PlbVals($r,BoxName,0) delete end"
	    } else {
		# Delete active row from column i
		eval "$PlbVals($r,BoxName,$i) delete $activeRow"
	    }
	}
    }
    update idletasks
    if {$line == "active"} {
	# Give focus to line below the one deleted.
	set val($r) [$live_col($r) get $activeRow]
	set old_val($r) $val($r)
	raise $r.repwin
    }
} ; # endproc PlbRemoveLine

##############################################################
# PlbGetBlankLines
#
# Description: Returns a list of the blank lines at the end of
#              a table. Start at the end of the table. 
#              Iterate through the rows checking to ensure
#              that each cell of the row is blank.  Stop when
#              the first non-blank row is encountered.
#
# Arguments:   r - root name for the listbox.
##############################################################
proc PlbGetBlankLines {r} {
    global PlbVals

    set nCols $PlbVals($r,nCols)

    set blankList {}
    # Start at the end of the table.
    for {set i $PlbVals($r,nRows)} {$i > 0} {} {
	incr i -1
	set blank 1
	# Go throught the columns
	for {set j 0} {$j < $nCols} {incr j} {
	    # If the column is enumerated no point in checking
	    # if blank as it always contains a value

	    # Note: This procedure is also called for STASH
	    # which doesn't know about PlbVals($r,numbered)
	    # hence the next test.
	    if {[info exists PlbVals($r,numbered)]} {
		if {!$PlbVals($r,numbered) || $j != 0} {
		    if { [$r.list$j get $i] != ""} {
			set blank 0
			break
		    }
		}
	    } else {
		# Enter here if called from STASH
		if { [$r.list$j get $i] != ""} {
		    set blank 0
		    break
		}
	    }
	}
	# Is the entire row blank?
	if $blank {
	    lappend blankList $i
	} else {
	    # ..No, stop here
	    break
	}
    }
    return $blankList
} ; # endproc PlbGetBlankLines

##################################################################
# PlbPaste
#
# Description: Obtains the contents of the clipboard or primary
#              selection and inserts it into the entry box at the
#              position of the cursor.
#
# Arguments: root - root name for the listbox.
##################################################################
proc PlbPaste {r} {

    if [catch {selection get} sel] {
	if [catch {selection get -selection CLIPBOARD} sel ] {
	    # no selection or clipboard data
	    return
	}
    }

    $r.repwin.entry insert insert $sel

    # Stop the current binding and suppress the bindings from any
    # remaining tags in the binding set order
    return -code break

} ; # endproc PlbPaste

##################################################################
# PlbTextSelect
#
# Description: Called by <ButtonRelease-1>.  If a selection has
#              been made in the entry box then it is added to the
#              clipboard to enable copying from one table cell to
#              another  
#
# Arguments:   r - root name for the listbox.
##################################################################
proc PlbTextSelect {r} {
    if {![catch {$r.repwin.entry index sel.first}]} {
	set data [string range [$r.repwin.entry get] [$r.repwin.entry index sel.first] \
		[expr [$r.repwin.entry index sel.last] - 1]]
	clipboard clear
	clipboard append $data
    }
    
} ; # endproc PlbTextSelect

# PlbBindCommands
#   Bound to tk actions requiring 
proc PlbBindCommands {r colNo} {
    global PlbVals

    set lbox $PlbVals($r,BoxName,$colNo)
    set command $PlbVals($r,Binding,$colNo)

    if {$PlbVals($r,columnActive,$colNo) == 1 && $command != "NONE" && $command != ""} {
	set colAndRow [Plb_Selected_Item $r]
	eval $command $r $colAndRow
    }
    # Check selected item is up to date as bindings that change the
    # contents of a listbox can affect the setting of the active row
    PlbSetSelectedItem $r $colNo
}

proc PlbSetActiveRow {r colNo} {
    global PlbVals

    set listbox $PlbVals($r,BoxName,$colNo)
    set PlbVals($r,activeRow) [$listbox index active]
}

################################################################
# PlbGetRepwY
#
# Description: Returns the position of the repwin window in the
#              y direction when it is over its column item.
#
# Arguments: r - root name for the listbox.
#            live_col    -
################################################################
proc PlbGetRepwY { r live_col } {
    global PlbVals

    set bb2 [ lindex [ $live_col bbox $PlbVals($r,pos) ] 1 ]
    return [expr $bb2 -2*$PlbVals($r,borderw_te) -$PlbVals($r,borderw_col) -$PlbVals($r,hl_t) -3 ]
} ; # endproc PlbGetRepwY 

#####################################################################
# PlbKillRepw
#
# Description: Destroys repwin, sets the flag to no edit in progress
#              and changes the footer colour.
#
# Arguments: master    - pathname of the toplevel that contains root.
#            root      - root name for the listbox.
#            live_foot - pathname of the footer of the active column.
#####################################################################
proc PlbKillRepw { master r} {
    global PlbVals live_foot
    
    if {[winfo exists $r.repwin]} {
	destroy $r.repwin
	set PlbVals($master,lb_edit_in_prog) 0
	$live_foot($r) configure -foreground $PlbVals($r,normalFg)
    }
} ; # endproc PlbKillRepw

#################################################################
# PlbLbReplace
#
# Description: Replaces a list element with another.
#
# Arguments: list_box - the list that contains the list element
#                       to be replaced. 
#            value    - the value to be inserted into the listbox
#################################################################
proc PlbLbReplace {r list_box value} {
    global PlbVals 
   
    $list_box  insert $PlbVals($r,pos) $value
    $list_box  delete [expr $PlbVals($r,pos) + 1]
} ; #endproc PlbLbReplace

proc PlbGetOpt {opt  default  numcols {arg_list {}} } {
    set index [lsearch -exact $arg_list $opt]
    if {$index == -1} {
	switch -- $opt {
	    -columnheadings {set default [PlbSetDefaults $numcols incre 0]}
	    -columnwidths   {set default [PlbSetDefaults $numcols const 10]}
	    -columnlists    {set default [PlbSetDefaults $numcols null n]}
	    -columnbindings {set default [PlbSetDefaults $numcols null n]}
	    -columnedits    {set default [PlbSetDefaults $numcols null n]}
	    -columnactive   {set default [PlbSetDefaults $numcols const 1]}
	    -columntype     {set default [PlbSetDefaults $numcols const c]}
	    default         {# value should be held in default}
	}
	return $default
    } else {
	return [lindex $arg_list [expr $index + 1]]
    }
} ; # endproc PlbGetOpt

proc PlbSetDefaults {numcols type value} {
    set default ""
    switch $type {
	incre {
	    set start $value
	    for {set i 0} {$i < $numcols} {incr i} {
		lappend default $start
		incr start
	    }
	}
	const {
	    for {set i 0} {$i < $numcols} {incr i} {
		lappend default $value
	    }
	}
	null {
	    for {set i 0} {$i < $numcols} {incr i} {
		lappend default {}
	    }
	}
	default {
	    error "plbTable: Invalid type $type";
	    return 1
	}
    }
    return $default
}
    
proc PlbArgCheck {opt_list  {arg_list {}} } {
    set opt_list_opts {}
    foreach element $opt_list {
	lappend opt_list_opts -[lindex $element 0] 
    }
    set list_len [llength $arg_list]
    for {set i 0} {$i < $list_len} {incr i 2} {
	set opt [lindex $arg_list $i]
	if {[lsearch -exact $opt_list_opts $opt] == -1} {
	    error "Invalid option for PLB_Make:   $opt"
	}
    }
} ; # endproc PlbArgCheck

# PlbSetVisibleSelection
#   Sets selection to an item that is within the current display. Called
#   when the scrollbar has stopped being manipulated by the user (ie on
#   a Key or ButtonRelease.

proc PlbSetVisibleSelection {r} {
    global PlbVals
    
    # Make sure that table has stopped moving, as it can continue to
    # scroll for a period after the release. NB "idletasks" is used
    # to avoid reacting to another button relese event that can 
    # cause havoc.
    update idletasks

    set activeRow [lindex [Plb_Selected_Item $r] 1]
    set displayed [PlbCheckDisplayed $r $activeRow]

    # Set selection to top line if current item scrolled of top,
    # to bottom line if it scrolled of bottom, or leave alone
    if {$displayed < 0} {
	Plb_Select_Item $r active $PlbVals($r,DisplayRow)
    } elseif {$displayed > 0} {
	Plb_Select_Item $r active [expr $PlbVals($r,DisplayRow)+$PlbVals($r,MaxDisplay)-1]
    }
}

# PlbSetInteractive
#   Sets colours that indicate to user that column has function
#   if double clicked

proc PlbSetInteractive {r colNo} {
    global PlbVals

    set PlbVals($r,sbg_a,$colNo) $PlbVals($r,selBgActive)
    set PlbVals($r,sfg_a,$colNo) $PlbVals($r,selFgActive)
    set PlbVals($r,sfont_a,$colNo) $PlbVals($r,ColFontBold)
    set PlbVals($r,fg_a,$colNo) $PlbVals($r,normalFg)
    set PlbVals($r,sbg_d,$colNo) $PlbVals($r,selBgDeactivated)
    set PlbVals($r,sfg_d,$colNo) $PlbVals($r,selFgDeactivated)
    set PlbVals($r,sfont_d,$colNo) $PlbVals($r,ColFontBold)
    set PlbVals($r,fg_d,$colNo) $PlbVals($r,selFgDeactivated)
    set PlbVals($r,takeFocus,$colNo) 1
}

# PlbSetInert
#   Sets colours that indicate to user that column has no function
#   if double clicked.

proc PlbSetInert {r colNo} {
    global PlbVals

    set PlbVals($r,sbg_a,$colNo) $PlbVals($r,selBgInactive)
    set PlbVals($r,sfg_a,$colNo) $PlbVals($r,selFgInactive)
    set PlbVals($r,sfont_a,$colNo) $PlbVals($r,ColFontMedium)
    set PlbVals($r,fg_a,$colNo) $PlbVals($r,normalFg)
    set PlbVals($r,sbg_d,$colNo) $PlbVals($r,selBgDeactivated)
    set PlbVals($r,sfg_d,$colNo) $PlbVals($r,selFgDeactivated) 
    set PlbVals($r,sfont_d,$colNo) $PlbVals($r,ColFontMedium)
    set PlbVals($r,fg_d,$colNo) $PlbVals($r,selFgDeactivated)
    set PlbVals($r,takeFocus,$colNo) 0
}

# PlbSaveSelection
#   Used to save current position of selection while items are altered.
#   This is because altering items requires actually replacing them. If an
#   item had the selection, then the selection highlighting would be lost.
# Arguments
#   r : Table id

proc PlbSaveSelection {r} {
    global SaveSelection
    
    set SaveSelection [Plb_Selected_Item $r]
}

# PlbRestoreSelection

#   Restores selection to that saved in plbSaveSelection - the
#   assumption being that the calling routine might have deleted the
#   selection highlight while modifying items
# Arguments
#   r : Table id
# Method
#   Calling routine first saves position of selection, then calls this
#   routine after making alterations to table. This ensures that
#   highlighting is not lost

proc PlbRestoreSelection {r} {
    global SaveSelection

    set selCol [lindex $SaveSelection 0]
    set selRow [lindex $SaveSelection 1]
    Plb_Select_Item $r $selCol $selRow
}

# PlbNint
#    Returns nearest integer to $v
proc PlbNint {v} {
    if {[regexp {[.]} $v] == 0} {return $v}
    return [expr [lindex [split $v .] 0] + [expr [string index [lindex [split $v .] 1] 0]/5]]
}

# MoveFocusTo
#    Moves focus to a given row and column ID and modify display
#    if new position is off display.
# Arguments
#    c : Canvas name and table id
#    colNo : Column number
#    lineId : Widget number of frame see Comment 2 at top

proc PlbMoveFocusTo {c colId lineId} {

    update idletasks

    event generate $c.list$colId <Button-1>
    focus $c.repwin.entry

    return $c.repwin.entry
}

# plbMethod
#   Wrapper for public methods. Checks for valid method and checks
#   number of arguments. Procedure that invokes method is same as
#   method but prefixed with "Plb".
# Arguments
#   r: Table id
#   command: Public method
#   args: List of arguments to send to command.
# Comments:
#   Additionally the table id $r is passed as an argument to the 
#   procedure that invokes the method.

proc plbMethod {r command args} {
    global PlbVals

    if ![info exists PlbVals($r,nRows)] {
	error "plbMethod: Nonexistent table id $r"
	return 1
    }

    set argn [llength $args]

    # Test for valid method and get expected number of arguments
    switch $command {
	AddRows         {set x -1 ;# Add one or more rows}
	DeleteRows      {set x  2 ;# Remove a range of rows}
	ClearTable      {set x  0 ;# Remove all rows}
	ColumnValue     {set x  1 ;# Return contents of column}
	GetActiveCol    {set x  0 ;# Get selected row even if focus not on table}
	GetActiveRow    {set x  0 ;# Get selected row even if focus not on table}
	GetSelectedRow  {set x  0 ;# Get row if focus on table}
	GetEntry        {set x  2 ;# Get contents of one box}
	GetRowContents  {set x  1 ;# Get contents of a whole row}
	GetLength       {set x  0 ;# Get number of rows in table}
	ChangeEntry     {set x  3 ;# Change contents of one box}
	ChangeColumn    {set x -1 ;# Change contents of a column (used in sort)}
	SearchAndRep    {set x  3 ;# Substitute rows with a given text}
	CheckDisplayed  {set x  1 ;# Returns value indicating whether row on display}
	MoveDisplayTo   {set x  1 ;# Scroll table to a given row}
	DestroyPlb      {set x  0 ;# Destroy instance of Plb table}
	BindAll         {set x -1 ;# Add a binding to the table}
	BindColumn      {set x -1 ;# Add a binding to one column}
	SortColumns     {set x  1 ;# Sort columns}
	OrderedSort     {set x -1 ;# Sort columns in the required order}
	ChangeColState  {set x  3 ;# Change the state of the column} 
	ChangeTableLength {set x 1 ;# Change the length of the table}
	GetActiveEntry  {set x  0 ;# Return widget name of an active entry}
	SetColumn       {set x  2 ;# Sets column of table to given values}
	ChangeRowRules  {set x  2 ;# Change minimum and maximum table lengths}
	ResetColState   {set x  3 ;# Resets the state of the given column}
	default         { 
	    error "plbTable: Invalid Command $command"; 
	    return 1
	}
    }

    # Check argument number. -1 implies that method allows variable arguments
    if {$x != $argn && $x != -1} {
	error "plbMethod: Wrong number of args for $command. Got $argn, expected $x"
	return 1
    }
    return [eval Plb$command $r $args]
}

# PlbBindAll
#   Bind all elements of a table to a command. Command 
#   will be called with arguments: column number, line number, 
#   event, args.
# Arguments
#   c : Canvas name and table id
#   command : command name
#   event : tk event description. eg space, Control-S, Button-1
#   args : Extra arguments for $command.

proc PlbBindAll {r command event args} {
    global PlbVals

    for {set colNo 0} {$colNo < $PlbVals($r,nCols)} {incr colNo} {
	PlbSetInteractive $r $colNo
	PlbBlackInCol $r $colNo
    }

    bind plb$r <$event> "+eval \[list PlbCallWithCoords $r $command $args\]"
}

# PlbBindColumn
#   Bind a command to a column, and change status of column to active
# Arguments
#   r : Table id
#   colNo : Column number
#   command : Name of callback
#   event : Tk event (Double-1, space etc)
#   args : Arguments for callback command
# Method
#   Actually binds the command "PlbCallWithCoords" to the row which
#   evals the command. This allows column and row to be added to 
#   argument list of command.

proc PlbBindColumn {r colNo command event args} {
    global PlbVals

    # Set colours to indicate that column is bound to a command
    PlbSetInteractive $r $colNo
    # Apply new colours
    PlbBlackInCol $r $colNo
    bind plb$r\Col$colNo <$event> "+eval \[list PlbCallWithCoords $r $command $args\]"
}

# PlbCallWithCoords
#   Calls bind command with currently selected row and column
# Arguments
#   r : Table id
#   command : Callback procedure
#   args : Argument list for callback

proc PlbCallWithCoords {r command args} {
    global PlbVals
    #puts "args are $args"
    set colAndRow [Plb_Selected_Item $r]
    eval $command $r $colAndRow $args
}

# PlbColumnValue
#   Procedure to return the contents of a column as a list.
# Arguments
#   r : Table id
#   index : Either "active" or the number of the col (starting at 0)

proc PlbColumnValue {r index} {
    global PlbVals 
    if {$index == "active"} {
	set index [lindex [Plb_Selected_Item] 1]
    }
    PlbFlushEditBox $r
    PlbKillRepw [winfo toplevel $r] $r
    return [$PlbVals($r,BoxName,$index) get 0 end]
} ; # endproc PlbColumnValue

# PlbGetRowContents
#   Procedure to return the contents of a row as a list.
# Arguments
#   r : Table id
#   index : The number of the row (starting at 0)
# Result
#   Returns a list of single element lists in keeping with the treatment
#   of multiple rows which are lists of multiple element lists.

proc PlbGetRowContents {r index} {
    global PlbVals 

    set list {}
    for {set i 0} {$i < $PlbVals($r,nCols)} {incr i} {
	lappend list [list [$PlbVals($r,BoxName,$i) get $index]]
    }
    return $list
} ; # endproc PlbGetRowContents

# PlbGetEntry
#   Procedure to return the contents of a row as a list.
# Arguments
#   r            Window name of the table
#   colNo,rowNo  Number of the column (starting at 0)

proc PlbGetEntry {r colNo rowNo} {
    global PlbVals 

    return [$PlbVals($r,BoxName,$colNo) get $rowNo]
} ; # endproc PlbGetEntry

# PlbAddRows
#   Add rows to an existing table
# Arguments
#   r : Table id
#   index : Indicates position in which to insert row/s
#   numRows : Number of rows being added
#   args : One argument per column. Each argument is a list - one
#          list item per row. So a single row is a list of single
#          element lists. eg {{column 1}} {{column 2} col3}

proc PlbAddRows {r index numRows args} {
    global PlbVals

    set nCols $PlbVals($r,nCols)

    if {$index == "before"} {
	set index [lindex [Plb_Selected_Item $r] 1]
    } elseif {$index == "after"} {
	set index [expr [lindex [Plb_Selected_Item $r] 1] + 1]
    }

    for {set i 0} {$i < $nCols} {incr i} {
	if {[lindex $args $i] != ""} {
	    eval "$PlbVals($r,BoxName,$i) insert $index [lindex $args $i]"
	} else {
	    # Request for a blank row - a plain "" does not add anything
	    # so a {} is required
	    for {set j 0} {$j < $numRows} {incr j} {
		if {[info exists PlbVals($r,numbered)] && $i == 0} {
		    # This is the first col which may enumerated.
		    if {$PlbVals($r,numbered) == 1} {
			# Add row to bottom of enumerated row
			eval "$PlbVals($r,BoxName,$i) insert end [expr [$PlbVals($r,BoxName,$i) get end] + 1]"
		    } else {
			eval "$PlbVals($r,BoxName,$i) insert $index {}"
		    }
		} else {
		    eval "$PlbVals($r,BoxName,$i) insert $index {}"
		}
	    }
	    #eval "$PlbVals($r,BoxName,$i) insert $index [lindex $args $i]"
	}
    }
    # Update table size
    set PlbVals($r,nRows) [$PlbVals($r,BoxName,0) size]

} ; # endproc PlbAddRows

# PlbClearTable
#   Delete all rows from table
# Argument
#   r : Table id

proc PlbClearTable {r} {
    global PlbVals

    set nRows $PlbVals($r,nRows)

    if {$nRows != 0} {
	PlbDeleteRows $r 0 $nRows
    }
}

# PlbDeleteRows
#   Delete a range of rows.
# Arguments
#   r : Table id
#   first : First row to delete. Can be "active", "end" or row number
#   last : Last row to delete. Can be "active", "end" or row number

proc PlbDeleteRows {r first last} {
    global PlbVals

    if {$first == "active"} {
	set first [lindex [Plb_Selected_Item $r] 1]
	if {$first == ""} {return}
    }
    if {$last == "active"} {
	set last [lindex [Plb_Selected_Item $r] 1]
	if {$last == ""} {return}
    }
    for {set i 0} {$i < $PlbVals($r,nCols)} {incr i} {
	eval "$PlbVals($r,BoxName,$i) delete $first $last" 
    }
    set PlbVals($r,nRows) [$PlbVals($r,BoxName,0) size]
    if {$PlbVals($r,nRows) > 0} {
	# Active row will be the row following the last deleted
	Plb_Select_Item $r active $first
    }
} ; # endproc PlbDeleteRows

# PlbChangeColumn
# Change the contents of a column.
# Arguments
#   r : Table id
#   colNo : Column number that is to be changed.
#   list : a list or part list of data to put into the column.
# Method
#   Lists shorter than the table are padded out with blanks

proc PlbChangeColumn {r colNo list} {
    global PlbVals

    PlbSaveSelection $r

    if {[llength $list] < $PlbVals($r,nRows)} {
	# pad the list.
	for {set i [llength $list]} {$i < $PlbVals($r,nRows)} {incr i} {
	    lappend list {}
	}
    }

    $PlbVals($r,BoxName,$colNo) delete 0 end
    eval $PlbVals($r,BoxName,$colNo) insert end $list

    # If the altered item was also the selected item, selection would
    # have been lost by the delete command. Therefore need to reinstate it.
    PlbRestoreSelection $r

} ; # endproc PlbChangeColumn

# PlbSearchAndRep
#   Search column for a given text, and replace
# Arguments
#   r : Table id
#   colNo : Column to alter
#   text1 : Text to replace
#   text2 : Replacement text

proc PlbSearchAndRep {r colNo text1 text2} {

    set newText ""
    set text [PlbColumnValue $r $colNo]
    foreach row $text {
	if {$row == $text1} {
	    lappend newText $text2
	} else {
	    lappend newText $row
	}
    }
    PlbChangeColumn $r $colNo $newText
}
# Currently unused procedure. Needs to be added to plbMethod list
# and changed to PlbChangeRow for consistency

proc Plb_Change_Row {r index list} {
    # Procedure to change the contents of a row.
    # r             is the window name of the table.
    # index         is the row to change, can be "active" "end" or row number
    # list          is a (part) list of data to put in the row.
    global PlbVals 
    if {$index == "active"} {
	set index [lindex [Plb_Selected_Item $r] 0]
	if {$index == ""} {return}
    }
    if {[llength $list] < $PlbVals($r,nCols)} {
	# pad the list.
	for {set i [llength $list]} {$i <= $PlbVals($r,nCols)} {incr i} {
	    lappend list {}
	}
    }
    for {set i 0} {$i < $PlbVals($r,nCols)} {incr i} {
	PlbChangeEntry $r $i $index [lindex $list $i]
    }
} ; #endproc Plb_Change_Row

# PlbChangeEntry
#   Procedure to change the contents of an entry
# Arguments
#   r        is the window name of the table.
#   colNo    is either "active" or the number of the column (starting at 0)
#   rowNo    is either "active", "end" or the number of the row (starting at 0)
#   element  is the element of data to use for replace.
# Result
#   1 if successful. 0 if nothing changed

proc PlbChangeEntry {r colNo rowNo element} {
    global PlbVals 

    # Save the current selection
    PlbSaveSelection $r

    if {$colNo == "active"} {
	set colNo $currCol
	if {$colNo == ""} {return 0}
    }
    if {$rowNo == "active"} {
	set rowNo $currRow
	if {$rowNo == ""} {return 0}
    }
    if {$rowNo >= $PlbVals($r,nRows)} {
	return 0
    }
    set currRow [$PlbVals($r,BoxName,$colNo) select includes $rowNo]
    set nextRow [$PlbVals($r,BoxName,$colNo) select includes [expr $rowNo + 1]]
    
    # Insertion before deletion works better when near table bottom
    $PlbVals($r,BoxName,$colNo) insert $rowNo $element
    $PlbVals($r,BoxName,$colNo) delete [expr $rowNo+1]
	
    # If the altered item was also the selected item, selection would
    # have been lost by the delete command. Therefore need to reinstate it.
    PlbRestoreSelection $r
    return 1
} ; # endproc PlbChangeEntry

# PlbMoveRow
#   Move focus right or left - if not already at edge
# Arguments
#   r : Root name of table
#   colNo : Current column number
#   direction : +1 or -1 for right or left

proc PlbMoveRow {r colNo direction} {
    global PlbVals

    set newCol [expr $colNo + $direction]
    set activeRow [lindex [Plb_Selected_Item $r] 1]

    if {$newCol >= 0 && $newCol < $PlbVals($r,nCols)} {
	focus $PlbVals($r,BoxName,$newCol)
	Plb_Select_Item $r $newCol $activeRow
    }
}

# Currently only a private procedure. If required for public use, it
# should to be added to plbMethod list and changed to PlbSelectItem
# for consistency

proc Plb_Select_Item {r colNo rowNo} {
    # Procedure to select an item
    # r             is the window name of the table.
    # colNo     is either "active" or the number of the column (starting at 0)
    # rowNo     is either "active", "end" or the number of the row (starting at 0)
    global PlbVals
 
    if {$colNo == "active"} {
	set colNo [lindex [Plb_Selected_Item $r] 0]
	if {$colNo == ""} {return}
    }
    if {$rowNo == "active"} {
	set rowNo [lindex [Plb_Selected_Item $r] 1]
	if {$rowNo == ""} {return}
    }
    if {$colNo != "" && $rowNo != ""} {
	#puts "SelectItem $rowNo"
	$PlbVals($r,BoxName,$colNo) see $rowNo
	$PlbVals($r,BoxName,$colNo) select clear 0 $PlbVals($r,nRows)
	$PlbVals($r,BoxName,$colNo) select set $rowNo $rowNo
	$PlbVals($r,BoxName,$colNo) activate $rowNo
	set PlbVals($r,activeRow) $rowNo
	set PlbVals($r,activeCol) $colNo
    }
} ; # endproc Plb_Select_Item

# Currently only a private procedure. If required for public use, it
# should to be added to plbMethod list and changed to PlbSelectedItem
# for consistency

proc Plb_Selected_Item {r} {
    # Procedure to return to col and row of the selected item.
    # Returns blanks if selection not set
    # r       is the window name of the table.
    global PlbVals
    #puts "r in PlbSelected_Item is $r"
    set selection [selection own -displayof $r]
    #puts "selection is $selection"
    if {$selection != ""} {
	set parent [winfo parent $selection]
    } else {
	set parent ""
    }
    #puts "parent is $parent, r is $r"
    if {$parent == $r} {
	#puts "Selected $PlbVals($r,activeCol) $PlbVals($r,activeRow)"
	return "$PlbVals($r,activeCol) $PlbVals($r,activeRow)"
    } else {
	#puts "Selected - Nothing"
	return [list "" ""]
    }
} ; # endproc Plb_Selected_Item

# PlbMoveDisplayTo
#   Scroll table so that row $rowNo is at top.
# Arguments
#   r : Table id
#   rowNo : Row number to move to.

proc PlbMoveDisplayTo {r rowNo} {
    global PlbVals

    set nRows      $PlbVals($r,nRows)
    set maxDisplay $PlbVals($r,MaxDisplay)
    set currentRow $PlbVals($r,DisplayRow)

    # Only need to move if table size bigger than display area
    if {$maxDisplay < $nRows} {

	# Check that $rowNo is within range
	if {$rowNo < 0} {
	    set rowNo 0
	} elseif {$rowNo > [expr $nRows - $maxDisplay]} {
	    set rowNo [expr $nRows - $maxDisplay]
	}

	set diff [expr $rowNo - $currentRow]
	PlbScrollAll $r scroll $diff units
    }
    # Return the new top line
    return $PlbVals($r,DisplayRow)
}

# PlbCheckDisplayed
#   Checks whether row is currently displayed. 
# Arguments
#   r : Table id
#   rowNo : Row number to check.
# Result
#   Returns 0 if row is displayed. 1 if row is below display
#   area and -1 if row is above display area

proc PlbCheckDisplayed {r rowNo} {
    global PlbVals

    set maxDisplay $PlbVals($r,MaxDisplay)
    set currentRow $PlbVals($r,DisplayRow)
    if {$rowNo < $currentRow} {
	return -1
    } elseif {$rowNo >= [expr $currentRow + $maxDisplay]} {
	return 1
    } else {
	return 0
    }
}

# PlbGetSelectedRow
#   Returns selected row if there is one

proc PlbGetSelectedRow {r} {
    global PlbVals
    set row [lindex [Plb_Selected_Item $r] 1]
    return $row
}

# PlbGetActiveCol
#   Returns last selected column regardless of whether focus is on
#   table or not

proc PlbGetActiveCol {r} {
    global PlbVals
    return $PlbVals($r,activeCol)
}

# PlbGetActiveRow
#   Returns last selected row regardless of whether focus is on
#   table or not

proc PlbGetActiveRow {r} {
    global PlbVals
    return $PlbVals($r,activeRow)
}

# PlbGetLength
#   Returns current length of table
# Arguments
#   r : Table id

proc PlbGetLength {r} {
    # Procedure to return the number of rows
    global PlbVals
    return $PlbVals($r,nRows)
} ; # endproc PlbGetLength

# PlbCurrentDisplay 
#   Return current top line

proc PlbCurrentDisplay {r} {
    global PlbVals
    return $PlbVals($r,DisplayRow)
}


# Currently only a private procedure. If required for public use, it
# should to be added to plbMethod list and changed to PlbGetNumCols
# for consistency

proc Plb_Num_Cols {r} {
    # Procedure to return the number of columns
    global PlbVals
    return $PlbVals($r,nCols)
} ; # endproc Plb_Num_Cols 

# PlbBlackInCol
#   Activate a column
# Arguments
#   r : Table id
#   colNo : Either "active" or the number of the column (starting at 0)
# Method
#   Changes colours and fonts and changes column footer to "Active".
#   Currently used to activate a column if a command is bound to it.
#   Not tested for toggling active status

proc PlbBlackInCol {r colNo} {
    global PlbVals  
    if {$colNo == "active"} {
	set colNo [lindex [Plb_Selected_Item $r] 0]
	if {$colNo == ""} {return}
    }
    set PlbVals($r,columnActive,$colNo) 1 
    $PlbVals($r,BoxName,$colNo) configure \
	    -selectbackground $PlbVals($r,sbg_a,$colNo) \
	    -selectforeground $PlbVals($r,sfg_a,$colNo) \
	    -foreground       $PlbVals($r,fg_a,$colNo) \
	    -font             $PlbVals($r,sfont_a,$colNo) \
	    -takefocus        $PlbVals($r,takeFocus,$colNo)
    $r.cf$colNo configure -text "Active"
} ; # endproc PlbBlackInCol

# PlbGreyOutCol
#   Grey out and deactivate a column
# Arguments
#   r : Table id
#   colNo : Either "active" or the number of the column (starting at 0)
# Method
#   Changes colours and fonts, and changes column footer to "Inert".
#   Not currently used.
#   Not tested for toggling active status

proc PlbGreyOutCol {r colNo} {
    # Procedure to deactivate a column
    # r             is the window name of the table.
    # colNo     is either "active" or the number of the column (starting at 0)
    global PlbVals  
 
    if {$colNo == "active"} {
	set colNo [lindex [Plb_Selected_Item $r] 0]
	if {$colNo == ""} {return}

    }
    set PlbVals($r,columnActive,$colNo) 0 
    $PlbVals($r,BoxName,$colNo) configure \
	    -selectbackground $PlbVals($r,sbg_d,$colNo) \
	    -selectforeground $PlbVals($r,sfg_d,$colNo) \
	    -foreground       $PlbVals($r,fg_d,$colNo)\
	    -font             $PlbVals($r,sfont_d,$colNo) \
	    -takefocus        $PlbVals($r,takeFocus,$colNo)

    $r.cf$colNo configure -text "Inert"
} ; # endproc PlbGreyOutCol

# PlbOrderedSort
#   Sorts values according to sort method $type and sort order.
# Arguments
#   args : List of columns that take preference

proc PlbOrderedSort {r type args} {
    global PlbVals
    # Get a list of column precedence
    set sortOrder [eval PlbGetSortOrder $r $args]
    if {[llength $sortOrder] == 0} {
	# No active columns so don't sort
	return 0
    }
    plbDoSort $r $type $sortOrder
}

# PlbSortColumns 
#   Sorts values according to sort method $type.

proc PlbSortColumns {r type} {
    # Get a list of column precedence
    set sortOrder [PlbGetSortOrder $r]
    if {[llength $sortOrder] == 0} {
	# No active columns so don't sort
	return 0
    }
    plbDoSort $r $type $sortOrder
}

proc plbDoSort {r type sortOrder} {
    global PlbVals

    # Flush contents of edit box to listbox
    PlbFlushEditBox $r
    PlbKillRepw [winfo toplevel $r] $r

    if {$type == "DESC"} {
	set sortOption decreasing
    } elseif {$type == "INCR"} {
	set sortOption increasing
    }

    set nRows $PlbVals($r,nRows)
    set nCols $PlbVals($r,nCols)

    set blankLines [PlbGetBlankLines $r]

    # Remove any blank lines amongst the non-blank lines
    if {[llength $blankLines] > 0} {
	# Blank Lines exist at end of table
	set notBlank [PlbRemoveBlankLines $r [lindex $blankLines end]]
    } else {
	# No Blank Lines at end of table
	set notBlank [PlbRemoveBlankLines $r $nRows]
    }

    if {$type == "TIDY"} {
	# blank lines have been removed so finish
	return
    }

    # Put the contents of all columns into lists
    for {set i 0} {$i < $nCols} {incr i} {
	if {[info exists PlbVals($r,numbered)] && $i == 0} {
	    # This is the first col which may be enumerated
	    if {!$PlbVals($r,numbered)} {
		# First col is not enumerated so sort it
		if {$notBlank == $nRows} {
		    # Sort whole table
		    set list($i) [PlbColumnValue $r $i]
		} elseif {$notBlank != 0} {
		    # Sort up to the first blank row
		    set list($i) [lrange [PlbColumnValue $r $i] 0 [expr $notBlank -1]]
		} else {
		    return
		}
	    }
	} else {
	    # Column not enumerated
	    if {$notBlank == $nRows} {
		# Sort whole table
		set list($i) [PlbColumnValue $r $i]
	    } elseif {$notBlank != 0} {
		# Sort up to the first blank row
		set list($i) [lrange [PlbColumnValue $r $i] 0 [expr $notBlank -1]]
	    } else {
		return
	    }
	}
    }
    # Number of rows to be sorted. (ie only those which are not blank)
    set nSortRows $notBlank

    for {set i 0} {$i < $nSortRows} {incr i} {
	# loop over rows making an ordered line and appending it to a big list
	set line {}
	foreach col $sortOrder {
	    lappend line [lindex $list($col) $i]
	}
	lappend line $i         ;# put an index on the end
	lappend bigList $line
    }
  
    # Sort the list according to the PlbSortCommand rules
    if {![info exists bigList]} {
	#Nothing to sort
	return
    }
    set sortedBigList [lsort -$sortOption -command PlbSortCommand $bigList]
    for {set col 0} {$col < $nCols} {incr col} {
	# initialise newList that holds an ordered list for each box
	set newList($col) {}
    }

    # Write the column lists according to the new order
    foreach line $sortedBigList {
	# fill ordered list
	set row [lindex $line end]  ;# use the index on the end
	for {set col 0 } { $col < $nCols} {incr col} {
	    if {[info exists PlbVals($r,numbered)] && $col == 0} {
		# This is the first col which may enumerated.
		if {!$PlbVals($r,numbered)} {
		    # First col is not enumerated so sort it.
		    lappend newList($col) [lindex $list($col) $row] 
		}
	    } else {
		lappend newList($col) [lindex $list($col) $row] 
	    }
	}
    }
 
    # Alter the table values
    for {set col 0} {$col < $nCols} {incr col} {
	if {[info exists PlbVals($r,numbered)] && $col == 0} {
	     # This is the first col which may enumerated.
	    if {!$PlbVals($r,numbered)} {
		# First col is not enumerated so sort it.
		PlbChangeColumn $r $col $newList($col)
	    }
	} else {
	    PlbChangeColumn $r $col $newList($col)
	}
    }
} ; # endproc PlbSortColumns

#####################################################
# PlbRemoveBlankLines
#
# Description: Removes all the blank lines amongst 
#              the non-blank lines.  If the table is
#              at the min length then the removed
#              lines are moved to the end of the table
#              o/w they are deleted.
#
# Arguments: r - root name for the listbox.
#            first - last non-blank line in the table
#####################################################
proc PlbRemoveBlankLines {r first} {
    global PlbVals

    set nCols $PlbVals($r,nCols)

    set list {}
    set notBlank 0

    # Start at the end of the table.
    #for {set i $PlbVals($r,nRows)} {$i > 0} {} 
    for {set i $first} {$i > 0} {} {
	incr i -1
	set blank 1
	# Go throught the columns
	for {set j 0} {$j < $nCols} {incr j} {
	    # If the column is enumerated no point in checking
	    # if blank as it always contains a value

	    # Note: This procedure is also called for STASH
	    # which doesn't know about PlbVals($r,numbered)
	    # hence the next test.
	    if {[info exists PlbVals($r,numbered)]} {
		if {!$PlbVals($r,numbered) || $j != 0} {
		    if { [$r.list$j get $i] != ""} {
			set blank 0
			break
		    }
		}
	    } else {
		# Enter here if called from STASH
		if { [$r.list$j get $i] != ""} {
		    set blank 0
		    break
		}
	    }
	}
	# Is the entire row blank?
	if $blank {
	    lappend list $i
	} else {
	    incr notBlank
	}
    }
    if [llength $list] {
	foreach line $list {
	    PlbRemoveLine $r $line
	}
    }
    return $notBlank
} ; # endproc PlbRemoveBlankLines
    
# PlbGetSortOrder
#   Compute an order of precedence for deciding how to sort.
#   Currently, precedence is in column order, excluding readonly columns

proc PlbGetSortOrder {r args} {
    global PlbVals

    set order $args
    for {set i 0} {$i < $PlbVals($r,nCols)} {incr i} {
	if {[info exists PlbVals($r,numbered)] && $i == 0} {
	    # This is the first col which may enumerated.
	    if {!$PlbVals($r,numbered)} {
		# Column not enumerated so sort it
		if {[lsearch $order $i] == -1} {
		    lappend order $i
		}
	    }
	} else {
	    if {[lsearch $order $i] == -1} {
		lappend order $i
	    }
	}
    }
    return $order
}

# PlbSortCommand
#   Command used by lsort to determine precedence of pairs of rows.
# Arguments
#   item1,item2: List of column contents of two rows to be compared
#                plus an index number at the end.
# Method
#   If first column identical, compares second, and so on.
# Result
#   Returns -1 if item1 < item2 and 1 for vice versa. Returns 0
#   if lists are identical

proc PlbSortCommand {item1 item2} {

    for {set i 0} {$i < [llength $item1]} {incr i} {
	set a [lindex $item1 $i]
	set b [lindex $item2 $i]
	if {$a<$b} {
	    return -1
	} elseif {$b<$a} {
	    return 1
	}
    }
    # This point never reached because of the index added by the sort routine
    return 0
}

# PlbDestroyPlb
#   Destroy instance of Plb and its variables

proc PlbDestroyPlb {r} {
    global PlbVals    
    
    # Remove all bindings from tags
    for {set i 0} {$i < $PlbVals($r,nCols)} {incr i} {
	set col plb$r\Col$i
	foreach event [bind $col] {
	    bind $col $event ""
	}
    }
    foreach event [bind plb$r] {
	bind plb$r $event ""
    }

    # Destroy the table instance
    destroy $r

    # Tidy PlbVals array
    foreach index [array names PlbVals $r,*] {
	unset PlbVals($index)
    }
}
#########################################################
# PlbFlushEditBox
#
# Description: Flush contents of edit box, if it exists,
#              to listbox.
# Arguments: r - root name for the listbox.
#########################################################
proc PlbFlushEditBox {r} {
    global live_col val old_val

    if {[winfo exists $r.repwin]} {
	# Entry box exists
	if { $old_val($r) != $val($r) } {
	    # The user has partly changed the value
	    # the call states that part edits are to be accepted.
	    # replace the value and destroy .repwin 
	    PlbLbReplace $r $live_col($r) $val($r)
	}
    }
} ; # endproc PlbFlushEditBox

##########################################################
# PlbChangeColState
#
# Description: Grays out a column or enables a column.
#
# Arguments: r    - root name for the column listbox.
#            colNo         - Column number
#            newState      - either enable or disable
#            newForeground - colour of the text fo be used
##########################################################
proc PlbChangeColState {r colNo newState newForeground} {
    global PlbVals

    if $PlbVals($r,numbered) {incr colNo}
    $r.list$colNo configure -fg $newForeground
    if {$newState == 1} {
	$r.list$colNo selection clear 0 end
	# Change column footer
	set PlbVals($r,columnActive,$colNo) 1
	$r.cf$colNo config -text "Edit"
	# Enable the sort button
	if {[winfo exists $r.sort]} {
	    $r.sort configure -state normal
	}
    } else {
	# Disabled
	PlbFlushEditBox $r
	PlbGreyOutCol $r $colNo
	# Disable the sort button
	if {[winfo exists $r.sort]} {
	    $r.sort configure -state disabled
	}
    }
} ; # endproc PlbChangeColState

#######################################################
# PlbChangeTableLength
#
# Description: Delete or Add rows to the min or max
#              length allowable for the table.
#
# Arguments: r - root name for the table
#            newLength - new length of the table.
#######################################################
proc PlbChangeTableLength {r newLength} {
    global PlbVals

    set nRows $PlbVals($r,nRows)

    if {$newLength > $nRows} {
	# Request to add new rows
	set newLength [min $newLength $PlbVals($r,MaxLength)]
	PlbAddRows $r end [expr $newLength-$nRows]
	update idletasks
    } elseif {$newLength < [max $nRows $PlbVals($r,MinLength)]} {
	# Request to delete some rows
	set newLength [max $newLength $PlbVals($r,MinLength)]
	PlbDeleteRows $r $newLength end
    }
    return 0
} ; # endproc PlbChangeTableLength

########################################################
# PlbGetActiveEntry
#
# Description: Returns the widget name of an active
#              table entry table - the first column of 
#              the row displayed at the top. Returns 0
#              if no active columns.
########################################################

proc PlbGetActiveEntry {r} {
    global PlbVals
  
    if {$PlbVals($r,nRows) == 0} {return 0}

    set found 0
    for {set i 0} {$i < $PlbVals($r,nCols)} {incr i} {
	if {($PlbVals($r,columnActive,$i) != 0) && ($PlbVals($r,ColEdit,$i) != 0)} { 
	    set found 1
	    break
	}
    }
    if $found {
	set lineId $PlbVals($r,DisplayRow)
	set colId $i
	return [PlbMoveFocusTo $r $colId $lineId]
    } else {
	return 0
    }
}

########################################################
# PlbSetColumn
#
# Description: Sets column of table to given values
#
# Arguments: r       - Table id
#            colNo   - Number of column
#            newVals - List of values. Can be shorter or
#                      longer than table.
########################################################
proc PlbSetColumn {r colNo newVals} {
    global PlbVals

    $r.list$colNo delete 0 end
    for {set i 0} {$i < $PlbVals($r,nRows)} {incr i} {
	$r.list$colNo insert $i [lindex $newVals $i]
    }
}

########################################################
# PlbChangeRowRules
#
# Description:  Change minimum and maximum table lengths
########################################################
proc PlbChangeRowRules {r MaxLength MinLength} {
    global PlbVals
 
    if {$MaxLength < $MinLength} {
	TableWarning $r "TableSetRowRules: Maximum length is less than minimum length"
	return 1
    }
    set PlbVals($r,MinLength)  $MinLength
    set PlbVals($r,MaxLength)  $MaxLength
    return 0
}

# plbResetColState 
#   Resets the state of the given column and changes the display
proc PlbResetColState {r colNo newState newForeground} {
    global PlbVals
 
    if { $newState == "" } {set newState $PlbVals($r,State,$colNo)
    }
    if { $newForeground == "" } {set newForeground $PlbVals($r,Foreground,$colNo)}
    if {$PlbVals($r,State,$colNo) != $newState || $PlbVals($r,Foreground,$colNo) != $newForeground} {
	# Change of state
	set PlbVals($r,State,$colNo) $newState
	set PlbVals($r,Foreground,$colNo) $newForeground
	#ChangeState $r $colNo
	PlbChangeColState $r $colNo $newState $newForeground
    }
    return 0
}
