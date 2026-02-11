#
# count_tseries.tcl
#
# Procedures to count total number of timeseries being 
# requested and to produce warnings if they are exceeded
#
# Usage:
#   First call initTSCount to initialise count. Then call sumTSCount 
#   once for each active diagnostic. Finally call checkTSCount to 
#   create a warning message if maximum exceeded.

# initTScount
#  Initialise counts in global count array

proc initTSCount {} {
    global TSCount

    # Unset existing array
    foreach index [array names TSCount *] {
	unset TSCount($index)
    }
    # Initialise count
    set TSCount(count) 0
}

# sumTSCount
#  For a given diagnostic count the number of timeseries

proc sumTSCount {m idom} {
    global TSCount
    set ml [modnumber_to_letter $m]

    # Is this a timeseries profile
    if {[get_variable_value DDOMTS_$ml\($idom\)] == "Y"} {
	# This is a timeseries domain profile
	if {[get_variable_value TDOMTS_$ml\($idom\)] != 2} {
	    # Method 1: Each row is a single request
	    incr TSCount(count) [get_variable_value NDOMTS_$ml\($idom\)]
	} else {
	    # Method 2: A row may request separate timeseries over a range of levels
	    for {set i 1} {$i <= [get_variable_value NDOMTS_$ml\($idom\)]} {incr i} {
		# Loop through each line of table
		set iopl [get_variable_value IOPL_$ml\($idom\)]
		if {$iopl == 5 } {
		    # Single or unspecified level
		    incr TSCount(count)
		} elseif {$iopl == 1 || $iopl == 2 || $iopl == 6} {
		    # One or more integer level
		    set ilevs [get_variable_value ILEVS_$ml\($idom\)]
		    if {$ilevs == 1} {
			# Range of levels
			set levb [lnConvertInput [get_variable_value LEVB_$ml\($idom\)]]
			set levt [lnConvertInput [get_variable_value LEVT_$ml\($idom\)]]
			incr TSCount(count) [expr $levt - $levb + 1]
		    } else {
			# Level list
			set list [get_variable_array LEVLST_$ml\(*,$idom\)]
			set start [get_variable_value DOMTSR_LF_$ml\($i,$idom\)]
			set end [get_variable_value DOMTSR_LL_$ml\($i,$idom\)]
			incr TSCount(count) [TSresolveRange $list $start $end]
		    }
		} else {
		    # List of real levels
		    if {$iopl == 3} {
			set list [get_variable_array PLEVLST_$ml\(*,$idom\)]
		    } else {
			set list [get_variable_array RLEVLST_$ml\(*,$idom\)]
		    }
		    set start [get_variable_value DOMTSR_RF_$ml\($i,$idom\)]
		    set end [get_variable_value DOMTSR_RL_$ml\($i,$idom\)]
		    incr TSCount(count) [TSresolveRange $list $start $end]
		}
	    }
	}
    }
}

# TSResolveRange
#   Given a list of levels and a range, returns the number of levels in that
#   range
# list : List of real or integer levels
# start,end : Defines range of levels to select

proc TSResolveRange {list start end} {			
    if {$end < $start} {
	set a $end
	set end $start
	set start $a
    }
    set p1 [lsearch $list $start]
    set p2 [lsearch $list $end]
    return [expr $p2 - $p1 + 1]
}

# checkTScount
#  Check that counts do not exceed $max requests
# Argument
#  max : Maximum number of timeseries requests allowed.

proc checkTSCount {w max} {
    global TSCount

    set warn 0

    if {$TSCount(count) > $max} {
	
	set text "
	\nWarning: \nYou have exceeded the maximum number of timeseries requests
	\nYou have requested $TSCount(count) timeseries but the limit is $max:\n"
	addTextToWindow $w $text "Timeseries Count Estimates"
    }

    return
}
