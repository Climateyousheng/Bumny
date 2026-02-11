#
# ancUpdateOptions.tcl
#
#   Each ancillary file has particular configure and update settings.
#   These procedures return the values.
#

# User ancillary information is read from the table in the user
# ancillary setup panel.

# Note on main ancillary setup. Currently, setup for main ancillaries
# is determined by referring to the indexing scheme held in A_STASHAN
# system variables:
#  For a given file number:
#    An entry is found in A_STASHAN in which 1st and 3rd columns both 
#    match the file number.
#    The row number of this item is the index number of the relevant
#    APATH, ACON etc variables. 
#    It would be possible to remove the requirement for the index 
#    variable by replacing 

# summariseAncilRequests
#   Really just a quick test that summarises the ancillary requests
#   on a file by file basis

proc summariseAncilRequests {mNumber} {
    
    set mLetter [modnumber_to_letter $mNumber]

    set allKeys [getAllKeys "AncilFields" "" $mLetter]

    foreach key $allKeys {
	# Don't repeat keys that exist in both user and main
	set ancilOptList [getAncOpt $mLetter $key]
    }
}

# getAncOpt
#   Return 3 item list describing ancillary update/conf options

proc getAncOpt {mLetter key} {

    set src [userOrMainField "AncilFields" $mLetter $key]

    set confOpt ""
    set updatePeriod ""
    set updateUnit ""
    if {$src == "user"} {
	set confOpt [getUserAncOpt $mLetter $key configure]
	if {$confOpt == "U"} {
	    set updatePeriod [getUserAncOpt $mLetter $key updatePeriod]
	    set updateUnit [getUserAncOpt $mLetter $key updateUnit]
	}
    } elseif {$src == "main"} {
	set confOpt [getMainAncOpt $mLetter $key configure]
	if {$confOpt == "U"} {
	    set updatePeriod [getMainAncOpt $mLetter $key updatePeriod]
	    set updateUnit [getMainAncOpt $mLetter $key updateUnit]
	}
    }	    
    return [list $confOpt $updatePeriod $updateUnit]
}

proc getUserAncOpt {mLetter key opt} {

    set mNumber [modletter_to_number $mLetter]

    set fieldList [get_variable_array UAFLD_FLDNO(*,$mNumber)]
    set pos [lsearch $fieldList $key]
    if {$pos == -1} {
	error "getUserAncOpt: Entry for user ancillary field $key does\
		not appear in the user ancillary setup table in\
		submodel $mLetter"
	return ""
    }
    incr pos
    set confOpt [get_variable_value UAFLD_CON($pos,$mNumber)]

    if {$opt == "configure"} {
	# Asking for the configure/update option
	return $confOpt
    }
    if {$confOpt != "U"} {
	# Configure or not used, so other update options are blank
	return ""
    }
    switch $opt {
	updatePeriod {
	    return [get_variable_value UAFLD_EVERY($pos,$mNumber)]
	}
	updateUnit {
	    return [get_variable_value UAFLD_UNIT($pos,$mNumber)]
	}
	default {
	    error "Invalid option $opt. Should be configure,\
		    updatePeriod or updateUnit"
	}
    }
}

# getMainAncOpt
#   Returns the user setting for main ancillary items.
# Comment

#   Some ancillary items are grouped together and all must have the
#   same settings. For purposes of implementing this, one item is
#   defined as the primary item and others in the group point to the
#   primary. This cross-referencing is defined by the 1st and 3rd 
#   columns of A_STASHAN.

proc getMainAncOpt {mLetter key opt} {

    set mNumber [modletter_to_number $mLetter]

    set list [get_variable_array $mLetter\_STASHAN]
    foreach row $list {
	set rowNum [lindex $row 0]
	if {$key == $rowNum} {
	    set fieldNo [lindex $row 2]
	    if {$fieldNo == -1} {return "Unused"}
	    set confOpt [get_variable_value $mLetter\CON($fieldNo)]
	    if {$opt == "configure"} {
		# Asking for the configure/update option
		return $confOpt
	    }
	    # SDM Don't know how to reference filename from field No
	    #if {$opt == "fileName"} {
		#set path [get_variable_value $mLetter\PATH($key)]
		#set file [get_variable_value $mLetter\FILE($key)]
		#return "$path/$file"
	    #}
	    if {$confOpt != "U"} {
		# Configure or not used, so update options are blank
		return ""
	    }
	    switch $opt {
		updatePeriod {
		    return [get_variable_value $mLetter\FRE($fieldNo)]
		}
		updateUnit {
		    return [get_variable_value $mLetter\TUN($fieldNo)]
		}
		default {
		    error "Invalid option $opt. Should be configure,\
			    updatePeriod or updateUnit"
		}
	    }
	}
    }
    error "Invalid field number $key. Entry not found in $mLetter\_STASHAN"
}
# userOrMainField
#   Determine whether record exists, has a "main" entry or has a "user"
#   entry.
# Result
#   Returns "user" if a user record exists for this key. Returns "main"
#   if a main record but not a user record exists. Otherwise returns ""

proc userOrMainField {rType mLetter key} {

    if {[getRecordElement $rType $mLetter $key key "user"] == $key} {
	return "user"
    } elseif {[getRecordElement $rType $mLetter $key key "main"] \
	    == $key} {
	return "main"
    }
    return ""
}
