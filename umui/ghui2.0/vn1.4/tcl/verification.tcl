#  This file contains the tcl to perform verification of panel entries.
#  Outputs error messages to dialogue boxes if $verify_flag=1 (as when
#  called from verify_variables).  Otherwise sends them to stdout (as
#  when called from um_nav_full_verify

proc check_variable_value {variable value type size flag} {

    global verify_flag
    global fv_index

    set verify_flag $flag

    set var_info      [get_variable_info $variable]
    set check_type    [lindex $var_info 8]
    set check_entry   [lindex $var_info 9]
    set var_type      [lindex $var_info 3]
    set var_help      [lindex $var_info 10]
    set string_length [lindex $var_info 4]
    set start_index   [lindex $var_info 13]

    # Functions are allowed optional arguments
    if {$check_type == "FUNCTION" } {
        set check_function [ lindex $check_entry 0 ]
        set check_function_args [lrange $check_entry 1 end ]
    } 
    
    set var_index     [lindex [split $variable "()"] 1]
    regsub {\*,} $var_index {} var_index
    set fv_index $var_index
    set vi_expr [active_status $variable]
    # vi_expr will be  - 0 for active
    #                  - 1 for variable is inactive 
    #                  - 0 for NEVER inactive 
    #                  - 2 for FN: which is dependent on index
    #                  - 1 for ALWAYS inactive
    #                  - 3 for an expression which requires an index

    # Consistency check compares active status with greyout status
    if {$verify_flag==1} {
	consistency_check $variable $vi_expr $var_index
    }

    # puts "variable=$variable, size=$size"
    if {$type=="array"} {
	if {$vi_expr!=1} { 
	    for {set i 0} {$i < $size} {incr i} {
		set row [expr $i+1]
		set failed 0
		set val [lindex $value $i]
		if {[regexp {^ *$} $val]} {set blank 1} else {set blank 0}

		# var_index will be already set if this is a 2D array - otherwise index on $i
		if {$var_index==""} {set vindex [expr $i+$start_index]} else {set vindex $var_index}
		set fv_index $vindex
		set inactive [active_element $variable $blank $vi_expr [expr $i>0] $vindex]
		#         0 active   - must not be blank
		# returns 1 inactive - go to next element
                # puts "row=$row, val=$val, blank=$blank, inactive=$inactive"
		
		# Otherwise variable is active 
		if {$inactive==1} {
		    # Not active - no checking required
		    continue
		} 
		
		if [set typeok [typecheck $val $var_type $string_length]] {
		    if {$typeok==1} {
			if {$blank} {
			    error_message .d {Blank not allowed} "You have not filled row $row of \
				    `$var_help'. Should be $var_type" warning 0 {OK}
			} else {
			    error_message .d {Type incorrect} "The value <$val> you have entered for \
				    row $row of `$var_help' is of the incorrect type. Should be \
				    $var_type" warning 0 {OK}
			}
			set failed 1
		    } elseif {$typeok==2} {
			error_message .d {String too long} "The character string you have entered for \
				row $row of `$var_help' is too long. Up to $string_length characters \
				only" warning 0 {OK}
			set failed 1
		    } elseif {$typeok==3} {
			error_message .d {No apostrophes allowed} "Please alter row $row of `$var_help'. \
				Apostrophes cannot be used in the user interface." warning 0 {OK}
			set failed 1
		    }
		}

		if {$failed==0} {
		    if { $var_type == "REAL" } {
			regsub E $val e val
                        set old_val $val
                        set new_val [set_precision $val $var_info]
			set value [ lreplace $value $i  $i  $new_val ]
		        if { $old_val != $new_val } {
			    # if the format changes the real value of the variable, give a message,
			    set format [lindex $var_info 11]
			    error_message .d {Type error} "You have specified a value of <$old_val> \
				    in array `$var_help'. The precision is lost when reformatted to $format. \
				    <$new_val> is suggested." warning 0 {OK}
			    return 1
                        }
		    }


		    if { $check_type=="RANGE" } {
			if {[check_range $variable $val $i $var_index ]!=0} {
			    set failed 1
			}
		    } elseif { $check_type=="LIST" } {
			set clist [check_list $variable $val $i $var_index]
			if {$clist==1} {
			    set failed 1
			} elseif {$clist==2} {
			    set value [lreplace $value $i $i [string toupper $val]]
			}
			
		    } elseif { $check_type=="FILE"} {
			if {[check_file $variable $val $var_index]!=0} {
			    set failed 1
			}
		    } elseif {$check_type=="NONE"} {
			# String input - check if blank input is allowed
			if {[check_string  $variable $val $var_index]!=0} {
			    return 1
			}
		    } elseif {$check_type=="FUNCTION"} {
			# Function call. Include optional arguments
			set rv [eval [list $check_function $value \
				$variable [ expr $i + $start_index]] \
				$check_function_args]
			if { $rv != 0} {
			    set failed 1
			}
		    }
		}
		if {$failed} {
		    # Error has occurred. If exiting from window, return
		    # If during Check Setup, continue to find all errors on list
		    if {$flag} {return 1}
		}
	    }
	}
	if {$flag} {set_variable_array $variable $value}
	return 0
    } else {
	# Checking scalar variable
	if {[regexp {^ *$} $value]} {set blank 1} else {set blank 0}
	#puts "Variable has blank status $blank (1=>blank)"

	set inactive [active_element $variable $blank $vi_expr 0 $var_index]
	#         0 active   - must not be blank
	# returns 1 inactive - go to next element
	
	# Otherwise variable is active 
	if {$inactive!=1} { 
	    if [set typeok [typecheck $value $var_type $string_length]] {
		if {$typeok==1} {
		    if {$blank} {
			error_message .d {Blank not allowed} "You have not filled in \
				`$var_help'. Should be $var_type" warning 0 {OK}
		    } else {
			error_message .d {Type incorrect} "The value <$value> you have \
				entered for `$var_help' is of the incorrect type. Should \
				be $var_type" warning 0 {OK}
		    }
		    return 1
		} elseif {$typeok==2} {
		    error_message .d {Type error} "The character string you have entered for \
			    `$var_help' is too long. Up to $string_length characters \
			    only" warning 0 {OK}
		    return 1
		} elseif {$typeok==3} {
		    error_message .d {No apostrophes allowed} "Please alter `$var_help'. \
			    Apostrophes cannot be used in the user interface." warning 0 {OK}
		    return 1
		}
	    }
	    
	    if { $var_type == "REAL" } {
		regsub E $value e value
	        set old_value $value
		set value [set_precision $value $var_info]
		if { $old_value != $value } {
		    # if the format changes the real value of the variable, give a message,
		    set format [lindex $var_info 11]
		    error_message .d {Type error} "You have specified a value  of <$old_value> \
			    for`$var_help'. The precision is lost when reformatted to $format. \
			    <$value> is suggested." warning 0 {OK}
		    return 1
                }
	    }
	    if {$check_type=="RANGE"} {
		if {[check_range $variable $value -1 $var_index]!=0} {
		    return 1
		}
	    } elseif {$check_type=="LIST"} {
		set clist [check_list $variable $value -1 $var_index]
		if {$clist==1} {
		    return 1
		} elseif {$clist==2} {
		    set value [string toupper $value]
		}
	    } elseif {$check_type=="FILE"} {
		if {[check_file $variable $value $var_index]!=0} {
		    return 1
		}
	    } elseif {$check_type=="NONE"} {
		# String input - check if blank input is allowed
		if {[check_string $variable $value $var_index]!=0} {
		    return 1
		}
	    } elseif {$check_type=="FUNCTION"} {
		# Function call. Include optional arguments
		set rv [eval [list $check_function $value $variable -1] \
			$check_function_args]
		if { $rv != 0 } {
		    return 1
		}
	    }
	}
    }
    if {$flag} {set_variable_value $variable $value}
    return 0
    
}

proc check_range {variable val index vindex } {
    # RANGE check
    # checks whether input is within specified range. Range can be a function of index

    set varinf      [get_variable_info $variable]
    set check_entry [lindex $varinf 9] 
    set help_text   [lindex $varinf 10]
    set row         [expr $index + 1]

    set start_index [lindex $varinf 13]
    set lower       [lindex $check_entry 0]
    set upper       [lindex $check_entry 1]

    if {($index!=-1)&&($vindex=="")} {
	# Checking elements of a 1D array. 
	# If range is a function of N, then N=$index + $start_index
	regsub -all {\(N\)} $lower "([expr $index + $start_index])" lower 
	regsub -all {\(N\)} $upper "([expr $index + $start_index])" upper
	
    }

    if {$vindex!={}} {
	# Single element of a 1D array (eg VARNAME(10)) or elements of a 2D array (eg VARNAME(*,10))
	# Where in each case $vindex will have been assigned the value 10.
	# If range is a function of N, then N=$vindex
	regsub -all {\(N\)} $lower "($vindex)" lower
	regsub -all {\(N\)} $upper "($vindex)" upper
    }
    foreach variable [getvars $lower /+-] {
	regsub {\(} $variable {\\(} part
	regsub {\)} $part {\\)} part
        set subval [get_variable_value $variable] 
        if { $subval == "" } { 
	    error_message .d {Range Check Error} "The range-check for entry \
		    `$help_text' not done as it depends on an unset value for \
		    $variable." warning 0 {OK}
	    return 0
        }
	regsub $part $lower $subval lower
    }
    set lower [expr $lower]
    foreach variable [getvars $upper /+-] {

	regsub {\(} $variable {\\(} part
	regsub {\)} $part {\\)} part
        set subval [get_variable_value $variable] 
        if { $subval == "" } { 
	    error_message .d {Range Check Error} "The range-check for entry \
		    `$help_text' not done as depends on an unset value for \
		    $variable." warning 0 {OK}
	    return 0
        }
	regsub $part $upper $subval upper
    }
    set upper [expr $upper]

    if {($val>$upper)||($val<$lower)} {
	if {$index==-1} {
	    error_message .d {Range Check Error} "The entry `$help_text' \
		    should lie between $lower and $upper" warning 0 {OK}
	} else {
	  error_message .d {Range Check Error} "Row $row in the `$help_text' \
		  column should lie between $lower and $upper" \
		warning 0 {OK}
	}
	return 1
    }
    return 0
}

proc check_list {variable val index vindex} {
    # LIST check
    # Compares entry with allowed values in list

    set varinf    [get_variable_info $variable]
    set help_text [lindex $varinf 10]
    set list      [lindex $varinf 9]
    set row       [expr $index + 1]
    set found 0
    for {set i 0} {($i<[llength $list])&&(!$found)} {incr i} {
	if {$val==[lindex $list $i]} {
	    # Exact match
	    set found 1
	} elseif {[string toupper $val]==[lindex $list $i]} {
	    # There is a match, but input is in lower case
	    set found 2
	}
    }
    if {!$found} {
	if {$index==-1} {
	    error_message .d {List Check Error} "The entry `$help_text' \
		    must take one of the values $list, but is '$val'" warning 0 {OK}
	} else {
	    error_message .d {List Check Error} "Row $row in the `$help_text' \
		    column must take one of the values $list, but is '$val'" warning 0 {OK}
	}
	return 1
    }
    if {$found==1} {return 0} else {return 2}
}

proc check_string {variable val vindex} {
    # NONE check
    # Checks whether string entry box is allowed to be blank

    set varinf    [get_variable_info $variable]
    set help_text [lindex $varinf 10]
    set type [lindex $varinf 9]

    if {($type=="NOTOPT")&&($val=="")} {
	error_message .d {Blank Not Allowed} "The entry `$help_text' must not be blank" warning 0 {OK}
	return 1
    }
    return 0
}

proc check_file {variable val vindex} {
    # FILE check
    # Checks file and path names (FILE PATH)
    # If $type includes OPT - allowed to be blank
    # If $type includes LOCAL - must be local, and file must be readable
    

    set varinf    [get_variable_info $variable]
    set help_text [lindex $varinf 10]
    set type [lindex $varinf 9]

    if {([regexp "OPT" $type])&&($val=="")&&(![regexp "NOTOPT" $type])} {
	# Optional input and blank - OK
	return 0
    }

    # Simple check on file or path name
    if {[regexp "PATH" $type]} {
	# Must start with ~ / or $. Must not contain spaces
	if {([regexp {[\/\$\~]} [string index $val 0]]==0)||([llength $val]>1)} {
	    error_message .d {Path Name Error} "The entry `$help_text' must contain a valid path" warning 0 {OK}
	    return 1
	}
    } elseif {[regexp "FILE" $type]} {
	# Must not contain spaces and must not be blank
	if {[llength $val]!=1} {
	    error_message .d {File Name Error} "The entry `$help_text' must contain a valid file name" warning 0 {OK}
	    return 1
	}
    }

    if {[regexp "LOCAL" $type]} {
	#  tests to see if a file is local and readable or path is local.
	#  it is used as a verification function to test on local files that need to
	#  be read, eg preSTASHmaster files.
	if {[regexp "FILE" $type]} {
	    if { !([file readable $val]) } {
		error_message .d {File Not Readable} "Named file <$val> should be local and readable." warning 0 {OK}
		return 1
	    } 
	} elseif {[regexp "PATH" $type]} {
	    if { !([file exists $val]) } {
		error_message .d {Path Not Local} "Named path <$val> should be local." warning 0 {OK}
		return 1
	    } 
	}
    }
    return 0
}

proc set_precision {value varinf} {
    set format [lindex $varinf 11]
    return [lindex [format %$format $value] 0]
}

proc getvars {expression letters} {
    set expressy [split $expression $letters]
    set list {}
    foreach bit $expressy {
	if {([regexp {^[A-Z_]+[0-9A-Z_]*\(([0-9A-Z_]+)\)$} $bit])||([regexp {^[A-Z_]+[0-9A-Z_]*$} $bit])} {
	    lappend list $bit
	}
	if {[string index $bit 0]=="("} {
	    lappend list [getvars [string range $bit 1 [expr [string length $bit] - 2]] "!="]
	}
    }
    return $list
}

proc typecheck {val typ length} {
    #puts "$val $typ $length regexp $a"
    if [regexp {'} $val] {
	# No apostrophes allowed
	return 3
    }
    if {$typ=="STRING"} {
	if {[string length $val]>$length} {
	    return 2
	}
    } elseif {$typ=="LOGIC"} {
	if {[regexp {[^TF]} $val]} {
	    return 1
	}
    } else {
	if [catch {set x [expr $val]}] {
	    # Should be a valid number
	    return 1
	}
	# If there is a + or -, it should be at start or preceded by e or E
	if {[regexp {[^Ee][+-]} $val]} {
	    return 1
	}
        if {($typ=="INT") && ([regexp {^[-]*([0-9]+)*$} $val]!=1)} {
	    return 1
        }
    }
    return 0
}


proc consistency_check {variable vi_expr var_index} {
    # Output warning if a variable is greyed out but active or not greyed out but inactive
    # Only outputs warning if CONSISTENCY_CHECK exists and is set to ON. This is because
    # if there is a lot of development going on, keeping consistency might not be a high priority.

    global grey

    set var_exists [catch {set grey_check [get_variable_value CONSISTENCY_CHECK]}] 
    if {$var_exists==0} {
	if {$grey_check=="ON"} {
	    if {(($vi_expr==0)&&($grey==1))||(($vi_expr==1)&&($grey==0))} {
		# Variable is greyed out but active in variable register or vice versa
		# First check that variable is not in inactive partition.
		# get code number (eg a2323) and use it to determine which partition
		set var_info [get_variable_info $variable]
		set code [lindex $var_info 6]
		set inact [partition_status $code $var_index]
		if {$inact==1} {
		    fv_errors "WARNING: Inconsistency while checking variable $variable. This appears to be due to the fact that you have not activated the partition relating to this window panel. Please check and report if this is not the case. In the meantime this warning will not affect the editing of your job."
		} else {
		fv_errors "SYSTEM WARNING: Internal inconsistency while checking variable $variable. Please report. In the meantime this warning will not affect the editing of your job." "Internal Inconsistency" 
		}
	    }
	}
    }
}















