proc wn_timpro {} {
    return "[wn_profile_name TIMPRO Time]_Time"
}
proc wn_dompro1 {} {
    return "[wn_profile_name DOMPRO "first (LEVS) panel of Domain"]_Domain"
}
proc wn_dompro2 {} {
    return "[wn_profile_name DOMPRO "PSEUDO panel of Domain"]_Domain2"
}
proc wn_dompro3 {} {
    return "[wn_profile_name DOMPRO "HORIZ panel of Domain"]_Domain3"
}
proc wn_dompro4 {} {
    return "[wn_profile_name DOMPRO "TSERIES panel of Domain"]_Domain4"
}
proc wn_usepro {} {
    return "[wn_profile_name USEPRO Usage]_Usage"
}



proc wn_profile_name {proftype description} {
    global fv_variable_name fv_value fv_index

    # get the submodel
    set bits [split $fv_variable_name "_"]
    set lastbit [lindex $bits [expr [llength $bits]-1]]
    set isubm [string index $lastbit 0]
    
    set profidx $fv_index

    if {$isubm=="A"} {
      set winpref "atmos"
    } elseif {$isubm=="O"} {
      set winpref "ocean"
    } elseif {$isubm=="S"} {
      set winpref "slab"
    } elseif {$isubm=="W"} {
      set winpref "wave"
    } else {
       error "error in wn_profile (tcl). Unknown sub-model. $isubm"
    }

    set profname [get_variable_value $proftype\_$isubm\($profidx\)]
    set location "$description Profile '$profname' (Edit Profile in window $winpref\_STASH)"
    set window "$winpref\_STASH"
    lappend list $location
    lappend list $window
    return $list
}
	


