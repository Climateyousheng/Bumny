#==============================================================================
# RCS Header:
#   File         [$Source: /home/hc0300/umui/srce_code/UMUI_archive/umui2.0/vn7.6/UM/levelNames.tcl,v $]
#   Revision     [$Revision: 1.1 $]     Named [$Name: head#main $]
#   Last checkin [$Date: 2010/02/02 17:05:27 $]
#   Author       [$Author: umui $]
#==============================================================================

namespace eval levelNames {
    namespace export lnSubLevelNames
    namespace export lnConvertInput
    namespace export lnNameList
    namespace export lnDisplayHelp
}


# levelNames.tcl
#
#   Contains procedures relating to the level names that can be
#   used in the definition of domain profiles.

# lnConvertInput
#   Substitutes level names then attempt to evaluate it. Just
#   return a string if evaluation cannot be completed.
# Arguments
#   x: Name, value or sum including both or either

proc ::levelNames::lnConvertInput {x {help nohelp}} {

    if {$help == "help"} {
	# Help button pressed
	LNDisplayHelp
    } else {

	set result [lnSubLevelNames $x]

	if {[regexp {[A-Z_]} $result] != 0} {
	    # Not substituted everything
	    set value $result
	} else {
	    if {[catch {set value [expr $result]}] == 1} {
		# Not a valid expression
		set value $result
	    }
	}
	# Returning a single number
	return [string trim $value]
    }
}    

# lnSubLevelNames
#   Substitutes level names then returns result which could be 
#   a value or a sum
# Arguments
#   x: Name, value or sum including both or either

proc ::levelNames::lnSubLevelNames {x} {
    variable nameList 

    # Setup nameList to be a list of names and sort by length to 
    # ensure that, say, "TOP_WET" is substituted before "TOP"
    LNInitialiseNames
    set nameList [lsort -command LNsortByLength $nameList]

    # Substitute each name in turn
    set i 0
    while {[regexp {[A-Z_]} $x] != 0 && $i < [llength $nameList]} {
	set name [lindex $nameList $i]
	set levelName [LNLevelName $name]
	if {$levelName == "" && [regexp $name $x] != 0} {
	    error "Levels value relating to level Name $name is unset"
	}
	regsub -all $name $x [LNLevelName $name] x
	incr i
    }

    return $x
}

# lnNameList
#  Returns a list of all valid names and their current values.

proc ::levelNames::lnNameList {} {
    variable nameList
    LNInitialiseNames
    set nameList [lsort $nameList]

    set valList {}
    foreach name $nameList {
	lappend valList [list $name [LNLevelName $name] [LNLevelNameDesc $name]]
    }
    return $valList
}

# LNInitialiseNames
#  Initialises the list of valid names. For each new name add 
#  an entry to the switch statement in LNLevelName

proc ::levelNames::LNInitialiseNames {} {
    variable nameList [list \
	    ATMOS_TOP ATMOS_BOTTOM ATMOS_LEVS BOTTOM_EG BOTTOM_EGND \
	    TOP_WET TOP_BL CLOUD_LEVS BOTTOM_GWD TOP_GWD SURFACE SOIL_LEVS\
	    ]
}

# lnDisplayHelp
#  Display help panel describing names
# Arguments
#  win: window name containing help button

proc ::levelNames::lnDisplayHelp {win} {
    variable nameList
 
    set text [getHelpText [directory_path help]/level_names.help]

    # Creates a list of lists containing names, values and descriptions
    # of names
    set infoList [list [list Name Value Description] [list "" "" ""]]
    set infoList [concat $infoList [lnNameList]]
    
    set blank "                "
    foreach item $infoList {
	set string ""
	foreach el $item length [list 15 5 56] {
	    append string "$el[string range $blank 0 [expr $length - [string length $el]]]"
	}
	append text "\n$string"
    }
    textToWindow .levelNames $text "Level Names in $win"
}

# LNLevelName
#  Returns value of a particular name.
# Arguments
#  name: Should be a valid name otherwise give an error

proc ::levelNames::LNLevelName {name} {
    return [LNNameInfo $name value]
}

# LNLevelNameDesc
#  Returns value of a particular name.
# Arguments
#  name: Should be a valid name otherwise give an error

proc ::levelNames::LNLevelNameDesc {name} {
    return [LNNameInfo $name description]
}

proc ::levelNames::LNNameInfo {name type} {

    variable nameList
    
    if {[lsearch $nameList $name] == -1} {
	error "Invalid level name $name"
    }
    
    switch $name\_$type {
	ATMOS_LEVS_value {set result [get_variable_value NLEVSA]}
	ATMOS_LEVS_description {set result "Number of atmosphere levels"}
	ATMOS_TOP_value {set result [get_variable_value NLEVSA]}
	ATMOS_TOP_description {set result "Number of top atmosphere level"}
	ATMOS_BOTTOM_value {set result 1}
	ATMOS_BOTTOM_description {set result "Number of bottom atmosphere level"}
        BOTTOM_EG_value {set result 0}
        BOTTOM_EG_description {set result "Number of bottom atmosphere End Game level"}
        BOTTOM_EGND_value {
           set l_endgame [get_variable_value L_ENDGAME]
           if {$l_endgame=="T"} {
              set result 0
           } else {
              set result 1
           }
        }
        BOTTOM_EGND_description {
           set l_endgame [get_variable_value L_ENDGAME]
           set result "Number of bottom atmosphere level when L_ENDGAME = $l_endgame"
        }
	TOP_WET_value {set result [get_variable_value NWLEVA]}
	TOP_WET_description {set result "Number of wet levels"}
	TOP_BL_value {set result [get_variable_value NBLLV]}
	TOP_BL_description {set result "Number of top boundary layer level"}
	CLOUD_LEVS_value {set result [get_variable_value CLRAD]}
	CLOUD_LEVS_description {set result "Number of cloud levels"}
        BOTTOM_GWD_value { set result 1 }
	BOTTOM_GWD_description {set result "Number of bottom gravity wave drag level"}
	TOP_GWD_value {set result [get_variable_value NLEVSA]}
	TOP_GWD_description {set result "Number of top gravity wave drag level"}
	SURFACE_value {set result 1}
	SURFACE_description {set result "Number of the surface level"}
	SOIL_LEVS_value {set result [get_variable_value NDSLV]}
	SOIL_LEVS_description {set result "Number of soil levels"}
	default {
	    # It's in the nameList but no value/description has been set
	    error "UMUI error: No $type for name $name"
	}
    }

    return $result
}

proc ::levelNames::LNsortByLength {x y} {
    if {[string length $x] > [string length $y]} {
	return -1
    } else {
	return 1
    }
}
