# componentLists.tcl
#   Contains routines for dealing with lists of components on a given
#   window id. The first few routines are concerned with which tables
#   exist on which panels.

# setTableVars
#   Gets all the values from all the tables on a panel and sets the
#   appropriate variable

proc setTableVars {win} {
    global Table

    set tables [getTableList $win]

    foreach n $tables {
	for {set i 0} {$i < $Table($n,nCols)} {incr i} {
    
 
	    if {$Table($n,State,$i) != 3} {
		# Only set if column is an input column.
         
		set var $Table($n,$i)
    	set_variable_array $var [getTableValues $n $i]
	    }
	}
    }
}

# removeTableVarBackup
#   Unsets the backup values of table variables

proc removeTableVarBackup {win} {
    global Table RestoreArray

    set tables [getTableList $win]

    foreach n $tables {
	for {set i 0} {$i < $Table($n,nCols)} {incr i} {
	    if {$Table($n,State,$i) != 3} {
		# Only unset if column is an input column.
		set var $Table($n,$i)
		unset RestoreArray($var)
	    }
	}
    }
}

# getTableList
#   Returns a list of all the tables on a panel.

proc getTableList {win} {
    global tablesOnWin
    
    if [info exists tablesOnWin($win)] {
	return $tablesOnWin($win)
    } else {
	return ""
    }
}

# addToWindowList
#   Registers instance of widget type $type in global widget $win
#   Currently only used for table widgets.

proc addToWindowList {type n} {
    global win tablesOnWin

    if [info exists tablesOnWin($win)] {
	if {[lsearch $tablesOnWin($win) $n] >=0} {
	    error "addToWindowList: Table $n already exists"
	}
    }
    lappend tablesOnWin($win) $n
    if {$type != "Table"} {
	error "addToWindowList: Need to extend this routine for any other use"
    }
}
    

# removeFromTableList
#   Remove the reference of table $n from the list of tables
#   in $win
# Arguments
#   win : Window name
#   n : Name of table

proc removeFromTableList {win n} {
    global tablesOnWin

    set i [lsearch $tablesOnWin($win) $n]
    set tablesOnWin($win) [lreplace $tablesOnWin($win) $i $i]
}

# getTableValues
#   Returns values from column $col of table $n

proc getTableValues {n col} {
    global Table

    set c $Table($n,TableId)
    if {$Table($n,Numbered)} {incr col}
    set vals [plbMethod $c ColumnValue $col]
    return $vals
}
    
