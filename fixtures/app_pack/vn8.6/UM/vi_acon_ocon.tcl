# acon_ocon
#   Checks active status of elements of ACON, the related variables 
#   AFRE, ATUN and ocean and wave equivalents.
# Arguments
#   variable: Name of variable with or without index - eg ACON(4)
#   call_type: Set to PRELIM when doing a preliminary quick check
#              PRELIM checks are not relevant for these variables.
#   index: Index of variable to check
# Result
#   Return 1 if inactive, 0 if active. Return 2 when called without 
#   index
# Comments
#     Certain groups of ancillary fields must all have the same update
#   or configure options. Grouping is indicated by a mapping array
#   ?_STASHAN. Thus, only one set of questions needs to be answered
#   for each group; the other fields in the group are given the same
#   setup. 
#     Each index of ?_STASHAN is a list. Index 0 of this list is the 
#   UMUI's internal item number which maps onto the item number at 
#   index 2. ACON(x) is active only where the item numbers match. Where
#   they don't match, ACON(x) is inactive and has the implicit value of 
#   the item onto which it is mapped. eg if two elements of A_STASHAN
#   are:
#
# ' 3  34  3 atmos_InFiles_OtherAncil_Orog   {Orog SD            }',
# ' 4  35  3 atmos_InFiles_OtherAncil_Orog   {Orog Grad XX       }',
#
#   Then ACON(3) needs to be set in the UMUI, but ACON(4) is inactive.
#   
#   Where ACON(x) is active, AFRE(x) and ATUN(x) are active only if 
#   ACON(x) is set to "U"; for periodic updating.


proc acon_ocon {variable call_type index} {

    # inactive checking of ACON, AFRE, ATUN 
    # Not checked if index is mapped on to another in A_STASHAN
    # Should be called with index taking account of any start index

    if {($call_type=="PRELIM")&&([regexp {\(|\)} $variable]==0)} {
	# Preliminary check - this function deals with variable element by element
	# so if called from full verification return 2 meaning cannot evaluate yet
	return 2
    }

    set var_info [get_variable_info $variable]
    set help_text [lindex $var_info 10]

    set vname [lindex [split $variable "()"] 0]
    set subm [string index $variable 0 ]

    set map_list [get_variable_value $subm\_STASHAN\($index\)]
    #puts "Checking $variable=$value (index $index) against $map_list"

    if {[lindex $map_list 0]==[lindex $map_list 2]} {set no_blanks "Y"} else {set no_blanks "N"}
    #Special check for item 111:
    if {[lindex $map_list 0] == 111 && [get_variable_value CTILE] != "Y" } {return 1}
    if {$no_blanks=="N"} {
	# Element not in use so end checking (apart from following system check)
	if [regexp {\(|\)} $variable] {
	    # System error - variable is listed being mapped on to another (and so allowed to be blank)
	    # in use but function has been called following window closure
	    error "Unexpected call to function acon_ocon. $variable is listed as not requiring blank checking"
	}
	return 1
    } else {
	# This index is in use 	
	# but AFRE, ATUN, are active only if ACON is "U"
	if {$vname!="$subm\CON"} {
	    set b $subm\CON\($index\)
	    set a [get_variable_value $b]
        #puts "$vname $index =  $b equals $a" 
	    if {$a!="U"} {return 1}
	    #if {[get_variable_value $subm\CON\($index\)]!="U"} {return 1}
	}
	return 0
    }
}
