# verify_stash.tcl
#
#   Contains procedures used to verify that the STASH request of
# a given submodel are complete and consistent. Toplevel routine
# is called with a model number, and the list of requests is 
# extracted from the diagnostic table.
# 
# Authors: Mick Carter, Andy Brady 7/95
#          Revised for ghui2.0: Steve Mullerworth 5/98

proc verifySTASH {m} {
    global stInstance
    
    # First check for any diagnostics with missing profiles or
    # any profiles that are unset.
    # If there are none continue and check validity of diagnostics
    # against profiles. If there are, produce a dialog with list of them.

    # Read diagnostics and profiles into stInstance object
    readSTASHWindow $m

    # Return if diagnostics table empty
    if {$stInstance($m,nDiags) == 0} {return}

    if [blankProfileCheck $m] {
	# Cannot continue check till all diagnostics have valid profiles
	return
    }

    # Cross-check diagnostics with attached profiles
    doProfilesMatchDiags $m
}

# blankProfileCheck
#   Checks STASH diagnostic requests for blank or invalid profiles
#   creates a descriptive error message if required
# Argument
#   m : Model number
# Globals
#   stInstance : This array needs to have been loaded with the
#                contents of the STASH diagnostics window
# Result
#   1 for error, 0 for no error

proc blankProfileCheck {m} {
    global stInstance

    set blankList {}
    set profDeleted {}

    set s $stInstance($m,Root)
    set nDiags [plbMethod $s GetLength]

    for {set i 0} {$i < $nDiags} {incr i} {
	if {[diagnosticOn $m $i] == 1} {
	    # Only check diagnostics that have been switched on
	    set tim $stInstance($m,time,$i)
	    set dom $stInstance($m,domain,$i)
	    set use $stInstance($m,usage,$i)
	    set itim [lsearch $stInstance($m,time)   $tim]
	    set idom [lsearch $stInstance($m,domain) $dom]
	    set iuse [lsearch $stInstance($m,usage)  $use]

	    # Check if any profiles are blank, or if the profile names no longer exist
	    if {($tim=="")||($dom=="")||($use=="")} {
		# we have a missing profile
		lappend blankList $i
	    } elseif {($itim==-1)||($idom==-1)||($iuse==-1)} {
		lappend profDeleted $i
	    }
	}
    }

    set errorFlag 0

    if {[llength $blankList] != 0} {
	set errorFlag 1
	lappend message "The following diagnostics require a profile to be attached:"
	foreach line $blankList {
	    lappend message [diagDescription $m $line]
	}
    }
    if {[llength $profDeleted] != 0} {
	set errorFlag 1
	lappend message "" "The following diagnostics have a nonexistent profile attached:"
	foreach line $profDeleted {
	    lappend message [diagDescription $m $line]
	}
    }
    if $errorFlag {
	lappend message "Cannot continue check" \
		"Correct these errors and then run check again"
	catch {destroy .vStash$m}
	text_to_window .vStash$m $message 20 "STASH errors: Wrongly set profiles"
    }
    return $errorFlag
}

# diagDescription
#   Returns a formatted text description of a diagnostic request.
# Arguments
#   m : Model number
#   line : Line number of table
# Globals
#   stInstance : This array needs to have been loaded with the
#                contents of the STASH diagnostics window
# Method
#   Requires table contents to have been read into stInstance

proc diagDescription {m line} {
    global stInstance

    set spaces "                                           "
    set is [format "%3d" $stInstance($m,isec,$line)]
    set it [format "%3d" $stInstance($m,item,$line)]
    set name [string range "$stInstance($m,inam,$line) $spaces" 0 34]
    set itim [string range "$stInstance($m,time,$line)        " 0 7]
    set idom [string range "$stInstance($m,domain,$line)        " 0 7]
    set iuse [string range "$stInstance($m,usage,$line)        " 0 7]
    return " $is $it $name $itim $idom $iuse"
}
    
# doProfilesMatchDiags
#   Cross-check profiles against diagnostics. Produces errors as
#   program runs, but allows user to quit at any point.
# Globals
#   stInstance : This array needs to have been loaded with the
#                contents of the STASH diagnostics window

proc doProfilesMatchDiags {m} {
    global stInstance
    global errors


    set s $stInstance($m,Root)
    set nDiags [plbMethod $s GetLength]

    # Refresh the status line
    updateDiagNumber $m

    # Now we check the complete diagnostic/profiles entries to make
    # sure the profiles are valid for the given diagnostic.
    set errors(exist) 0
    set count 0

    # Initialise a count of pp-fields per stream
    initPPCount
    initTSCount

    set errWindow .diagErrors

    for {set i 0} {$i < $nDiags} {incr i} {
	if {[diagnosticOn $m $i] == 1} {
	    # Only check diagnostics that have been switched on
	    incr count
	    set isec $stInstance($m,isec,$i)
	    set item $stInstance($m,item,$i)
	    set txt $stInstance($m,inam,$i)
	    set tim $stInstance($m,time,$i)
	    set dom $stInstance($m,domain,$i)
	    set use $stInstance($m,usage,$i)
	    set itim [lsearch $stInstance($m,time) $tim]
	    set idom [lsearch $stInstance($m,domain) $dom]
	    set iuse [lsearch $stInstance($m,usage) $use]
	    incr itim
	    incr idom
	    incr iuse
	    set errors(msgs) ""
	    set errors(check) 0
	    set errors(txt) $txt
	    set errors(tim) $tim
	    set errors(dom) $dom
	    set errors(use) $use
	    check_diag $isec $item $itim $idom $iuse $m
	    if {$errors(check) !=0 } {
		set errors(exist) 1
		print_errors $errWindow
	    } else {
		# Diagnostic is active, included and there were no errors
		# so add up its contribution to count estimates
		sumPPCount $m $isec $item $itim $idom $iuse
		sumTSCount $m $idom
	    }
	}
    }
    checkPPCount $errWindow 4096

    # This limit is set by NTimSerP in VERSION.dk
    checkTSCount $errWindow 1500
    if {[climateMeaningRequired] == 0 && [inactive_var AMEAN($m)] == 0 && [get_variable_value AMEAN($m)] == "Y"} {
	addTextToWindow $errWindow "\nWarning:\
	\nYou have requested the climate means system but you have no diagnostics\
	\ntagged for climate meaning. This is inefficient. Turn off climate \
	\nmeaning in the \
	\n  -> Control\
        \n   -> Post processing, Dumping and Meaning\
	\nwindow.\n" "Turn off Climate Meaning"
    }
    
    if {$errors(exist) == 0 } {
	append_message $stInstance($m,Window) " of which $count are switched on : No Errors. Please report if this was unexpected"
    } else {
	append_message $stInstance($m,Window) ". Verification unsuccessful"
    }
}

# diagnosticOn
#   Determines whether diagnostic request is included or excluded 
#   from STASH request
# Arguments
#   m : Model id
#   i : Number of item in array

proc diagnosticOn {m i} {
    global stInstance
    if {$stInstance($m,iinc,$i) == "Y" && $stInstance($m,itag,$i) == "Y"} {
	return 1
    } else {
	return 0
    }
}


# check_diag
#   Runs a cross-check comparing a diagnostic with its attached profiles.
# Arguments
#   isec : stash section
#   item : stash item
#   tim_ind : time profile index
#   dom_ind : domain profile index
#   use_ind : usage profile index
#   model_number : 1 atmos
# Results
#   If error is found, sets errors(check) flag and stores details
#   in errors array.

proc check_diag {isec item tim_ind dom_ind use_ind model_number} {
    global stmsta errors
    
    set model_letter [modnumber_to_letter $model_number ] ; # A]

    set errors(isec) $isec
    set errors(item) $item
    set dumpfre ""

    #-----------------------------------------------------------------------------------------------
    # SECTION 1 -- check section,item is available
    
    if {$stmsta($model_number,$isec,$item,avail) == "N"} {
 	lappend errors(msgs) "DIAGNOSTIC    ERROR: Diagnostic is not available for this model configuration."
	set errors(check) 1
    } else {
    #-----------------------------------------------------------------------------------------------
    # SECTION 2 -- get all STASHmaster codes required for cross checking against profiles.
    set mmm $stmsta($model_number,$isec,$item,mmm)
    set model_id [get_variable_value MODEL_ID($model_number)] ; # set to A,O,S,W
    set model_partition [get_variable_value MODEL_PARTITION($model_number)] ; # set to 1,2,1,4 
    set partition_id [get_variable_value MODEL_ID($model_partition)] ; # set to 1,2,1,4 
    set sp  $stmsta($model_number,$isec,$item,sp)
    set ti  $stmsta($model_number,$isec,$item,ti)
    set gr  $stmsta($model_number,$isec,$item,gr)
    set lv  $stmsta($model_number,$isec,$item,lv)
    set lb  $stmsta($model_number,$isec,$item,lb)
    set lt  $stmsta($model_number,$isec,$item,lt)
    set pt  $stmsta($model_number,$isec,$item,pt)
    set pf  $stmsta($model_number,$isec,$item,pf)
    set pl  $stmsta($model_number,$isec,$item,pl)

    #-----------------------------------------------------------------------------------------------
    # SECTION 3 -- check diagnostic against time profile
    #...............................................................................................
    # 3.1 checks not dependent on frequency.
    set adump [get_variable_value ADUMP($model_partition)]
    set ityp [get_variable_value ITYP_$model_letter\($tim_ind\)]
    if { $ityp == 1 } {
	# unt1 and unt2 unused
	set unt1 "ZZ"
	set unt2 "ZZ"
    } else {
	set unt1  [get_variable_value UNT1_$model_letter\($tim_ind\)]
	set unt2  [get_variable_value UNT2_$model_letter\($tim_ind\)]
    }
    set unt3 [get_variable_value UNT3_$model_letter\($tim_ind\)]
    if { ( $adump!=1 && $adump!=3 ) && ( $unt1 == "DU" || $unt2 == "DU" || $unt3 == "DU"  ) } {
	lappend errors(msgs) "TIME PROFILE ERROR: Frequency set as 'DUMPS', but dumps are irregular."
	set errors(check) 1
    }
    if {[get_variable_value IOPT_$model_letter\($tim_ind\)]==1} {
	#.............................................................................................
	# 3.2 checks dependent on frequency.
    
	#  set output frequency and start time.
	set ifrep [get_variable_value IFRE_$model_letter\($tim_ind\)]
	set istrp [get_variable_value ISTR_$model_letter\($tim_ind\)]
	set ifre [ totimep $ifrep $unt3 $model_id ] 
	set istr [ totimep $istrp $unt3 $model_id ] 
	if { $adump == 1 } {
	    set adumpp [get_variable_value ADUMPP($model_partition)]
	    set dumpfre [ totimep $adumpp [get_variable_value ADUMPU($model_partition)] $model_id ]
    } elseif { $adump == 3 } {  
            set adumpprm [get_variable_value ADUMPPRM($model_partition)]
            set dumpfre [ totimep $adumpprm H $model_id ]
	} else {
	    set dumpfre 0 
	}
	if { ($ityp!= 1) && ( $ti == 2 || $ti == 3 || $ti == 4 || $ti == 13 ) } { 
	    # Not available every timestep and not snapshot. Need to check.
	    # Climate means are assumed available evry timestep (as STASH is called only when needed)  
	    # Set variables for cross checking
	    #
	    # set period (interval) & set sampling freq
	    if { $ityp == 1 } {
		# snap-shot 
		set intv 1 
		set isam 1 
	    } else {
		set intvp [get_variable_value INTV_$model_letter\($tim_ind\)]
		set isam [get_variable_value ISAM_$model_letter\($tim_ind\)]
		# period required 
		set intv [ totimep $intvp $unt1 $model_id ] 
		# sample freq required 
		set isam [ totimep $isam  $unt2 $model_id ] 
	    }
	    #
	    # set availability frequency:
	    if { $ti == 2 } {
		# LW-Rad timesteps
		set one_day [ totimep 1 "DA" "A" ]
		set ita [ expr $one_day / [get_variable_value LWINC ] ]
                unset one_day
	    } elseif { $ti == 3 } {
		# SW-Rad timesteps 
		set one_day [ totimep 1 "DA" "A" ]
		set ita [ expr $one_day / [ get_variable_value SWINC ]  ]
                unset one_day
	    } elseif { $ti == 13 } {
		# Convection timesteps  
		set ita [ get_variable_value CONFRE ] 
	    } elseif { $ti == 14 } {
		# Leaf Phenology Timestep
		set ita [ totimep [ get_variable_value VEGLPF ] "DA" "A"]
	    } elseif { $ti == 15 } {
		# Triffid Timestep.
		set ita [ totimep [ get_variable_value VEGIVF ] "DA" "A"]
	    } else  {
		lappend errors(msgs) "STASHmaster ERROR: Unrecognised time availablity code $it."
		set errors(check) 1
		set ita 1
	    }
	    #
	    # Checks on frequency
	    if { [ expr $ifre % $intv ] != 0 } {
		lappend errors(msgs) "TIME PROFILE ERROR: Output frequency does not divide into interval."
		set errors(check) 1
	    } 
	    if { ( [ expr $isam % $ita ] != 0 ) && $isam != 1 } {
		lappend errors(msgs) "TIME PROFILE ERROR: Diagnostic is not available at frequency specified."
		set errors(check) 1
	    } 
	    if { [ expr  $intv % $isam ] != 0 } {
		lappend errors(msgs) "TIME PROFILE ERROR: Processing interval is not a multiple of sampling freq."
		set errors(check) 1
	    } 
	}
    }
    #  end of time profile check.    
    
    #-----------------------------------------------------------------------------------------------
    # SECTION 4 -- check diagnostic against usage profile
    
    set locn [get_variable_value LOCN_$model_letter\($use_ind\)]
    
    if { $ti >= 5 && $ti <= 12} {
	# climate mean diagnostic
	if { $locn != 5 } {
	    # to pp file
	    lappend errors(msgs) "USAGE PROFILE ERROR: This diagnostic must be sent to the climate mean pp file."
	    set errors(check) 1
	}
    }

    if { $locn == 5} {
	# to pp file
	if { !($ti >= 5 && $ti <= 12)} {
	    # not a climate mean diagnostic
	    lappend errors(msgs) "USAGE PROFILE ERROR: Only climate mean diagnostics can be written direct to this pp-file."
	    set errors(check) 1
	}
    }

    if {$locn == 3} {
	# PP stream
        set iunt [get_variable_value IUNT_$model_letter\($use_ind\)]
        set stream [ expr ( $iunt  -  59 ) ]
    
        # Change the array index for unit 151
        if {$stream == 92} {
           set stream 11
        }        
        
        set ppm [get_variable_value PPM($stream)]
        set ppi [get_variable_value PPI($stream)]
       
	if {$ppi == "Y"} {
	    # Periodic re-initialisation
	    if { $ppm != $partition_id } {
		# atmospheric type and not atmosphere diagnostic, etc
		lappend errors(msgs) "USAGE PROFILE ERROR: You have not reserved this unit number for diagnostics in partition $partition_id."
		set errors(check) 1
	    }
	}
    }

    if {$locn == 2} {
	set amean [ get_variable_value AMEAN($model_partition) ]
	if {$amean !=  "Y"} {
	    # The interval is a divisor of the dumping period
	    lappend errors(msgs) "USAGE PROFILE ERROR: You are writing to the climate mean dump, you have no climate means."
	    set errors(check) 1
	}
	# Dump store, climate mean tag.
	if {$ityp != 1} {
	    # Not a single time field.
	    if { $unt1== "T"} {
		# Timesteps
		lappend errors(msgs) "USAGE PROFILE ERROR: Do not specify units of timesteps when writing to climate mean dump."
		set errors(check) 1		
	    }
	    if {($ifre > $dumpfre)||(fmod($dumpfre,$ifre) != 0)} {
		# Saving does not agree with dump frequency
		lappend errors(msgs) "TIME/USE PROF ERROR: Climate Mean. Your time frequency ($ifre) does not agree with dumping ($dumpfre)."
		set errors(check) 1
	    } elseif { $ifre != $dumpfre } {
		# Advisable to have matching time and dumping frequency
		lappend errors(msgs) "TIME/USE PROF WARNING: For climate meaning, output time frequency ($ifre) should normally match dumping ($dumpfre)."
		set errors(check) 1
	    }
	    set istrp [get_variable_value ISTR_$model_letter\($tim_ind\)]
	    set istr [ totimep $istrp $unt3 $model_id ] 
	    if {$istr != 0} {
		# Output time is not from start of run
		if {fmod($istr,$dumpfre) != 0} {
		    # Saving does not agree with dumping start
		    lappend errors(msgs) "TIME/USE PROF ERROR: Climate Mean. Your output start-time does not agree with dumping."
		    set errors(check) 1
		}
	    }
	}
    }
    
    #-----------------------------------------------------------------------------------------------
    # SECTION 5 -- check diagnostic against domain profile
    #...............................................................................................
    # 5.1 check level type.
    set iopl [get_variable_value IOPL_$model_letter\($dom_ind\)] 
    set ilevs [get_variable_value ILEVS_$model_letter\($dom_ind\)] 
    set plt [get_variable_value PLT_$model_letter\($dom_ind\)]
    if {$iopl != $lv} {
	# wrong level type.
	if { $lv == 0 } {
	    lappend errors(msgs) "DOMAIN PROF ERROR: system error, seek professional help."
	    set errors(check) 1
	} elseif { $lv == 1 } {
	    lappend errors(msgs) "DOMAIN PROF ERROR: Use profile on model rho-levels."
	    set errors(check) 1
	} elseif { $lv == 2 } {
	    lappend errors(msgs) "DOMAIN PROF ERROR: Use profile on model theta-levels."
	    set errors(check) 1
	} elseif { $lv == 3 } {
	    lappend errors(msgs) "DOMAIN PROF ERROR: Use profile on pressure levels."
	    set errors(check) 1
	} elseif { $lv == 4 } {
	    lappend errors(msgs) "DOMAIN PROF ERROR: Use profile on geometric height levels."
	    set errors(check) 1
	} elseif { $lv == 5 } {
	    lappend errors(msgs) "DOMAIN PROF ERROR: Use profile on single or unspecified levels."
	    set errors(check) 1
	} elseif { $lv == 6 } {
	    lappend errors(msgs) "DOMAIN PROF ERROR: Use profile on deep soil levels."
	    set errors(check) 1
	} elseif { $lv == 7 } {
	    lappend errors(msgs) "DOMAIN PROF ERROR: Use profile on theta levels."
	    set errors(check) 1
	} elseif { $lv == 8 } {
	    lappend errors(msgs) "DOMAIN PROF ERROR: Use profile on potential vorticity levels."
	    set errors(check) 1
	} elseif { $lv == 9 } {
	    lappend errors(msgs) "DOMAIN PROF ERROR: Use profile on cloud threshold levels (octars)."
	    set errors(check) 1
	} elseif { $lv == 10 } {
	    lappend errors(msgs) "DOMAIN PROF ERROR: Use profile on wave direction (levels)."
	    set errors(check) 1
	} else  {
	    lappend errors(msgs) "STASHmaster ERROR: Unrecognised level type $lv."
	    set errors(check) 1
	}
    } else {
	#........................................................................................
	# 5.2 Check bottom and top level if list is chosen.
	if { ( ($iopl==1) || ($iopl==2) || ($iopl==6) ) } {
	    set toplev [levcod $lt $isec $item $dom_ind $model_number]
	    set botlev [levcod $lb $isec $item $dom_ind $model_number]

	    if { $ilevs==2  } {
		# On model-type levels with a list.
		set levlst [get_variable_array LEVLST_$model_letter\(*,$dom_ind\)] 
		foreach level $levlst {
		    if { ( $level < $botlev ) || ( $level > $toplev ) } {
			lappend errors(msgs) "DOMAIN PROF ERROR: Level in list is out of range. $botlev to $toplev allowed"
			set errors(check) 1
		    }
		}
	    } elseif { $ilevs==1 } {
		# On model-type levels with a range.
		set levb [lnConvertInput [get_variable_value LEVB_$model_letter\($dom_ind\)]]
		set levt [lnConvertInput [get_variable_value LEVT_$model_letter\($dom_ind\)]]
		if {[regexp {^[-+]*[0-9]*$} $levb] == 0 || [regexp {^[-+]*[0-9]*$} $levt] == 0} {
		    lappend errors(msgs) "DOMAIN PROF ERROR: Could not evaluate level settings"
		    set errors(check) 1
		} elseif { ( $levb < $botlev ) || ( $levt > $toplev ) } {
		    lappend errors(msgs) "DOMAIN PROF ERROR: Range of levels outside allowed range. $botlev to $toplev allowed"
		    set errors(check) 1
		}
	    } 
	}
    }
    #...............................................................................................
    # 5.3 Check Pseudo Level Type.
    if { $pt != $plt } {
	if { $pt == 0 } {
	    set pl_type "No pseudo levels"
	    lappend errors(msgs) "DOMAIN PROF ERROR: Invalid pseudo level type. This diag is type: $pl_type"
	    set errors(check) 1 
	} elseif { $pt == 1 } {
	    set pl_type "SW radiation bands"
	    lappend errors(msgs) "DOMAIN PROF ERROR: Invalid pseudo level type. This diag is type: $pl_type"
	    set errors(check) 1 
	} elseif { $pt == 2 } {
	    set pl_type "LW radiation bands"
	    lappend errors(msgs) "DOMAIN PROF ERROR: Invalid pseudo level type. This diag is type: $pl_type"
	    set errors(check) 1 
	} elseif { $pt == 3 } {
	    set pl_type "ATMOS assimilation groups"
	    lappend errors(msgs) "DOMAIN PROF ERROR: Invalid pseudo level type. This diag is type: $pl_type"
	    set errors(check) 1 
#	} elseif { $pt == 4 } {
#	    set pl_type "MW surface emissivity frequencies"
#	    lappend errors(msgs) "DOMAIN PROF ERROR: Invalid pseudo level type. This diag is type: $pl_type"
#	    set errors(check) 1 
	} elseif { $pt == 8 } {
	    set pl_type "HadCM2 Suplhate Loading Pattern Index"
	    lappend errors(msgs) "DOMAIN PROF ERROR: Invalid pseudo level type. This diag is type: $pl_type"
	    set errors(check) 1 
	} elseif { $pt == 9 } {
	    set pl_type "Land and Vegetation Surface Types"
	    lappend errors(msgs) "DOMAIN PROF ERROR: Invalid pseudo level type. This diag is type: $pl_type"
	    set errors(check) 1 
	} elseif { $pt == 10 } {
	    set pl_type "Multiple-category sea-ice"
	    lappend errors(msgs) "DOMAIN PROF ERROR: Invalid pseudo level type. This diag is type: $pl_type"
	    set errors(check) 1 
#	} elseif { $pt == 11 } {
#	    set pl_type "Number of land surface tiles multiplied by maximum number of snow layers"
#	    lappend errors(msgs) "DOMAIN PROF ERROR: Invalid pseudo level type. This diag is type: $pl_type"
#	    set errors(check) 1 
        } elseif {$pt == 12} {
	    set pl_type "COSP radar reflectivity intervals"
	    lappend errors(msgs) "DOMAIN PROF ERROR: Invalid pseudo level type. This diag is type: $pl_type"
	    set errors(check) 1 
        } elseif {$pt == 13} {
	    set pl_type "COSP hydrometeors"
	    lappend errors(msgs) "DOMAIN PROF ERROR: Invalid pseudo level type. This diag is type: $pl_type"
	    set errors(check) 1 
        } elseif {$pt == 14} {
	    set pl_type "COSP lidar SR intervals"
	    lappend errors(msgs) "DOMAIN PROF ERROR: Invalid pseudo level type. This diag is type: $pl_type"
	    set errors(check) 1 
        } elseif {$pt == 15} {
	    set pl_type "COSP tau bins"
	    lappend errors(msgs) "DOMAIN PROF ERROR: Invalid pseudo level type. This diag is type: $pl_type"
	    set errors(check) 1 
        } elseif {$pt == 16} {

	    set pl_type "COSP subcolumns"
	    lappend errors(msgs) "DOMAIN PROF ERROR: Invalid pseudo level type. This diag is type: $pl_type"
	    set errors(check) 1   
	} elseif { $pt>=101  } {
	    set pl_type "User type $pt"
	    lappend errors(msgs) "DOMAIN PROF ERROR: Invalid pseudo level type. This diag is type: $pl_type"
	    set errors(check) 1 
	} else {
	    lappend errors(msgs) "STASHmaster ERROR: Unrecognised pseudo-level type $pt."
	    set errors(check) 1    
	}   
    }
    #...............................................................................................
    # 5.4 Check Pseudo Level levels
    if { ($pt != 0) && ($plt != 0) } {
	set pslist [get_variable_array PSLIST_$model_letter\(*,$dom_ind\)]
	set firstlev [psfcod $pf $model_number]
	set lastlev [pslcod $pl $model_number]
	foreach level $pslist {
	    if { ( $level < $firstlev ) || ( $level > $lastlev ) } {
		lappend errors(msgs) "DOMAIN PROF ERROR: Pseudo-Level in list is out of range. $firstlev to $lastlev allowed"
		set errors(check) 1
	    }
	}
    }
    #...............................................................................................
    # 5.5 Checks against grid type code (GR).
    set imsk [get_variable_value IMSK_$model_letter\($dom_ind\)]  
    set imn [get_variable_value IMN_$model_letter\($dom_ind\)]    
    set iwt [get_variable_value IWT_$model_letter\($dom_ind\)] 
    if { ($imsk==2) && ( $gr==3 || $gr==13) } {
	lappend errors(msgs) "DOMAIN PROF ERROR: Requested over land only. Available over sea only"
	set errors(check) 1    
    }    
    if { ($imsk==3) && ( $gr==2 || $gr==12) } {
	lappend errors(msgs) "DOMAIN PROF ERROR: Requested over sea only. Available over land only"
	set errors(check) 1    
    }    
    if { ($imn==2) && ( $gr==4 || $gr==14 || $gr==17 || $gr==45 || $gr==46 || $gr==47 ) } {
	lappend errors(msgs) "DOMAIN PROF ERROR: Requested zonal mean, but there is no dimension to mean"
	set errors(check) 1    
    }    
    if { ($imn==3) && ( $gr==17 || $gr==47 ) } {
	lappend errors(msgs) "DOMAIN PROF ERROR: Requested field mean, but there is no dimension to mean"
	set errors(check) 1    
    }    
    if { ($imn==4) && ( $gr==5 || $gr==15 || $gr==17 || $gr==45 || $gr==46 || $gr==47 ) } {
	lappend errors(msgs) "DOMAIN PROF ERROR: Requested meridional mean, but there is no dimension to mean"
	set errors(check) 1    
    }    
    if { ($iwt==3) && ( $lv!=1 || $model_id!="A" ) } {
	lappend errors(msgs) "DOMAIN PROF ERROR: Mass weighting only works for atmospheric diagnostics on full levels"
	set errors(check) 1    
    }    
    if { ($iwt==1) && ( $gr >= 30 ) } {
	lappend errors(msgs) "DOMAIN PROF ERROR: Area weighting only works for atmospheric grids"
	set errors(check) 1    
    }

    #...............................................................................................
    # 5.6 Checks for DOMAIN Timeseries horizontal range
    set ddomts [get_variable_value DDOMTS_$model_letter\($dom_ind\)]
    if {$ddomts=="Y"} {
	set south [get_variable_array DOMTS_S_$model_letter\(*,$dom_ind\)]
	set east [get_variable_array DOMTS_E_$model_letter\(*,$dom_ind\)]
	set ncol [numb_cols $gr]
	set nrow [numb_rows $gr]
	for {set i 0} {$i<[llength $south]} {incr i} {
	    set var [lindex $south $i]
	    if {$var>$nrow} {
		lappend errors(msgs)  "DOMAIN PROF TIMESERIES ERROR: the value for SOUTH (=$var) in row [ expr $i +1] is out of range(>$nrow)"
		set errors(check) 1
	    }
	}
	for {set i 0} {$i<[llength $east]} {incr i} {
	    set var [lindex $east $i]
	    if {$var>$ncol} {
		lappend errors(msgs)  "DOMAIN PROF TIMESERIES ERROR: the value for EAST (=$var) in row [ expr $i +1] is out of range (>$ncol)"
		set errors(check) 1
	    }
	}
    }
    } ; # End of loop for available items
}



proc levcod {lev_code isec item dom model_number} {

    set model_letter [modnumber_to_letter $model_number ] ; # A,O,S,W]

    if { $lev_code == 1 } {
	return 1
    } elseif { $lev_code == 2 } {
	get_variable_value NLEVSA
    } elseif { $lev_code == 3 } {
	get_variable_value NWLEVA
    } elseif { $lev_code == 4 } {
	expr [get_variable_value NLEVSA] - 1
    } elseif { $lev_code == 5 } {
	return 1     
    } elseif { $lev_code == 6 } {
	get_variable_value NBLLV 
    } elseif { $lev_code == 7 } {
	expr [get_variable_value NBLLV] + 1
    } elseif { $lev_code == 8 } {
	return 1      
    } elseif { $lev_code == 9 } {
	get_variable_value NDSLV 
    } elseif { $lev_code == 10 } {
        if { [ get_variable_value USE_TCA ] == "Y" } {
	  expr [ get_variable_value NLEVSA ] - [ get_variable_value NTRLA ] + 1
        } else {
          return 0
        }
    } elseif { $lev_code == 11 } {
	get_variable_value NLEVSA
    } elseif { $lev_code == 12 } {
	expr [ get_variable_value NLEVSA ] + 1
    } elseif { $lev_code == 13 } {
    # 	get_variable_value SLEVGW
       return 1 
    } elseif { $lev_code == 14 } {
	get_variable_value NLEVSA
    } elseif { $lev_code == 15 } {
	get_variable_value VDIFB 
    } elseif { $lev_code == 16 } {
	expr [ get_variable_value VDIFT ] - 1
    } elseif { $lev_code == 17 } {
	get_variable_value VDIFT 
    } elseif { $lev_code == 18 } {
	expr [ get_variable_value NBLLV ] - 1
    } elseif { $lev_code == 19 } {
	expr [ get_variable_value NLEVSA ] + 1
    } elseif { $lev_code == 20 } {
	return 2
    } elseif { $lev_code == 21 } {
	return 1
    } elseif { $lev_code == 23 } {
	get_variable_value NOZLEV
    } elseif { $lev_code == 30 } {
	return 2
    } elseif { $lev_code == 34 } {
        return [ set_hydr_levels ]
    } elseif { $lev_code == 35 } {
	get_variable_value CLRAD 
    } elseif { $lev_code == 36 } {
	return 1 
    } elseif { $lev_code == 38 } {
	return 0
    } elseif {$lev_code == 40} {
        set l_endgame [get_variable_value L_ENDGAME]
        if {$l_endgame=="T"} {
             return 0
        } else {
             return 1
        }
    } elseif { $lev_code >= 100 } {
        set index [ expr $lev_code - ( 100 * $model_number ) ]
        if { $index > 3 } {
           error "Invalid user level code for this submodel found. Code is <$lev_code>; while checking diagnostic Section $isec Item $item, domain profile $dom"
        }
        set retv [ get_variable_value ULEV_$model_letter\($index\) ]
        if { ( [ get_variable_value USERCODES_$model_letter ] != "Y" ) || \
             ( [ get_variable_value USERPRE_$model_letter ] != "Y" ) } {
            error "You are using an extended bottom/top-level-code of\
                  $code without defining it; while checking diagnostic Section $isec Item $item, domain profile $dom"
        }
        if { $retv == 0 } {
            error "Bottom/top-level-code $code is zero. Check user\
                   code definitions as zero means unset; while checking diagnostic Section $isec Item $item, domain profile $dom"
        }
        return $retv
    } else {
	error "Error in levcod. Unknown level code: $lev_code while checking diagnostic Section $isec Item $item, domain profile $dom"
    } 
}


proc psfcod {code model_number} {
    set model_letter [modnumber_to_letter $model_number ] ; # A,O,S,W]

    if { $code == 1 } {
	return 1
    } elseif { $code==21 || $code==22 || $code==23 || $code==24 || $code==25 || $code==29 } {
	set block [ expr $code % 20 ] 
	set aobind [get_variable_array AOBIND]
	set aobinc [get_variable_array AOBINC]
	set aobgrp [get_variable_array AOBGRP]
	set len [ llength AOBIND ]
	set retval 0
	for { set i 0 } { $i < $len } { incr i } {
	    set thisind  [lindex $aobind $i]
	    set thisinc  [lindex $aobinc $i]
	    set thisgrp  [lindex $aobgrp $i]
	    set thisblock [expr ( $thisind - ($thisind % 100) ) / 100 ]
	    if { ($thisblock == $block) && ($thisinc == "Y") } {
		if { $thisgrp < $retval } { set retval $thisgrp } 
	    }
	}
	return $retval
    } elseif { $code >= 100 } {
        set index [ expr $code - ( 100 * $model_number ) ]
        if { $index > 3 } {
           error "Invalid user level code for this submodel found. Code is <$lev_code>."
        }
        set retv [ get_variable_value UPSF_$model_letter\($index\) ]
        if { ( [ get_variable_value USERCODES_$model_letter ] != "Y" ) || \
             ( [ get_variable_value USERPRE_$model_letter ] != "Y" ) } {
            error "You are using an extended first-pseudo-level code of\
                  $code without defining it. "
        }
        if { $retv == 0 } {
            error "First-pseudo-level-code $code is zero. Check user\
                   code definitions as zero means unset."
        }
        return $retv
    } else {
	error "Error in psfcod. Unknown first-pseudo-level code: $code "
	return 9999
    } 
}


proc pslcod {code model_number} {
    set model_letter [modnumber_to_letter $model_number ] ; # A]

    if { $code == 1 } {
	get_variable_value SWBND
    } elseif { $code == 2 } {
	get_variable_value LWBND
    } elseif { $code == 5 } {
	return 3
    } elseif { $code == 6 } {
	return 2
    } elseif { $code == 7 } {
	return 9
    } elseif { $code == 8 } {
	return 5
    } elseif { $code == 9 } {
	set aggregate [get_variable_value JL_AGGREGATE]
        if {$aggregate == "Y"} {
            return 1
        } else {
            return 9
        } 
    } elseif { $code == 10 } {
        return [get_variable_value NCICECAT]
    } elseif { $code==12 || $code==14 } {
        return 15
    } elseif { $code==13 } {
        return 9
    } elseif { $code==15 } {
        return 7
    } elseif { $code==16 } {
        return 200
    } elseif { $code==21 || $code==22 || $code==23 || $code==24 || $code==25|| $code==29 } {
	set block [ expr $code % 20 ] 
	set aobind [get_variable_array AOBIND]
	set aobinc [get_variable_array AOBINC]
	set aobgrp [get_variable_array AOBGRP]
	set len [ llength AOBIND ]
	set retval 99
	for { set i 0 } { $i < $len } { incr i } {
	    set thisind  [lindex $aobind $i]
	    set thisinc  [lindex $aobinc $i]
	    set thisgrp  [lindex $aobgrp $i]
	    set thisblock [expr ( $thisind - ($thisind % 100) ) / 100 ]
	    if { ($thisblock == $block) && ($thisinc == "Y") } {
		if { $thisgrp > $retval } { set retval $thisgrp } 
	    }
	}
	return $retval
    } elseif { $code >= 100 } {
        set index [ expr $code - ( 100 * $model_number ) ]
        if { $index > 3 } {
           error "Invalid user level code for this submodel found. Code is <$lev_code>."
        }
        set retv [ get_variable_value UPSL_$model_letter\($index\) ]
        if { ( [ get_variable_value USERCODES_$model_letter ] != "Y" ) || \
             ( [ get_variable_value USERPRE_$model_letter ] != "Y" ) } {
            error "You are using an extended last-pseudo-level code of\
                  $code without defining it. "
        }
        if { $retv == 0 } {
            error "Last-pseudo-level-code $code is zero. Check user\
                   code definitions as zero means unset."
        }
        return $retv
    } else {
	error "Error in pslcod. Unknown last-pseudo-level code: $code "
	return -9999
    } 
}

proc print_errors {w} {

    #+
    # NAME: write_errors
    # SYNOPSIS: write any errors generated when checking stash diagnostics
    # ARGS: None
    # TREE: experiment_instance navigation create_window stash verify_diags write_errors
    # GLOBAL VARIABLES:
    #  errors -- errors array
    # AUTHOR: AJB
    #-

    global errors font_butons contflag


    set title "Diagnostic Errors"

    addTextToWindow $w "\nDiag: \"$errors(txt)\" ($errors(isec),$errors(item)) ($errors(tim),$errors(dom),$errors(use))" $title
    
    # loop over errors
    # print diagnostics with missing profiles to the dialog box
    
    for {set i 0 } {$i < [llength $errors(msgs)] } { incr i} {
	addTextToWindow $w "\n  [lindex $errors(msgs) $i]"
    }
}

proc numb_cols { code } {
    # Provide maximum column dimension given a GR code from STASHmaster file.
    # Field size is 1 to $code columns.
    if { $code==1  || $code==2  || $code==3  || $code==5  || $code==18 || \
	    $code==11 || $code==12 || $code==13 || $code==15 || $code==19 || \
	    $code==45 || $code==46 } {
	set ocaaa [ get_variable_value OCAAA ]
	if { $ocaaa == 1 } {
	    return [ get_variable_value NCOLSAG ]
	} elseif { $ocaaa == 2 } { 
	    return [ get_variable_value NCOLSAL ]
	} elseif { $ocaaa == 3 || $ocaaa == 4 } { 
	    return 1
	}
    } elseif { $code == 4 || $code == 14  || $code == 17 } {
	return 1
    } elseif { $code == 22 } {
	if { [ get_variable_value EXPOZ ] == "Y" } {
	    return 1
	} else {
	    return [ get_variable_value NCOLSAG ]
	}
    } elseif {$code==43 || $code==44 || $code==47 } { 
	return 1
    } else {
	error "Unknown grid code in numb_cols : code=\"$code\""
    }
}


proc numb_rows { code } {
    # Provide maximum row dimension given a GR code from STASHmaster file.
    # Field size is 1 to $code rows.
    if { $code==1 || $code==2 || $code==3 || $code==4 || $code==18 || \
	    $code==22} {
	set ocaaa [ get_variable_value OCAAA ]
	if { $ocaaa == 1 } {
	    return [ get_variable_value NROWSAG ]
	} elseif { $ocaaa == 2 } { 
	    return [ get_variable_value NROWSAL ]
	} elseif { $ocaaa == 3 || $ocaaa == 4 } { 
	    return 1
	}
    } elseif { $code == 5 || $code == 15  || $code == 17 } {
	return 1
    } elseif {$code==11 || $code==12 || $code==13 || $code==14 || $code==19} {
	set ocaaa [ get_variable_value OCAAA ]
	if { $ocaaa == 1 } {
	    return [ expr [ get_variable_value NROWSAG ] -1 ]
	} elseif { $ocaaa == 2 } { 
	    return [ expr [ get_variable_value NROWSAL ] -1 ]
	} elseif { $ocaaa == 3 || $ocaaa == 4 } { 
	    return 1
	}
    } elseif {$code==45 || $code==46 || $code==46} {   
	return 1
    } else {
	error "Unknown grid code in numb_rows : code= \"$code\""
    }
}


