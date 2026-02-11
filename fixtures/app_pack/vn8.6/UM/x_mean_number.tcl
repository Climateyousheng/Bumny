proc x_mean_number {model_index} {
    # Calculate the number of meaning periods for cases ADUMP(x)=1 and 3.
    # Set to zero otherwise.

    set sm_index [get_variable_value MODEL_PARTITION($model_index) ]

    set xdump [get_variable_value ADUMP($sm_index)] 

    if {$xdump==0} {
        set x_mean_number 0
    } elseif {$xdump==1} {  
        if {[get_variable_value AMEAN($sm_index)]=="Y"} {      
	    set x_mean_number [get_variable_value ANMP($sm_index)]
        } else {
	    set x_mean_number 0
	}
    } elseif {$xdump==3} {  
        if {[get_variable_value AMEAN($sm_index)]=="Y"} {     
            set x_mean_number [get_variable_value ANMPRM($sm_index)]
        } else {
	    set x_mean_number 0
	}
    } elseif {$xdump==2} {
	    set x_mean_number 0
    } else {
	    set x_mean_number 0
    }

    return $x_mean_number

}

