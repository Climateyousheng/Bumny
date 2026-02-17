################################################################################
#                                                                              #
#           Routines for creating an ASCII output of a GHUI table              #
#                                                                              #
################################################################################
# 
# Loads table information into an array
# Ignores columns within an inactive case statement
# Returns 0 if there are no active variables or if the current table length is
# zero or if there are no entries on the table
#
#

#################################################################################
# proc table_values                                                             #
# loads table info into array and if worth printing calls next level of routine #
#################################################################################
proc table_values {win win_text line_no width} {

    set worth_printing 0
    set columns 0
    set max_length 0

    set line [lindex $win_text $line_no]

    set length_def [lindex $line 5]
    if {[regexp {[a-zA-Z]} $length_def ]} {
	set size [get_variable_value [lindex [split $length_def {[]}] 0]]
	set adjustment [lindex [split $length_def {[]}] 1]
	if {$adjustment!=""} {set size [expr $size $adjustment]}
    } else {
	set size $length_def
    }
    if {$size==0} {return 0}

    set data(super) ""
    set data(max_width) $width

    for {set i [incr line_no]} {$i<[llength $win_text]} {incr i} {
	set line [lindex $win_text $i]
	#puts "line $line"
	
	if {[set text [component_text $line [list .element]]]!=0} {
	    incr columns
	    set var [variable_on_line $line]

	    set data($columns,min_width) [lindex $line 4]
	    set data($columns,title_width) [max [string length $text] $data($columns,min_width)]
	    set data($columns,title) $text
	    set data($columns,value) [lrange [get_variable_array $var] 0 [expr $size-1]]
	    # type=1 for .element

	    if {[js_set_winname $var]==$win} {
		if {[lindex $line 5]=="in"} { set worth_printing 1}
	    }
	    
	    if {[lindex $line 5]=="in"} {
		set data($columns,type) 1
		set max_length [max $max_length [llength $data($columns,value)]]
	    } else {
		set data($columns,type) 2
	    }
	    
	} elseif {[set text [component_text $line .elementautonum]]!=0} {
	    incr columns
	    set var [variable_on_line $line]

	    set data($columns,min_width) [lindex $line 4]
	    set data($columns,title_width) [string length $text]
	    set data($columns,title) $text
	    # type=0 for autonum
	    set data($columns,type) 0
	} elseif {[set expression [component_expr $line [list .case]]]!=0} {
	    # Ignoring grey columns
	    #puts "Found a case"
	    if {[eval_logic [convert_expression $expression]]==0} {
		set i [find_matching_end $win_text $i]
	    }
	} elseif {[set text [component_text $line .super]]!=0} {
	    lappend data(super) $text 
	    lappend data(super) [expr $columns+1]
	} elseif  {[component_expr $line .superend]!=0} {
	    lappend data(super) $columns
	} elseif {[lindex $line 0]==".tableend"} {break}
    }
    #puts "Finished parsing table worth_printing $worth_printing"

    if { $worth_printing==0 } {return 0}

    set data(total_columns) $columns
    set data(max_length) $max_length
    if {$max_length==0} {return "Table is Blank\n"}

    set output [check_min_width 1 $columns]
    
    #puts "table_values returning $output"
    return $output

}

###############################################################################
# proc check_min_width                                                        #
# If minimum width of table greater than 80 characters it splits table in two #
# and calls itself recursively. Otherwise calls next level of routine         #
###############################################################################

proc check_min_width {start end} {
    upvar data data


    if {[test_width $start $end "min_width"]==0} {
	return [printout_table $start $end]
    } elseif {[set super [super_division $start $end]]!=0} {
	append op [check_min_width $start $super]
	append op [check_min_width [incr super] $end]
	return $op
    } elseif {$start==$end} {
	return [printout_table $start $end]
    } else {
	set middle [expr ($start+$end)/2]
	append op [check_min_width $start $middle]
	append op [check_min_width [incr middle] $end]
	return $op
    }
}

###############################################################################
# proc test_width                                                             #
# Calculate minimum width of selected columns + any additional mandatory      #
# columns and return the result if too wide or zero if not                    #
###############################################################################
proc test_width {start end type} {
    upvar data data

    set width 0
    set cols 0
    for {set i 1} {$i<=$data(total_columns)} {incr i} {
	if { ($data($i,type)!=1) || ( ($i>=$start) && ($i<=$end) ) } {
	    set width [expr $width+$data($i,$type)]
	    incr cols
	}
    }
    if {$width>=[expr $data(max_width)-$cols]} {
	return $width
    } else {
	return 0
    }
}

###############################################################################
# proc super_division                                                         #
# Returns a point in middle of table related to super heading divisions or 0  #
###############################################################################
proc super_division {start end} {
    upvar data data
    set division_found 0
    for {set j 2} {$j<[llength $data(super)]} {incr j 3} {
	set superend [lindex $data(super) $j]
	if { ($superend>$start) && ($superend<$end) } {
	    lappend list $superend
	    set division_found 1
	}
    }
    if {$division_found==0} {return 0} else {return [lindex $list [expr [llength $list]/2]]}
}

########################################################################################
# proc printout_table                                                                  #
# Checks maximum width and outputs if ok - otherwise determines new format and outputs #
########################################################################################
proc printout_table {start end} {
    upvar data data

    if { [set width [test_width $start $end "title_width"]]==0 } {
	return [print_columns $start $end]
    } elseif {$start==$end} {
	squeeze_column $start
	return [print_columns $start $end]
    } else {
	# determine new format - store in title_width and call as above
	#puts "TABLE WAS TOO WIDE - reformatting"
	reformat_columns $start $end $width
	return [print_columns $start $end]
    }
}

###############################################################
# proc squeeze_column                                         #
# minimum width of column is too wide - reduce it             #
###############################################################
proc squeeze_column {col} {
    upvar data data

    set tot_width 0
    for {set i 1} {$i<=$data(total_columns)} {incr i} {
	if { ($data($i,type)!=1) || ( $i==$col ) } {
	    set tot_width [expr $tot_width+$data($i,title_width)]
	}
    }

    if {$data($col,title_width)>[expr $tot_width-$data(max_width)]} {
	set data($col,title_width) [expr $data($col,title_width)-$tot_width+$data(max_width)]
    }
}

########################################################################################
# proc reformat_columns                                                                #
# Determine new format of columns to enable it to fit within limits                    #
########################################################################################
proc reformat_columns {start end actual_width} {
    upvar data data

    set min_width 0
    for {set i 1} {$i<=$data(total_columns)} {incr i} {
	if { ($data($i,type)!=1) || ( ($i>=$start) && ($i<=$end) ) } {
	    lappend list $i
	    set min_width [expr $min_width+$data($i,min_width)]
	}
    }
    
    set required [expr $data(max_width)-[llength $list]]

    set factor [expr ($actual_width.-$required.)/($actual_width.-$min_width)]

    set new_tot 0
    foreach i $list {
	# Reduce title_width by an amount proportional how oversized the title is in relation
	# To the minimum width
	set c $data($i,title_width)
	set change [expr ($c-$data($i,min_width))*$factor]
	set data($i,title_width) [expr int( $c-$change )]

	set new_tot [expr $new_tot+$data($i,title_width)]
    }
    set under [expr $required-$new_tot]
    for {set i 0} {$i<$under} {incr i} {
	incr data([lindex $list $i],title_width)
    }
}


###############################################################################
# proc print_columns                                                          #
# Prints out columns $start to $end plus any mandatory columns                #
###############################################################################
proc print_columns {start end} {
    upvar data data

    set input_columns 0
    set max_length 0
    for {set i 1} {$i<=$data(total_columns)} {incr i} {
	if { ($data($i,type)!=1) || ( ($i>=$start) && ($i<=$end) ) } {
	    lappend list $i
	    lappend form $data($i,title_width)
	    if {$data($i,type)==1} {
		set input_columns 1
		set max_length [max $max_length [llength $data($i,value)]]
	    }
	}
    }
    if {$input_columns==0} {
	# These columns are all output or element autonum columns
	return ""
    }

    if {[set text [print_super $list $form]]!=0} {
	append op $text
    }
    append op "[print_titles $list $form]\n"
    
    if {$max_length!=0} {
	for {set i 0} {$i<$data(max_length)} {incr i} {
	    append op [print_data_line $list $form $i]
	}
	append op "\n"
    } else {
	append op "Input columns of this part of table are blank\n\n"
    }
    return $op
}

proc print_super {list form} {
    upvar data data

    if {[set super $data(super)]==""} {return 0}

    for {set i 2} {$i<[llength $data(super)]} {incr i 3} {
	set from [lindex $data(super) [expr $i-1]]
	set to [lindex $data(super) $i]
	
	set format -1
	foreach item $list {
	    if {($item>=$from)&&($item<=$to)} {
		set title [lindex $data(super) [expr $i-2]]
		set format [expr $format+$data($item,title_width)+1]
	    }
	}
	if {$format!=-1} {
	    lappend super_list $title
	    lappend super_form $format
	}
    }
    return [print_table_row $super_list $super_form 1]
}



#########################################################
# proc print_titles                                     #
# Prints out titles of tables                           #
#########################################################
proc print_titles {list form} {
    upvar data data

    foreach item $list {
	lappend strings $data($item,title)
    }
    return [print_table_row $strings $form 1]
}

#########################################################
# proc print_data_line                                  #
# Prints out a line of data                             #
#########################################################
proc print_data_line {list form line} {
    upvar data data

    foreach item $list {
	if {$data($item,type)!=0} {
	    # Variable attached to this column
	    lappend strings [lindex $data($item,value) $line]
	} else {
	    # Autonum column - use line number
	    lappend strings [expr $line+1]
	}
    }
    return [print_table_row $strings $form 1]
}

#############################################################
# print_table_row                                           #
# Prints a general formatted line                           #
# If line longer than format, breaks at space or hyphenates #
#############################################################
proc print_table_row {list form {indent 0}} {
    
    set overflow 0
    # Add an indentation to line if requested
    set op [format "%${indent}s" ""]

    for {set i 0} {$i<[llength $list]} {incr i} {
	set string [lindex $list $i]

	# If first character is a space (during recursive call) remove it
	if {[string index $string 0]==" "} {
	    set string [string range $string 1 end]
	}
	set format [lindex $form $i]

	if {[string length $string]>$format} {
	    # String too wide for format - indicate that second line will be required
	    set overflow 1
	    # Determine point at which to break line
	    set break [split_line $string $format]
	    if {([string length $string]>$break)&&([string index $string $break]!=" ")\
		    &&([string index $string [expr $break-1]]!="-")} {
		# Line broken mid-word and not already hyphenated so hyphenate it
		set string "[string range $string 0 [expr $break-2]]-[string range $string [expr $break-1] end]"
	    }
	    append op [format "%-${format}s " [string range $string 0 [expr $break-1]]]
	    lappend list2 [string range $string $break end]
	} else {
	    append op [format "%-${format}s " $string]
	    lappend list2 ""
	}
    }
    append op "\n"
    if {$overflow==1} {append op [print_table_row $list2 $form $indent]}

    return $op
}

###########################################################################
# proc split_line                                                         #
# For lines which overflow format: returns point at which to break line   #
# At a space if there is one, otherwise at the original point             #
###########################################################################
proc split_line {string format} {
    
    if {[string index $string $format]==" "} {
	return $format
    }
    for {set i [expr $format-1]} {([string index $string $i]!=" ")&&($i>=0)} {incr i -1} {}

    if {$i<0} {return $format}

    return $i
}


