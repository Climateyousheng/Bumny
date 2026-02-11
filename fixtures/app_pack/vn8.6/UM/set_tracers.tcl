
proc set_tracers {} {
    # Procedure for setting tracer element of ATMOS_SR which is not set
    # explicitly in window panel but which is dependent on the USE_TCA
    # configuration.  Called on exit from atmos_Config_Tracer

    set use_tca [get_variable_value USE_TCA]

    if {$use_tca=="Y"} {
        # Use prognostic tracers
		    set_variable_value ATMOS_SR(33) "1A"
	} else {
	    # Do not use prognostic tracers
            set_variable_value ATMOS_SR(33) "0A"
	}
	
    # Additional warning that LBC tracers cannot be used with the global model
    set gmodel [get_variable_value OCAAA]
    set lbc [get_variable_value ATMOS_SR(36)]
    
    if {$gmodel!=2 && $lbc=="1A"} {
        # Warning to switch off LBC tracers
	error_message .d {Invalid choice} "LBC tracers cannot be used with the global model. \
	              Please switch off LBC tracers (Section 36)" warning 0 {OK}
        return
    }
}
