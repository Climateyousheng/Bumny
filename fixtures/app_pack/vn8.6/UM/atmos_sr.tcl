proc check_sr {value variable index} {
    
    # Verification of ATMOS_SR and INDEP_SR
    # Function verifies one element if called with index=-1
    # Verifies all $index elements otherwise
    # For each element, obtains a list from appropriate section index variable
    # and calls compare_list to make a comparison

    set var_info [get_variable_info $variable]
    set help_text [lindex $var_info 10]
    set start_index [lindex $var_info 13]

    set splitvar [split $variable "_"]
    set prefix [lindex $splitvar 0 ]

    set start 3
    set listarray "$prefix\_SI"

    if {$index==-1} {
	set index [get_value [lindex [split $variable "()"] 1]]
    } else {
	# called with index to check but with value set to whole list
	set value [lindex $value $index]
    }
    if {$value==""} {
	error_message .d {Unset option} "The entry `$help_text' has not yet been set." warning 0 {OK}
	return 1
    }

    set list [get_variable_value $listarray\($index\)]
    if {[compare_list $value $list $start]==0} {
 	error_message .d {Unexpected value} "The entry `$help_text' is set to an invalid value. Please reselect from the available list. If you still obtain the error then this is a system error - please report " warning 0 {OK}
	return 1
    }

    # Special Cases: Atmosphere cases first, then Submodel independent
    set atmos [get_variable_value ATMOS]
    if { ($atmos=="T") && ($prefix=="ATMOS") } {
        set retval 0
        set msg {}

	if { $index == 8 || $index == 3 } {
            set bl_type  [get_variable_value BL_TYPE]
            set hyd_type [get_variable_value HYD_TYPE]
            if {$bl_type==0} {
              set bl_type 1 		;# same logical type for cross check
            }
            if { $hyd_type==0 } {
              set hyd_type 1 		;# same logical type for cross check
            }
	    if { $bl_type != $hyd_type } {
		set msg "$msg \nHydrology and Boundary-Layer types need to agree." 
	    }
	}

	if { $index == 19 || $index == 3 || $index == 8 } {
	    set bl_type [get_variable_value BL_TYPE] 
	    if { [get_variable_value ATMOS_SR(19) ] == "0A" } {
		if { $bl_type==4 } {
		    set msg "$msg \nVegetation param scheme must be used with JULES boundary\
			    layer and Hydrology. \n\Correct this and reconsider associated ancillary files." 
		}
	    }
	    if { [get_variable_value ATMOS_SR(19) ] != "0A" } {
		if {  $bl_type!=4  } {
		    set msg "$msg \nVegetation param scheme can only be used with JULES boundary\
			    layer and Hydrology. \n\Correct this and reconsider associated ancillary files." 
		}
	    }
	    set jules [get_variable_value JULES]
	    set atm_vn [get_variable_value ATMOS_SR($index)]

            if { $index=="3" } {
		set j_vn {"9B" "9C" "1A"} 
            } elseif { $index=="8" } {
		set j_vn {"8A"}
            } elseif { $index=="19" } {
                set j_vn {"1B" "2B"}
            }

            set match "FALSE"
            foreach scheme $j_vn {
                if { $scheme == ${atm_vn} } {
                   set match "TRUE"
                   set j_vn $scheme
                break
                }
            }
	    if { $jules=="T" && $match=="FALSE" } {
               set msg "JULES Land Surface Model is currently in use.\n\
	               Please select version $j_vn."
	       set retval 1
            } elseif { $jules=="F" && $match=="TRUE" } {
               set msg "Version <$atm_vn> is only appropriate when JULES Land Surface Model is in use.\n\
	               Please select an alternative."
	       set retval 1
            } 
	}

	if { $index == 3 } {
	    set bl_type [get_variable_value BL_TYPE] 
	    if {$bl_type == 4 && [get_variable_value ES_RAD] != 3} {
		set msg "$msg \nEdwards-Slingo radiation options must be set for SW and \
			LW when using JULES boundary layer"
	    }
	}

	if { ($index == 4) || ($index == 9) } {
            set lspice [get_variable_value LSPICE]
            set lspice_comp [get_variable_value LSPICECOMP]
	    if { $lspice != $lspice_comp } {
		set msg "$msg \nCloud and LS-Rain schemes must both be either mixed-phase compliant or not."
	    }
	}

	if { ($index == 1) || ($index == 2) } {
            set es_rad [get_ES_RAD] 
            set 3d_cca [get_variable_value L3DCCA]
            if { ($3d_cca == "Y") && ( $es_rad != 3 ) } {
                set msg "$msg \nElsewhere, you are asking for Radiative Represenatation \
                for Convective Anvils. \
                You must also use a General 2-Stream radiation (SW & LW)."
            }
	}

	if { $index == 31 } {
	    set ocaaa [get_variable_value OCAAA]
	    set s31 [get_variable_value ATMOS_SR(31)]
	    if { ($ocaaa != 2 && $ocaaa != 3 && $ocaaa != 4) && $s31 != "0A" } {
		set msg "$msg \nSection 31 should be set to 0A for non atmos LAM"
	    } elseif { ($ocaaa == 2 || $ocaaa == 3 && $ocaaa != 4) && $s31 != "1A" } {
		set msg "$msg \nSection 31 should be set to 1A for atmos LAM"
	    }
	}
		
	if { $index == 32 } {
	    set s32 [get_variable_value ATMOS_SR(32)]
	    if { $s32 != "1A"} {
		set msg "$msg \nSection 32 should be set to 1A for atmospheric model"
	    }
	}

	if { ($index == 70) } {
            set clmchfcg  [set_CLMCHFCG] 
            set sv70 [get_variable_value ATMOS_SR(70)]
            set esrad [ get_variable_value ES_RAD ]
            if { ( $clmchfcg==1 || $esrad==2 || $esrad==3)  && ( $sv70=="0A" ) } {
                set msg "$msg \nYour configuration requires the inclusion of \
                Atmospheric section 70 (shared radiation routines). \
                See the help."
            }
	}


        if {($retval != 0) ||($msg!="") } { 	   
           error_message .d {Inconsistent choice} "$msg" warning 0 {OK}
        }
        return $retval
    }

#     if { $index == 72 && ($prefix=="INDEP") } {
#         set i72 [get_variable_value INDEP_SR(72)]
#         set atmos [get_variable_value ATMOS]
#         set ocean [get_variable_value OCEAN]
# 	if { $i72 != "0A"  && ($atmos!="T" || $ocean!="T") } {
# 	    error_message .d {Inconsistent choice} "You must use a null version of the Atmos-Ocean coupling section (72) if not coupling" warning 0 {OK}
# 	    return 1
# 	}
#     }

    if { $index == 96 && ($prefix=="INDEP") } {
        set i96 [get_variable_value INDEP_SR(96)]
	    if { $i96 == "0A" } {
	        error_message .d {Inconsistent choice} "Valid Version must be selected for Section 96 when general MPP machine chosen" warning 0 {OK}
	        return 1
	    }
    }

    return 0
}
		
