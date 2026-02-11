# count_ppfields.tcl
#   Count the PP fields to be written to each stream.
#
# Usage:
#   First call initPPCount to initialise count. Then call sumPPCount 
#   once for each active diagnostic. Finally call checkPPCount to 
#   create a warning message if maximum exceeded.

# initPPcount
#  Initialise counts in global count array

proc initPPCount {} {
    global PPCount

    # Unset existing array
    foreach index [array names PPCount *] {
	unset PPCount($index)
    }
    
    # Initialise counts for all possible streams
    # PP streams
    for {set i 60} {$i <=69} {incr i} {
	set PPCount($i) 0
    }
    
    # For 151 output unit    
    set PPCount(151) 0
    
    # Climate mean PP files
    for {set i 1} {$i <=4} {incr i} {
	set PPCount(P$i) 0
    }
}

# sumPPCount
#  For a given diagnostic count the number of fields to be written
#  before its stream is first initialised and add to total.

proc sumPPCount {m isec item itim idom iuse} {
    global PPCount
    set ml [modnumber_to_letter $m]

    # How many timesteps before this PPfile is finished with - will
    # return -1 for climate means

    set period [resolveUsagePeriod $ml $iuse]

    if {$period != 0} {
	# Data is going to a PP field

	# Where is data going to (60 to 69, or a list of P1 to P4 for 
	# climate means)

	set stream [resolveUsageStream $ml $iuse]

	if {$period != -1} {
	    # How many times will field be output during this period
	    set l_reinit [periodicReinitialise $ml $iuse]
	    set nOutputTimes [resolveTime $ml $itim $iuse $l_reinit $period]
	} else {
	    # For climate mean PP files, just get one output per period
	    set nOutputTimes 1
	}

	# How many levels will be output
	set nLevels [resolveDomain $ml $idom]

	# Allow for climate means that can go to one or more of P1, 
	# P2, P3, P4
	set nFields [expr $nOutputTimes * $nLevels]
	foreach s $stream {
	    incr PPCount($s) $nFields
	}
    }
}

# checkPPcount
#  Check that counts do not exceed $max fields
# Argument
#  max : Maximum number of fields allowed in a PP field.
#  Returns: no value 

proc checkPPCount {w max} {
    global PPCount

    set warn 0

    # PP streams
    for {set i 60} {$i <=69} {incr i} {
	set j [expr $i - 60]
	set maxPPs($j) $max
	set ppos [lindex [get_variable_array PPOS] $j]
	if {$ppos > $max} {
	     set maxPPs($j) $ppos
	}
	if {$PPCount($i) > $maxPPs($j)} {
	    set warn 1
	}
    }
    # For 151 output unit 
        set max151 $max
	set ppos [lindex [get_variable_array PPOS] 10]
	if {$ppos > $max} {
	     set max151 $ppos
	}	
	if {$PPCount(151) > $max151} {
	    set warn 1
	}    
    # Climate mean PP files
    set max_mean 14000
    for {set i 1} {$i <=4} {incr i} {
	if {$PPCount(P$i) > $max_mean} {
	    set warn 1
	}
    }
    if {$warn == 0} {return}

    set text "\nWarning!!! You may exceed the maximum number of PP fields per file
	      \nEstimated number of PP files to be written:\n"
    addTextToWindow $w $text "PP-Field Count Estimates"

    # PP special stream 151
    if {$PPCount(151) > $max151} {
	    addTextToWindow  $w "\n$PPCount(151) fields in stream 151.  Maximum allowed is $max151."    
    }
   
    # PP streams
    for {set i 60} {$i <=69} {incr i} {
        set j [expr $i - 60]
	if {$PPCount($i) > $maxPPs($j)} {
	    addTextToWindow  $w "\n$PPCount($i) fields in stream $i.  Maximum allowed is $maxPPs($j)."
	}
    }
    # Climate mean PP files
    set warnCM 0
    for {set i 1} {$i <=4} {incr i} {
	if {$PPCount(P$i) > $max_mean} {
	    addTextToWindow  $w "\n$PPCount(P$i) fields in Climate mean Period_$i"
	    set warnCM 1
	}
    }
    if { $warnCM == 1 } {
        addTextToWindow $w "\n\nMaximum allowed is $max fields per Climate Mean Period.\n\n "
    }

    return
}

# climateMeaningRequired
#   Returns 1 if any climate meaning is requested.

proc climateMeaningRequired {} {
    global PPCount
    set CMRequired 0
    for {set i 1} {$i <=4} {incr i} {
	if {$PPCount(P$i) != 0} {set CMRequired 1}
    }
    return $CMRequired
}

# resolveUsagePeriod
#  Calculate period over which a given stream will be sent PP fields
# Arguments
#  l : Model letter
#  iuse : Usage profile number
# Method
#  For reinitialised PP files, return the period. For PP files that 
#  aren't reinitialised return the run target end as being an estimate.
#  For climate means return -1 - the fields are only written at one point
#  after which the file will be archived immediately.

proc resolveUsagePeriod {l iuse} {
    global PPCount
    
    # Check first in case this one has already been calculated
    if {[array names PPCount "use$iuse,period"] != "use$iuse,period"} {
	if {[get_variable_value LOCN_$l\($iuse)] == 2} {
	    # Climate means
	    set PPCount(use$iuse,period) -1
	} elseif {[get_variable_value LOCN_$l\($iuse)] == 3} {
	    # Normal PP stream
	    set stream [expr [get_variable_value IUNT_$l\($iuse)]-59]  
        
        # Assign 11th stream for 151 unit         
        if {$stream == 92} {
           set stream 11
        } 
            
	    if {[get_variable_value PPI($stream)] == "Y"} {
		# Reinitialising. So convert period to timesteps
		set period [get_variable_value PPIF($stream)]
		set unit   [get_variable_value PPIU($stream)]
		set PPCount(use$iuse,period) [totimep $period $unit $l]
	    } elseif {[get_variable_value PPI($stream)] == "N"} {
		# Not reinitialising - assume length of run
		set PPCount(use$iuse,period) [getRunLength $l T]
        }
             
	} else {
	    # Not outputting to PP file
	    set PPCount(use$iuse,period) 0
	}
    }
    return $PPCount(use$iuse,period)
}

# periodicReinitialise
#  Returns 1 if profile attached to stream that is periodically reinitialise
# Arguments
#  l : Model letter
#  iuse : Usage profile

proc periodicReinitialise {l iuse} {

    set result 0
    if {[get_variable_value LOCN_$l\($iuse)] == 3} {
	# Normal PP stream
	set stream [expr [get_variable_value IUNT_$l\($iuse)]-59]
    
    # Assign 11th stream for 151 unit         
        if {$stream == 92} {
           set stream 11
        } 
            
	if {[get_variable_value PPI($stream)] == "Y"} {
	    set result 1
	}
    }
    return $result
}

# resolveUsageStream 
#  Return a list of streams to which this usage profile directs PP-fields
# Arguments
#  l : Model letter
#  iuse : Number of usage profile

proc resolveUsageStream {l iuse} {
    global PPCount

    if {[array names PPCount "use$iuse,stream"] != "use$iuse,stream"} {
	set PPCount(use$iuse,stream) ""
	if {[get_variable_value LOCN_$l\($iuse)] == 2} {
	    # Climate means
	    for {set i 1} {$i <= 4} {incr i} {
		if {[get_variable_value TAGCM$i\_$l\($iuse)]=="T"} {
		    lappend PPCount(use$iuse,stream) P$i
		}
	    }
	} elseif {[get_variable_value LOCN_$l\($iuse)] == 3} {
	    set PPCount(use$iuse,stream) [get_variable_value IUNT_$l\($iuse)]
	}
    }

    return $PPCount(use$iuse,stream)
}

	    
# resolveTime
#  Calculate number of output periods this time profile has per PP file
# Arguments
#  l : Model letter
#  itim : Time profile number
#  iuse : Usage profile number
#  l_reinit : Logical - 1 for periodic reinitialisation
#  period : Reinitialisation period or length of run
# Method
#  Some guesswork is required:
#  If the start to end time is smaller than the period, use this. But
#  if the start to end time is larger, use the period - even if it is
#  possible that the overlap

#  For streams that are not periodically reinitialised, take the start
#  and end times into account. For streams that are periodically
#  reinitialised, only take start and end times into account if they
#  don't span a full period.
#
#  For specified lists of output periods, assume that whole list goes
#  to one PP file

proc resolveTime {l itim iuse l_reinit period} {
    global PPCount

    # Calculation depends on a combination of time and usage profiles
    if {[array names PPCount "tim$itim,use$iuse,$l_reinit"] != "tim$itim,use$iuse,$l_reinit"} {

	# Regular intervals (1) or specified list (2)
	set iopt [get_variable_value IOPT_$l\($itim)]
	
	if {$iopt == 1 || $iopt == 3} {
	    # Regular intervals
	    # Get time units and output frequency in timesteps
	    set ifre [get_variable_value IFRE_$l\($itim)]
	    
	    
	    if { $iopt == 1 } {
	        set iend [get_variable_value IEND_$l\($itim)]
	        set unt3 [get_variable_value UNT3_$l\($itim)]
	    } else { 
	        set iend [ profileHrs $l $itim END ]
	        set unt3 H	       
	    }
	    set ifret [totimep $ifre [get_variable_value UNT3_$l\($itim)] $l]
	    
            if {$iend == -1} {
	        # Continue till end of run
	        if {$l_reinit==0} {
		    # Not reinitialising - so subtract start time
		    set istr [get_variable_value ISTR_$l\($itim)]
		    set istrt [totimep $istr $unt3 $l]
		    set period [expr $period - $istrt + $ifret]
	        }
	        set nOutputTimes [int [expr $period/$ifret]]
	    } else {  
	        if { $iopt == 1 } {	       
	            set istr [get_variable_value ISTR_$l\($itim)]
	        } elseif { $iopt == 3 } {
	            set istr [ profileHrs $l $itim START ]
                }
	        if {$l_reinit==0} {
		    # Not reinitialising - set period to iend if less than period
		    set iendt [totimep $iend $unt3 $l]
		    if {$period > $iendt } {set period $iendt}
		    # Then subtract start time
		    set istrt [expr [totimep $istr $unt3 $l] - $ifret]
		    set nOutputTimes [int [expr ($period - $istrt)/$ifret]]
		    # If start time greater than period - no outputs
		    if {$nOutputTimes < 0} {set nOutputTimes 0}
		} else {
		    # Reinitialising - use min of period or start-end time
		    set p2 [totimep [expr $iend - $istr+1] $unt3 $l]
		    if {$p2 < $period} {set period $p2}
		    # Round up to largest possible number of output times
		    set nOutputTimes [int [expr ($period + $ifret - .0001)/$ifret]]
	        }
	    }
	} else {
	    # Specified list
	    set nOutputTimes [get_variable_value ITIMES_$l\($itim)]
	}
	set PPCount(tim$itim,use$iuse,$l_reinit) $nOutputTimes
	#puts "Profile $itim has  $nOutputTimes OutputTimes"
    }
    return $PPCount(tim$itim,use$iuse,$l_reinit)
}

# profileHrs
# When IOPT=3 then the given start/end dates must be converted to model hours
# Arguments
#  l : Model letter
#  itim : Time profile number
#  input : "START" or "END"
#
proc profileHrs {l itim input} {
    set rsyr [get_variable_value SRYR]
    set rsmo [get_variable_value SRMO]
    set rsda [get_variable_value SRDA]
    set rshr [get_variable_value SRYR]
    set startrun [ expr $rsyr*360*24 + $rsmo*12*24 + $rsda*24 + $rshr ]

    if {$input=="START"} {
	set psyr [get_variable_value ISDTY_$l\(1,$itim)]
        set psmo [get_variable_value ISDTM_$l\(1,$itim)]
        set psda [get_variable_value ISDTD_$l\(1,$itim)]
        set pshr [get_variable_value ISDTY_$l\(1,$itim)]
        set startprofile [ expr $psyr*360*24 + $psmo*12*24 + $psda*24 + $pshr ]  
	set hrs [ expr $startprofile - $startrun ] 
        if { $hrs < 1 } {
	    set hrs 0
	}
	return $hrs
	 
    
    } elseif {$input=="END"} {
        set peyr [get_variable_value IEDTY_$l\(1,$itim)]
        set pemo [get_variable_value IEDTM_$l\(1,$itim)]
        set peda [get_variable_value IEDTD_$l\(1,$itim)]
        set pehr [get_variable_value IEDTY_$l\(1,$itim)]
        set endprofile [ expr $peyr*360*24 + $pemo*12*24 + $peda*24 + $pehr ] 
       	set hrs [ expr $endprofile - $startrun ]
        if { $hrs < 1 } {
	    set hrs 0
	}
	return $hrs
	
    } else {
        error "unknown limit for TIME profile calculation ($input)."
    }
    return 0
}
 


# resolveDomain
#  Calculate number of fields in the domain.
# Arguments
#  l : Model letter
#  idom : Number of domain

proc resolveDomain {l idom} {
    global PPCount

    if {[array names PPCount "dom$idom,levels"] != "dom$idom,levels"} {
	# What sort of level list
	if {[get_variable_value IMN_$l\($idom)] == 1} {
	    # Vertical mean - only one level
	    set levs 1
	} else {
	    set iopl [get_variable_value IOPL_$l\($idom)]
	    if {$iopl == 5} {
		# Single level
		set levs 1
	    } elseif {$iopl == 1 || $iopl == 2 || $iopl == 6} {
		# Range or selection of integer levels
		set ilevs [get_variable_value ILEVS_$l\($idom)]
		if {$ilevs == 1} {
		    set levb [lnConvertInput [get_variable_value LEVB_$l\($idom\)]]
		    set levt [lnConvertInput [get_variable_value LEVT_$l\($idom\)]]
		    set levs [expr $levt - $levb + 1]
		} else {
		    set levs [llength [get_variable_array LEVLST_$l\(*,$idom)]]
		}
	    } elseif {$iopl == 4 || $iopl == 7 || $iopl == 8 || $iopl == 9} {
		set levs [llength [get_variable_array RLEVLST_$l\(*,$idom)]]
	    } elseif {$iopl == 3} {
                set isccp [get_variable_value ISCCP_$l\($idom\)]
                if {$isccp == 2} {
                    # Set to number of ISCCP levels - this is the length of the levels 
                    # list in the stashcall processing file when ISCCP is chosen.
                    set levs 7
                } else {
		    set levs [llength [get_variable_array PLEVLST_$l\(*,$idom)]]
                }
	    } else {
		error "Level type $iopl not recognised in Domain Profile \
			$idom ([get_variable_value DOMPRO_$l\($idom)])"
	    }
	}
	# Any pseudo levels ?
	set plt [get_variable_value PLT_$l\($idom)]
	if {$plt == 0} {
	    set pslevs 1
	} else {
	    set pslevs [llength [get_variable_array PSLIST_$l\(*,$idom)]]
	}
	set PPCount(dom$idom,levels) [expr $levs * $pslevs]
    }
    return $PPCount(dom$idom,levels)
}

# getRunLength
#  Return target run length in requested units
# Arguments
#  l : Model letter
#  unit : Time units to return.
# Comments
#  Initially only returns timesteps, not DA, DU, H for days, dump periods
#  or hours.

proc getRunLength {l unit} {
    if {$unit != "T"} {
	error "getRunLength: Only works for unit T=timesteps at the moment, \
		not unit $unit"
    }
    set days [expr \
	    [get_variable_value ERYR] * 365 + \
	    [get_variable_value ERMO] * 30  + \
	    [get_variable_value ERDA]       + \
	    [get_variable_value ERHR] / 24. + \
	    [get_variable_value ERMI] / (24.*60.) + \
	    [get_variable_value ERSE] / (24.*60.*60.) \
	    ]
    set length [totimep $days DA $l]
    #puts "Days $days timesteps $length"
    return $length
}
    
