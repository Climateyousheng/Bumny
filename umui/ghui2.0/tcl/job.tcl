# The object for a job
#


# constructor
#
proc job {id args} {

  global job_fields job_field_defaults

  # create object
  dp_objectCreateProc job $id

  # set defaults for each slot
  foreach field $job_fields {
    dp_objectSlotSet $id $field $job_field_defaults($field)
  }

  # evaluate any arguments
  eval $id configure $args

  return $id
}


# destructor
#
proc job.destroy id {
  dp_objectFree $id
}


# slot value
#
proc job.slot-value {id slot} {
  dp_objectSlot $id $slot
}


# configure
#
proc job.configure {id args} {
  eval dp_objectConfigure job $id $args
}
