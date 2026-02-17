proc block_start {real indentation} {

  global win in_block block_count block_indentation in_invis case_no_i cases
  global block_nest

   if $real {
    incr in_block
    lappend block_nest $indentation
  } 
  set block_indentation [lindex $block_nest $in_block]
  incr block_count
  if $in_invis {
    set c [lindex $cases($case_no_i) 6].$block_count
  } else {
    set c $win.$block_count
  }
  frame $c
  frame $c.l
  frame $c.r
  pack $c -side top -padx 2m -fill x
  pack $c.l -side left
  pack $c.r -side left
}


proc block_end {} {

  global in_block block_nest

  if {! $in_block} {
    error ".blockend encountered without .block"
  }

  incr in_block -1
  set block_nest [lrange $block_nest 0 $in_block]
  block_start 0 0
}
