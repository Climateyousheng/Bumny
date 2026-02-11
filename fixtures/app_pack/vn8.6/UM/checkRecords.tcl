#
# checkRecords
#
# Contains record-type specific code to check the contents of STASH or
# ANCIL record files. 

# checkRecordHeader
#  Checks header of file against current UMUI version, record type
#  and so on.
# Arguments
#  recordType: Type of record
#  source: user or master
#  mLetter: Letter defining submodel
#  header: List of header lines - each line should be of the form
#   Hn| VARIABLE=value where n is the line number

proc checkRecordHeader {recordType source mLetter header} {

    set umVersion [get_variable_value VERSION]

    set errors ""
    # STASH and ANCIL have similar header requirements
    if {$recordType == "STASH" || $recordType == "AncilFiles" || \
	$recordType == "AncilFields"} {
	# User records may not have headers
	if {$source == "main"} {
	    set scanLines [list "H1| SUBMODEL_NUMBER=%d" \
		    "H2| SUBMODEL_NAME=%s" \
		    "H3| UM_VERSION=%s"\
		    "H4| TYPE=%s"]
	    
	    set varList [list mNumber mVersionText umReqVersion fileType]

	    # Store value of each header line in appropriate variable
	    foreach line $header scanLine $scanLines var $varList {
	    
		if {[catch {set returnCode \
			[scan $line $scanLine $var]} err]} {
		    lappend errors "Error reading header in command"
		    lappend errors "scan $line $scanLine $var"
		    lappend errors "$err"
		} else {
		    if {$returnCode != 1} {
			lappend errors "Unable to scan header\
				of STASH record file:"
			lappend errors "$line"
			lappend errors "Correct format is:"
			lappend errors "$scanLine"
		    }
		}
	    }
	
	    if {$errors == ""} {
		# Test the values in the header
		if {$umVersion != $umReqVersion} {
		    lappend errors "This file is for UM version\
			    $umReqVersion and is therefore invalid for\
			    this UM version"

		}
		set fileMLetter [modnumber_to_letter $mNumber]
		if {$mLetter != $fileMLetter} {
		    lappend errors \
			    "File is valid for submodel number\
			    $mNumber (letter $fileMLetter) and is\
			    therefore invalid for this submodel"
		}
	    }
	}
    }
    return $errors
}
	    
    
    
# checkRecord
#   Wrapper for recordType-dependent check code

proc checkRecord {recordType source mLetter key} {
    upvar errors errors
    upvar warnings warnings
    set errors ""
    set warnings ""

    if {$recordType == "AncilFiles" || $recordType == "AncilFields"} {
	return [checkAncilRecord $recordType $source $mLetter $key]
    }
    return 0
}
