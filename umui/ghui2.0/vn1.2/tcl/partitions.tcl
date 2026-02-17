####################################################################################
#                       Variable partition procedures                              #
####################################################################################
# These procedures are concerned with the classification of variables by partition #
#                                                                                  #
# proc partition_info creates two arrays from the data stored in a standard        #
# partition database in the /variables directory:                                  #
# 1. $partVar contains one element for each listed partition identifier  #
#    the element is set to the active status expression. For cross-submodel        #
#    variables the value is a list starting with X followed by one element for     #
#    each partition. In the database, the status of cross-partition variables may  #
#    relate to the values set for the partitions it contains, so this routine reads#
#    the file twice: first time it reads single partition indexes, second time it  #
#    reads cross-partition variables                                               #
# 2. win_prefix is used when the name of window relating to a cross-submodel       #
#    variable is required. In the

namespace eval partitionInfo {
    namespace export partition_info
    namespace export partition_status
    namespace export sub_partition_status
    namespace export windowPrefix
}

proc ::partitionInfo::partition_info {partVar winVar fileName} {
    # Build up array of partitions and whether partitions are active or not
    # Partitions maybe fully active or inactive in which case 0 or 1 is returned
    # Inactive status may depend on index in which case a list is returned
    variable $partVar
    variable $winVar

    if {[info exists $partVar] == 1} {
	unset $partVar
    }
    if {[info exists $winVar] == 1} {
	unset $winVar
    }
    
    if {[file readable [directory_path variables]/$fileName]==0} {
	eval set ${partVar}(fileExists) 0
	return
    }
    eval set ${partVar}(fileExists) 1

    for {set loop 1} {$loop<=2} {incr loop} {
	# The loop is an artificial way to make sure that single partition variables
	# are read in before multiple partition ones. This is because the multiple
	# ones can depend on the single ones
	set a [open [directory_path variables]/$fileName]
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

		#puts "set ${partVar}(expr,$part) $status"
		eval set ${partVar}(expr,$part) $status

		# winpref relates partition name to window prefix for all the 
		# single partition identities - this is used when cross-partition
		# identities relate to these partitions
		set winpref($part) $name
		#puts "partition1 $part [set ${partVar}(expr,$part)]"

	    } elseif {([llength $status]!=1)&&($loop==2)} {
		# loop==2: 2nd pass through database
		# Some elements of variable are active; some are inactive

		#puts "set ${partVar}(expr,$part) X"
		eval set ${partVar}(expr,$part) "X"
		#puts "eval set ${winVar}($name) $name"
		eval set ${winVar}($name) $name
		foreach subExpr $status {
		    if [info exists ${partVar}(expr,$subExpr)] {
			# status of this index of cross-partition number
			# relates to a previously recorded single partition number
			# ie $expr is a partition identifier
			# Use the active expression relating to that partition
			#puts "eval lappend ${winVar}($name) $winpref($subExpr)"
			eval lappend ${winVar}($name) $winpref($subExpr)
			set inactive [set ${partVar}(expr,$subExpr)]
		    } else {
			# Does not relate to a single partition identifier
			# $expr is a valid expression
			#puts "eval lappend ${winVar}($name) $name"
			eval lappend ${winVar}($name) $name
			set inactive $subExpr
		    }
		    #puts "eval lappend ${partVar}(expr,$part) $inactive"
		    eval lappend ${partVar}(expr,$part) $inactive
		}
		#puts "partition2 $part [set ${partVar}(expr,$part)] ${winVar}($name)"
	    }
	}
	close $a
    }
}


# partition_status

#   Public procedure that returns active status of partition group;
#   only considers initial letter of partition number (cf
#   sub_partition_status below). 
# Arguments
#   part: Whole partition id
#   index: For arrays that exist in more than one partition group
#          the index of the array will indicate the group that the
#          element of interest is in. Index of -1 obtains  list for 
#          each partition
#   partVar: Array variable containing information read from partition
#            database in matching call to partition_info. Default
#            value of inactive_partition relates to main 
#            partition.database file.
# Result
#   Return the active status of the partition (1 for inactive or 0 for
#   active). If the partition is not registered return -1, if the
#   partition database does not exist return 0 ie. if no database
#   exists, the partition is active by default. If there is no data at
#   all for this partition database variable give an error.

proc ::partitionInfo::partition_status {part index {partVar inactive_partition}} {
    variable $partVar

    if {[info exists $partVar] == 0} {
	error "No corresponding call to partition_info to set up $partVar database"
    }
    if {[set ${partVar}(fileExists)] == 0} {
	# This application does not contain a partition database of this type
	# so by default all partitions are active
	return 0
    }

    set code [string index $part 0]
    if {[info exists ${partVar}(expr,$code)]==0} {
	# This partition has not been listed - return -1
	return -1
    }

    set inactive [set ${partVar}(expr,$code)]

    return [eval_part_list $inactive $index]
}

#####################################################################################
# proc sub_part_status                                                              #
# Similar to partition_status but:                                                  #
#    - returns -1 if partition is not listed.                                       #
#    - considers whole partition number rather than just first letter.              # 
# Written with jobsheet function in mind but can be used for any partition database #
#####################################################################################
proc ::partitionInfo::sub_partition_status {part index {partVar inactive_partition}} {
    variable $partVar

    if {[info exists $partVar] == 0} {
	error "No corresponding call to partition_info to set up $partVar database"
    }
    if {[set ${partVar}(fileExists)] == 0} {
	# This application does not contain a partition database of this type
	return 0
    }

    if {[info exists ${partVar}(expr,$part)]==0} {
	# This partition has not been listed - return -1
	return -1
    }

    set inactive [set ${partVar}(expr,$part)]
    
    return [eval_part_list $inactive $index]
}

proc ::partitionInfo::windowPrefix {winVar winPref} {
    variable $winVar
    if {[info exists ${winVar}($winPref)]} {
	return [set ${winVar}($winPref)]
    } else {
	return ""
    }
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
