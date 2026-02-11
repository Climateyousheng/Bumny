#
# recordFiles.tcl
#
#   Contains procs relating to access of files holding UM records
#   such as ancil masters and, perhaps later, STASHmasters
# 
#   These record files are designed to be read in in the background;
#   the user interface is displayed before files are read, but regular
#   calls to "update" mean that the user can interact with the 
#   application without noticing what is going on.
#      However, there is the risk that the user may select a function
#   that requires the data being read in. Such a function must not
#   be allowed to run till the data is read.
#      This possibility is handled by the procs in startupProcs.tcl.
#   Essentially, functions check whether file reading is complete.
#   If not, then the function first sets up a binding so that it is 
#   re-called once reading is complete. The function then exits. See
#   the startupProcs.tcl file for more details.

# Data objects
#
# recordFormat
#  Holds information about the format of records in a file and the
#  names of each record which are used for accessing the individual 
#  items in the record.
# recordFormat(string rType, string property, [int lineNumber])
#  rType: Such as ANCILmaster - also used as name of record array
#  property: 
#    numLines: Number of lines per record
#    fieldList: List of field identities
#    genericFields: List of field identities held by all record types
#    key: Holds unique identity of key; it's a list of positions of 
#         key variables in fieldList list.
#    EOFmarker: Setting of key in EOF marker record
#   The following are a function of lineNumber
#    barLine: A line with "|" chars in the correct place
#    barPositions: List of positions of | characters in bar line
#    fieldNames: Identities for elements of record for a given line
#    numElementList: Number of elements per field
#  lineNumber: Numbers the above few items: 1 to numLines
#
# rTable
#  Array variable that holds all records
# rTable(string rType, string source, char mLetter, 
#                    string key, string elementName)
#  rType: Such as STASH or ANCIL
#  src: Defines whether item is from a user file or the master file
#  mLetter: A,O,W or S - identifies submodel
#  key: Identifies individual record
#  elementName: Identifies individual element within a record. All
#               records have a fileName element which says which
#               file name they come from
#
# Also
# rTable(string rType, string fileName, keyList)
#       List of keys read from given filename
# rTable(string rType, string fileName,
#                 string source, char mLetter, allKeys)
#       List of all keys for a given source and submodel
#
# For creating appropriate job library file from a set of user files:
#  rTable(string rType,char mLetter,fileHeader)
#       Suitable text for a file header
#  rTable(string rType,EOFRecord)
#       Suitable text for an end-of-file marker file header

# TO BE DONE
#  Provide error output routine
#  Type-specific routines to check records and header

namespace eval RecordFiles {
    namespace export readRecordFile
    namespace export getRecordElement
    namespace export getEOFRecord
    namespace export getFileHeader
    namespace export getAllKeys
    namespace export deleteRecords
    namespace export outputRecordFileErrors
}

# readRecordFile
#  Reads file of a particular type and stores results in appropriate 
#  array. Displays error if errFlag set
# Arguments
#  rType: Type of record such as ANCIL, STASH etc.
#  src: main or user
#  mLetter: Submodel id and one of the keys to the rType table
#  fileName: File holding list of records
#  errFlag: set to one of the following
#   0: Output nothing
#   1: Only output if there were errors
#   2: Output if there were errors and/or warnings
# Result
#  Return 0 for OK, 1 for an error and 2 for a warning.

proc ::RecordFiles::readRecordFile \
	{rType src mLetter fileName errFlag} {
    variable rTable
    
    # Check file and initialise variables as required
    set rCode [prelimChecks $rType $src $mLetter $fileName]

    if {$rCode != 0} {
	outputRecordFileErrors 1 $errFlag
	return 1
    }

    # Read in all records from file
    set result [readAllRecords $mLetter $fileName $rType $src]
    set errorList [lindex $result 0]
    set warningList [lindex $result 1]

    set errors ""
    set returnCode 0
    if {$warningList != ""} {
	set errors [concat [list "Warnings in $fileName"] $warningList]
	set returnCode 2
    }
    if {$errorList != ""} {
	set errors [concat [list "Errors in $fileName."] $errorList \
		[list ""] $errors]
	set returnCode 1
    }
    if {$returnCode != 0} {
	# If there are problems $errors will be a list of errors and 
	# warnings.
	recordFileError $errors
	outputRecordFileErrors $returnCode $errFlag 
    }
    return $returnCode
}

# getRecordElement
#  Obtain value of a particular element from a rTable hash table
# Arguments
#  rType
#  mLetter
#  key : Unique key to a particular item
#  item : Name of element required
#  src : main or user. If not provided, look for user first
# Result
#  Returns value of item or returns blank and sets warning variable if
#  record not available for this key, or if element not valid for this
#  record type

proc ::RecordFiles::getRecordElement \
	{rType mLetter key item {src ""}} {
    variable rTable
    variable recordFormat
    upvar warning warning
    set warning ""
    # If source not provided, check for user record first
    if {$src == ""} {
	if {[info exists \
		rTable($rType,user,$mLetter,$key,$item)\
		] == 1} {
	    return $rTable($rType,user,$mLetter,$key,$item)
	} elseif {[info exists \
		rTable($rType,main,$mLetter,$key,$item)\
		] == 1} {
	    return $rTable($rType,main,$mLetter,$key,$item)
	}
    } elseif {[info exists \
	    rTable($rType,$src,$mLetter,$key,$item)\
	    ] == 1} {
	set result $rTable($rType,$src,$mLetter,$key,$item)
	return $result
    }

    # Record not found

    # Set source string to main by default, for use in error messages
    if {$src == ""} {set src "main"}

    # Check that records of this type exist
    if {[info exists recordFormat($rType,fieldList)] == 0} {
	set warning "Record type $rType does not exist"
	return ""
    }
    set fieldList $recordFormat($rType,fieldList)
    set fieldList [concat $fieldList $recordFormat($rType,genericFields)]
    # Check that the requested element has a valid name
    if {[lsearch $fieldList $item] == -1} {
	set warning "Invalid item $item for $rType records"
	return ""
    }
    # Otherwise key does not exists for this submodel
    set warning "Item $item in $src $rType files does not exist\
	    for model $mLetter record $key"
    return ""
}

# getEOFRecord
#   Returns an end-of-file record for a particular record type
# Arguments
#  rType: Type of record such as ANCIL, STASH etc.

proc ::RecordFiles::getEOFRecord {rType} {
    variable rTable

    return $rTable($rType,EOFRecord)
}

# getFileHeader
#   Returns a suitable header for a particular record type
# Arguments
#  rType: Type of record such as ANCIL, STASH etc.
#  mLetter: Submodel id

proc ::RecordFiles::getFileHeader {rType mLetter} {
    variable rTable

    return $rTable($rType,$mLetter,fileHeader)
}

# getAllKeys
#  Get list of record keys for a given record type, submodel and source
# Arguments
#  rType: Type of record such as ANCIL, STASH etc.
#  src: main or user, or "" for both.
#  mLetter: Submodel id and one of the keys to the rType table
#  fileName: Optional - returns keys obtained from given file.
# Result
#  Returns list of keys or blank if there are no keys
# Comments
#  Cannot use $src == "" for a specified filename

proc ::RecordFiles::getAllKeys \
	{rType src mLetter {fileName ""}} {
    variable rTable
    if {$src != ""} {
	if {$fileName == ""} {
	    if {[info exists \
		    rTable($rType,$src,$mLetter,allKeys)]\
		    == 1} {
		return $rTable($rType,$src,$mLetter,allKeys)
	    }
	} else {
	    if {[info exists \
		    rTable($rType,$src,$mLetter,$fileName,keyList)\
		    ] == 1} {
		return $rTable($rType,$src,$mLetter,$fileName,keyList)
	    }
	}
    } else {
	if {$fileName != ""} {
	    error "getAllKeys: file name cannot be specified when\
		    requesting all keys for both main and user items"
	    return ""
	}
	set userList [getAllKeys $rType "user" $mLetter ""]
	set mainList [getAllKeys $rType "main" $mLetter ""]

	set allKeys [lsort -integer [concat $userList $mainList]]
	set keyList ""
	set lastKey -1
	foreach key $allKeys {
	    # Don't repeat keys that exist in both user and main
	    if {$key == $lastKey} {continue}
	    lappend keyList $key
	    set lastKey $key
	}
	return $keyList
    }
    return ""
}


# deleteRecords
#  Remove a record.
# Arguments
#  rType: Type of record such as ANCIL, STASH etc.
#  mLetter: Submodel id and one of the keys to the rType table
#  keyList : List of keys to item or items. Pattern matching allowed
#  src : main or user
# Comments
#  A key of * will clear out all elements with a particular source

proc ::RecordFiles::deleteRecords {rType mLetter keyList src} {
    variable rTable

    if {$keyList == "*"} {
	set keyList [getAllKeys $rType $src $mLetter]
    }

    # Clear out particular part of array
    foreach key $keyList {
	foreach index [array names rTable \
		$rType,$src,$mLetter,$key,*] {
	    unset rTable($index)
	}
	set keyList $rTable($rType,$src,$mLetter,allKeys)
	set keyPos [lsearch $keyList $key]
	if {$keyPos != -1} {
	    set rTable($rType,$src,$mLetter,allKeys) \
		    [lreplace $keyList $keyPos $keyPos]
	}
    }
}   

# prelimChecks
#  Reads file format and initialises variables as required
# Arguments
#  rType: Type of record such as ANCIL, STASH etc.
#  src: main or user
#  mLetter: Submodel id and one of the keys to the rType table
#  fileName: File holding list of records

proc ::RecordFiles::prelimChecks {rType src mLetter fileName} {
    variable rTable
    
    # Read in various details about the format of the records
    readRecordFormatFile $rType

    # Check for existence of file
    if {![file readable $fileName] || ![file isfile $fileName]} {
	recordFileError [list \
		"File $fileName not found or not readable"]
	return 1
    }

    # If file has been read already, remove its previous records first
    set keyList [getAllKeys $rType $src $mLetter $fileName]
    if {$keyList != ""} {
	deleteRecords $rType $mLetter $keyList $src
	unset rTable($rType,$src,$mLetter,$fileName,keyList)
    }

    # Initialise allKeys list
    if {[info exists rTable($rType,$src,$mLetter,allKeys)]\
	    == 0} {
	set rTable($rType,$src,$mLetter,allKeys) ""
    }
    # Check header to ensure file is valid for this model and version
    if {[set result [checkFileHeader \
	    $fileName $src $rType $mLetter]] != ""} {
	recordFileError [concat	[list "Errors in header of $fileName"]\
		$result]
	return 1
    }
    return 0
}
  

# readRecordFormatFile
#  Reads file that contains information about format of a given file
#  type.
# Arguments
#  rType: Type of record. eg. ancilMaster

proc ::RecordFiles::readRecordFormatFile {rType} {
    variable recordFormat

    # Return if already read this format file
    if {[info exists recordFormat($rType,EOFmarker)] == 1} {return}

    # Initialise list of fields
    set fieldList ""

    # Open file containing format details for given record type
    set file [directory_path variables]/$rType\Format
    set f [FRopenFile $file]

    # Read in number of lines per record
    set numLines [FRnextNonBlankLine $f]
    if {[catch {expr $numLines} errMsg]} {
	FRcloseFile $f
	error $errMsg
	return
    } elseif {[expr int($numLines)] != $numLines} {
	FRcloseFile $f
	error "First line of $rType\Format should be\
		integer but is $numLines"
	return
    }
    set recordFormat($rType,numLines) $numLines

    # Read in a bar position line for each line of records
    for {set i 1} {$i <= $numLines} {incr i} {
	set barLine [FRnextNonBlankLine $f]
	set recordFormat($rType,barLine,$i) $barLine

	# Record the positions of the | characters
	set recordFormat($rType,barPositions,$i) ""
	for {set j 0} {$j < [string length $barLine]} {incr j} {
	    if {[string index $barLine $j] == "|"} {
		lappend recordFormat($rType,barPositions,$i) $j
	    }
	}
    }

    # Read in a list of field names for each item in the lines
    for {set i 1} {$i <= $numLines} {incr i} {
	set recordFormat($rType,fieldNames,$i) \
		[FRnextNonBlankLine $f]

	# Store list of fields in fieldList and check for duplicates
	set recordFormat($rType,numElementList,$i) ""
	foreach fieldSet $recordFormat($rType,fieldNames,$i) {
	    # Field sets contain one or more fields - store the number
	    lappend recordFormat($rType,numElementList,$i) \
		    [llength $fieldSet]

	    # All rTypes have the following fields by default
	    set genericFields [list fileName key record]

	    # Check for duplicate names and store all names in one list
	    foreach field $fieldSet {
		if {[lsearch $fieldList $field] != -1} {
		    error "Duplicate field name '$field' while reading\
			    $rType format file"
		    return
		} elseif {[lsearch $genericFields $field] != -1} {
		    error "Error reading $rType format file:\
			    Field name '$field' is a reserved name"
		} else {
		    lappend fieldList $field
		}
	    }
	}
    }
    set recordFormat($rType,fieldList) $fieldList
    set recordFormat($rType,genericFields) $genericFields
    
    # Read in the key field name or names
    set key [FRnextNonBlankLine $f]
    if {$key == ""} {
	error "Expected [expr $recordFormat($rType,numLines) \
		* 2 + 3] lines of data in $rType\Format file"
	return
    }
    set recordFormat($rType,key) ""
    # key lists the positions of the key variables in the field list
    foreach element $key {
	if {[set pos [lsearch $fieldList $element]] == -1} {
	    error "Key variable $element should also be a field variable"
	    return
	}
	lappend recordFormat($rType,key) $pos
    }

    # Read in the key for the END of file marker
    set EOFkey [FRnextNonBlankLine $f]
    if {$EOFkey == ""} {
	error "Expected [expr $recordFormat(numLines) * 2 + 3]\
		lines of data in $rType\Format file"
	return
    }
    # Set EOF marker to be a comma separated list
    set comma ""
    set recordFormat($rType,EOFmarker) ""
    foreach element $EOFkey {
	append recordFormat($rType,EOFmarker) "$comma$element"
	set comma ","
    }
    FRcloseFile $f
}

# checkFileHeader
#  Read header of a record file. Should contain a number of 
#  lines of the form Hn| VARIABLE=VALUE where n is the line
#  number. Checks that file is appropriate for this model and
#  version
# Arguments
#  fileName: Full pathname of file
#  src: user or main
#  rType: Type of record such as ancilMaster, ancilUser etc.
#  mLetter: A,O,W or S
# Result
#  Return "" for success or error message if file is inappropriate or 
#  contains errors. 

proc ::RecordFiles::checkFileHeader \
	{fileName src rType mLetter} {
    variable rTable

    set f [FRopenFile $fileName]

    if {$src == "main"} {
	set rTable($rType,$mLetter,fileHeader) ""
	set carriageReturn ""
    }
    set header ""
    while {1} {
	set l1 [FRnextLine $f]
	if {[string index $l1 0] != "H"} {
	    break
	}
	lappend header $l1
	# Create a header that can be added to processed user file
	if {$src == "main"} {
	    append rTable($rType,$mLetter,fileHeader) "$carriageReturn$l1"
	    set carriageReturn "\n"
	}
    }
    FRcloseFile $f

    # Check header using version and file dependent code to ensure 
    # record is appropriate
    set result [checkRecordHeader \
	    $rType $src $mLetter $header]
    return $result
}

# readAllRecords
#  Read in all records from a given file.
# Arguments
#  mLetter: A,O,W or S
#  fileName: Full pathname of file
#  rType: Such as ANCILmaster, etc
#  src: main or user records
# Result
#  Adds valid records to appropriate hash table. Returns "" if no errors
#  otherwise returns a list of errors

proc ::RecordFiles::readAllRecords \
	{mLetter fileName rType src} {
    variable recordFormat

    set errorList ""
    set warningList ""

    set f [FRopenFile $fileName]

    set numLines $recordFormat($rType,numLines)
    # First line of a record should start with same character as first 
    # line of record in format file
    for {set i 1} {$i <= $numLines} {incr i} {
	set char0Line($i) [string index $recordFormat($rType,barLine,$i) 0]
    }

    # Initialise variables
    set counter 0
    set line(1) "X"
    set key ""

    # Loop till end of file reached or until end of file record read
    while {$line(1) != "" && \
	    $key != "$recordFormat($rType,EOFmarker)"} {

	# Run Tk update now and then so that application doesn't freeze
	incr counter
	if {$counter >= 10} {
	    update
	    set counter 0
	}

	# Loop till first line of record read or till end of file
	set line(1) [FRnextLine $f]
	while {$line(1) != "" && \
		[string index $line(1) 0] != $char0Line(1)} {
	    set line(1) [FRnextLine $f]
	}

	# If not end of file, read in rest of record lines
	set errorFound 0
	for {set i 2} {$i <= $numLines} {incr i} {
	    set line($i) [FRnextLine $f]
	    # Check each line has the correct initial line number/ID
	    if {[string index $line($i) 0] != $char0Line($i)} {
		if {$line($i) == ""} {
		    lappend errorList "Unexpected blank line\
			    near line [FRgetLineNumber $f]"
		} else {
			    
		    lappend errorList \
			    "Wrong number of lines or incorrect line\
			    numbers near line [FRgetLineNumber $f]:"
		    lappend errorList $line($i)
		}
		set errorFound 1
		break
	    }
	}
	if {$errorFound == 1} {
	    continue
	}
	# Check that last line not blank (implies end of file)
	# Put details of record into hash table. Pass
	# "line" variable with upvar 
	set key [transposeToArray \
		$mLetter $rType $src "line" $fileName]
	# If key is blank, error variable will have been set
	# by proc using upvar
	if {$key == ""} {
	    lappend errorList "Format error near line\
		    [FRgetLineNumber $f]"
	    set errorList [concat $errorList $errors]
	} else {
	    if {$errors != ""} {
		# Warning message
		lappend warningList "Warning near line\
			[FRgetLineNumber $f]"
		set warningList [concat $warningList $errors]			
	    }
	    # Check record with the record-type dependent code
	    # checkRecord sets errors list variable with upvars
	    set result [checkRecord $rType $src $mLetter $key]
	    if {$result == 1} {
		lappend errorList "Error near line [FRgetLineNumber $f]\
			in record $key. Record will be ignored"
		set errorList [concat $errorList $errors]
		# If error rather than warning, remove record
		deleteRecords $rType $mLetter $key $src
	    } elseif {$result == 2} {
		lappend warningList "Warning near line [FRgetLineNumber $f]\
			in record $key."
		set warningList [concat $warningList $warnings]
	    }
	}
    }
    
    # Check that final record has EOF key
    if {$key != "$recordFormat($rType,EOFmarker)"} {
	lappend errorList "No End-of-file marker found in file"
    }
    # Close file and return
    FRcloseFile $f
    return [list $errorList $warningList]
}


# transposeToArray
#  Transposes contents of a read of a file record to appropriate array
#  based on the record format
# Arguments
#  mLetter: A,O,W or S
#  rType: Such as ANCILmaster, etc
#  src: main or user
#  lines: Name of array containing contents of read from record
#  fileName: Filename that holds this record
# Result
#  Returns key for this record or if there was a problem, returns
#  blank and sets errors variable using upvar

proc ::RecordFiles::transposeToArray \
	{mLetter rType src lines fileName} {
    upvar $lines recordLine
    upvar errors errors
    variable rTable
    variable recordFormat

    set errors ""
    set numLines $recordFormat($rType,numLines)
    set fieldList $recordFormat($rType,fieldList)

    # Section 1:
    # Read each field of each line of the record held in $lines.
    # Check the position of the | characters

    for {set i 1} {$i <= $numLines} {incr i} {
	# List giving number of elements per field
	set numElementList $recordFormat($rType,numElementList,$i)

	# Break up input line at the bar positions
	set fields [lrange [split $recordLine($i) |] 1 end]

	# Loop through list of fields and corresponding field names
	foreach value $fields numElements $numElementList {

	    # There can be more than one element in a fieldName
	    # But ignore anything with numElements == "" this happens
	    # after splitting on |, when there is an extra blank field
	    # in $fields caused by the last | in the line
	    if {$numElements == 1} {
		# This field has one element 
		# Remove beginning and end whitespace first
		regsub -all "^\[ 	\]*|\[ 	\]*$" $value "" value
		lappend fieldVals $value
	    } elseif {$numElements != ""} {
		# This field has multiple elements
		set numVals [llength $value]
		if {$numElements != $numVals} {
		    lappend errors "Format Error: Expected\
			    $numElements values but got $numVals\
			    in one of the fields in:"
		    lappend errors "$recordLine($i)"
		} else {
		    set fieldVals [concat $fieldVals $value]
		}
	    }
	}

	# Check that "|" characters are in correct place
	foreach j $recordFormat($rType,barPositions,$i) {
	    if {[string index $recordLine($i) $j] != "|"} {
		lappend errors "Bars in wrong place in the line:"
		lappend errors $recordLine($i)
		return ""
	    }
	}
    }

    # Section 2:
    # Compute the key for this record

    foreach item $recordFormat($rType,key) {
	lappend keyVals [lindex $fieldVals $item]
    }
    set key [join $keyVals ,]

    # Section 3:
    # If key is setup OK, we can now put items in appropriate place in
    # hash table

    if {$key != "$recordFormat($rType,EOFmarker)"} {
	# See if such an item already read in from another file
	if {[info exists \
		rTable($rType,$src,$mLetter,$key,fileName)\
		] == 1} {
	    set oldFile \
              $rTable($rType,$src,$mLetter,$key,fileName)
	    lappend errors "Warning item $key in this file will\
		    overwrite item with same key in"
	    lappend errors $oldFile

	    # Remove key from key list for original file
	    set keyList $rTable($rType,$src,$mLetter,$oldFile,keyList)
	    set keyPos [lsearch $keyList $key]
	    set rTable($rType,$src,$mLetter,$oldFile,keyList) \
		    [lreplace $keyList $keyPos $keyPos]
	}

	# Save filename that holds this item
	set rTable($rType,$src,$mLetter,$key,fileName)\
		$fileName
	lappend rTable($rType,$src,$mLetter,$fileName,keyList) $key
	if {[lsearch $rTable($rType,$src,$mLetter,allKeys)\
		$key] == -1} {
	    lappend rTable($rType,$src,$mLetter,allKeys)\
		    $key
	}
	foreach element $fieldList value $fieldVals {
	    set rTable($rType,$src,$mLetter,$key,$element)\
		    $value
	}
	# Also save key itself for completeness
	set rTable($rType,$src,$mLetter,$key,key) $key

	# Save copy of formatted record for writing out to job library
	if {$src == "user"} {
	    set rTable($rType,$src,$mLetter,$key,record) "#"
	    for {set i 1} {$i <= $numLines} {incr i} {
		append rTable($rType,$src,$mLetter,$key,record) \
			"\n$recordLine($i)"
	    }
	}
    } else {
	# Create an EOF record for writing out to job library
	if {$src == "main"} {
	    set rTable($rType,EOFRecord) "#\n"
	    for {set i 1} {$i <= $numLines} {incr i} {
		append rTable($rType,EOFRecord) \
			"$recordLine($i)\n"
	    }
	}
    }
    return $key
}

# clearRecordFileErrors
#  Procedure for clearing old errors.

proc ::RecordFiles::clearRecordFileErrors {} {
    variable recordFileErrorList
    set recordFileErrorList ""
}

# recordFileError
#  Procedure for saving errors from the reading of a particular file.

proc ::RecordFiles::recordFileError {errorList} {
    variable recordFileErrorList
    foreach error $errorList {
	append recordFileErrorList "$error\n"
    }
}

# outputRecordFileErrors
#  Procedure for outputting errors from the reading of a particular file
#  either through a supplied addTextToWindow procedure or using puts.
# Arguments
#  returnCode: Return code that the calling procedure will pass back
#              0 for OK,1 for errors, 2 for warnings
#  errFlag: 
#  0: Output nothing
#  1: Only output if there were errors - don't output warnings only
#  2: Output if there were errors and/or warnings

proc ::RecordFiles::outputRecordFileErrors {returnCode errFlag} {

    set errorList [getRecordFileErrors $returnCode $errFlag]

    if { ($errFlag == 1 && $returnCode == 1) || \
	    ($errFlag == 2 && $returnCode != 0) } {
	if {[info commands "addTextToWindow"] == "addTextToWindow"} {
	    addTextToWindow .recordFilesError $errorList \
		    "Errors and warnings reading record files"
	} else {
	    puts $errorList
	}
    }
}

# getRecordFileErrors
#  Procedure for obtaining errors from the reading of a particular file.
# Arguments
#  returnCode: Return code that the calling procedure will pass back
#              0 for OK,1 for errors, 2 for warnings
#  errFlag: 
#  0: Output nothing
#  1: Only output if there were errors - don't output warnings only
#  2: Output if there were errors and/or warnings
# Comments
#  There may be more than one error and warning message as the code
#  allows for warnings to be saved while processing continues. 
#  Calling this procedure also has the effect of reinitialising
#  the error list to blank.

proc ::RecordFiles::getRecordFileErrors {returnCode errFlag} {
    variable recordFileErrorList
    set errorList $recordFileErrorList
    clearRecordFileErrors

    if { ($errFlag == 1 && $returnCode == 1) || \
	    ($errFlag == 2 && $returnCode != 0) } {
	return $errorList
    }
}

# testRecordFiles
#   Test procedures and also demonstrate method of use without
#   invoking rest of navigation system. Analysis of the first 
#   few lines demonstrates the coupling that exists between this
#   module and others.

proc testRecordFiles {} {
    if {[info command readRecordFile] == ""} {
	namespace import RecordFiles::*
	
	# These are needed for test harness
	# Wrapper commands for reading files and ignoring comments
	source fileReader.tcl
	namespace import FileReader::*
	# Makes external call to obtain format file location which is
	# currently held in variables directory
	proc directory_path {type} {return ../variables}
	# Makes external call to check the header of the file
	source checkRecords.tcl
	# checkRecords checks header against umui variable VERSION using call
	# to get_variable_value
	proc get_variable_value {var} {
	    if {$var=="VERSION"} {
		# Get version name from current directory path
		set aboveDir [exec dirname [pwd]]
		set version [exec basename $aboveDir]
		return $version
	    } else {
		error "don't know $var"
	    }
	}
    }

    set mLetter A
    set rType STASHmaster
    set file ${rType}_$mLetter
    set result [readRecordFile $rType main $mLetter \
	    ../variables/$file 1]
    puts "Read in $rType $mLetter with error code $result"
    if {$result == 0} {
	# Run a few basic tests to search for items
	# Expected results are matched against the actual results
	foreach item [list 0,4 0,986 0,4] \
		key [list name key fred] \
		expectWarn [list "" \
		"Item key in main STASHmaster files does not\
		exist for model A record 0,986" \
		"Invalid item fred for $rType records"] \
		expectResult [list "THETA AFTER TIMESTEP" "" ""] {

	    set result [getRecordElement $rType $mLetter $item $key]
	    puts "getRecordElement $rType $mLetter $item $key"

	    # Compare the expected with the actual and output helpful message
	    # Error messages are stored in "warning" variable
	    if {("$expectWarn" == "" && "$warning" != "") || \
		    ("$expectWarn" == "" && "$warning" != "")} {
		puts "Expected warning \"$expectWarn\" but got \"$warning\""
	    } elseif {"$expectWarn" == ""} {
		puts "As expected, no warning message obtained"
		puts "Result was $result. Result should have been something like:"
		puts "$expectResult"
	    } else {
		puts "As expected, a warning message was obtained"
		puts "Warning was: $warning" 
		puts "Warning should have been something like:"
		puts "$expectWarn"
	    }
	}
    }
}
