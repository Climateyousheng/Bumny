# Procedures for parsing and calculating value of arithmetical sums
# Handles +-/* operators and also array variables eg in the form of 
# a(x,y,z(c)). Routine uses Tcl split function to separate the elements
# of an expression so you cannot use +-/* or commas within array elements.
# ie no expressions and no 2D arrays within an array.
# eg a(x(y,z)) and a(x(y+z)) will not work. If necessary it would
# be easy to write a split function that accounts for level of
# parentheses.
# Assumes get_variable_value can provide value of
# variables when called with numerical elements eg a(2,3)
# If get_variable_value returns a blank, variable has not been set and is assumed to be 0

# proc sum_parse {sizef}
# Separates $sizef into variables/numbers and operators (+-/ or *), obtains
# numerical value of variables/numbers, concatenates with operators, evaluates 
# resulting sum and returns total
proc sum_parse {sizef} {
    #puts "sum_parse called with $sizef"
    set total ""
    set sum [split $sizef "+-/*"]
    # obtain a list of +,-,/ and * characters in $sizef
    if {[lindex $sum 0]==""} {
	# If eg -90, replaces with 0-90
	set sum [lreplace $sum 0 0 0]
    }
    set ops [get_operators $sizef]
    for {set i 0} {$i<=[llength $ops]} {incr i} {

	set element [getv [lindex $sum $i]]
	set total "$total $element [lindex $ops $i]"
    }

    #If any of the variables are not yet defined (ie blank) evaluating will cause error - return zero
    if [catch {set answer [expr $total]}] {set answer ""}
    return $answer
}

# proc getv {x}
# x is either an integer or a variable in the form var,var(y) or var(y,z)
# Separates out elements of array and calculates each one in turn.
# Because list of elements is split up at commas cannot handle array
# elements which are 2D arrays
# ie elements of A(B,C(D,E)) are split up into B /  C(D  / E)
# Could rewrite split to take account of level of parentheses 
proc getv {x} {
    #puts "getv $x"
    # Is x an integer
    if {[regexp {[A-Z]} $x]==0} {return $x}
    # Is x an element of an array variable
    if {[regexp {\(|\)} $x]==1} {
	set splitx [split_outer_brackets $x]
	set p1 [lindex $splitx 0]
	set p2 [split [lindex $splitx 1] ","]
	#puts "p1=$p1, p2=$p2"
	set vp2 {}
	# Obtain numerical value for each element and reform into a list
	# of arguments
	foreach element $p2 {
	    set velement [getv $element]
	    set vp2 "$vp2,$velement"
	}
	# Remove leading comma
	set vp2 [string range $vp2 1 end]
    
	#puts "vp2 is $vp2"
	set x "$p1\($vp2\)"
    }
    #puts "getting value of $x=[get_variable_value $x]"
    # $x should now be in form that can be read by get_variable_value
    # ie an element of an array with numerical arguments (eg A(2,3)) 
    if [catch {set result [get_variable_value $x]}] {
	error "System error in active column of variable register - variable $x does not exist. Please report"
    }
    return $result
}

# proc split_outer_brackets {x}
# Separates string of form varname(anystring) into list: varname anystring
proc split_outer_brackets {x} {
    for {set i 0} {[string index $x $i]!="\("} {incr i} {}
    lappend splitx [string range $x 0 [expr $i-1]]
    lappend splitx [string range $x [expr $i+1] [expr [string length $x]-2]]
    #puts "split brackets from $x to $splitx"
    return $splitx
}

# proc get_operators {sum}
# Returns list of all arithmetic operators contained within $sum
proc get_operators {sum} {

    set list {}
    for {set i 0} {$i <= [string length $sum]} {incr i} {
	set ch [string index $sum $i]
	if {($ch=="+") ||($ch=="-") ||($ch=="/") ||($ch=="*")} {
	    lappend list $ch
	}
    }
    #puts "$sum becomes $list"
    return $list
}

