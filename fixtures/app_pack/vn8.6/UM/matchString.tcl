#==============================================================================
# RCS Header:
#   File         [$Source: /home/hc0300/umui/srce_code/UMUI_archive/umui2.0/vn7.6/UM/matchString.tcl,v $]
#   Revision     [$Revision: 1.1 $]     Named [$Name: head#main $]
#   Last checkin [$Date: 2010/02/02 17:05:29 $]
#   Author       [$Author: umui $]
#==============================================================================

# matchString.tcl

#   Contains routines for non-generic testing of string inputs.
#   Objects in the variable register will use these routines as
#   their check functions.
#     Called from the verification routines of the GHUI.
#   S.D.Mullerworth 24/09/01

# regexpMatch
#    Matches input value against supplied match string using regexp 
#    function and returns result.
# Arguments
#    value: Value of variable
#    variable: Name of variable and possible array index
#    index: right-most array index. Set to -1 for non-list variables
#    match: string to match against
#    description: Description of match for use in errors

proc regexpMatch {value variable index match description} {

    set result [regexp $match $value]

    set varInfo [get_variable_info $variable]
    set helpText [lindex $varInfo 10]

    if {$result == 0} {
	error_message .d {Incorrect input} "The entry '$helpText' must \
		comprise $description" warning 0 OK
	return 1
    }
    return 0
}
  
