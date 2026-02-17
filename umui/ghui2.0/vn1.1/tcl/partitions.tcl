####################################################################################
#                       Variable partition procedures                              #
####################################################################################
# These procedures are concerned with the classification of variables by partition #
#                                                                                  #
# proc partition_info creates two arrays from the data stored in a standard        #
# partition database in the /variables directory:                                  #
# 1. inactive_partition contains one element for each listed partition identifier  #
#    the element is set to the active status expression. For cross-submodel        #
#    variables the value is a list starting with X followed by one element for     #
#    each partition. In the database, the status of cross-partition variables may  #
#    relate to the values set for the partitions it contains, so this routine reads#
#    the file twice: first time it reads single partition indexes, second time it  #
#    reads cross-partition variables                                               #
# 2. win_prefix is used when the name of window relating to a cross-submodel       #
#    variable is required. In the


proc partition_info {part_var win_var file_name} {
    # Build up array of partitions and whether partitions are active or not
    # Partitions maybe fully active or inactive in which case 0 or 1 is returned
    # Inactive status may depend on index in which case a list is returned
    upvar $part_var inactive_partition
    upvar $win_var win_prefix
    set inactive_partition(q) 1
    unset inactive_partition
    
    if {[file readable [directory_path variables]/$file_name]==0} {return}

    for {set loop 1} {$loop<=2} {incr loop} {
	# The loop is an artificial way to make sure that single partition variables
	# are read in before multiple partition ones. This is because the multiple
	# ones can depend on the single ones
	set a [open [directory_path variables]/$file_name]
	while {[gets $a line]!=-1} {
	    #puts "line $line"
	    # Ignore comments
	    if {[string index $line 0]=="#"} {continue}

	    set part [lindex $line 0]
	    set name [lindex $line 1]
	    set status [lrange $line 2 end]
	    if {([llength $status]==1)&&($loop==1)} {
		# loop==1: 1st pass through database
		# Variable is either totally active 0  or totally inactive 1

		set inactive_partition($part) $status

		# winpref relates partition name to window prefix for all the 
		# single partition identities - this is used when cross-partition
		# identities relate to these partitions
		set winpref($part) $name
		#puts "partition1 $part $inactive_partition($part)"

	    } elseif {([llength $status]!=1)&&($loop==2)} {
		# loop==2: 2nd pass through database
		# Some elements of variable are active; some are inactive

		set inactive_partition($part) "X"
		set win_prefix($name) $name
		foreach expr $status {
		    if [info exists inactive_partition($expr)] {
			# status of this index of cross-partition number
			# relates to a previously recorded single partition number
			# ie $expr is a partition identifier
			# Use the active expression relating to that partition
			lappend win_prefix($name) $winpref($expr)
			set inactive $inactive_partition($expr)
		    } else {
			# Does not relate to a single partition identifier
			# $expr is a valid expression
			lappend win_prefix($name) $name
			set inactive $expr
		    }
		    lappend inactive_partition($part) $inactive
		}
		#puts "partition2 $part $inactive_partition($part) $win_prefix($name)"
	    }
	}
	close $a
    }
}


#####################################################################################
# proc partition_status                                                             #
# Checks active status of partition as read in by proc partition_info. Only         #
# considers initial letter of partition number. May be called from anywhere         #
# without need to declare any global variables (cf proc js_partition_status below   #
# index relates to partition number. Should be -1 to obtain list for each partition #
#####################################################################################
proc partition_status {part index} {
    global inactive_partition

    set code [string index $part 0]
    set inactive $inactive_partition($code)

    return [eval_part_list $inactive $index]
}

#####################################################################################
# proc js_part_status                                                               #
# Similar to partition_status but:                                                  #
#    - uses a variable that must be visible to the calling routine; hence local.    #
#    - returns -1 if partition is not listed.                                       #
#    - considers whole partition number rather than just first letter.              # 
# Written with jobsheet function in mind but can be used for any partition database #
#####################################################################################
proc js_part_status {part index} {
    # Get partition list from calling routine
    upvar js_inactive_partition partition_list

    if {[info exists partition_list($part)]==0} {
	# This partition has not been listed - return -1
	return -1
    }

    set inactive $partition_list($part)
    
    return [eval_part_list $inactive $index]
}


####################################################################################
# proc eval_part_list                                                              #
# This routine does the evaluation of a general partition active status list       #
####################################################################################
proc eval_part_list {inactive index} {

    if {[llength $inactive]==1} {
	# This is a single partition variable - evaluate and return result
	return [eval_logic $inactive]
    }
    if {[lindex $inactive 0]=="X"} {
	# A cross-partition variable
	if {$index!=-1} {
	    # Called with an index relating to the partition so return appropriate result
	    return [eval_logic [lindex $inactive $index]]
	} else {
	    # Called without index so return a list of values starting with X to 
	    # highlight fact that its a list
	    set result X
	    for {set i 1} {$i<[llength $inactive]} {incr i} {
		lappend result [eval_logic [lindex $inactive $i]]
	    }
	    return $result
	}
    }
}
