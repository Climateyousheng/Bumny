# compare_tables.tcl
#    Procedures to create a comparison between the contents of tables
#    in two different GHUI jobs.

# table_difference
#    Entry procedure with $line_no pointing to a line in $win_text
#    that is within a table.
# Global 
#    tables_compared: A list of tables already considered so tables are
#                     not done twice.

proc table_difference {win win_text line_no variable} {
    global tables_compared

    # Return if this table has already been compared
    set two_D_index [two_D_index $variable]
    set tab_start [find_table_start $win $win_text $line_no]
    set line [lindex $win_text $tab_start]

    set table_name [lindex $line 1]
    if [info exists tables_compared] {
	# Using window name avoids omission if two tables on different
	# windows have same name
	if {[lsearch $tables_compared "$table_name $win"]!=-1} {return ""}
    }
    lappend tables_compared "$table_name $win"

    # Get a list of variables on the table
    set var_list [get_table_vars $win $win_text $tab_start $two_D_index]

    set table1 [table_contents $var_list]
    swap_roots
    set table2 [table_contents $var_list]
    swap_roots
    return [compare_tables $table1 $table2]
}

proc find_table_start {win win_text line_no} {
    set line [lindex $win_text $line_no]
    for {set i [incr line_no -1]} { ([lindex $line 0]!=".table")&&($i>0) } {incr i -1} {
	set line [lindex $win_text $i]
    }
    if {$i<=0} {
	# This means a system error
	error "table title not found while searching window $win"
	return 0
    }
    return [incr i]
}

proc table_contents {var_list} {
    set i 0
    set len 0

    foreach var $var_list {
	set col($i) [get_variable_array $var]
	set length($i) [llength $col($i)]
	set len [max $len $length($i)]
	incr i
    }
    set list ""
    for {set row 0} {$row<$len} {incr row} {
	set line ""
	for {set colno 0} {$colno<$i} {incr colno} {
	    if {$row<$length($colno)} {
		set line "$line [lindex $col($colno) $row]"
	    } else {
		set line "$line Blank"
	    }
	}
	lappend list [list $line [expr $row+1]]
    }
    return $list
}

# get_table_vars
#    Return list of variables in the table being pointed to by line_no.

proc get_table_vars {win win_text l index} {
    set vars ""
    incr l
    
    while {[lindex [set line [lindex $win_text $l]] 0]!=".tableend"&&$l<[llength $win_text]} {
	if {[lindex $line 0]==".element"} {
	    set variable [lindex $line 2]
	    # If variable in table has a 2D variable index, 
	    # the following will substitute the index
	    if {$index!=-1 && [llength [split $variable "()"]] != 1 } {
		set variable "[lindex [split $variable "()"] 0](*,$index)"
	    }
	    lappend vars $variable
	}
	incr l
    }
    return $vars
}

# compare_tables
#    t1 and t2 each contain a list of table rows. This routine compares
#    the two and returns the difference.
# Method
#    The table information is written out to temporary files and the UNIX
#    diff function is applied to them. A catch is required because 
#    differing files are considered to be an error.

proc compare_tables {t1 t2} {

    set f1 [unique_jobfile]
    set f2 [unique_jobfile]
    set output [unique_jobfile]
    set n1 [open $f1 w]
    set n2 [open $f2 w]
    set l1 ""
    for {set i 0} {$i<[llength $t1]} {incr i} {
	puts $n1 [lindex [lindex $t1 $i] 0]
    }
    for {set i 0} {$i<[llength $t2]} {incr i} {
	puts $n2 [lindex [lindex $t2 $i] 0]
    }
    close $n1
    close $n2
    catch {[exec /bin/sh -c "diff $f1 $f2>$output"]}
    set o [open $output]
    set diff [read $o]
    close $o
    exec rm $f1 $f2 $output
    return $diff
}
proc compare_tables2 {t1 t2} {
    set diff ""
    set len1 [llength $t1]
    set len2 [llength $t2]

    set m [max $len1 $len2]
    for {set i 0} {$i<$m} {incr i} {
	set l1 [lindex [lindex $t1 $i] 0]
	set l2 [lindex [lindex $t2 $i] 0]
	set n1 [lindex [lindex $t1 $i] 1]
	set n2 [lindex [lindex $t2 $i] 1]

	if {$i>=$len1} {set l1 "Blank"}
	if {$i>=$len2} {set l2 "Blank"}
	if { $l1!=$l2 } {
	    set diff "$diff \n$n1<$l1 \n$n2>$l2\n"
	}
    }
    return $diff
}
    
proc two_D_index {variable} {
    set var_index     [lindex [split $variable "()"] 1]
    if [regsub {\*,} $var_index {} var_index] {
	set index $var_index
    } else {
	set index -1
    }
    return $index
}
