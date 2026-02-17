proc convert_justification {text} {

  switch -exact $text {
    L {return w}
    l {return w}
    R {return e}
    r {return e}
  }
  error "Invalid justification encountered: $text"
}


proc convert_orientation {text} {

  switch -exact $text {
    H {return left}
    h {return left}
    V {return top}
    v {return top}
  }
  error "Invalid orientation encountered: $text"
}

######################################################################
# proc convert_expression                                            #
# Originally case statements had funny syntax which was converted    #
# by this proc into an expression that could be evaluated by [expr]  #
# Now it should return an expression that can be evaluated by the    #
# eval_logic command                                                 #
######################################################################

proc convert_expression {text} {

    if {[lindex $text 0]=="active"} {
	# Expression refers to inactive logic of variable register
	# get the contents and return with a ! to give active status
	# Note - will not work with functions
	set variable [lindex $text 1]
    	set vi [lindex [get_variable_info $variable] 7]
	set last_colon [string last ":" $vi]
	set vi [string range $vi [expr $last_colon+1] end]
    	return "!\($vi\)"
    }
        

    regsub -all " " $text "" text
    return \($text\)
}
