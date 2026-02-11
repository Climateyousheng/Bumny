
# jobsheet_title

#   Application specific routine required to add a title page to the
#   jobsheet. It may optionally move the jobsheet file from the
#   default location 
#     $env(HOME)/[get_variable_value JOB_OUTPUT]/JS_$expid$jobid
#   to some other location such as the processing directory. Use
#   the Tcl "file rename" command to do this:
# 
#   file rename $env(HOME)/[get_variable_value JOB_OUTPUT]/JS_$expid$jobid \
#        $env(HOME)/[get_variable_value JOB_OUTPUT]/$expid$jobid/JOBSHEET

proc jobsheet_title {width} {

    global env version

    set desc [get_variable_value JOBDESC]
    set job_id [get_variable_value JOB_ID]
    set exp_id [get_variable_value EXPT_ID]

    # Move jobsheet file into job library and rename it
    set output_dir $env(HOME)/[get_variable_value JOB_OUTPUT]
    file rename -force $output_dir/JS_$exp_id$job_id $output_dir/$exp_id$job_id/JOBSHEET

    set hw [expr $width/2]

    if {[get_variable_value ATMOS] == "T"} {
	switch [get_variable_value OCAAA] {
	    1 {set atmos Global}
	    2 {set atmos "Limited Area"}
            3 {set atmos "Limited Area"}
            4 {set atmos "Limited Area"}
	    5 {set atmos "Single Column"}
	    default {set atmos No}
	}
    } else {
	set atmos No
    }

    if {$atmos == "Limited Area" && [get_variable_value MESO] == "Y"} {
	set meso Yes
    } else {
	set meso No
    }

    append page [print_line [list "UM Jobsheet for Experiment and Job ID $exp_id$job_id"] $width]
    append page [divider $width]
    append page [print_line [list "$desc"] $width]
    append page [divider [string length $desc]]
    append page "\n"
    append page [print_line [list "UM Version [get_variable_value VERSION]" "UMUI Version $version"] \
	    [list $hw $hw]]
    append page [print_line [list "Atmosphere" $atmos] [list $hw $hw]]
    append page [print_line [list "Mesoscale" $meso] [list $hw $hw]]
    append page "\n"

    append page [solid_divider $width]

    return $page
}
