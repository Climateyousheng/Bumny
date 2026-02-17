# Set globals that list the fields describing experiments and jobs.
#
proc read_field_info {} {

    global exp_fields exp_field_defaults job_fields job_field_defaults titles

    # experiment fields
    set exp_fields {}
    set job_fields {}
    # Experiments have no need for the "opened" field or the "id" field
    foreach field $titles(all_columns) {
	puts "field_info: $field"
	if {$field != "opened" && $field != "id"} {lappend exp_fields $field}
    }
    set job_fields {}
    # Jobs have no need for the "owner", "access_list", "id" or "privacy" field
    foreach field $titles(all_columns) {
	if {$field != "owner" && $field != "access_list" && $field != "id" && $field != "privacy"} {lappend job_fields $field}
    }
}
