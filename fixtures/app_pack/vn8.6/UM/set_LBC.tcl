#==============================================================================
# RCS Header:
#   File         [$Source: /home/hc0300/umui/srce_code/UMUI_archive/umui2.0/vn7.6/UM/set_LBC.tcl,v $]
#   Revision     [$Revision: 1.1 $]     Named [$Name: head#main $]
#   Last checkin [$Date: 2010/02/02 17:05:29 $]
#   Author       [$Author: umui $]
#==============================================================================
proc set_LBC {} {
    # Procedure for setting LBC elements of ATMOS_SR which are not set
    # explicitly in window panels but which are dependent on the atmosphere
    # configuration.  Called on exit from atmos_InFiles_OtherAncil_LBC

    set ocaaa [get_variable_value OCAAA]
    set atmos [get_variable_value ATMOS]

    if {$atmos=="T"} {
	if {$ocaaa==2 || $ocaaa==3 || $ocaaa==4} {
	    # Atmosphere LAM
	    set_variable_value ATMOS_SR(31) "1A"
	} else {
	    # Other Atmosphere configuration
            set_variable_value ATMOS_SR(31) "0A"
	}
	set_variable_value ATMOS_SR(32) "1A"
    } else {
	set_variable_value ATMOS_SR(31) "0A"
	set_variable_value ATMOS_SR(32) "0A"
    }
}
