# Update the experiment details to take account of changes in its jobs


# Update version, atmosphere, ocean, slab and mesoscale which are dependent on
# the underlying jobs
#
proc update_exp_details id {

    global experiments jobs titles

    # Collect list of columns - all application columns + version column if displayed
    set list $titles(app_columns)
    if {[lsearch $titles(ghui_columns) "version"]!=-1} {lappend list "version"}

    foreach item $list {
	set types($item) {}
    }
    foreach job_id $experiments($id,joblist) {
	foreach item $list {
	    lappend types($item) $jobs($id$job_id,$item)
	}
    }

    # set experiment details
    foreach item $list {
	if { $item=="version" } {
	    set experiments($id,version) [highest_version $types(version)]
	} else {
	    set  experiments($id,$item) [const_or_mix $types($item)]
	}
    }

    # save experiment details to disk
    save_experiment_details $id
}

# highest_version
#   return the highest experiment number from the list. If there is
#   more than one different version number, add a minus sign to
#   indicate that lower versions are present
# Argument
#   versions: List of version numbers. Integers and decimal points only.
# Comments
#   For the following versions: 
#         1.1 < 1.2 < 1.2.1 < 1.9 < 1.10 < 1.10.9 < 1.10.10

proc highest_version {versions} {

    # return none! for empty list
    if {[set len [llength $versions]] == 0} {
	return "none!"

	# just return if a single item
    }

    # Must be digits, decimal points and spaces only
    if {[regexp {^[ .0-9]*$} $versions] == 0} {
	return "Error!"
    }

#    -unique option only available in tcl from version 8.3.0. Rewrite in
#    order to use older versions of tcl
#    set versions [lsort -decreasing -unique -command sortJobids $versions]
    set versions [lsort -decreasing -command sortJobids $versions]
    set v1 ""
    foreach version $versions {
       if {$version != $v1} {lappend versions1 $version}
       set v1 $version
    }
    set versions $versions1
    set highVersion [lindex $versions 0]

    # prepend a minus sign if there are multiple versions
    if {[llength $versions] > 1} {
	return -$highVersion
    } else {
	return $highVersion
    }
}

# sortJobIds
#   Given two job IDs, returns a value indicating which is the higher 
#   version number. See proc highest_version for sort order.
# Arguments
#   id1, id2: Two job IDs to compare
# Comments
#   Used as -command argument in lsort call in proc highest_version

proc sortJobids {id1 id2} {

    # Split versions into a list of integers eg 4.1.10 goes to [list 4 1 10]
    set list1 [split $id1 .]
    set list2 [split $id2 .]

    # Get length of each list and get shortest length
    set length [set length1 [llength $list1]]
    set length2 [llength $list2]
    if {$length2 < $length} {
	set length $length2
    }

    # Check elements of version id one by one from left to right up to the 
    # last element of the shortest list.
    
    for {set i 0} {$i < $length} {incr i} {
	set index1 [lindex $list1 $i]
	set index2 [lindex $list2 $i]
	if {$index1 < $index2} {
	    return -1
	} elseif {$index2 < $index1} {
	    return 1
	}
    }

    # At this point elements are the same up to the last version of the 
    # shortest list. ie. we have compared the first two elements of 
    # "5.5" and "5.5.1". Given this, the latest version is the one with
    # an additional element ("5.5.1" in this case)

    if {$length1 < $length2} {
	return -1
    } elseif {$length2 < $length1} {
	return 1
    }
    # Still the same so return 0
    return 0
}

# return value of list elements if they are all the same, or M for mixed.
#
proc const_or_mix items {

    # return N (No) for an empty list
    if {[llength $items] == 0} {
	return N
    }

    # compare each to first item
    set first [lindex $items 0]
    for {set i 1} {$i < [llength $items]} {incr i} {
	# if there is a different item then return M (mixed).
	if {! [string match $first [lindex $items $i]]} {
	    return M
	}
    }

    # They are all the same, so just return that
    return $first
}
