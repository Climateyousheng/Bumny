#
# diagTags.tcl
#
# Procedures related to the tags that can be attached to groups of 
# diagnostics.
#

# initTags
#   Initialise some globals for tag tables.

proc initTags {} {
    global diagTags

    set diagTags(inChar)  "+"
    set diagTags(outChar) "\ "
    set diagTags(tagPos)  [string length $diagTags(inChar)]
}

# changeTag
#   Set entry to the selected tag (uppercase keystroke)
# Arguments
#   t : Table id
#   col : Column number
#   row : Row number
#   key : Key pressed
#   mNumber : Model id number

proc changeTag {t col row key mNumber} {
    global stInstance diagTags

    set w $stInstance($mNumber,Window)

    if {$col == 7} {
	# Column 7 is tag column - set to A-Z
	if {[regexp {[A-Z]} $key] == 1 && [string length $key] == 1} {
	    # Appropriate key pressed, so set tag
	    set newVal $key
	    modifyTag $mNumber $t $col $row $newVal
	} elseif {[regexp {[a-z]} $key] == 1 && [string length $key] == 1} {
	    # Lower case - remind user that upper case is required
	    status_message $w \
 "Need uppercase keys to set package column as keys q,w,a,s,z,x already used for moving between profiles"
	} elseif {$key == "space"} {
	    # Unset tag
	    plbMethod $t ChangeEntry 7 $row $diagTags(inChar)
	    update idletasks
	    displayTagDescription $t $col $row $mNumber
	}
    }
}

# displayTagDescription 
#   Display description of tag in status line when event occurs
# Arguments
#   t : Table id
#   col : Column number
#   row : Row number
#   mNumber : Model id number

proc displayTagDescription {t col row mNumber} {
    global stInstance diagTags

    set w $stInstance($mNumber,Window)
    set mLetter [modnumber_to_letter $mNumber]

    if {$col == 7} {
	# Column 7 is tag column - set to A-Z
	set tag [string index [plbMethod $t GetEntry $col $row] $diagTags(tagPos)]
	set tagList [get_variable_array D_TAG]
	set tagNo [lsearch $tagList $tag]
	if {$tagNo != -1} {
	    incr tagNo
	    set desc [get_variable_value D_TAG_DESC_$mLetter\($tagNo\)]
	    status_message $w $desc
	} else {
	    status_message $w ""
	}
    }
}

# setTags
#  Open panel to set tag options
# Arguments
#   mNumber : Model id number

proc setTags {mNumber} {
    set mName [string tolower [modnumber_to_name $mNumber]]
    create_window $mName\_STASH_Tags
}

# modifyTag
#  Modify the tag setting for a diagnostic. Include > or < in column
#  to indicate whether the tag is active or inactive.
# Arguments
#  mNumber : Model id number
#  t : Table id
#  row : Row number
#  newVal : Proposed new tag

proc modifyTag {mNumber t col row newVal} {
    global stInstance diagTags

    set w $stInstance($mNumber,Window)

    set mLetter [modnumber_to_letter $mNumber]
    set tagList [get_variable_array D_TAG]
    set tagNo [expr [lsearch $tagList $newVal] + 1]

    if {$tagNo == 0} {
	error "Invalid package: Package $newVal is not in list of allowed values. Please report"
    }

    set status [get_variable_value D_TAGF_$mLetter\($tagNo\)] 
    if {$status == "Y"} {
	set colVal "$diagTags(inChar)$newVal"
    } else {
	set colVal "$diagTags(outChar)$newVal"
    }	
    plbMethod $t ChangeEntry 7 $row $colVal
    displayTagDescription $t $col $row $mNumber
    if {$status != "Y" && $status != "N"} {
	status_message $w \
		"The status of package $newVal has not been determined. The default status is Off"
    }
}

# setupTagList
#   Sets up contents for tag column. Each entry is a > or < depending
#   on whether the tag is included, followed by the tag itself
# Arguments
#   mNumber : Model id

proc setupTagList {mNumber} {
    global diagTags

    set mLetter [modnumber_to_letter $mNumber]

    set tagList [get_variable_array D_TAG]
    set tagFlag [get_variable_array D_TAGF_$mLetter]
    set tagCol [get_variable_array ITAG_$mLetter]
    set nDiags [get_variable_value NDIAG_$mLetter]

    for {set i 0} {$i < [llength $tagList]} {incr i} {
	set tag [lindex $tagList $i]
	set tagArray($tag) [lindex $tagFlag $i]
    }
    set colVal ""
    for {set i 0} {$i < $nDiags} {incr i} {
	set tag [lindex $tagCol $i]
	if {$tag == ""} {
	    lappend colVal "$diagTags(inChar)"
	} elseif {$tagArray($tag) == "Y"} {
	    lappend colVal "$diagTags(inChar)$tag"
	} else {
	    lappend colVal "$diagTags(outChar)$tag"
	}
    }
    return $colVal
}

# saveTags
#   Saves current settings of tags so that we can check for changes
#   on closure of panel
# Arguments
#   mLetter : Model letter

proc saveTags {mLetter} {
    global tagFlags

    set tagFlags($mLetter) [get_variable_array D_TAGF_$mLetter]
}

# updateTagsAbandon
#   Called on abandoning of tag include option panel to unset global
# Arguments 
#   mLetter : Model letter

proc updateTagsAbandon {mLetter} {
    global tagFlags stash_open
    set mNumber [modletter_to_number $mLetter]
    if {[info exists stash_open($mNumber)] == 1} {
	unset tagFlags($mLetter)
    }
}

# updateTagsClose
#   Called on closure of tag include option panel. Modifies the tag column
#   in the diagnostic table to < or > as appropriate.
# Arguments 
#   mLetter : Model letter
# Globals
#   tagFlags : Contains list of tag flags (ie. Y or N) for each diagnostic
# Method
#   For each tag flag, compares current setting with previous. If the setting
#   changed, modify columns where the flag is used

proc updateTagsClose {mLetter} {
    global tagFlags stInstance stash_open diagTags

    set mNumber [modletter_to_number $mLetter]

    # If STASH still open, update panel if appropriate
    if {[info exists stash_open($mNumber)] == 1} {
	set s $stInstance($mNumber,Root)
	set tagList [get_variable_array D_TAG]
	set tagsNew [get_variable_array D_TAGF_$mLetter]

	for {set i 0} {$i < [llength $tagList]} {incr i} {
	    set oldTag [lindex $tagFlags($mLetter) $i]
	    set newTag [lindex $tagsNew $i]
	    if {$oldTag != $newTag} {
		set tag [lindex $tagList $i]
		if {$newTag == "Y"} {
		    plbMethod $s SearchAndRep 7 "$diagTags(outChar)$tag" "$diagTags(inChar)$tag"
		} else {
		    plbMethod $s SearchAndRep 7 "$diagTags(inChar)$tag" "$diagTags(outChar)$tag"
		}
	    }
	}
    }
    unset tagFlags($mLetter)
}






