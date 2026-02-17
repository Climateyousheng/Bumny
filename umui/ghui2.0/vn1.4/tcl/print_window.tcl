################################################################################
#                            JOB SHEET FUNCTION                                #
################################################################################
# This file contains the main routines for creating an ASCII output of GHUI    #
# windows.                                                                     #
#                                                                              #
# The entry procedure, print_window, should be called with the file name       #
# of the window without the .pan extension. Presence of a .function command    #
# in the window file is first checked for. If it exists then the execution is  #
# passed to the named function.                                                # 
#                                                                              #
# The function window_content creates a list of variables and partitions on    #
# each window and stores it in the global variable win_content.                #
# Using the information stored in win_content it is determined whether or not  # 
# the window contains anything worth printing - ie at least one variable needs #
# to be active. This test is carried out by the window_active procedure        #
#                                                                              #
# The window is then parsed line-by-line appending any output to a variable    #
# called output - anything inside an inactive case or invisible construct is   #
# ignored. If all variables are within such constructs then nothing is output  #
# (though ideally the case logic should already match the inactive logic)      #
#                                                                              #
# Output from tables is handled by procedures in the file print_table.tcl      #
#                                                                              #
# If window contains a .pushsequence button then the appropriate follow-on     #
# window is output next. Note that only those windows listed as main panels in #
# nav.spec (ie preceded by ..p) are read into the window_content variable      #
# so pushsequence windows are read whether or not they contain variables in    #
# requested partitions. Conversely, if the main window contains no active      #
# variables then the .pushsequence window will not be output.                  #
################################################################################

# print_window
#  Outputs settings in a window to a file and, optionally, outputs the 
#  settings in related windows related windows.
# output_file : Stream to send output to.
# page_width : Page width to format to in characters
# win : Name of panel control file
# type : Option to print follow-on windows or not

proc print_window {output_file page_width win {type 1}} {

    # Get window definition with all .include text
    set win_text [get_window_text $win]

    # Check for jobsheet function
    set fn 0
    for {set i 0} {$i<[llength $win_text]} {incr i} {
	
	set line [lindex $win_text $i]
	if {[lindex $line 0]==".panel"} {
	    # .function should be added before .panel
	    break
	}
	if {[set fn [component_text $line .function]]!=0} {
	    # .function found
	    break
	}
    }
    if {$fn!=0} {
	# Printing to be carried out by function
	eval $fn $output_file $page_width
    } elseif {$type == 1} {
	set from 1
	set to 1
	set var ""
	# Is a loop required for eg profile windows
	for {set i 0} {$i<[llength $win_text]} {incr i} {
	    set line [lindex $win_text $i]
	    
	    if {[lindex $line 0]==".panel"} {break}
	    if {[lindex $line 0]==".loop"} {
		set line [lindex $win_text $i]
		set var [lindex $line 1]
		set from [get_value [lindex $line 2]]
		set to [get_value [lindex $line 3]]
		#puts "loop found: from $from to $to"
	    }
	}

	for {set i $from} {$i<=$to} {incr i} {
	    if {$var!=""} {
		# Window contains an index variable - so set it
		set_variable_value $var $i
	    }
	    # Check that at least one variable is active and return if not
	    if {[window_active $win $win_text]==0} {
		continue
	    }
	    if {[set push_sequence [print_out $output_file $win_text $win $page_width]]!=0} {
		print_window $output_file $page_width $push_sequence
	    }
	}
    } else {
	print_out $output_file $win_text $win $page_width
    }
}

# insert_include
#   Read include file, make substitutions and return the text
# Arguments
#   line : Line from .pan control file that contains .include
# Method
#   Variables in the line are not converted to their actual
#   values - this substitution will occur when processed
#   by get_variable_value. This is because the variable may
#   not be set just yet.

proc insert_include {line} {
    set file [lindex $line 1]
    set a [open [window_include_file $file] r]
    set win_text [read $a]
    close $a
    # Convert GHUI variable arguments (listed as %VAR) to the same
    # without the %, so that the actual conversion to the variable's
    # value is done when the window text is processed by the print
    # function.
    set line [dontConvertVariables $line]
    return [make_substitutions $win_text [lrange $line 2 end]]
}

#################################################################
# proc window_active                                            #
# Returns 1 if there is at least one active variable on window  #
# Otherwise returns 0                                           #
#################################################################
   
proc window_active {win win_text} {

    # This routine sets a variable win_content which contains information
    # about the variables on the window
    set win_content [window_content $win $win_text]

    set active 0 
    foreach variable $win_content {
	set var_info      [get_variable_info $variable]
	set var_inactive  [lindex $var_info 7]
	set var_index     [lindex [split $variable "()"] 1]
	regsub {\*,} $var_index {} var_index
	
	# get code number (eg a2323) and use it to determine which partition
	set code [lindex $var_info 6]
	if {[partition_status $code $var_index]==1} {
	    # Partition is inactive
	    continue
	}
	if {[sub_partition_status $code $var_index js_inactive_partition]==1} {
	    # This partition is not required
	    continue
	}
	if {[js_set_winname $variable]!=$win} {
	    # Not on home window
	    continue
	}
	
	if {[active_status $variable]!=1} {
	    # Found an active variable in an active partition
	    set active 1
	    break
	}
    }
    return $active
}


###############################################################################
# proc print_out                                                              #
# This outputs the settings for any single window and returns name of any     #
# .pushsequence follow-on window. It will not output anything in the event    #
# that all active entries are cased out (ideally though, if the inactive      #
# logic matches the window logic, this case should not arise). Nor will it    #
# output anything if all active entries have other home windows.              #
# MAIN FEATURES                                                               #
# Only outputs entries related to variables on own home window                #
# $buffer stores .textd text until an active component is reached. If the     #
# component is on its own home window, $buffer is output with it. Otherwise   #
# buffer is reset.                                                            #
# Tables are output by the routines in print_table.tcl                        #
# Anything within an inactive .case or .invisible construct is ignored        #

proc print_out {output_file win_text win page_width} {

    set half_width [expr $page_width/2-1]
    set pushsequence 0
    set worth_printing 0
    set buffer ""
    #puts "print_out called with $win"

    # Go through window text line by line
    for {set i 0} {$i<[llength $win_text]} {incr i} {
	set line [lindex $win_text $i]
	#puts "printing line $line"
	
	if {[set text [component_text $line [list .entry .basrad .check .file_entry]]]!=0} {
	    # Dealing with entry boxes, check buttons and radio buttons
	    # ie all input components but tables
	    # Above sets $text to the text in the command
	    set var [variable_on_line $line]
	    if {[js_set_winname $var]==$win} {
		# Only output something if the variable is in its home window

		# Get a description of the variable's value
		set value_text [simple_component_value $win_text $i [get_variable_value $var]]

		# Output any items in buffer that are related to this component. 
		# ie usually .textd components which would have been discarded
		# if the component/s following was/were inactive or not in its
		# home window
		append output $buffer

		# Now add the description of the current line
		append output [print_line [list $text $value_text] [list $half_width $half_width] 1]

		# This panel contains something worth outputting
		set worth_printing 1
	    }
	    # Clear buffer - so a .textd items followed by components not in its
	    # home panel would now be discarded as not worth printing
	    set buffer ""

	} elseif {[set text [component_text $line [list .entry_active]]] != 0} {
	    # Dealing with entry boxes, check buttons and radio buttons
	    # ie all input components but tables
	    # Above sets $text to the text in the command
	    set var [variable_on_line $line]
	    if {[js_set_winname $var]==$win} {
		# Only output something if the variable is in its home window

		# Get a description of the variable's value and its conversion value
		set value_text [get_variable_value $var]
		set command [lindex $line 3]
		set conversion [$command $value_text]
		if {$value_text != $conversion} {
		    set value_text "$value_text: Converts to $conversion"
		}

		# Output any items in buffer that are related to this component. 
		# ie usually .textd components which would have been discarded
		# if the component/s following was/were inactive or not in its
		# home window
		append output $buffer

		# Now add the description of the current line
		append output [print_line [list $text $value_text] [list $half_width $half_width] 1]

		# This panel contains something worth outputting
		set worth_printing 1
	    }
	    # Clear buffer - so a .textd items followed by components not in its
	    # home panel would now be discarded as not worth printing
	    set buffer ""
	} elseif {[set text [component_text $line [list .text .textj]]]!=0} {
	    # Dealing with normal and jobsheet-only text components
	    append output [print_line [list $text] $page_width]

	} elseif {[set text [component_text $line .textd]]!=0} {

	    # Add .textd items to buffer. These are additional descriptions
	    # of following items and are only relevant if the following item
	    # is to be output. So add it to a buffer and it will only
	    # be added to output if the next active item is found to
	    # be on its home window (see a few lines above)
	    append buffer [print_line [list $text] $page_width]

	} elseif {[set text [component_text $line .table]]!=0} {
	    # Table components are dealt with by another major procedure
	    if {[set table [table_values $win $win_text $i $page_width]]!=0} {
		# Table is worth printing - $table is set to its description.

		# Output any buffered description that prefixed the table (see
		# above for more description of the buffer variable).
		append output $buffer

		# Create a title for the table
		set title_length [string length "Table: $text"]
		append output "[divider [min $title_length $page_width]]"
		append output [print_line [list "Table: $text"] $page_width]

		# Output table text with suitable dividers
		append output "[divider [min $title_length $page_width]]"
		append output $table
		append output "[divider [min $title_length $page_width]]"

		# This window is now worth printing
		set worth_printing 1
	    }
	    # Clear buffer as above
	    set buffer ""

	    # Index $i now points to .table line - now that above has dealt with
	    # table, we need to jump forward to the .tableend on next loop.
	    set i [find_matching_end $win_text $i]

	} elseif {[set expression [component_expr $line [list .case .invisible]]]!=0} {
	    # Ignoring grey or invisible sections by moving i to point to the 
	    # matching .caseend if case is inactive.
	    if {[eval_logic [convert_expression $expression]]==0} {
		set i [find_matching_end $win_text $i]
	    }

	} elseif {[set text [component_text $line .title]]!=0} {
	    # Dealing with text components
	    append output [print_line [list $text] $page_width]
	    append output "[divider [min [string length $text] $page_width]]"

	} elseif {$pushsequence==0} {
	    # Panel is part of a sequence of panels - need to indicate
	    # to the calling routine that this window should be followed
	    # by the next in the sequence.
	    set pushsequence [component_text $line .pushsequence]
	}
    } ; # End of loop over all lines of panel text

    if {$worth_printing} {
	# Above loop over lines found at least one thing worth printing,
	# so send the whole window to the output.
	append output "[solid_divider $page_width]\n"
	puts $output_file $output
	#diff_message $output
    }
    # Returns next window in sequence if there is one or, 0 if there isn't
    return $pushsequence
}

# divider
#   Returns a section divider of width $width
proc divider {width} {
    return "[string range "---------------------------------------------------------------------------------------------------------------------------" 1 $width]\n"
}

# solid_divider
#   Returns a section divider of width $width
proc solid_divider {width} {
    return "[string range "____________________________________________________________________________________________________________________________" 1 $width]\n"
}

# variable_on_line
#   Returns name of the variable on line_no of win_text, or 0 if this
#   is not an input component
# Argument
#   line : Command line parsed from a panel control file

proc variable_on_line {line} {
    set type [lindex $line 0]
    if { $type==".entry" } {return [lindex $line 3]}
    if { $type==".file_entry" } {return [lindex $line 3]}
    if { $type==".check" } {return [lindex $line 3]}
    if { $type==".basrad" } {return [lindex $line 5]}
    if { $type==".entry_active" } {return [lindex $line 4]}
    if { $type==".set_on_closure" } {return [lindex $line 2]}

    if { $type==".element" } {return [lindex $line 2]}

    # Otherwise, not an input component
    return 0
}



# proc component_expr
# If the component type in line matches one of the types in type_list
# it returns the related component or NULL if there isn't one (eg .caseend)
# Otherwise return 0
# Like proc component_text but no substitution is done
# Argument
#   line : Command line parsed from a panel control file

proc component_expr {line type_list} {

    set type [lindex $line 0]
    if { [lsearch $type_list $type]==-1 } {
	set text 0
    } elseif {($type==".case") || ($type==".invisible") } {
	# Remove command from line to leave logical expression
	regsub " *$type *" $line "" text
    } elseif { $type==".superend" } {
	set text ""
    }
    return $text
}

# component_text
#   If the component type in line matches one of the types in
#   type_list it returns the related text component after substituting
#   any [get_variable_value ...]  Otherwise return 0. Default: it is
#   assumed that the text is the second component.  For some
#   components it is the 3rd.
# Arguments
#  line : Full line from a panel control file
#  type_list : List of panel commands that have a text component
# Method
#  Routine needs to deal with text from:
#  .text "Output in form \"example\""  - ie nested quotes
#  .text "Output in form \$RUNID" - ie need to avoid evaluating a variable RUNID
#  .text "Stream [get_variable_value STREAM_NO] is active"  - ie enclosed command
#  This is handled by the evalEmbeddedCommands utility

proc component_text {line type_list} {

    set type [lindex $line 0]
    if { [lsearch $type_list $type]==-1 } {
	set text "0"
    } elseif { ($type==".table") || ($type==".pushsequence") } {
	set text "[lindex $line 2]"
    } else {
	set text "[lindex $line 1]"
    }
    return [evalEmbeddedCommands $text]
}

# simple_component_value
#   Returns text describing current value for simple window components
# Arguments
#   win_text : Full text from control panel
#   line_no : Line in win_text to be looked at
#   value : value of variable

proc simple_component_value {win_text line_no value} {
    # Returns help which depends on value of variable
    # For entry boxes, table columns, and hidden variables just returns value.
    # For check boxes, returns on or off.
    # For radio buttons, returns text associated with value
    # Returns "Entry is unset" if variable is not set
    #
    # win_text should be a list of lines from a window panel.
    # line_no  is list item number of line about which help will be returned.
    # value is value of variable

    if {$value==""} {return "Entry is unset"}

    set line [lindex $win_text $line_no]
    set type [lindex $line 0]

    # Return just the value for the following
    if { $type==".entry" } {return $value}
    if { $type==".file_entry" } {return $value}
    if { $type==".element" } {return $value}
    if { $type==".set_on_closure" } {return $value}


    # Return ON or OFF for check boxes rather than the actual 
    # values which can be meaningless to the user.
    if { $type==".check" } {
	set line [lindex $win_text $line_no]
	if {$value==[lindex $line 4]} {return "ON"}
	if {$value==[lindex $line 5]} {return "OFF"}
	return "Entry is unset"
    }

    # Search for text which matches value for radio buttons
    if { $type==".basrad"} {
	set current_line [expr $line_no+1]
	set opts 0
	set options ""
	while { ($opts<[expr [lindex $line 3]*2])&&($current_line<=[llength $win_text]) } {
	    set options [concat $options [lindex $win_text $current_line]]
	    set opts [llength $options]
	    incr current_line
	}

	for {set i 0} {$i<[llength $options]} {incr i 2} {
	    if {$value==[lindex $options [expr $i+1]]} {return "'[remove_trailing_spaces [lindex $options $i]]'"}
	}
	return "Entry is unset"
    }
    return 0
}

    
# find_matching_end
#   Called with $i pointing to start of a structure. Returns line
#   number of its end. 
# Arguments
#   win_text : Full text from control panel
#   i : Line in win_text to be looked at


proc find_matching_end {win_text i} {

    set type [lindex [lindex $win_text $i] 0]

    # Apart from .invisible, the related end structures have same name
    # but with "end" added.
    if { $type==".invisible"} {
	set typeend .invisend
    } else {
	set typeend "$type\end"
    }

    # Some structures can be nested, so make sure we get the closing
    # one which matches this one.
    set level 1
    set length [llength $win_text]
    while { ($level > 0) && ($i<$length) } {
	incr i
	set command [lindex [lindex $win_text $i] 0]
	if { $command==$typeend} {
	    incr level -1
	} elseif {$command == $type} {
	    incr level
	}
    }
    return $i
}

# js_set_winname
#   Variables taken from input panels may have indices eg
#   DOMTS_A(*,PROFILE), ACON(4). This routine parses out
#   the index that might affect the window name, evaluates
#   it and calls set_window_name appropriately.
# Argument
#   variable : Variable name parsed from panel control file
proc js_set_winname {variable} {

    regsub {\*,} $variable {} var
    set index [lindex [split $var "()"] 1]
    if {[regexp {[A-Z]} $index]} {set index [get_variable_value $index]}

    return [lindex [set_window_name $var $index] 1]
}



# print_line
#  Prints a general formatted line If line longer than format, breaks
#  at space or hyphenates, and indents the follow-on lines. Prints
#  follow-on lines by making recursive calls to itself.
# Arguments
#  list : A list of text, one for each column of text.
#  form : A format list - width of each column
#  indent : Number of spaces to indent first column
# Method
#  Usually, first line is not indented. Indentation is added when
#  it calls itself, to indicate line is a follow-on line.

proc print_line {list form {indent 0}} {
    
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
	
	if {$overflow==1} {
	    # A previous column overflowed - don't output any more on this line
	    lappend list2 $string
	} elseif {[string length $string]>$format} {
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
    if {$overflow==1} {append op [print_line $list2 $form $indent]}

    return $op
}



