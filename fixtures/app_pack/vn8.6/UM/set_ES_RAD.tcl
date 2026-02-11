#
# set_ES_RAD.tcl
#
# Procedures for setting variable ES_RAD .Is this Edwards-Slingo radiation
# 0 neither.  1 SW only.   2 LW only.  3 Both E-S

proc set_ES_RAD {} {
    set_variable_value ES_RAD [get_ES_RAD]
}


# get_ES_RAD
# This procedure is called from vi_sulp_rad in addition to above

proc get_ES_RAD {} {

    set sw_sr [get_variable_value ATMOS_SR(1)] 
    set lw_sr [get_variable_value ATMOS_SR(2)] 

    if {$sw_sr == "0A"} {
      set sw_es 0 
    } elseif {($sw_sr == "3Z")} {
      set sw_es 1
    } elseif { $sw_sr=="" } {
      set sw_es 0
    } else {
	if {[check_variable_value ATMOS_SR(1) $sw_sr scalar -1 2]!=1} {
	    error "Error in proc set_ES_RAD. Unknown SW_RAD version $sw_sr"
	} else {
	    set sw_es 0
	}
    }

    if {$lw_sr == "0A"} {
      set lw_es 0 
    } elseif {($lw_sr == "3Z")} {
      set lw_es 2
    } elseif {$lw_sr == ""} {
      set lw_es 0
    } else {
	if {[check_variable_value ATMOS_SR(2) $lw_sr scalar -1 2]!=1} {
	    error "Error in proc set_ES_RAD. Unknown LW_RAD version $lw_sr"
	} else {
	    set lw_es 0
	}
    }

    set es_rad [ expr $sw_es + $lw_es ]
    return $es_rad 
}
