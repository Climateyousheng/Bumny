proc read_sm_rec { fileid  call_type} {

    #+
    # NAME: 
    # SYNOPSIS: This is the proc thatv reads one record of a
    # STASHmaster format file and passes variables back up a level
    # using upvar. The variable names are assumed at the higher
    # level. The all start sm_rec_
    #   
    # ARGS: fileid defines the file to be read.
    # TREE: called from user-progs and read_stash
    # GLOBAL VARIABLES:
    # AUTHOR: MC
    #-

    set status incomplete
    set line_saught 1

    while { $status == "incomplete" } {
      set icode [ gets $fileid line($line_saught) ]
      if { $icode == -1 } {
          # unexpected EOF found
          return "Error: unexpected end of file on STASHmaster file."
      }
      set firstchar  [ string range $line($line_saught) 0 0 ]
      if { ($firstchar != "#") && ($firstchar != "H") && ($firstchar != $line_saught) } {
          # unexpected first character
          return "Error: STASHmaster format incorrect. Expecting comment,\
          header or line $line_saught of a record. Got <$firstchar> in line <$line($line_saught)>."
      } elseif {$firstchar == $line_saught} {
        if { $line_saught == 5 } {
           set status complete
        } else {
           incr line_saught
        }
      }  
    }
    upvar sm_rec_model model
    upvar sm_rec_sec   sec   
    upvar sm_rec_item  item 
    upvar sm_rec_name  name 
    upvar sm_rec_space space
    upvar sm_rec_point point
    upvar sm_rec_time  time 
    upvar sm_rec_grid  grid 
    upvar sm_rec_levT  levT 
    upvar sm_rec_levF  levF 
    upvar sm_rec_levL  levL 
    upvar sm_rec_pseudT  pseudT
    upvar sm_rec_pseudF  pseudF
    upvar sm_rec_pseudL  pseudL
    upvar sm_rec_levcom  levcom 
    upvar sm_rec_option  option
    upvar sm_rec_version version
    upvar sm_rec_halo    halo
    
    set ret [scan $line(1) "1|%5d |%5d |%5d |%36s|" \
        model sec item name ]
    set name [ string range $line(1) 23 58 ] 
    # puts "$model $sec $item $name "
    if { $ret != 4 } { 
          return "Error: STASHmaster format incorrect.\
          Line $line(1) could not be parsed."
    }

    set ret [scan $line(2) "2|%5d |%5d |%5d |%5d |%5d\
        |%5d |%5d |%5d |%5d |%5d |%5d |" \
        space point time grid levT levF levL pseudT pseudF pseudL levcom  ]
    # puts "$space $point $time $grid $levT $levF $levL $pseudT $pseudF $pseudT $levcom" 
    if { $ret != 11 } { 
           return "Error: STASHmaster format incorrect.\
          Line $line(2) could not be parsed."
    }

#    set ret [scan $line(3) "3| %20s | %20s |%5d |" 
    set ret [scan $line(3) "3| %30s | %20s |%5d |" \
        option version halo]
    set option "S$option"
    # puts "$option $version " 

    if { $ret != 3 } { 
          return "Error: STASHmaster format incorrect.\
          Line $line(3) could not be parsed."
    }


   if { $call_type == "check" } {

     upvar sm_rec_t        t
     upvar sm_rec_dmpp     dmpp
     upvar sm_rec_pack     pack
     upvar sm_rec_r        r
     upvar sm_rec_ppfc     ppfc
     upvar sm_rec_user     user
     upvar sm_rec_lbvc     lbvc
     upvar sm_rec_blev     blev
     upvar sm_rec_tlev     tlev
     upvar sm_rec_rlbv     rlbv
     upvar sm_rec_cfll     cfll
     upvar sm_rec_cfff     cfff

     set ret [scan $line(4) "4|%5d |%5d\
         |%4d %4d %4d %4d %4d %4d %4d %4d %4d %4d |" \
         t dmpp\
         pack(1) pack(2) pack(3) pack(4) pack(5)\
         pack(6) pack(7) pack(8) pack(9) pack(10)]
    
     if { $ret != 12 } { 
           return "Error: STASHmaster format incorrect.\
           Line $line(4) could not be parsed."
     }

    
     set ret [scan $line(5) "5|%5d |%5d |%5d |%5d |%5d |%5d |%5d |%5d |%5d |" \
         r ppfc user lbvc blev tlev rlbv cfll cfff ]
    
     if { $ret != 9 } { 
           return "Error: STASHmaster format incorrect.\
           Line $line(5) could not be parsed."
     }

     # check positions of bars.
     set bars(1) { 1 8 15 22 59 } 
     set bars(2) { 1 8 15 22 29 36 43 50 57 64 71 78 } 
     set bars(3) { 1 34 57 64 } 
     set bars(4) { 1 8 15 66 } 
     set bars(5) { 1 8 15 22 29 36 43 50 57 64 } 
     for { set l 1 } { $l <= 5 } { incr l } {
       foreach pos $bars($l) {
         set found [ string index $line($l) $pos ]
         if { $found != "|" } {
            set col [expr $pos + 1 ]
            return "Parsing error on line: $line($l).   Vertical bar out of \
                    place.   Should be one at column $col.   Found <$found> in \
                    vicinity of \
                    <[ string range $line($l) [ expr $pos-2] [ expr $pos+2] ]>"
         }
       }
     } ; # endfor { set l 1 } { $l <= 5 } { incr l }

   } ; # endif { $call_type == "check" }

  return OK
}
