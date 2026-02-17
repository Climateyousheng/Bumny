# Searches the server directory for .exp files. For each experiment
# the experiment information is extracted. The experiment list is
# updated with a sorted list.
#
proc read_all_experiments {} {

  global database_dir experiments

  # log activity
  server_log "Reading experiment details..."

  set exps {}

  # search for all local experiments
  foreach filename [glob -nocomplain $database_dir/*.exp] {

    # extract the id and add to list
    set id [string range $filename \
      [expr [string last / $filename] + 1] \
      [expr [string last .exp $filename] - 1]]
    lappend exps $id

    # read the experiment info
    read_experiment_info $id
  }

  # sort the experiment list
  set experiments(list) [lsort $exps]

  server_log "...[llength $exps] experiments read."
}


# Reads the summary info for an experiment and creates an associated array.
#
proc read_experiment_info id {

  global database_dir experiments

  # read experiment description file (pairs of field and value lines)
  set fp [open $database_dir/$id.exp r]
  while {[gets $fp field] != -1} {
    if {[gets $fp value] == -1} {
      error "Premature end to description file for experiment $id."
    }
    # update array
    set experiments($id,$field) $value
  }
  set experiments($id) 1
  close $fp
}


# Reads summary information for every job from .job files.
# A list of all jobs is kept, in alphabetical order in the experiment array.
# If the directory for an experiment does not exist, then it is created.
#
proc read_all_jobs {} {

  global job_count experiments

  # initialise job_count
  set job_count 0

  # log activity
  server_log "Reading job details..."

  # loop through each experiment reading job info
  foreach exp_id $experiments(list) {
    read_exp_jobs $exp_id
  }
  server_log "...$job_count jobs read."
}


# Read job info for each job in a geven experiment
# update the experiment info at the end.
#
proc read_exp_jobs exp_id {

  global database_dir job_count experiments

  set joblist {}

  # create experiment directory if it doesn't exist.
  if {! [file exists $database_dir/$exp_id]} {
    exec mkdir $database_dir/$exp_id
    exec chmod a+rwx,go-w $database_dir/$exp_id
  } else {

    # search for all local experiments
    foreach filename [glob -nocomplain $database_dir/$exp_id/*.job] {

      # increment number of jobs
      incr job_count
      if {[expr $job_count % 500] == 0} {
	server_log "...read $job_count jobs so far..."
      }

      # extract id of .job files and add to list
      set id [string range $filename \
        [expr [string last / $filename] + 1] \
        [expr [string last .job $filename] - 1]]
      lappend joblist $id

      # read the job info
      read_job_info $exp_id $id
    }
  }

  # sort the job list and store in experiment array
  set experiments($exp_id,joblist) [lsort $joblist]

  # reform experiment details and save to disk
#  update_exp_details $exp_id
}


# Reads the summary info for an job and creates an associated array.
#
proc read_job_info {exp_id job_id} {

  global database_dir jobs

  # read job description file (pairs of field and value lines)
  set fp [open $database_dir/$exp_id/$job_id.job r]
  while {[gets $fp field] != -1} {
    if {[gets $fp value] == -1} {
      error "Premature end to description file for \
             experiment $exp_id, job $job_id."
    }
    # update job array
    set jobs($exp_id$job_id,$field) $value
  }
  set jobs($exp_id$job_id) 1
  close $fp
}


