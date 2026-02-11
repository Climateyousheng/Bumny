# Check active status of DOMTS_*_$isubm	
# $variable = for example DOMTS_N_A(*,PROFILE)	
proc active_domts {variable call_type index} {
    # Will be called with call_type="PRELIM" only
    # Return 1 if variable inactive
    #        0 if active

    if {$index==""} {
	# Called from nav_full_verify
	# will not have index
	return 2
    }
    # Get the model letter id from the variable name
    set modelLetter [string index [lindex [split $variable "_"] 2] 0]

    # index is a profile number or PROFILE if called from window
    # get_value procedure deals with these situations
    set profile [get_value $index]

    # Do we want Timeseries for this DOMAIN profile return 1:inactive if not
    set dts [get_variable_value DDOMTS_$modelLetter\($profile\)]
    set proname [get_variable_value DOMPRO_$modelLetter\($profile\)]
    if {$proname==""} {return 1}
    if {$dts != "Y"} {return 1}

    set tType [get_variable_value TDOMTS_$modelLetter\($profile\)]

    set vType [lindex [split $variable "_"] 0] ; # DOMTS or DOMTSR
    if {($tType == 1 && $vType == "DOMTSR") || ($tType == 2 && $vType == "DOMTS")} {
	return 1
    }

    set ident [lindex [split $variable "_"] 1] ; # N S NS E W EW LL LF RL or RF
    
    #puts "PROFILE is $profile"
    #puts "$variable = $value, "

    # Now find out which dimensions are inactive.
    # This depends on which levels the variable is on (single or multiple)
    # and whether the variable is already meaned in a particular dimension
    set iopl [get_variable_value IOPL_$modelLetter\($profile\)] ; # Vert Lev Type
    set imn [get_variable_value IMN_$modelLetter\($profile\)]  ; # Meaning option
    
    set blanks {}
    
    if { $imn==1 || $iopl==5 || $iopl==10} {
	# a vertical mean or single level:
	lappend blanks "LF" "LL" "RF" "RL"
    } else {
	# not a vertical mean:
	if { $iopl!=1 && $iopl!=2 && $iopl!=6  } { 
	    # not integer levs
	    lappend blanks "LF" "LL"
	} elseif  { $iopl!=3 && $iopl!=4 && $iopl!=7 && $iopl!=8 && $iopl!=9} { 
	    # not real levs
	    lappend blanks "RF" "RL"
	}
    } 
    
    if {$imn==2 || $imn==4} {
	# zonal or horizontal mean
	lappend blanks "E" "W" "EW"
    } 

    if {$imn==3 || $imn==4} {
	# meridional or horizontal mean
	lappend blanks "N" "S" "NS"
    } 

    if {[lsearch $blanks $ident]==-1} {
	# Column is active - no blanks
	return 0
    } else {
	# Column is inactive
	return 1
    }
}


