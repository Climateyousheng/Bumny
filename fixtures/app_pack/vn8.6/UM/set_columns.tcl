###########################################################################
# proc set_id                                                             #
# Procedure to return value to set entry window column to required string #
# Called from nav_save                                                    #
# Arg:                                                                    #
#    col is set to name of a particular column - eg "description".        #
# Suggest use of a switch statement to search for each string and return  #
# an appropriate setting.                                                 #
###########################################################################
proc set_id {col} {
    # get info about job
    switch $col {
	description {return [get_variable_value JOBDESC]}
	atmosphere  {return [set_atmosphere]}
    ocean       {return [set_ocean]}
	slab        {return [set_slab]}    
	mesoscale   {return [set_mesoscale]}
	default     {error "There is no procedure for setting column $col"}
    }
}

proc set_atmosphere {} {
    if {[get_variable_value ATMOS] == "T"} {
	switch [get_variable_value OCAAA] {
	    1 {set atmosphere Global}
	    2 {set atmosphere "Limited Area"}
	    3 {set atmosphere "Limited Area"}
            4 {set atmosphere "Limited Area"}
	    5 {set atmosphere "Single Column"}
	    default {set atmosphere N}
	}
    } else {
	set atmosphere N
    }
    return $atmosphere
}

proc set_ocean {} {
#     if {[get_variable_value OCEAN] == "T"} {
# 	switch [get_variable_value OCAAO] {
# 	    1 {set ocean Global}
# 	    2 {set ocean "Limited Area"}
# 	    default {set ocean N}
# 	}
#     } else {
# 	set ocean N
#     }
#     return $ocean
#    return N
     if {[get_variable_value NEMO] == "T"} {
        set ocean NEMO
     } else {
 	set ocean N
     }
     return $ocean
}

proc set_slab {} {
#     if {[get_variable_value SLAB] == "T"} {
# 	set slab Y
#     } else {
# 	set slab N
#     }
#     return $slab
#    return N  
     if {[get_variable_value CICE] == "T"} {
 	set slab CICE
     } else {
 	set slab N
     }
    return $slab
     
}

proc set_mesoscale {} {
    set atmosphere [set_atmosphere]
    if {$atmosphere == "Limited Area" && [get_variable_value MESO] == "Y"} {
	set mesoscale Y
    } else {
	set mesoscale N
    }
    return $mesoscale
}
