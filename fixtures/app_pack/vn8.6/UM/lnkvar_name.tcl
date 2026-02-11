proc lnkvar_name {value variable index} {
    #  This is a verification function.
    #  this procedure checks variable LNK_NM_NEMO or LNK_NM_CICE to make sure 
    #  that there are no repeats.
   
    # Run check only when called the first time
    if {$index!=1} {return 0}

    set count 0
    set ev_list [lsort -ascii $value]
    
    foreach name $ev_list {
	   incr count
	   if { $count == 1 } {
	    set lastname $name
	   } else {
	       if { $name != "" && $name == $lastname } {
		      error_message .d {Bad Name} "The variable named <$name> is duplicated in table." warning 0 {OK}
		      return 1
		   }
	}
	set lastname $name
    }
    return 0
}
