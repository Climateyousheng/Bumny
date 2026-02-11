# Procedure `verify profs' general procedure which calls verification 
# functions for some of the variables concerned with the Time and Domain
# profile settings. 
# If flag is 1, implies called after window closed and does a straightforward 
# call to the function associated with $var. ie calls only one function
# If flag is 0, implies called during full verification procedure. Loops 
# through all possible values of PROFILE, 1-48. Since this routine is being
# called for both Time and Domain profile variables, before function called
# checks TIMPRO_* or DOMPRO_* to determine whether a profile has been saved
# for this location.

# Variable name $var should be in the form $PREFIX_*$SUBMODEL. The * is
# any string that ends in a _ , eg *="N_" in DOMTS_N_A. The function
# which is called usually depends on the prefix eg ISAM_A 
# are checked by the same function. However for some of the domain profile
# variables, ocean functions differ from those for atmosphere and slab,
# so the suffix, $SUBMODEL=A,O or S, is considered.


proc verify_profs {val var index} {

    global verify_flag
    global fv_name_of_window fv_variable_name fv_value fv_index
    set splitvar [split $var "_"]
    set prefix [lindex $splitvar 0 ]
    set isubm [lindex $splitvar [expr [llength $splitvar]-1]]
    set isubm [lindex [split $isubm "("] 0 ]
    if {[regexp {\*} $var]} {
	set profile [lindex [split $var (,)] 2]
    } else {
	set profile [lindex [split $var ()] 1]
    }

    if {$verify_flag} {
	# Called after closing window panel

	# The following are common to all submodels
	if {($prefix=="TIMPRO")||($prefix=="DOMPRO") || ($prefix=="USEPRO")} {
	    return [chk_prof_nm $val $var $profile $isubm ]
	} elseif {$prefix == "ISAM" } {
	    return [isama  $val $var $profile $isubm]
	} elseif {$prefix == "IOFF" } {
	    return [ioffa  $val $var $profile $isubm]
	} elseif {$prefix == "IOPT" } {
	    return [iopt  $val $var $profile $isubm ]
	} elseif {$prefix == "IFRE" } {
	    return [ifre  $val $var $profile $isubm]
	} elseif {$prefix == "ISTR" } {
	    return [istr  $val $var $profile $isubm]
	} elseif {($prefix == "GNTH")||($prefix == "GSTH")||   \
	  ($prefix == "GEST")||($prefix == "GWST") } {  
	    return [x_area_gp $val $var $profile $isubm]
	} elseif {$prefix == "UNT3" } {
	    return [ tunt3a  $val $var $profile $isubm]
	} elseif {$prefix == "DOMTS" || $prefix == "DOMTSR"} {
	    return [domts  $val $var $index $isubm $profile]
	} elseif {($prefix == "LEVB")||($prefix == "LEVT") } {  
	    return [xlevels $val $var $profile $isubm]
	} elseif {$prefix == "LEVLST" } {
	    return [xilevlist  $val $var $index $isubm $profile]
	} elseif {$prefix == "PSLIST" } {
            return [xpslist  $val $var $index $isubm $profile]
	} elseif {($prefix == "RLEVLST")||($prefix == "PLEVLST") } {  
	    return [xrlevlist $val $var $index $isubm $profile]
	} else {
	    error_message .d {UMUI bug} "No function for verifying $var. Please report" warning 0 {OK}
	    return 1
	}
    } else {
	# Called for full sweep verification

	# These variables will be output if there is an error
	
	# Is it one of the Time profile variables ?
	if {($prefix=="IOFF")||($prefix=="ISAM") \
		||($prefix=="IFRE")||($prefix=="ISTR") \
		||($prefix=="UNT3")||($prefix=="IOPT")} {

	    # These functions check 1D variables which depend 
	    # only on index (set to profile number) and submodel
	    
	    # Check IOFF_$isubm
	    if {$prefix=="IOFF"} {
		ioffa 0 0 $index $isubm
	    }
	    # Check ISAMA_$isubm
	    if {$prefix=="ISAM"} {
		isama 0 0 $index $isubm
	    }
	    # Check IFRE_$isubm
	    if {$prefix=="IFRE"} {
		ifre 0 0 $index $isubm
	    }
	    # Check ISTR_$isubm
	    if {$prefix=="ISTR"} {
		istr 0 0 $index $isubm
	    }
	    # Check IOPT_$isubm
	    if {$prefix=="IOPT"} {
		iopt 0 0 $index $isubm
	    }
	    # Check UNT3_$isubm
	    if {$prefix=="UNT3"} {
		tunt3a 0 0 $index $isubm
	    }
	    
	    
	} elseif {($prefix=="LEVB")||($prefix=="LEVT")} {
	    # Note prefix LEVB also checks LEVT
	    xlevels 0 $var $index $isubm
	} elseif {($prefix=="GNTH")||($prefix=="GSTH") \
		||($prefix=="GEST")||($prefix=="GWST")} {
	    # Check GNTH_ GSTH_ GWST_ and GEST_$isubm
	    x_area_gp 0 $var $index $isubm
	} elseif {[regexp {\*} $var]} {
	    # An asterisk implies a 2D array - 
	    # for these, the function is called once for each index of each PROFILE
	    # Usually, the procedures check all elements on the first call with
	    # index of 0 and return immediately for higher index values

	    if {$prefix=="DOMTS" || $prefix=="DOMTSR"} {
		domts $val $var $index $isubm $profile
	    } elseif {$prefix=="RLEVLST" || $prefix=="PLEVLST"} {
		xrlevlist 0 $var $index $isubm $profile
	    } elseif {$prefix=="PSLIST"} {
		xpslist 0 0 $index $isubm $profile
	    } elseif {$prefix=="LEVLST"} {
		xilevlist 0 0 $index $isubm $profile
	    } else {
		error_message .d {UMUI bug} \
			"No function for verifying $var. Please report" \
			warning 0 {OK}
		return 1
	    }

	} else {
	    error_message .d {UMUI bug} \
		    "No function for verifying $var. Please report" \
		    warning 0 {OK}
	    return 1
	}
    }
    return 0
}

# Verification of ISAM_$isubm		
proc isama {value variable profile isubm} {
    set ityp    [get_variable_value ITYP_$isubm\($profile\)]
    if {$ityp!=1 } { 
	set intv    [get_variable_value INTV_$isubm\($profile\)]
	set isam    [get_variable_value ISAM_$isubm\($profile\)]
	if {( ( $isam < 1 ) || ( $isam > 99999 ) ) } {
	    error_message .d {Range} "'Sampling' should be between 1 and 999999" warning 0 {OK}
	    return 1
	}  
	if { $intv=="" } {
	    # This check must be made because blank value will cause crash
	    error_message .d {Blank value} "Period should not be blank" warning 0 {OK}
	    return 1
	}
	if { $intv!=-1 } {
	    set unt1    [get_variable_value UNT1_$isubm\($profile\)]
	    set unt2    [get_variable_value UNT2_$isubm\($profile\)]
	    if { ($unt1=="")||($unt2=="") } {
		# This check must be made because blank value will cause crash
		error_message .d {Blank value} "Time units should not be blank" warning 0 {OK}
	    return 1
	    }
	    set intvt   [ totimep $intv $unt1 "$isubm" ]
	    set isamt   [ totimep $isam $unt2 "$isubm" ]
	    if { $isamt >= $intvt } { 
		error_message .d {Inconsistent} "The sampling period must be less than the Interval/Processing-Period. ($isamt,$intvt)" warning 0 {OK}
		return 1
	    }
	    if { [ expr $intvt % $isamt ] != 0 } { 
		error_message .d {Inconsistent} "Interval/Processing-Period is not a multiple of sampling period. ($intvt,$isamt)" warning 0 {OK}
		return 1
	    }
	}
        if { ($ityp==8 )&& ($unt2!="DA") } {
		error_message .d {Invalid} "For day-mean time-series, sampling period must be in days." warning 0 {OK}
		return 1
        }
    } 
    return 0
}

# Verification of IOFF_$subm
proc ioffa {value variable profile isubm} {
    set ityp    [get_variable_value ITYP_$isubm\($profile\)]
    if {$ityp!=1} { 
	set intv    [get_variable_value INTV_$isubm\($profile\)]
	set ioff    [get_variable_value IOFF_$isubm\($profile\)]
	set isam    [get_variable_value ISAM_$isubm\($profile\)]
	
	if { $isam != "" } {
	    if {$ioff < 0} {
		error_message .d {Range} "'Offset' should be 0 or above" warning 0 {OK}
		return 1
	    } elseif {$ioff > $isam} {
		error_message .d {Range} \
			"'Offset' should be less than or equal to the sampling frequency $isam" warning 0 {OK}
		return 1
	    }  
	}

        if { ($ityp==8) && ($ioff != 0) } {
		error_message .d {Invalid} "For day-mean time-series, offset must be zero." warning 0 {OK}
		return 1
        } 
    } 
    return 0
}

# Verification of ISTR_$isubm
proc istr {value variable profile isubm} {
    set intv    [get_variable_value INTV_$isubm\($profile\)]
    set ityp    [get_variable_value ITYP_$isubm\($profile\)]
    set iopt    [get_variable_value IOPT_$isubm\($profile\)]
    set istr    [get_variable_value ISTR_$isubm\($profile\)]
    if { ($iopt==1) && (( $istr < 0 )||( $istr > 99999 ))} {
	error_message .d {Range} "Starting should be between 1 and 99999" warning 0 {OK}
	return 1
    }
    return 0
}

# Verification of IFRE_$isubm		
proc ifre {value variable profile isubm} {
    set intv    [get_variable_value INTV_$isubm\($profile\)]
    set ityp    [get_variable_value ITYP_$isubm\($profile\)]
    set iopt    [get_variable_value IOPT_$isubm\($profile\)]
    set ifre    [get_variable_value IFRE_$isubm\($profile\)]
    if { ($iopt==1) && (( $ifre < 1 )||( $ifre > 99999 ))} {
	error_message .d {Range} "Frequency should be between 1 and 99999" warning 0 {OK}
	return 1
    }  
    if { ($ityp!=1) && (( $intv < -1 )||( $intv > 99999 )||( $intv == 0 ))} {
	error_message .d {Range} "Interval should be -1 or between 1 and 99999" warning 0 {OK}
	return 1
    }  
    if { $ityp!=1 && $intv!=-1 } {
	set unt3    [get_variable_value UNT3_$isubm\($profile\)]
	set ifret   [ totimep $ifre $unt3 "$isubm" ]
	set unt1    [get_variable_value UNT1_$isubm\($profile\)]
	set intvt   [ totimep $intv $unt1 "$isubm" ]
	if { [ expr $ifret % $intvt ] != 0 } { 
	    error_message .d {Inconsistent} "Output frequency is not a multiple of interval/processing period. ($ifret,$intvt)" warning 0 {OK}
	    return 1
	}
    } 
    return 0
}

# Verification of IOPT_$isubm		
proc iopt {value variable profile isubm } {
    set ityp    [get_variable_value ITYP_$isubm\($profile\)]
    set iopt    [get_variable_value IOPT_$isubm\($profile\)]
    set intv    [get_variable_value INTV_$isubm\($profile\)]
    if { ($iopt!=1) && ($iopt!=2) && ($iopt!=3) } {
	error_message .d {Blank not allowed} "'Specification type' has not been set to any of the options." warning 0 {OK}
	return 1
    }  
    if { (($ityp!=1) && ($ityp!=2) && ($iopt==2))|| (($ityp==2) && ($iopt==2) && ($intv!=-1))} {
	error_message .d {Inconsistent} "'Specification type' can be set to 'specified list' only if 'No time processing' is selected or accumulations over indefinite period is selected." warning 0 {OK}
	return 1
    }  
    if { ($ityp!=1) && ($ityp!=2) && ($ityp!=3) && ($iopt==3) } {
	error_message .d {Inconsistent} "'Specification type' can be set to 'Regular intervals Start/stop date' only if 'No time processing', 'Time accumulations' or 'Time mean' is selected." warning 0 {OK}
	return 1
    }
    return 0
}

# domts
#  Verification of DOMTS_*_$isubm: for example DOMTS_N_A(*,PROFILE)
#  Check levels in range
proc domts {value variable index isubm profile} {

    # Do we want Timeseries for this DOMAIN profile
    set dts [get_variable_value DDOMTS_$isubm\($profile\)]
    if {$dts != "Y"} {return 0}

    # Function checks whole list at once so only run if called with
    # first index
    if {$index!=1} {return 0}

    # Number of rows in table
    set nRows [get_variable_value NDOMTS_$isubm\($profile\)]

    # Name of column in table for error dialog boxes
    set varinfo [get_variable_info $variable]
    set columnName [lindex $varinfo 10]

    # Which particular DOMTS variable being checked
    set ident [lindex [split $variable "_"] 1] ; # N S E W LL LF RL or RF
    
    #puts "$variable = $value, size=$index "

    set iopl [get_variable_value IOPL_$isubm\($profile\)] ; # Vert Lev Type
    set imn [get_variable_value IMN_$isubm\($profile\)]  ; # Meaning option
    
    # Loop over variable values
    for {set i 0} {$i < $nRows } {incr i} {

	set var [lindex $value $i]

	if { $ident=="LL" || $ident=="LF" || $ident=="RL" || $ident=="RF"} {
	    # Check that the level information is valid for choices given
	    # elsewhere in STASH DOMAIN.
	    set levvar "X" ; # ie default is levels not a list, is a range
	    if {($iopl==1)||($iopl==2)||($iopl==6)} {
		# Model rho, theta or deep soil levels
		if {[get_variable_value ILEVS_$isubm\($profile\)]!=1} {
		    set levvar LEVLST_$isubm\(*,$profile\)
                }
	    } elseif {($iopl==4)||($iopl==7)||($iopl==8)||($iopl==9)} {
		# List of real model levels
                set levvar RLEVLST_$isubm\(*,$profile\)
	    } elseif {($iopl==3)} {
		# List of real model pressure levels
		set levvar PLEVLST_$isubm\(*,$profile\)
	    }
	    if {$levvar != "X"} {
                # list. is level in list. 
                set list [get_variable_array $levvar] 
                if { [lsearch $list $var] == -1 } {
		    # element not in list.
		    error_message .err "Not in List." \
			    "Column $columnName: Element <$var> is not in levels list <$list>." \
			    {} 0 {OK}
		    return 1
                }  
	    } else {
		set levb [lnConvertInput [get_variable_value LEVB_$isubm\($profile\)]]
		set levt [lnConvertInput [get_variable_value LEVT_$isubm\($profile\)]]
		if {[regexp {^[-+]*[0-9]*$} $levb] == 0} {
		    error_message .err "Level Range" \
			    "Could not evaluate sum [get_variable_value LEVB_$isubm\($profile\)].\
			    Check first domain profile panel" {} 0 {OK}
		    return 1
		}
		if {[regexp {^[-+]*[0-9]*$} $levt] == 0} {
		    error_message .err "Level Range" \
			    "Could not evaluate sum [get_variable_value LEVT_$isubm\($profile\)].\
			    Check first domain profile panel" {} 0 {OK}
		    return 1
		}
	        if {($var<$levb)||($var>$levt)} {
		    error_message .err "Level Range." \
			    "Column $columnName: The level value <$var> on row [expr $i +1] is out of range. \
			    It should be between $levb to $levt" {} 0 {OK}
		    return 1
	        }
	    }
	}
    }
    return 0
}

# Verification of PSLIST_$isubm		
proc xpslist {value variable index isubm profile} {

    if {$index!=1} {return 0}
    set plt  [get_variable_value PLT_$isubm\($profile\)]
    set plist [get_variable_array PSLIST_$isubm\(*,$profile\)]
 
    if { $plt == 0 } { return 0 }

    if {  [ lindex $plist 0 ] == {}  } {
        error_message .d {Level list invalid} "Set at least one value in table" error 0 {OK}
    }

    if { $plt == 1 } {
	set maxv [get_variable_value SWBND]
    } elseif { $plt == 2 } {
	set maxv [get_variable_value LWBND]
    } elseif { $plt == 3 } {
        set gplst [get_variable_array AOBGRP]
        set gpmax 0
        foreach group $gplst {
            if { ( $group != {} ) && ( $group > $gpmax ) } { set gpmax $group }
        }
	set maxv $gpmax
    } elseif { $plt == 4 } {
	set maxv 5
    } elseif { $plt == 8 } {
	set maxv 2
    } elseif { $plt == 9 } {
	set maxv 9     ; # This is for Land and Vegetation types.
    } elseif { $plt == 10 } {
	set maxv [get_variable_value NCICECAT]
    } elseif {$plt == 12 || $plt == 14} {
	set maxv 15
    } elseif {$plt == 13} {
	set maxv 9
    } elseif {$plt == 15} {
	set maxv 7
    } elseif {$plt == 16} {
	set maxv 200  
    } elseif { $plt > 100 }  {
        # This is a user code so do not check
	set maxv 100
    } else  {
         error "Unknown pseudo level code of $plt in xpslist "
    }

    # remember      if { $plt == 0 } { return 0 }
    foreach pl $plist {
        if { $pl!={} && $pl!= -1 } {
	    if { ($pl < 1)  || ($pl > $maxv) } {
	        error_message .d {Level list invalid} "$pl: All values in the levels list must satisfy : 1 <= `pseudo lev' <= $maxv" error 0 {OK}
		return 1
	    }
        }
    }

    return 0

}

# Verification of LEVLST_$isubm
proc xilevlist {value variable index isubm profile} {
    if {$index!=1} {return 0}
    set iopl  [get_variable_value IOPL_$isubm\($profile\)]
    set levlist [get_variable_array LEVLST_$isubm\(*,$profile\)]
    set ilevsa  [get_variable_value ILEVS_$isubm\($profile\)]

    if {$ilevsa == 2 && ( $iopl == 1 || $iopl == 2 || $iopl == 6 ) } {
        set max_lev [max_ilev $iopl $isubm]
        set min_lev [min_ilev $iopl $isubm]
    } else {
         return 0 
    }

    # remember        if { $ilevsa != 2 } { return 0 }
    foreach lev $levlist {
        if { $lev!={} && $lev!= -1 } {
	    if { ($lev < $min_lev)  || ($lev > $max_lev) } {
	        error_message .d {Level list invalid} "$lev: All values in the list of levels must satisfy : $min_lev <= `Level' <= $max_lev" warning 0 {OK}
	        return 1
	    }
	}
    }
    
    return 0
}



# returns minimum level for that model/level type
proc min_ilev { iopl isubm } {
    if { $iopl == 2 && $isubm == "A" } {
      return 0
    } else {
      return 1
    }
}


# returns maximum level for that model/level type
proc max_ilev { iopl isubm } {
    if { $iopl == 1 } {
        if { $isubm == "A" } {
	    # Variables derived on model rho levels (Charney-Philips grid)
            return [expr 1 + [get_variable_value NLEVSA]]
        } else {
            error "Unexpected model $isubm in max_ilev, iopl=1. Report"
        }
    } elseif { $iopl == 2 } {
        if { $isubm == "A" } {
            return  [expr [get_variable_value NLEVSA] +1 ] 
        } else {
            error "Unexpected model $isubm in max_ilev, iopl=2. Report"
        }
    } elseif { $iopl == 6 } {
        if { $isubm == "A" } { 
            return [get_variable_value NDSLV]
        } else {
            error "Unexpected model $isubm in max_ilev, iopl=6. Report"
        }
    } else {
         error "Unexpected call to max_ilev.  iopl=$iopl. Report"
         return 0 
    }
}

# Verification of RLEVLST_$isubm and PLEVLST_$isubm
proc xrlevlist {value variable index isubm profile} {

    if {$index!=1} {return 0}
    set levlist [get_variable_array $variable]
    set iopl  [get_variable_value IOPL_$isubm\($profile\)]
    if {$iopl==3} {
        set min 0.001
        set max 1100.0
    } elseif {$iopl==4} {
        set min 0.0
        set max 99999.0
    } elseif {$iopl==7} {
        set min 100.0
        set max 10000.0
    } elseif {$iopl==8} {
        set min 0.001
        set max 100.0
    } elseif {$iopl==9} {
        set min 0.0
        set max 8.0
    } else {
        return 0
    }
    foreach lev $levlist {
        if { $lev != {} &&  $lev != -1 } {
	    if { ($lev< $min) || ($lev>$max) } {
	        error_message .d {Level list invalid} "$lev:All values in the level list should satisfy :- $min <= `Level' <= $max" warning 0 {OK}
		return 1
	    }
	}
    }
    return 0
}

# Verification of GNTH_, GSTH_, GWST_, and GEST_$isubm
proc x_area_gp {value variable profile isubm} {
    set prefix [lindex [split $variable "_"] 0]
    if {$prefix != "GNTH"} {
	# All 4 variables GNTH_, GSTH_, GWST_, and GEST are
	# checked with one call, so return immediately
	return 0
    }

    set iopa    [get_variable_value IOPA_$isubm\($profile\)]
    if { $iopa != 10 } { return 0 }


    if { $isubm == "A" } {
        set ocaaa    [get_variable_value OCAAA]
        if { $ocaaa == 1} {
  	    set ncols    [get_variable_value NCOLSAG]
	    set nrows    [get_variable_value NROWSAG]
        } elseif { $ocaaa == 2} {
	    set ncols    [get_variable_value NCOLSAL]
	    set nrows    [get_variable_value NROWSAL]
        } elseif { $ocaaa == 3 || $ocaaa == 4} {
	    set ncols 1   
	    set nrows 1
        }
    } else {
       error "Unexpected model $isubm in x_area_gp. Report problem."
    }
    set gnth    [get_variable_value GNTH_$isubm\($profile\)]
    set gsth    [get_variable_value GSTH_$isubm\($profile\)]
    set gest    [get_variable_value GEST_$isubm\($profile\)]
    set gwst    [get_variable_value GWST_$isubm\($profile\)]
    #-------
    if { $isubm != "A" && $isubm != "W" && $isubm != "O"  } {
      # check as normal
      if { ($gnth < 1) || ($gnth > $gsth) || ( $gsth > $nrows ) } {
          error_message .d {Range incorrect} "The area is not correct. Row limits are 1 and\
	    $nrows" error 0 {OK}
	  return 1
      }
    } else {
      # For atmosphere,ocean and wave, gnth must be greater than gsth:
      if { ($gsth < 1) || ($gnth < $gsth) || ( $gnth > $nrows ) } {
          error_message .d {Range incorrect} "The area is not correct. Row limits are 1 and\
	    $nrows" error 0 {OK}
	  return 1
      }
    } 
    #-------
    if { ($gwst < 1) || ($gwst > $ncols) || ( $gest < 1 ) || ( $gest > $ncols ) } {
	error_message .d {Range incorrect} "The area is not correct. Column limits are 1 and\
          $ncols" error 0 {OK}
	return 1
    }

    return 0
}


# Verification of LEVB_$isubm LEVT_$isubm 
proc xlevels {value variable profile isubm} {
    set prefix [lindex [split $variable "_"] 0]
    if {$prefix != "LEVB"} {
	# Variables LEVB and LEVT are checked with one call, 
	# so return immediately if not LEVB
	return 0
    }
    set ilevs   [get_variable_value ILEVS_$isubm\($profile\)]
    if {$ilevs != 1} { return 0 }
    set iopl    [get_variable_value IOPL_$isubm\($profile\)]
    set levb [lnConvertInput [get_variable_value LEVB_$isubm\($profile\)]]
    set levt [lnConvertInput [get_variable_value LEVT_$isubm\($profile\)]]
    if {[regexp {^[-+]*[0-9]*$} $levb] == 0} {
	error_message .err "Level Range" \
		"Could not evaluate sum [get_variable_value LEVB_$isubm\($profile\)].\
		Check identity names and level settings" warning 0 {OK}
	return 1

    }
    if {[regexp {^[-+]*[0-9]*$} $levt] == 0} {
	error_message .err "Level Range" \
		"Could not evaluate sum [get_variable_value LEVT_$isubm\($profile\)].\
		Check identity names and level settings" warning 0 {OK}
	return 1
    }


    if { $ilevs == 1 && ( $iopl == 1 || $iopl == 2 || $iopl == 6 ) } {
        set max_lev [ max_ilev $iopl $isubm ]
        set min_lev [ min_ilev $iopl $isubm ]
	if { ($levb < $min_lev) || ($levt < $levb) || ( $levt > $max_lev ) } {
	    error_message .d {Range incorrect} "The range of levels you have specified is not allowed. The values should obey \
		    $min_lev <= `Range starting at' <= `Range ending at' <= $max_lev" warning 0 {OK}
	    return 1
	}
    } 

    return 0
}


# Verification of UNT3_$isubm
proc tunt3a {value variable profile isubm} {
    set unt3    [get_variable_value UNT3_$isubm\($profile\)]
    set iopt    [get_variable_value IOPT_$isubm\($profile\)]
    if { $unt3 != "DA" && $unt3 != "H" && $unt3 != "DU" && $unt3 != "T" } { 
	error_message .d {Not from list} "Specify a time unit from the list" warning 0 {OK}
	return 1
    } 
    if { $iopt == 2 &&  $unt3 == "DU" } {
	error_message .d {Bad Unit} "Dump units cannot be used with a time list." warning 0 {OK}
	return 1
    }
    return 0
}

# chk_prof_nm
#   Checking for duplicate profile names
# Arguments
#   value : Value of current profile name
#   variable : Variable name in format eg. TIMPRO_A(PROFILE)
#   profile : Profile number
#   isubm : A,O,S or W for atmos, ocean etc.
# global
#   profile_changed : contains the profile, profile number and profile
#                     type that is currently being changed
# Method
#   After checking for valid name, compare with all other names and
#   give an error if it matches an existing profile.
# Comments
#   Diagnostic table ought to be altered if this is a name change.
# Author: AJB 19/06/95

proc chk_prof_nm {value variable profile isubm} {

    set var_info [get_variable_info $variable]
    set max_length [lindex $var_info 4]
    if {[string length $value]>$max_length} {
	dialog .d {Name too long} \
		"Profile name \"$value\" is too long. Maximum $max_length characters allowed" \
		warning 0 {OK}
	return 1
    }
    if {$value==""} {
	dialog .d {Blank not allowed} \
		"You must enter a valid name." warning 0 {OK}
	return 1
    }
    
    # Get list of profiles and check that value does not duplicate any.
    set prefix [lindex [split $variable "()"] 0]
    set profList [get_variable_array $prefix]

    for {set i 0} {$i <= [llength $profList]} {incr i} {
	if {$i != [expr $profile - 1]} {
	    if {$value == [lindex $profList $i]} {
		error_message .d {Profile already exists} "Profile name '$value' already exists.\
			Please choose another name." warning 0 {OK}
		return 1
	    }
	}
    }
    return 0
}
