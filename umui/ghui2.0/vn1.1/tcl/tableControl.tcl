
# GHUIcreateTable
#   This is the interface between the GHUI table code and the Table
#   package.
# Comments
#   It should be noted that settings of the Table array minimum and maximum
#   lengths do not always correspond with the settings given to the Table 
#   widget. For example, a table controlled by an entry box only changes
#   its length when the value in the entry box changes. As far as the Table
#   package is concerned then, the minimum and  maximum widths set for the
#   widget need to be identical. If the entrybox value is changed, the min
#   and max values are changed accordingly. The GHUI has its own limit on 
#   on the table size which depend on the GHUI array variable max sizes -
#   these are the min and max size set in the Table array.

proc GHUIcreateTable {n} {
    global Table PlbVals tab_list win in_case in_invis in_colour cases case_no fonts

    set nSuper $Table($n,nSuper)
    # Set up a list for each superheading containing the col numbers
    # it spans.
    for {set i 0} {$i < $nSuper} {incr i} {
	set lastcol [lindex $Table($n,lastCol) $i]
	if {$lastcol != 0 && $i == 0} {
	    # First superheading starting a column 0
	    for {set j 0} {$j <= $lastcol} {incr j} {
		lappend colspan $j
	    }
	    lappend supercols $colspan
	} elseif {$i != 0} {
	    # Not the first superheading. 
	    # Determine which col superheading starts spanning.
	    set firstcol [lindex $Table($n,lastCol) [expr $i - 1]]
	    for {set j [expr $firstcol + 1]} {$j <= $lastcol} {incr j} {
		lappend colspan $j
	    }
	    lappend supercols $colspan
	} else {
	    # Superheading for column one only
	    lappend supercols 0
	}	
	set colspan ""
    }
    set nCols $Table($n,nCols)
    # Set up the flags to indicate whether a column is editable.
    for {set i 1} {$i <= $nCols} {incr i} {
	if {$Table($n,State,[expr $i - 1]) == 3} {
	    # column not editable
	    lappend colEdits 0
	} else {
	    # column editable
	    lappend colEdits 1
	}
    }
    # Determine the sort order for the table
    if {$Table($n,SortOrder) == "DESC"} {
	# Decreasing
	set sortbutn -1	
    } elseif {$Table($n,SortOrder) == "INCR"} {
	# Increasing
	set sortbutn 1
    } elseif {$Table($n,SortOrder) == "TIDY"} {
	# Remove Blank Lines
	set sortbutn 2
    } else {
	# No sorting
	set sortbutn 0
    }
    
    set f [component_name centre]
    frame $f

    # Declare the table and store its id
    set c [declareTable $f]
    set Table($n,TableId) $c

    set PlbVals($c,name) $n
    set PlbVals($c,win) $win

    # Keyboard bindings.  Whether or not focus is allowed.
    lappend tab_list($win) $n
    if {$Table($n,SortOrder) != "NONE"} {
	lappend tab_list($win) $c.sort
	if {$in_case || $in_invis || $in_colour} {
	    lappend cases($case_no) "tablebutton $c.sort"
	}
    }

    # Rules concerning the number and state of columns
    set numbered $Table($n,Numbered)
    
    #set PlbVals($c,numbered) $numbered
    set widths $Table($n,Width)
    for {set i 0} {$i < $nCols} {incr i} {
	lappend state $Table($n,State,$i)
    }

    set foreground ""
    initialiseTable $c SetColRules $nCols $numbered $widths $state $foreground

    # Ensure length of each column not longer than nRows
    for {set i 0} {$i < $Table($n,nCols)} {incr i} {
	set values [lrange [lindex $Table($n,Values) $i] 0 [expr $Table($n,nRows) - 1]]
        lappend tableValues $values
    }

    set colTypes $Table($n,DataType)
    if {$Table($n,Numbered) == 1} {
	set autonums ""
	
	# Table to contain a numbered column which is always the first
	for {set i 1} {$i <= $Table($n,nRows)} {incr i} {
	    lappend autonums $i
	}
	#set tableValues [linsert $Table($n,Values) 0 $autonums]
        set tableValues [linsert $tableValues 0 $autonums]
	
	# This column is always inert and of datatype i(nteger)
	set colEdits [linsert $colEdits 0 0]
	set colTypes [linsert $colTypes 0 i]
	incr nCols
    }

    set maxLength  $Table($n,nRows)
    set minLength  $Table($n,nRows)
    set nRows      $Table($n,nRows)
    if {$Table($n,SortOrder) == "NONE"} {
	set closeGaps  0
    } else {
	set closeGaps  1
    }

    # Rules concerning the number of rows
    if {[TableSetRowRules $c $Table($n,MaxDisplay) $maxLength $minLength $nRows $closeGaps]!=0} {
	return 1
    }
    
    # Test validity of font
    if {[llength $fonts(tables,entries)] != 2 || [catch {expr [lindex $fonts(tables,entries) 1]}]} {
	multioption_dialog .illegal_font "Illegal font" \
		"Illegal font \n\"$fonts(tables,entries)\" \nin appearance file \n\
		Use format \"name size\". Resetting to \"helvetica 10\"\n \
		Press OK to continue" \
		"OK"
	set fonts(tables,entries) "helvetica 10"
    }
    # Determine whether the table has superheadings
    if {$Table($n,nSuper) == 0} {
	Plb_Make $c -numcols $nCols -showrows $Table($n,MaxDisplay) \
                -title $Table($n,Title) -columnheadings $Table($n,Heading) \
                -columnwidths $Table($n,Width) \
                -columnlists $tableValues \
                -columnedits $colEdits  \
                -sortbutton $sortbutn \
		-columntype $colTypes \
		-tablelength $nRows \
		-font $fonts(tables,entries)
    } else {
	Plb_Make $c -numcols $nCols -showrows $Table($n,MaxDisplay) \
                -title $Table($n,Title) -columnheadings $Table($n,Heading) \
                -columnwidths $Table($n,Width) \
                -columnlists $tableValues \
                -columnedits $colEdits  \
                -sortbutton $sortbutn \
		-columntype $colTypes \
		-superheadings $Table($n,Super) \
		-superheadingcols $supercols \
		-tablelength $nRows \
		-font $fonts(tables,entries)
    }

    pack $c -pady 6
    pack $f
}

# GHUIdestroyTable 
#   Unset all the relevant elements of Table

proc GHUIdestroyTable {n} {
    global Table

    set c $Table($n,TableId)
    plbMethod $c DestroyPlb

    
    if [info exists Table($n,LinkVar)] {
	# Table is linked to an entry box variable
	set linkVar $Table($n,LinkVar)
	# Remove the table name from the list of tables linked to this entry.
	set i [lsearch $Table($linkVar) $n]
	set Table($linkVar) [lreplace $Table($linkVar) $i $i]

	# Clean up if no more tables linked
	if {$Table($linkVar) == ""} {unset Table($linkVar)}
    }
    
    # Unset entries for table $n
    foreach index [array names Table $n,*] {
	unset Table($index)
    }

    unset Table(currentTable,$n)
}
    
    
    

# Procedures used to modify an existing table

# entryboxUpdated
#   Called when any box is updated. Checks if the entry is linked to a
#   current table and alters the table as required. Calls routine to
#   deal with link variable.
# Arguments
#   entryComponent : Widget name of the entry box
#   var : GHUI Variable attached to the entry box

proc entryboxUpdated {entryComponent var} {
    global Table
  
    # Set the GHUI variable
    set value [$entryComponent get]
    set_variable_value $var $value

    # Apply change to any tables linked to this entry box
    if [info exists Table($var)] {
	foreach n $Table($var) {
	    if [info exists Table(currentTable,$n)] {
		if ![catch {set newLength \
			[expr [get_variable_value $Table($n,LinkVar)] $Table($n,LengthAdjustment)]}] { 
		    adjustTableLength $n $newLength
		}
	    }
	}
    }
    # Apply any changes to window cases and link variables
    apply_changes $var
}

# adjustTableLength
#   Adjusts length of table within the GHUI set limits.
# Arguments
#   n : Name of table
#   newLength : Requested length
# Comments
#   The GHUI does not want to allow the user to change the size of 
#   a table with the delete line and add line keyboard bindings. This
#   is done by setting the maximum and minimum size of the table widget
#   to be equal to each other. (The Table MaxLength and MinLength are 
#   the limits set by the GHUI rather than the Table package).

proc adjustTableLength {n newLength} {
    global Table

    set c $Table($n,TableId)
    # Ensure requested length is within GHUI limits
    set newLength [min $newLength $Table($n,MaxLength)]
    set newLength [max $newLength $Table($n,MinLength)]

    # Set the max/min lengths of the table
    plbMethod $c ChangeRowRules $newLength $newLength
    # Change the size of the table
    #PlbChangeTableLength $c $newLength
    plbMethod $c ChangeTableLength $newLength

    # State=3 columns have constant settings - from system database.
    # However, reducing and then increasing table size will result in
    # some values being blanked out of table. Therefore, on resizing,
    # reset these columns to initial value.
    for {set i 0} {$i < $Table($n,nCols)} {incr i} {
	if {$Table($n,State,$i) == 3} {
	    set ColVals [lindex $Table($n,Values) $i]
	    plbMethod $c SetColumn $i $ColVals
	}
    }
	    
    set Table($n,nRows) $newLength
}

# RSH - Still used with new tables - 981207
proc getActiveColumn {n} {
    global Table

    set c $Table($n,TableId)

    set box [plbMethod $c GetActiveEntry]

    if {$box == "NONE"} {
	return 0
    } else {
	return $box
    }
}

proc GHUITableColumnActive {n colNo} {
    global Table

    if {$Table($n,State,$colNo) != 3} {
	return 1
    } else {
	return 0
    }
}

# GHUITableLength
#   Return length of table $n

proc GHUITableLength {n} {
    global Table

    return $Table($n,nRows)
}

# GHUITableNCols
#   Return Number of columns (apart from number column) of table $n

proc GHUITableNCols {n} {
    global Table

    return $Table($n,nCols)
}

# GHUITableVariable
#   Return variable related to column $colNo in table $n

proc GHUITableVariable {n colNo} {
    global Table

    return $Table($n,$colNo)
}

# GHUITableIndexVar
#   Return index variable related variable $var

proc GHUITableIndexVar {n var} {
    global Table

    if $Table($n,Indexed) {
	if {$Table($n,Index,$var) != $Table($n,MasterIndex)} {
	    return $Table($n,Index,$var)
	}
    }
    return ""
}

# leaveOnEscape
#   Binding to whole table to leave on escape

proc leaveOnEscape {key win n} {
    if {$key == "Escape"} {
	leaveWidget $win $n
    }
}

