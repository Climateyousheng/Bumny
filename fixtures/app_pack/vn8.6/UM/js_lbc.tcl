#########################################################################
# proc js_lbc                                                           #
# Jobsheet function for atmos_Control_OutputData_LBC windows            #
# Dependent on output choices variable SECTFL                           #
#########################################################################
proc js_lbc {output_file page_width} {

    if {[get_variable_value SECTFL]=="N"} {return}

    # Output preamble to say which streams active
    # then output windows
    puts $output_file "Generating Lateral Boundary Tendencies"
    puts $output_file "--------------------------------------\n"
    for {set i 1} {$i<=[get_variable_value NMLAP]} {incr i} {
	if {[get_variable_value OCBILA($i)]==1} {
	    puts $output_file "Stream $i is active"
	} else {
	    puts $output_file "Stream $i is not active"
	}
    }
    puts $output_file "--------------------------------------\n"
    for {set i 1} {$i<=[get_variable_value NMLAP]} {incr i} {
	if {[get_variable_value OCBILA($i)]==1} {
	    set_variable_value OCBMLA $i
	    # Window LBC3 is output via a .pushsequence command in LBC2
	    print_window $output_file $page_width "atmos_Control_OutputData_LBC2"
	}    
    }
}
