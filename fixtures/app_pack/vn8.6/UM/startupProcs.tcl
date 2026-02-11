#
# startupProcs.tcl
#
#  Holds application specific procedures that will be called. One is
#  called to load packages, the second is called directly
#  after the navigation window has been created and displayed.
#

# appSpecificPackages
#  Called as soon as application specific files sourced.
#  Load packages and namespaces required by the application.

proc appSpecificPackages {} {

        namespace import RecordFiles::*
        namespace import FileReader::*
        namespace import levelNames::*
}

# appSpecificStartup
#   Called as soon as navigation window appears.
# Comments
#   If it is process-intensive it will freeze up navigation window till
#   complete. This can be avoided by including periodic calls to 
#   "update". But ensure routine is allowed to complete before user
#   does an action that requires one of the results from the procedure.
#   See proc "checkFilesRead" for a way of doing this.

proc appSpecificStartup {} {
    global env

	setupHistoryFlag
    readUMRecordFiles
}


# setupHistoryFlag set up flag for creating history file
# if version is 6.0 - flag is 1, else is 0

proc setupHistoryFlag {} {
	global version
	global createhistflag
	
	if {$version >= "6.0"} {
		set createhistflag 1
	} else {
		set createhistflag 0
	}
}


# readUMRecordFiles
#   Reads in Ancil and STASHmaster files
# globals
#   UMRecordsRead(string fileType,char mLetter)
#     fileType: ANCIL or STASH
#     mNumber: 1,2,3 or 4 for Atmos, ocean etc
#   Set to 1 once files read in: procedures that require these files need
#   to know not to access them till array element set.

proc readUMRecordFiles {} {
    global UMRecordsRead

    set dir [directory_path variables]

    # Initialises UMRecordsRead and returns number of models to read
    set maxMNumber [initUMRecordsGlobal]
    set typeList $UMRecordsRead(typeList)

    # Read each file for the appropriate range of model numbers
    foreach type $typeList {
	for {set mNumber 1} {$mNumber <= $maxMNumber} {incr mNumber} {
	    set mLetter [modnumber_to_letter $mNumber]
	    # If file exists, read it in
	    set fName $dir/$type\_$mLetter
	    set result [readRecordFile $type main $mLetter $fName 2]

	    # 0 arg implies errors to be ignored
	    readUserFiles $type $mLetter 0
	    set UMRecordsRead($type,$mNumber) 1

	    # User may have already attempted a function that uses
	    # this file. The function should have made a call to 
	    # checkAllFilesRead or checkFilesRead that stored the
	    # command for running now - the file having now been
	    # read. The following call repeats any commands that
	    # have been stored in this way.
	    # Examples of where this is used include processing 
	    # and STASH panel.
	    repeatRecordAccessCommands $type $mNumber

	}
    }
}

proc initUMRecordsGlobal {} {
    global UMRecordsRead

    set UMRecordsRead(initialise) 1
  
    # Read STASHmaster only when system implemented for STASH
    #set typeList [list AncilFiles AncilFields STASHmaster]
    set typeList [list AncilFiles AncilFields]
    # Only read in atmos files for now
    set maxMNumber 1

    # This variable is supposed to hold name and model number of last
    # file to be read in. When checkAllFilesRead is called by a function
    # this is the file that will be checked for.
    set UMRecordsRead(lastType)\
	    [lindex $typeList [expr [llength $typeList] -1]]
    set UMRecordsRead(lastMNumber) $maxMNumber

    set UMRecordsRead(typeList) $typeList
    return $maxMNumber
}

# checkAllFilesRead
#  Calls checkFilesRead with details of last file to be read in. This can
#  be called by routines that reference record files and that might need
#  to wait for reading in to finish
# Argument
#  callback: If files not read in, this is the command that is repeated 
#            once they are
# Method
#  Record file reading routine carries out periodic updates so that the
#  user does not need to wait till all records read before beginning 
#  editing. However, some editing functions do need all records to have
#  been read in. For such functions, put a call to this proc at the 
#  beginning and set the callback to be a repeat of the command.
# Result
#  Returns 1 if files have been read. If it returns 0, it implies that
#  files are not read, but that once they are, the $callback will be
#  evaluated. Typically, the calling routine would then exit as the 
#  $callback routine will repeat its call.

proc checkAllFilesRead {callback} {
    global UMRecordsRead    
    
    # In case the procedure was called before the call to the startup
    # procedure was made

    if {[info exists UMRecordsRead] == 0} {
	initUMRecordsGlobal
    }

    return [checkFilesRead $UMRecordsRead(lastType) \
	    $UMRecordsRead(lastMNumber) $callback]
}

# checkFilesRead
#  Checks that UM files read in before routine that requires them is
#  needed. If not, create a little dummy window and bind destroy event
#  to recall procedure. More specific version of checkAllFilesRead.
# Argument
#  type: Type of record file required.
#  mNumber: Model number of record file required.
#  callback: If files not read in, this is the command that is repeated 
#            once they are
# Method

#  Say, for example, processing is pressed. Processing requires the
#  atmosphere ancillary record files to be read in so needs to call
#  this procedure with eg. "AncilFiles" to check that they have been
#  read. It will also supply the name of the process procedure (and
#  any arguments) in the callback.

#  If the records have been read already, this procedure returns 1 and
#  processing should just continue. If the records are still being
#  read the processing command is stored and the procedure returns
#  0 which indicates that the processing should exit.
#   Once the required file has been read the readUMRecordFiles proc
#  checks for the existence of stored commands and reevaluate them 
#  hence restarting the processing function.

proc checkFilesRead {type mNumber callback} {
    global UMRecordsRead

    if {[info exists UMRecordsRead] == 1} {
	if {[info exists UMRecordsRead($type,$mNumber)] == 0} {
	    # Records not read for this file type and submodel
	    if {[info exists \
		    UMRecordsRead($type,$mNumber,cmdList)] == 0} {
		lappend UMRecordsRead($type,$mNumber,cmdList) update
	    }
	    # Store the command and return 0 to indicate that
	    # records not read in yet.
	    addRecordAccessCommand $type $mNumber $callback
	    return 0
	}
    }
    return 1
}

# addRecordAccessCommand
#   Maintains a list of commands that require access to certain
#   records but that were called before required record file was read
#   in
# Arguments
#     type: Type of file such as ANCIL or STASH
#     mNumber: 1,2,3 or 4 for Atmos, ocean etc

proc addRecordAccessCommand {type mNumber callback} {
    global UMRecordsRead
    
    if {[lsearch $UMRecordsRead($type,$mNumber,cmdList) \
	    $callback] == -1} {
	lappend UMRecordsRead($type,$mNumber,cmdList) $callback
    }
}

# repeatRecordAccessCommands
#  Called once file is read in to repeat commands that were called
#  before required file was read in.
# Arguments
#     type: Type of file such as ANCIL or STASH
#     mNumber: 1,2,3 or 4 for Atmos, ocean etc

proc repeatRecordAccessCommands {type mNumber} {
    global UMRecordsRead
    
    # If command list exists then repeat each command in it
    if {[array names UMRecordsRead $type,$mNumber,cmdList] == \
	    "$type,$mNumber,cmdList"} {
	foreach command $UMRecordsRead($type,$mNumber,cmdList) {
	    eval $command
	}
	unset UMRecordsRead($type,$mNumber,cmdList)
    }
}

# readUserFiles
#   Read in user files that overwrite records in master files
# Arguments
#   type: eg STASH or AncilFiles
#   mLetter: Submodel letter
#   errFlag: 1 to display errors, 0 to ignore them

proc readUserFiles {type mLetter errFlag} {

    set mNumber [modletter_to_number $mLetter]

    if {$type == "AncilFiles" || $type == "AncilFields"} {
# ILP User Ancil Files not used
#	setupUser$type $mNumber 0
    } elseif {$type == "STASH"} {
	# Not implemented yet
    }
}
    
