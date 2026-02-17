package provide GHUITable 1.0

# tableMain.tcl

# Global structures
#  PlbVals($c,numbered)   : Logical: does table have number column


#  Comments
# 1 Indexing of rows starts at 0.

# ChangeState
#    Change the state of a particular column
# Arguments
#    c : Canvas name and table id
#    colNo : Column number
# Comments
#    Called once one of the global state variables for colNo
#    has been changed. Computes entry box name and calls 
#    SetEntryStatus once for each row

proc ChangeState {c colNo} {
    global PlbVals
    
    
    if $PlbVals($c,numbered) {incr colNo}
    set column $PlbVals($c,BoxName,$colNo)
        
    # Change state of heading.
    # Add one to account for any enumerated column
    set headingNo $colNo
}

# ColumnActive
#   Returns 1 if column allows input, 0 otherwise
# Arguments
#    c : Canvas name and table id
#    colNo : Column number

proc ColumnActive {c colNo} {
    global PlbVals
    #puts "ColumnActive"
    set state $PlbVals($c,State,$colNo)

    if {$state == 1 || $state == 2} {
	return 1
    } else {
	return 0
    }
}	

# nint
#    Returns nearest integer to $v
proc nint {v} {
    if {[regexp {[.]} $v] == 0} {return $v}
    return [expr [lindex [split $v .] 0] + [expr [string index [lindex [split $v .] 1] 0]/5]]
}

proc max {a b} {if {$a>$b} {return $a} {return $b}}
proc min {a b} {if {$a<$b} {return $a} {return $b}}

proc TableWarning {c text} {
    puts $text
}

proc TableError {c text} {
    puts $text
}




