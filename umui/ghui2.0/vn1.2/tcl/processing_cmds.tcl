# processing_cmds.tcl
# 
#     Contains a set of Tcl procedures that are used in processing 
#     control files. Some procs send output to the job library 
#     file using the put procedure. Others return values for use
#     in Tcl logical tests etc.
#
#------------------------------------------------------------------
#
# if_active
#     Called with variable name. Output first value if variable
#     is active. Otherwise output second value
#
# Arguments
#     Variable    : A GHUI application variable with optional index
#     OnVal       : Output value if variable active. Or if set to
#                   VALUE, the variable value itself.
#     OffVal      : Default value
# Method
#     The reason for using VALUE as the OnVal rather than %VARNAME
#     is that if VARNAME is an unset REAL then processing will fail
#     when it tries to substitute.

proc if_active {Variable OnVal OffVal} {
    upvar out_fd out_fd

    set Inactive [inactive_var $Variable]
    if { $Inactive == 0 } {
	if {$OnVal == "VALUE"} {
	    put [get_variable_value $Variable]
	} else {
	    put $OnVal
	}
    } else {
	put $OffVal
    }
}

# inactive_var
#    Returns inactive status of variable - either 0 for active, or 1. 
#    Error occurs if active status not known (eg for an array without 
#    an index)
# Arguments
#    Variable: A GHUI application variable with optional index

proc inactive_var {Variable} {
    set Inactive [active_status $Variable]
    if { $Inactive!=1 && $Inactive!=0 } {
	error "Unable to obtaining active status of $Variable when executing \[active_var $Variable\]"
    }
    return $Inactive
}

proc put {string} {

  upvar out_fd out_fd

  puts -nonewline $out_fd $string
}

proc putl {string} {

  upvar out_fd out_fd

  puts $out_fd $string
}

proc pad {var} {

  set parts [split $var {(),}]
  set numparts [llength $parts]
  set varinfo [get_variable_info $var]
  set type [lindex $varinfo 3]

  if {($numparts == 1 && [lindex $varinfo 2] == 0) || $numparts == 3 || \
      ($numparts == 4 && \
      [lindex $parts 1] != "*" && [lindex $parts 2] != "*")} {
    if {$type == "REAL"} {
      return [format %[lindex $varinfo 11] [get_variable_value $var]]
    } elseif {$type == "STRING"} {
      return [format %-[lindex $varinfo 4]s [get_variable_value $var]]
    } else {
      return [get_variable_value $var]
    }
  } else {
    if {$type == "REAL"} {
      return [format_each %[lindex $varinfo 11] [get_variable_array $var]]
    } elseif {$type == "STRING"} {
      return [format_each %-[lindex $varinfo 4]s [get_variable_array $var]]
    } else {
      return [get_variable_array $var]
    }
  }
}

proc padp {var} {

  upvar out_fd out_fd

  puts -nonewline $out_fd [pad $var]
}

proc padpq {var} {

  upvar out_fd out_fd

  puts -nonewline $out_fd \"[pad $var]\"
}

proc padpqc {var} {

  upvar out_fd out_fd

  puts -nonewline $out_fd \"[pad $var]\",
}

proc delimit {values separator surround} {

  upvar out_fd out_fd

  set last [expr [llength $values] - 1]
  for {set i 0} {$i < $last} {incr i} {
    puts -nonewline $out_fd $surround[lindex $values $i]$surround$separator
  }
  puts -nonewline $out_fd $surround[lindex $values $last]$surround
}

proc tdelimit {values separator surround} {

  upvar out_fd out_fd

  set j 30
  set last [expr [llength $values] - 1]
  for {set i 0} {$i < $last} {incr i} {
    set str $surround[lindex $values $i]$surround$separator
    set len [string length $str]
    incr j $len
    if {$j > 79} {
      puts -nonewline $out_fd "\n "
      set j [expr $len + 1]
    }
    puts -nonewline $out_fd $str
  }
  set str $surround[lindex $values $last]$surround
  if {[expr $j + [string length $str]] > 79} {
    puts -nonewline $out_fd "\n "
  }
  puts -nonewline $out_fd $str
}

proc replacep {var args} {

  upvar out_fd out_fd

  eval put \[replace $var $args\]
}

proc replace {var args} {

  set len [llength $args]
  if {[expr {$len % 2}] != 0} {
    error "Wrong number of arguments to replace."
  }
  
  set parts [split $var {(),}]
  set numparts [llength $parts]
  set varinfo [get_variable_info $var]

  if {($numparts == 1 && [lindex $varinfo 2] == 0) || $numparts == 3 || \
      ($numparts == 4 && \
      [lindex $parts 1] != "*" && [lindex $parts 2] != "*")} {
    return [substitute $var [get_variable_value $var] $args]
  } else {
    set result {}
    foreach value [get_variable_array $var] {
      lappend result [substitute $var $value $args]
    }
    return $result
  }
}

proc substitute {var value matches} {

  set varinfo [get_variable_info $var]
  set type [lindex $varinfo 3]
  for {set i 0} {$i < [llength $matches]} {incr i 2} {
    if {[lindex $matches $i] == "*"} {
      return [lindex $matches [expr $i + 1]]
    }
    if {$type == "REAL" || $type == "INT"} {
      if {$value == [lindex $matches $i]} {
        return [lindex $matches [expr $i + 1]]
      }
    } else {
      if {[string compare $value [lindex $matches $i]] == 0} {
        return [lindex $matches [expr $i + 1]]
      }
    }
  }
  set patterns {}
  for {set i 0} {$i < [llength $matches]} {incr i 2} {
    lappend patterns [lindex $matches $i]
  }
  set winid [ lindex [get_variable_info $var] 5]
  if { $value != "" } {
      error "$var has a value of \"$value\", but should be one of the following:\
	      \"$patterns\". Its needs to be set in window \"$winid\"."
  } else {
      error "$var is unset. It needs to be set in window \"$winid\" to one of the following:\
	      \"$patterns\""
  }
}

proc format_each {spec values} {

  set result {}
  foreach value $values {
    lappend result [format $spec $value]
  }
  return $result
}


###################################################################
# proc format_if_needed                                           #
# Called from c when var listed as VAR_$suffix\(1); ie with a tcl #
# variable within. In these situations, C code cannot determine   #
# format or whether variable or array because it cannot decipher  #
# variable until script is evaluated. This routine is called      #
# during this evaluation                                          #
###################################################################

proc format_if_needed {var} {
    
    set var_info [get_variable_info $var]
    set type "%[lindex $var_info 3]"

    # Do not know whether it is a variable or an array
    set val [get_var_or_array $var]

    if {$type=="REAL"} {
	set form [lindex $var_info 11]
	return [format_each $form $val]
    } else {
	return $val
    }
}

proc get_var_or_array {var} {
    
    if [catch {set val [get_variable_value $var]} ] {
	set val [get_variable_array $var]
    }
    return $val
}

proc is_value_blank spec {

  set varinf [get_variable_info $spec]
  set blank [lindex $varinf 1]
  set type [lindex $varinf 3]

  set value [get_variable_value $spec]

  if {$value == "" || \
      (($type == "REAL" || $type == "INT") && \
       [string compare $value $blank] == 0)} {
    return 1
  }
  return 0
}
