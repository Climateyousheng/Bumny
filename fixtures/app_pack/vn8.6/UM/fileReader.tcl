#
# smallUtilities.tcl
#
# Additional small scripts used by recordFiles that might be of wider
# use.
#

namespace eval FileReader {
    namespace export FRopenFile
    namespace export FRcloseFile
    namespace export FRnextLine
    namespace export FRnextNonBlankLine
    namespace export FRgetLineNumber
}


# FRopenFile
#   Opens file for reading and initialises a line count

proc ::FileReader::FRopenFile {fileName} {
    variable fileReader

    set f [open $fileName]

    set fileReader($f,lineNo) 0
    return $f
}

# FRnextLine
#   Reads file and returns next line ignoring empty lines 
#   or comments. 
# Results
#   Returns valid contents of next valid line or blank if end of file
# Arguments
#   f: id for file
# Comments
#   Much quicker than FRnextNonBlankLine but does not spot lines that
#   contain spaces only

proc ::FileReader::FRnextLine {f} {
    variable fileReader

    # Read line and increment line number
    gets $f l1
    incr fileReader($f,lineNo)

    # Loop till non blank line found or till end of file
    while {[string index $l1 0] == "#" || $l1 == ""} {

	# Return "" at end of file
	if {[gets $f l1] == -1} {return ""}
	incr fileReader($f,lineNo)

    }
    return $l1
}

# FRnextNonBlankLine
#   Reads file and returns next line ignoring those that contain only 
#   whitespace or comments. Removes whitespace, including tabs, from 
#   start and end of line. 
# Results
#   Returns valid contents of next valid line or blank if end of file
# Arguments
#   f: id for file

proc ::FileReader::FRnextNonBlankLine {f} {
    variable fileReader

    set l1 ""

    # Loop till non blank line found or till end of file
    while {$l1 == ""} {

	# Read line and increment line number
	set l [gets $f line]

	# Return blank on end of file
	if {$l == -1} {return ""}
	incr fileReader($f,lineNo)

	# Truncate comments
	set l1 [lindex [split $line #] 0]

	# Remove spaces and tabs from beginning and end of string
	# (both square brackets below contain a space and a tab)
	regsub -all "^\[ 	\]*|\[ 	\]*$" $l1 "" l1
    }
    return $l1
}

# FRgetLineNumber 
#  Returns current line number of file reader

proc ::FileReader::FRgetLineNumber {f} {
    variable fileReader
    return $fileReader($f,lineNo)
}

# FRcloseFile
#  Close file and clean up

proc ::FileReader::FRcloseFile {f} {
    variable fileReader
    close $f
    unset fileReader($f,lineNo)
}

# test_getNextLine
#   Test procedure for getNextLine that outputs all valid lines in 
#   a given file

proc test_getNextLine {file} {
    set f [open $file]

    set l1 "initial"

    while {$l1 != ""} {
    
	set l1 [getNextLine $f]
	puts "Line $l1"
    }
    close $f
}

