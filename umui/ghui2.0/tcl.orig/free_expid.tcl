
# getExperimentInitial
#   Ask user for the initial letter for new experiments
# Arguments
#   bannedList: List of letters that should not be selected

proc getExperimentInitial {{bannedList ""}} {
    global expIdInfo

    set text $expIdInfo(text)
    set expInitial [getId "Experiment Initial" $text $bannedList]
    if {$expInitial == "NONE"} {
	# This causes the calling program also to return
	return -code return
    } else {
	return $expInitial
    }
}
    
# getExpInitialDetails
#   Reads details about setting of experiment initial letter from 
#   application definition file
# Arguments
#   f: File ID
#   app: Name of app (if error message needs to be produced

proc getExpInitialDetails {f app} {
    global expIdInfo

    set expIdInfo(text) ""

    while {[lindex [set line [gets $f]] 0] != "END"} {
	 lappend expIdInfo(text) [lindex $line 0]
    }
}
   



# Find the next free experiment id
#

proc next_exp_id initial {

  global experiments

  # check initial is valid
  if {! [string match {[a-z]} $initial]} {
    error "Bad initial letter $initial for experiment id. Must be a-z."
  }

  # find highest free id by scanning through existing id.
  # handily, the experiments are sorted alphabetically
  set free [numerate_expid ${initial}aaa]
  set last [numerate_expid ${initial}zzz]
  foreach id $experiments(list) {
    set this [numerate_expid $id]
    # break loop if we have gone past the end of valid range
    if {$this > $last} {
      break
    }
    if {$this >= $free} {
      set free [expr $this + 1]
      if {$free > $last} {
        error "No more experiment ids free for inital letter $initial."
      }
    }
  }

  return [literate_expid $free]
}


# Turn an experiment id into a number by treating it as base 26
#
proc numerate_expid id {

  scan $id %c%c%c%c ascii1 ascii2 ascii3 ascii4
  return [expr (($ascii1 - 97) * 17576) + \
               (($ascii2 - 97) * 676) + \
               (($ascii3 - 97) * 26) + \
               ($ascii4 - 97)]
}


# Turn a number into an experiment id by treating is as base 26
#
proc literate_expid num {

  set id [format %c [expr ($num / 17576) + 97]]
  append id [format %c [expr (($num % 17576) / 676) + 97]]
  append id [format %c [expr (($num % 676) / 26) + 97]]
  append id [format %c [expr ($num % 26) + 97]]
  return $id
}
