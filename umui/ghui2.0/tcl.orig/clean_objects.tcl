# unset the fields in the experiments array associated with a 
# particular experiment exp_id.
#
proc clean_expt {exp_id} {

  global experiments exp_fields

  # unset the experiment exp_id and the joblist of the expt
  unset experiments($exp_id)
  unset experiments($exp_id,joblist)

  # loop over fields in experiment array, unset-ing as we go
  foreach field $exp_fields {
    catch {unset experiments($exp_id,$field)}
  }

  # remove exp_id from list
  set listidx [lsearch $experiments(list) $exp_id]
  set list [lreplace $experiments(list) $listidx $listidx]
  set experiments(list) $list
}

# unset the fields in an the jobs list for a particular expt
# also removes the job_id from the experiments($id,joblist)
#
proc clean_job { exp_id job_id } {

  global jobs job_fields experiments

  # unset the experiment id
  unset jobs($exp_id$job_id)

  # loop over fields in jobs array, unset-ing as we go
  foreach field $job_fields {
    catch {unset jobs($exp_id$job_id,$field)}
  }

  # remove job_id from experiments list
  set listidx [lsearch $experiments($exp_id,joblist) $job_id]
  set list [lreplace $experiments($exp_id,joblist) $listidx $listidx]
  set experiments($exp_id,joblist) $list
}
