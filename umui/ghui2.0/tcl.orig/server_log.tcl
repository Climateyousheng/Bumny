# log a message
#
proc server_log text {

  global database_dir

  set fp [open $database_dir/log a]
  puts $fp "[exec date] on $fp: $text"
  close $fp
}


# empty message log
#
proc empty_log {} {

  global database_dir

  set fp [open $database_dir/log w]
  close $fp
}
