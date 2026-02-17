package provide GHUITable 1.0

# Need a SetBindings method for columns and for whole table
# Need columns with actions (State=2) - bind to columns only
# for neatness rather than to whole table
# Bind on sort button ?

# declareTable
#    Called to declare that a new table will be created. Sets up
#    global TVals array, scrollbars and canvas. Also sets up 
#    default settings

proc declareTable {f} {
    global PlbVals TVals
 
    set c $f.c

    # $c will be the id of this table
    set PlbVals($c,OuterFrame) $f

    # Default settings
    set TVals($c,DisplayRow) 0   ;# Row 0 will be shown at top of display

    
    return $c
}

# initialiseTable
#    Called to initialise or change parameters of a table
# arguments
#    c : Canvas name, used as table id
#    command : Name of command
#    args : list of arguments for command

proc initialiseTable {c command args} {
    global PlbVals
 
    if ![info exists PlbVals($c,OuterFrame)] {
	TableWarning $c "initialiseTable: Nonexistent table id $c"
	return 1
    }
    #if [info exists TVals($c,TableDisplayed)] {
	#TableWarning $c "initialiseTable: You cannot initialise table once it has been displayed"
	#return 1
    #}

    set argn [llength $args]

    switch $command \
	    SetRowRules    {set x 5} \
	    SetColRules    {set x 5} \
	    default        { \
	    TableWarning $c "initialiseTable: Invalid Command $command"; \
	    return 1}

    if {$x != $argn && $x != -1} {
	TableWarning $c "initialiseTable: Wrong number of args for $command. Got $argn, expected $x"
	return 1
    }
    #puts "Table$command $c $args"
    return [eval Table$command $c $args]
}

#############################################
# Note this function should no longer be used
# Delete if no errors/warnings are received.
#############################################
proc tableMethod {c command args} {
 
    set argn [llength $args]
   
    TableWarning $c "initialiseTable: Invalid Command $command"; \
    return 1
}

# TableSetColRules
#    Set minimum widths for entry boxes (including any number column)
#    Set active status; 1 for active, 0 for disabled
# RSH called from tableControl

proc TableSetColRules {c nCols numbered widths state foreground} {
    global PlbVals
 
    set PlbVals($c,numbered) $numbered
    # Set the requested active status, and whether column can take focus
    for {set i 0} {$i < $nCols} {incr i} {
	set PlbVals($c,State,$i) [lindex $state $i]
	set PlbVals($c,Foreground,$i) [lindex $foreground $i]
    }
}

# TableSetRowRules 
#   Initialise table size rules
# Arguments
#    MaxDisplay : Size of display area in units of rows
#    MaxLength MinLength: Maximum and minimum length of table
#    StartLength : Initial size of table
#    CloseGaps : Logical: Close up any gaps when deleting a line
# Result:
#    0 : Success
#    1 : Fatal error
#   -1 : Style warning
# RSH called from tableControl

proc TableSetRowRules {c MaxDisplay MaxLength MinLength StartLength CloseGaps} {
    global PlbVals TVals
   
    set warningCode 0

    if {$MaxLength < $MinLength} {
	TableWarning $c "TableSetRowRules: Maximum length is less than minimum length"
	return 1
    }
    if {$StartLength < $MinLength} {
	TableWarning $c "TableSetRowRules: Start length $StartLength \
		is less than minimum length $MinLength"
	return 1
    }
    if {$StartLength > $MaxLength} {
	TableWarning $c "TableSetRowRules: Start length is greater than maximum length"
	return 1
    }
    if {$MaxLength != $MinLength && $CloseGaps == 0} {
	TableWarning $c "TableSetRowRules: Variable length tables should \
		close gaps on deletion of lines"
	set warningCode -1
    }
    set PlbVals($c,MinLength)  $MinLength
    set PlbVals($c,MaxLength)  $MaxLength
    set PlbVals($c,MaxDisplay) $MaxDisplay
    set PlbVals($c,CloseGaps)  $CloseGaps
    set PlbVals($c,LastId)     [expr $StartLength - 1]

    # TableInitDisplayRow has previously been called. Now we can check that
    # value is valid.
    if {$TVals($c,DisplayRow) != 0} {
	if {[set code [tableInitDisplayRow $TVals($c,DisplayRow)!=0]] != 0} {
	    return $code
	}
    }

    return $warningCode

}
