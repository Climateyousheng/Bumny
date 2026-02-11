#
# userAncils.tcl
#
# Contains procedures relating to reading in and checking user 
# ancillary master files
#   Ancillary record files are read in when the UMUI is first opened.
# Additionally, user ancillaries are reread when the user ancillary
# window is closed in case the file list is changed. However, we only
# want to output errors and warnings for these in the latter case. 
# Therefore the errFlag argument has been provided so that confusing
# error windows do not appear when the UMUI is first opened.

# readUserAncils
#   Reads user ancillary master files.
# Result
#   Returns 0 if OK or 1 if any errors found.
# Arguments
#   fileType: Either AncilFiles or AncilFields
#   mNumber: Identifies submodel
#   errFlag: Determines whether warnings and errors are output.

proc readUserAncils {fileType mNumber errFlag} {
    set errors 0
    if {$fileType == "AncilFiles"} {
	set variable UANCFILES
    } else {
	set variable UANCFLDS
    }
    set mLetter [modnumber_to_letter $mNumber]

    # Deletes all user records for this file type
    deleteRecords $fileType $mLetter * user
    # Check logical switch for table
    if {[get_variable_value L$variable\($mNumber\)] == "Y"} {
	set fileList [get_variable_array $variable\(*,$mNumber\)]
	set incList [get_variable_array INC$variable\(*,$mNumber\)]
	# Change lower case "y" and "n" to upper case for neatness
	set incList [string toupper $incList]
	set_variable_array INC$variable\(*,$mNumber\) $incList

	# Read records from each file.
	foreach file $fileList incVal $incList {
	    # Convert environment variables in name
	    set fileName [get_env $file]
	    if {$incVal == "Y"} {
		# Read in file. Errors will be output to a window
		set result [readRecordFile $fileType "user" \
			$mLetter $fileName $errFlag]
		if {$result == 1} {set errors 1}
	    }
	}
    }
    return $errors
}

# setupUserAncils
#  Called on closing InFiles_PAncil_User, the window relating to
#  defining user ancillary files. Reads in user AncilFields files then
#  calls separate proc to read in user AncilFiles files
# Arguments
#  mNumber: Model number (eg 1 for Atmos)
#  errFlag: Determines whether errors and warnings are output


proc setupUserAncils {mNumber errFlag} {
    
    # Read in user AncilFields files
    setupUserAncilFields $mNumber $errFlag

    # Read in user AncilFiles files
    setupUserAncilFiles $mNumber $errFlag
}

# setupUserAncilFields
#  Called by setupUserAncils. Reads in AncilFields files. If no errors,
#  sets up data for creating configure/update option table in User2.pan
# Arguments
#  mNumber: Model number (eg 1 for Atmos)
#  errFlag: Determines whether errors and warnings are output
# Method
#  Reads in files. Stores error result in UMUI variable which if set
#  means that table is not displayed.

proc setupUserAncilFields {mNumber errFlag} {
    
    set fileType "AncilFields"

    # Read or reread user ancillary file files
    set result [readUserAncils $fileType $mNumber $errFlag]

    # If no errors, create data for tables and open window
    if {$result != 1} {

	set mLetter [modnumber_to_letter $mNumber]
	
	set keys [getAllKeys $fileType "user" $mLetter]
	set nKeys [llength $keys]
	set max [get_variable_value N_UANCS]
	if {$nKeys > $max} {
	    set result 1
	    if {$errFlag != 0} {
		error_message .d "To many fields" "Maximum number of \
			fields allowed is $max, but you have $nKeys. \
			Either reduce number of fields or seek help." \
			warning 0 OK
	    }
	} else {
	    set_variable_array UAFLD_FLDNO(*,$mNumber) $keys
	    set titles ""
	    foreach key $keys {
		set title [getRecordElement $fileType $mLetter\
			$key title "user"]
		lappend titles $title
	    }
	    set_variable_array UAFLD_TITLE(*,$mNumber) $titles
	    set_variable_value UAFLD_COUNT($mNumber) [llength $keys]
	}
    }

    # If there is an error we want to avoid dealing with the UMUI inputs
    # that relate to these files so set error flag. Eg this deactivates
    # the field table in the UMUI input panel.
    set_variable_value UAFLD_ERR($mNumber) $result
}

# setupUserAncilFiles
#  Called by setupUserAncils. Reads in AncilFiles files. If no errors,
#  sets up data for creating file table in User2.pan
# Arguments
#  mNumber: Model number (eg 1 for Atmos)
#  errFlag: Determines whether errors and warnings are output
# Method
#  Reads in files. Stores error result in UMUI variable which if set
#  means that table is not displayed.

proc setupUserAncilFiles {mNumber errFlag} {
    
    set fileType "AncilFiles"

    # Read or reread user ancillary file files
    set result [readUserAncils $fileType $mNumber $errFlag]
    # If no errors, create data for tables and open window
    if {$result != 1} {

	set mLetter [modnumber_to_letter $mNumber]
	
	set keys [getAllKeys $fileType "user" $mLetter]
	set nKeys [llength $keys]
	set max [get_variable_value N_UANCS]
	if {$nKeys > $max} {
	    set result 1
	    if {$errFlag != 0} {
		error_message .d "To many files" "Maximum number of \
			files allowed is $max, but you have $nKeys. \
			Either reduce number of files or seek help." \
			warning 0 OK
	    }
	} else {
	    set_variable_array UAFILE_FILENO(*,$mNumber) $keys
	    set titles ""
	    foreach key $keys {
		set title [getRecordElement $fileType $mLetter\
			$key title "user"]
		lappend titles $title
	    }
	    set_variable_array UAFILE_TITLE(*,$mNumber) $titles
	    set_variable_value UAFILE_COUNT($mNumber) $nKeys
	}

    }
    # If there is an error we want to avoid dealing with the UMUI inputs
    # that relate to these files so set error flag. Eg this deactivates
    # the file table in the UMUI input panel.
    set_variable_value UAFILE_ERR($mNumber) $result
}

# checkUserAncils
#   Verification of setup of user ancillary file tables which set 
#   UANCFLDS and UANCFILES arrays.
# Arguments
#   value: Value of variable which should be list of local files
#   variable: eg UANCFLDS(*,1) or UANCFILES(*,4). Index is submodel no.
#   row: Row number of table
# Result
#   Return 0 for OK. Output dialog and return 1 if error.
# Comments
#   For each table column, will be called for row=1 and then for 
#   subsequent non-blank rows. However, all checking will be done
#   during first call

proc checkUserAncils {value variable row} {

    # Do all checking on first call
    if {$row != 1} {return 0}

    # variable is INCUANCFLDS, INCUANCFILES, UANCFLDS or UANCFILES
    # with index of, eg. (*,1) for atmosphere

    if {[string range $variable 0 2] == "INC"} {
	# Check include column of table for Y or N

	# Get name of variable for other table column
	set fileVar [string range $variable 3 end]
	set helpText [lindex [get_variable_info $fileVar] 10]
	# Number of rows containing files
	set nFiles [llength [get_variable_array $fileVar]]
	for {set i 0} {$i < $nFiles} {incr i} {
	    # Value should be Y or N, any case
	    set rowVal [lindex $value $i]
	    if {[lsearch [list y Y n N] $rowVal] == -1} {
		# Error, invalid or blank
		error_message .d "Invalid Input" "Include column row\
			[expr $i+1] should be 'Y' or 'N' but is set\
			to '$rowVal' in table for $helpText"\
			"warning" 0 OK
		return 1
	    }
	}
    } else {
	# Check filename column of table for valid file

	# Get contents of include column
	set incVal [get_variable_array INC$variable]
	set i 1
	set helpText [lindex [get_variable_info $variable] 10]
	if {[llength $value] == 0} {
	    error_message .d "No files" "Table column '$helpText'\
		    is empty. Deactivate table using switch above"\
		    "warning" 0 OK
	    return 1
	}
	foreach file $value include $incVal {
	    # Convert environment variables
	    if {$include != "N" && $include != "n"} {
		set fileName [get_env $file]
		if {$file == ""} {
		    # Blank row not allowed
		    error_message .d "Invalid Input" "Row $i of\
			    column '$helpText' is blank"\
			    "warning" 0 OK
		    return 1
		} elseif {[file isfile $fileName] == 0} {
		    # File does not exist
		    error_message .d "Invalid Input" "Row $i of column\
			    '$helpText should be a valid local file name"\
			    "warning" 0 OK
		    return 1
		}
		incr i
	    }
	}
    }
    return 0
}

# checkAncilFileSettings
#   Checks validity of the configure/update options for user ancillaries
#   held in variables UAFLD_UNIT and UAFLD_EVERY. Variables required only
#   if UAFLD_CON is set to "U" for update. If active UAFLD_UNIT should be 
#   Y, M, DA or H. UAFLD_EVERY is an appropriate number of units.
# Arguments
#   value: List of values of variable
#   variable: Variable with index: eg UAFLD_UNIT(*,1) or UAFLD_EVERY(*,2)
#   row: Row number of table being checked
# Method
#   Check whole list in one go, so return for all but row 1

proc checkAncilFileSettings {value variable row} {

    # Check UAFLD_UNIT and UAFLD_EVERY at the same time - so do nothing
    # when called with UAFLD_EVERY
    set varName [lindex [split $variable "()"] 0]
    if {$varName == "UAFLD_UNIT"} {

	# Do all checking on first call
	if {$row != 1} {return 0}

	set index [lindex [split $variable "()"] 1]
	set conOptions [get_variable_array UAFLD_CON($index)]
	set numUnits [get_variable_array UAFLD_EVERY($index)]
	set validUnits [list Y M DA H]
	set validRange [list 10000 12 31 24]
	set helpTextUnit [lindex [get_variable_info UAFLD_UNIT] 10]
	set helpTextEvery [lindex [get_variable_info UAFLD_EVERY] 10]

	set rowNum 0
	# Loop through all rows that have a configure/update option set
	foreach conOpt $conOptions rowUnit $value number $numUnits {
	    incr rowNum
	    if {$conOpt == "U" || $conOpt == "u"} {
		# Values only required when updating
		if {$rowUnit == ""} {
		    # Check for blank unit
		    error_message .d "Blank not allowed" "Row $rowNum\
			    of $helpTextUnit should be set to a valid\
			    time unit but is blank"\
			    "warning" 0 OK
		    return 1
		} elseif {$number == ""} {
		    # Check for blank Every
		    error_message .d "Blank not allowed" "Row $rowNum\
			    of $helpTextEvery should be set to a valid\
			    number of units but is blank"\
			    "warning" 0 OK
		    return 1
		} elseif {[lsearch $validUnits $rowUnit] == -1} {
		    # Check for invalid unit
		    error_message .d "Invalid value" "Row $rowNum\
			    of $helpTextUnit should be set to one of\
			    $validUnits but is '$rowUnit'"\
			    "warning" 0 OK
		    return 1
		} else {
		    # Check that "Every" is an integer (cannot declare
		    # UAFLD_EVERY as INT as it can be blank for updated
		    # ancillaries)
		    if {[regexp {^[0-9]+$} $number]!=1} {
			error_message .d "Integer needed" "Row $rowNum\
				of $helpTextEvery should be positive\
				integer but is '$number'"\
				"warning" 0 OK
			return 1
		    }
		
		    # Check for "Every" row being out of valid range
		    set range [lindex $validRange \
			    [lsearch $validUnits $rowUnit]]
		    if {$number < 1 || $number >= $range} {
			error_message .d "Invalid value" "Row $rowNum\
				of $helpTextEvery should be greater\
				than 0 and less than $range but is\
				'$number'"\
			    "warning" 0 OK
		    return 1
		    }
		}
	    } 
	}   
    }
    return 0
}
	    

# checkAncilRecord
#   Checks a single record from an ancillary master (field or files)
# Result
#   Returns 0 for OK, 1 for error and 2 for warning. Sets errors
#   and warnings variable appropriately - these should be lists;
#   use lappend or list command

proc checkAncilRecord {recordType source mLetter key} {
    upvar errors errors
    upvar warnings warnings
    set result 0
    if {$source == "user" && [getRecordElement \
	    $recordType $mLetter $key key main] == $key} {
	lappend warnings \
		"User record $key overwrites record in the master file"
	set result 2
    }
    return $result
}

# jsUserAncils_A
#   Jobsheet procedure for user ancillaries

proc jsUserAncils_A {outputFile pageWidth} {
}

# mainAncilActiveStatus
#  Function used in case statements in windows to determine active
#  status of the enclosed elements
# Argument
#  mLetter: Submodel letter
#  fileNo: Number of file

proc mainAncilActiveStatus {mLetter fileNo} {

    puts -nonewline "mainAncilActiveStatus $mLetter $fileNo "

    # If there is a user ancil file with this number, then element
    # is inactive
    if {[getRecordElement "AncilFiles" \
	    $mLetter $fileNo "fileNo" "user"] == $fileNo} {
	puts "0"
	return 0
    } else {
	puts "1"
	return 1
    }
}
