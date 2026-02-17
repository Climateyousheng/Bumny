#########################################################################
# proc active_status                                                    #
# Called with variable name and an index. Gets active status expr from  #
# variable register. If it's a function, return result of PRELIM call   #
# (which will be 0 or 1, or 2 if cannot evaluate yet                    # 
# If it's an expression then evaluates and returns 0 or 1, or 3 if      #
# cannot evaluate (ie if vindex is unset and needs a value              #
#########################################################################

proc active_status {variable} {
    # returns    0 if NEVER or if variable active in these circumstances
    #            1 if blank allowed in these circumstances
    #            2 if FN:
    #            1 if ALWAYS - always inactive - only likely when called from:
    #            proc partition_info - proc um_nav_full_verify
    #            3 if expression is a function of N and vindex not set

    set vindex     [lindex [split $variable "()"] 1]

    # Remove * if variable is 2 dimensional ie A(x,*) or A(*,x)
    regsub {\*,} $vindex {} vindex
    regsub {,\*} $vindex {} vindex

    set var_info [get_variable_info $variable]
    set var_inactive [lindex $var_info 7]
    set vi_list [split $var_inactive :]

    # If a function exists, make preliminary call and return result
    if {[set n [lsearch -exact $vi_list FN]] !=-1 } {
	set active_function [lindex $vi_list [expr $n+1]]
 	# Make preliminary call to function - Function will return 1 or 0 if blank 
 	# rule applies to whole list, or 2 if rule is index dependent (in which case
 	# function will be called once for each element during loop)
 	return [$active_function $variable "PRELIM" $vindex]  
    }

    # Get last element of list which will be inactive rule
    set var_inactive [lindex $vi_list [expr [llength $vi_list]-1]]

    if {($vindex!="")||([regexp {\(N\)} $var_inactive]==0)} { 
    # var_inactive is not a function of N; can evaluate and return result
	regsub -all {\(N\)} $var_inactive "\($vindex\)" var_inactive
	return [eval_logic $var_inactive]
    } else {
	return 3
    }
}

################################################################################
# proc eval_logic                                                              #
# Evaluate logic expression involving ghui variables and return result         #
# Expression may be ALWAYS or NEVER                                            #
################################################################################

proc eval_logic {expression} {
    if {$expression=="ALWAYS"} {
	return 1
    }
    if {$expression=="NEVER"} {
	return 0
    }
    eval set result \[evaluate_expression $expression\]
    return $result
}

##################################################################################
# proc active_element                                                            #
# called with blank=1 if value is blank                                          #
#             vi_expr=0,1,2 or 3 set to what preceding call to active_status     #
#                      returned                                                  #
#             gt1 is 1 if this is part of a list and index >=1, otherwise 0      #
#                   only used for GT1 determinations                             #
#             vindex is main index of 2D array or index+start_index of 1D arrays #
##################################################################################

proc active_element {variable blank vi_expr gt1 vindex} {
    # Returns 0 blank not allowed - error will have been output if required
    #         1 inactive: blank allowed
    #         2 active, but allowed to be blank

    set var_info [get_variable_info $variable]
    set var_inactive [lindex $var_info 7]

    if {$vi_expr==0} {
	# Element is active unless GT1: rule applies and element is blank 
	if {$gt1&&([regexp "GT1:" $var_inactive])&&($blank)} {return 1}
	return 0
    }

    if {$vi_expr==1} {
	# Inactive - no further check required
	return 1
    }

    if {$vi_expr==2} {
	# Function call - next two lines parse out string following FN:
	set n [lsearch [set vi_list [split $var_inactive :]] FN]
	set active_function [lindex $vi_list [expr $n+1]]
	return [$active_function $variable 0 $vindex]
    }

    # if neither 0,1 or 2, then must be 3 meaning an expression which is a
    # function of N 

    set last_colon [string last ":" $var_inactive]
    set var_inactive [string range $var_inactive [expr $last_colon+1] end]

    regsub -all {\(N\)} $var_inactive "\($vindex\)" var_inactive
    return [evaluate_expression $var_inactive]
}
