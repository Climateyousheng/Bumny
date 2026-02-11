# 
# js_stash.tcl
#
#   Procedures for creating formatted text output of STASH selections.
#   Output is sent to stream $output_file. Procedure names are obtained from
#   STASH panel control file by the Jobsheet procedure.
#
#   S.D.Mullerworth


# js_stash_*
#   A set of coupling routines to the main output routine. * represents
#   the model letter. Calls js_stash with the appropriate model number.
# Arguments
#   output_file : Stream for output
#   page_width  : Output should be formatted to this width
# Method
#   Arguments are appended to procedure call by the jobsheet procedure.


proc js_stash_a {output_file page_width} {

    if {[get_variable_value ATMOS]!="T"} {return}
    js_stash $output_file $page_width 1 
    return
}


# js_stash
#   Create formatted text output of diagnostics and profile settings and send
#   to $output_file.

proc js_stash {output_file page_width model_number} {

    global stmsta stash_read

    set model_name [modnumber_to_name $model_number]
    set prefix [string tolower $model_name]
    
    if {[info exists stash_read($model_number)]==0} {
	# STASHmaster only needs to be read if it has not been read before

        # load_stash argument==0 prevents output of warning messages
	if {[load_stash 0 $model_number]==1} {
	    error "Error trying to read stashmaster"
	}
        set stash_read($model_number) 1
    }
    puts $output_file "STASH Diagnosic table for $model_name partition\n"
    puts $output_file "-----------------------------------------\n"
    printDiagTable $output_file $model_number
    puts $output_file [solid_divider $page_width]

    print_window $output_file $page_width "$prefix\_STASH_Tags"
    print_window $output_file $page_width "$prefix\_STASH_Time"
    print_window $output_file $page_width "$prefix\_STASH_Domain"
    print_window $output_file $page_width "$prefix\_STASH_Usage"

}

