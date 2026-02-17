# Save details of experiments and jobs to disk.
# Required details depend on specifications in the application
# definition file.

# Save experiment details to .exp file. Create job directory if it
# doesn't exist already.
#
proc save_experiment_details id {

  global database_dir exp_fields exp_field_defaults
  global experiments

  # write experiment description file (pairs of field and value lines).
  set fp [open $database_dir/$id.exp w]
  foreach field $exp_fields {
    if {$field != "jobs"} {
      if {! [info exists experiments($id,$field)]} {
        set fieldval {}
      } else {
	set fieldval $experiments($id,$field)
      }
      puts $fp ${field}\n$fieldval
    }
  }
  close $fp
  exec chmod a+rw-x,go-w $database_dir/$id.exp

  # create job directory if needed.
  if {! [file exists $database_dir/$id]} {
    exec mkdir $database_dir/$id
    exec chmod a+rwx,go-w $database_dir/$id
  }
}


# Save job details to .job file.
#
proc save_job_details {exp_id job_id} {

    global database_dir job_fields job_field_defaults
    global jobs

    # write job description file (pairs of field and value lines).
    set fName $database_dir/$exp_id/$job_id
    set fp [open $fName.job w]
    foreach field $job_fields {
	if {! [info exists jobs($exp_id$job_id,$field)]} {
	    set fieldval {}
	} else {
	    set fieldval $jobs($exp_id$job_id,$field)
	}
	puts $fp ${field}\n$fieldval
    }
    close $fp
    file attributes $fName.job -permissions 00644

    # create empty job file if there isn't one
    if {! [file exists $fName] && ! [file exists $fName.gz]} {
	set f [open $fName w]
	close $f
	file attributes $fName -permissions 00644
    }
}


# Check that a user can write to an experiment
#
proc check_exp_permissions {id user} {

  global experiments base_dir

  # user is owner of installation ie Superuser
  #if {[file owned $base_dir]} {return}

  # check user against experiment owner
  if [string match $experiments($id,owner) $user] {
    return
  }

  # check user against access list users
  foreach al_user $experiments($id,access_list) {
    if [string match $al_user $user] {
      return
    }
  }

  # no matches means no access.
  error "User $user does not have permission to alter experiment $id."
}
