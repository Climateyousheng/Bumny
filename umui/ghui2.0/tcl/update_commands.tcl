# Commands used to update a job from one version to another.
# They all manipulate the global variable "basis_string", which
# holds a memory copy of a job.
#
# all activity and errors are stored in the global variable "update_info".

# SUMMARY OF MAIN COMMANDS:

# move_variable variable_name new_partition
#  if job contains variable, moves variable into another partition

# variable_value var_name [index 1] [index 2] [size of 1st dimension]
#  gets value of a variable or single value from array. indices are 0 and size is 1 by default

# array_value_list var_name [index 2] [size of 1st dimension]
#  returns values in form of a list - index is 0 and size is 1 by default

# delete_variable var_name
#  removes variable from database

# delete_partition part_name
#  removes partition from database

# add_variable var_name list_of_values type="number" or "string" partition
#  adds a variable with value or list of values to partition specified. 
#  Deletes previous instance of variable

# add_partition part
#  adds a partition. Deletes any previous instance (and contents) of partition

# rename_variable var_name new_name
# rename_partition part new_name
#   renames partition or variable name

# change_array_dimension var_name old_dimension new_dimension [padding] 
#  Changes array lists of 2D arrays to cope with change in dimension.
#  If new is greater than old, need to specify a blank padding string
#  to insert. padding should include ' ' if necessary
#  NB FOR LARGE ARRAYS, THIS IS SLOW. ALSO NOTE THAT WHILE JOB IS BEING
#  UPDATED, SERVER CANNOT BE USED BY OTHERS - IF THIS IS REQUIRED FOR
#  LARGE ARRAYS IT SHOULD BE REWRITTEN IN C.


# This file can be sourced from the upgrade routine whenever it changes
# By changing the version number below and calling this routine from the
# upgrade routine, one can be sure that the sourcing has worked and also
# more importantly that both servers are using the same version
proc version_of_updates {} {
    return "2.1"
}


################################################################
# proc add_partition                                           #
# Adds or replaces a partition                                 #
################################################################
proc add_partition {part} {
    global basis_string
    global update_info
    delete_partition $part
    append update_info "Adding partition $part\n"
    set basis_string " &$part\n &END\n$basis_string"
}


##############################################################################
# proc get_whole_variable                                                    #
# Cuts copy of var from carriage return preceding variable name to character #
# preceding carriage return following last value                             #
##############################################################################
proc get_whole_variable {var} {
    global basis_string

    if {[set start [find_variable $var $basis_string]]==0} {return ""}
    set end [find_next_item $var $basis_string]

    set var_string [string range $basis_string $start [incr end -1]]

    return $var_string
}

##############################################################################
# proc delete_variable                                                       #
# Removes variable and all values from database string                       #
##############################################################################

proc delete_variable {var} {
    global basis_string
    global update_info

    if {[set start [find_variable $var $basis_string]]==0} {return}
    set end [find_next_item $var $basis_string]
    append update_info "Removing variable $var\n"

    set new_string [string range $basis_string 0 $start]
    append new_string [string range $basis_string [incr end] end]
    set basis_string $new_string
}

##############################################################################
# proc delete_partition                                                      #
# Removes partition and all variables from database string                   #
##############################################################################

proc delete_partition {part} {
    global basis_string
    global update_info

    if {[set start [find_partition $part $basis_string]]==-1} {
	append update_info "delete_partition: Partition $part was not found\n"
	return
    }
    set end [find_next_partition $part $basis_string]

    append update_info "Removing partition $part\n"
    set new_string [string range $basis_string 0 $start]
    append new_string [string range $basis_string [incr end] end]
    set basis_string $new_string
}


##############################################################################
# proc variable_value
# Obtains single value of variable with optional index and (for 2D arrays)
# optional 2nd index and size of first dimension.
##############################################################################

proc variable_value {var {index 0} {index2 0} {size 0}} {
    global basis_string

    set val2 [array_value_list $var $index2 $size]

    set val [lindex $val2 $index]

    return $val
}

##############################################################################
# proc array_value_list
# Returns a list of values of array - index $index assuming size of each element $size
##############################################################################

proc array_value_list {var {index 0} {size 0}} {
    global basis_string

    if {[set pos [find_first_value $var $basis_string]]==0} {return ""}

    set start [expr $index*$size]

    for {set i 0} {$i<$start} {incr i} {
	set pos [find_next_value $pos $basis_string]
	if {$pos==-1} {return ""}
    }

    lappend list [get_next_value $pos $basis_string]
    for {set i 1} {$i<$size || $size==0} {incr i} {
	if {[set pos [find_next_value $pos $basis_string]]==-1} {
	    return $list
	}
	lappend list [get_next_value $pos $basis_string]
    }
    return $list
}

#####################################################################
# proc move_variable                                                #
# Moves variable from one partition to another                      #
#####################################################################
proc move_variable {var part} {
    global basis_string
    global update_info
    append update_info "Moving $var to partition $part\n"
    set var_val [get_whole_variable $var]
    if {$var_val==""} {
	# Variable is not in this database
	append update_info "Cannot move $var since it does not exist in this job\n"
	return
    }

    delete_variable $var
    append update_info "Inserting $var into partition $part\n"
    insert_variable $var_val $part
}

###############################################################
# proc add_variable                                           #
# Sets scalar variable or whole array to new value/s          #
# type is either "number" or "string"                         #
###############################################################
proc add_variable {var val type part} {
    global basis_string
    global update_info

    delete_variable $var
    set var_val [database_format $var $val $type]
    append update_info "Inserting $var into partition $part\n"
    insert_variable $var_val $part
}

###############################################################
# proc rename_variable                                        #
# Renames a variable if it is listed in basis_string          #
###############################################################
proc rename_variable {var new_var} {
    global basis_string
    global update_info
    if {[regsub "\n $var=" $basis_string "\n $new_var=" basis_string]==0} {
	append update_info "Cannot rename variable since $var not included in this job\n"
    } else {
	append update_info "Renaming variable $var to $new_var\n"
    }
}

###############################################################
# proc rename_partition                                       #
# Renames partition which should be listed in basis_string    #
###############################################################
proc rename_partition {part new_part} {
    global basis_string
    # & interacts with regsub and \ interacts badly with Tcl so do substitution in
    # two stages
    set rep "\\&$new_part"

    if {[regsub " \&$part\n" $basis_string " $rep\n" basis_string]==0} {
	append update_info "ERROR: Cannot rename partition since $part not included in this job\n"
    } else {
	append update_info "Renaming partition $part to $new_part\n"
    }
}

#################################################################################
# proc change_array_dim                                                         #
# For 2D arrays whose first dimension is changing. If increasing, the database  #
# is padded out with the specified character. If decreasing, excess entries are #
# removed                                                                       #
#################################################################################

proc change_array_dim {var old new {padding ""} {type number} } {
    global basis_string

    set array ""
    if {[set part [partition_of_variable $var $basis_string]]==""} {
	# Variable not present in this job
	return $basis_string
    }
    # Get array values in form of list
    set val [array_value_list $var]

    # Loop through each row of array
    for {set i 0} {$i<=[llength $val]} {incr i $old} {
	set new_val [lrange $val $i [expr $i+$old-1]]
	if {$new>$old} {
	    # Need to add extra blank characters to extend row
	    # But only if this is not last row
	    if {[llength $val]>[expr $i+$old]} {
		for {set j $old} {$j<$new} {incr j} {
		    lappend new_val $padding
		}
	    }
	} else {
	    # Need to reduce length of each row
	    set new_val [lrange $new_val 0 [expr $new-1]]
	}
	# Add row to array
	set array [concat $array $new_val]
    }
    # Replace with new values
    add_variable $var $array $type $part
}    



###################################################################
# proc find_variable                                              #
# Find start of variable name in basis string: returns string     #
# index of space preceding variable name. Returns 0 if not found  #
###################################################################

proc find_variable {name basis_string} {
    return [expr [string first "\n $name=" $basis_string]+1]
}

################################################################
# proc find_variable                                           #
# Find start of partition name in basis string                 #
################################################################
proc find_partition {name basis_string} {
    return [string first " &$name\n" $basis_string]
}

################################################################
# proc find_first_value                                        #
# Finds position of first value of variable                    #
################################################################
proc find_first_value {name basis_string} {
    if {[set varpos [find_variable $name $basis_string]]==0} {return 0}
    return [expr $varpos + [string length $name] + 2]
}

################################################################
# proc find_next_value                                         #
# Called with position of a value -                            #
# returns position of next value or -1 if end                  #
################################################################
proc find_next_value {pos basis_string} {
    
    # Find end of value
    set string [string range $basis_string $pos end]
    set new_pos [string first "\n" $string]
    if {[string index $string [expr $new_pos-1]]==","} {
	return [incr pos [expr $new_pos+2]]
    } else {
	return -1
    }
}

##############################################################
# proc get_next_value                                        #
# Gets value of item at position pos                         #
##############################################################

proc get_next_value {pos basis_string} {

    if {$pos==-1} {return '}
    if {[string index $basis_string $pos]=="'"} {
	# Find end of value
	set string [string range $basis_string [incr pos] end]
	set end [string first "'" $string]
	return [string trimright [string range $string 0 [incr end -1]] " "]
    } else {
	# Find end of value
	set string [string range $basis_string $pos end]
	set end [string first "\n" $string]
	if {[string index $string [incr end -1]]==","} {incr end -1}
	return [string trimright [string range $string 0 $end] " "]
    }

}

################################################################
# proc find_next_item                                          #
# Returns character number of carriage return that precedes    #
# next variable or partition                                   #
################################################################
proc find_next_item {var basis_string} {

    set pos [find_first_value $var $basis_string]

    while {[set new_pos [find_next_value $pos $basis_string]]!=-1} {
	set pos $new_pos
    }
    # Find end of value
    set string [string range $basis_string $pos end]
    set end [string first "\n" $string]

    return [expr $pos+$end+1]
}

###################################################################
# proc find_next_partition                                        #
# Returns character number carriage return that precedes          #
# partition following $part                                       #
###################################################################
proc find_next_partition {part basis_string} {

    set pos [find_partition $part $basis_string]

    set rest [string range $basis_string $pos end]

    set part_end [string first "\n &END" $rest]

    return [expr $pos+$part_end+7]
}

################################################################
# proc partition_of_variable                                   #
# Returns partition number of variable                         #
################################################################
proc partition_of_variable {var basis_string} {
    set part ""
    if {[set pos [find_variable $var $basis_string]]==0} {return ""}
    if {[set part_pos [string last "\n &" [string range $basis_string 0 $pos]]]==-1} {
	set part_pos 2
    } else {
	incr part_pos 3
    }
    while {[set char [string index $basis_string $part_pos]]!="\n"} {
	append part $char
	incr part_pos
    }
    return $part
}

################################################################
# proc insert_variable                                         #
# var_val is a formatted list starting with carriage return    #
# ready for inserting into basis_string                        #
################################################################

proc insert_variable {var_val part} {
    global basis_string update_info
    if {[set pos [find_partition $part $basis_string]]==-1} {
	append update_info "Cannot find partition $part\n"
	add_partition $part
	set pos [find_partition $part $basis_string]
    }
    # Add length of partition number + & to get to next carriage return
    set pos [expr $pos + 2 + [string length $part]]
    set new_string [string range $basis_string 0 $pos]
    append new_string $var_val
    append new_string [string range $basis_string [incr pos] end]
    set basis_string $new_string
}

################################################################
# proc database_format                                         #
# Converts variable name and list of values into form which    #
# can be inserted into database                                #
################################################################
proc database_format {var val type} {

    set string " $var="
    append string [dbase_val_format $val $type]
    return "$string\n"
}

################################################################
# proc dbase_val_format                                        #
# Converts the list $val into a string of form:                #
# val1,\n val2,\n, val3,\n.... valn                            #
# Delimits values with ' character if type is string           #
################################################################
proc dbase_val_format {val type} {

    if {$type=="string"} {set d "'"} else {set d ""}
    set string "$d[lindex $val 0]$d"

    for {set i 1} {$i<[llength $val]} {incr i} {
	append string ",\n $d[lindex $val $i]$d"
    }

    return $string
}

