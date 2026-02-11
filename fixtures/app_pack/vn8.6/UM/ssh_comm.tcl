proc get_passwd {host user {title ""} {text ""}} {
   global passwd_win

   set win .w

   if {$title == ""} {set title "Enter Password"}
   if {$text == ""} {set text "$title for user $user on host $host"}

   set passwd_win ""
   get_passwd_win $win $host $user $title $text
   tkwait window $win

   return $passwd_win
}

proc get_passwd_win {win host user title text} {

   if {$win == "."} {
      set ww .passwd_win
      catch {destroy $ww}
      frame $ww
      pack $ww
   } else {
      set ww $win
      catch {destroy $ww}
      toplevel $ww
   }
   wm title $win $title

   frame $ww.passwd -bd 8
   pack $ww.passwd -side top

   label $ww.label -text $text
   entry $ww.entry -textvariable passwd_win -relief sunken -show "*"
   pack $ww.label $ww.entry -expand yes -fill x -side top -in $ww.passwd

   frame $ww.buttons -bd 8
   pack $ww.buttons -side top -fill x

   button $ww.ok -text "  OK  " -command "destroy $win"
   button $ww.cancel -text "Cancel" -command "set passwd_win 1 ; destroy $win"
   pack $ww.ok $ww.cancel -in $ww.buttons -side left -expand yes

   focus $ww.entry
   bind $ww.entry <Return> "destroy $win"
}

proc get_yesno {text} {
   global yesno_win

   set win .yn

   set yesno_win ""
   get_yesno_win $win $text
   tkwait window $win

   return $yesno_win
}

proc get_yesno_win {win text} {

   catch {destroy $win}
   toplevel $win
   wm title $win "Answer Yes or No"

   frame $win.yesno -bd 8
   pack $win.yesno -side top

   label $win.label -text $text -justify left
   pack $win.label -expand yes -fill x -side top -in $win.yesno

   frame $win.buttons -bd 8
   pack $win.buttons -side top -fill x

   button $win.yes -text "Yes " -command "set yesno_win yes ; destroy $win"
   button $win.no -text " No " -command "set yesno_win no ; destroy $win"
   pack $win.yes $win.no -in $win.buttons -side left -expand yes
}

proc run_spawn {win host user spawn_comm} {

   global passwd passph env win_exists pwstatus ppstatus

   set out ""
   set err ""

   if {! [info exist pwstatus($host,$user)]} {
      set pwstatus($host,$user) unset
   } elseif {$pwstatus($host,$user) == "set"} {
      set pwstatus($host,$user) correct
   }
   if {! [info exist ppstatus]} {
      set ppstatus unset
   } elseif {$ppstatus == "set"} {
      set ppstatus correct
   }

   if {[info exists env(UMUI_SSH_TIMEOUT)]} {
      set timeout $env(UMUI_SSH_TIMEOUT)
   } else {
      set timeout 90
   }

   if {[info exists env(UMUI_SSH_LOGFILE)]} {
      if {$env(UMUI_SSH_LOGFILE) == ""} {
         log_file
      } else {
         log_file $env(UMUI_SSH_LOGFILE)
      }
   } else {
      log_file
   }

   if {$win != "" && [winfo exists $win]} {
      set win_exists true
   } else {
      set win_exists false
   }
   #if {$win_exists && [winfo class $win] == "Text"} {
   #   match_max -d 40
   #} else {
   #   match_max -d 2000
   #}

   #exp_internal 1

   eval spawn $spawn_comm

   expect {
      -re "ermission denied.*please try again" {
         set pwstatus($host,$user) incorrect
         win_output $win "$host: Permission denied, please try again"
         exp_continue
      } -ex "Password: " {
         if {$ppstatus == "set"} {
            set ppstatus incorrect
         }
         if {$pwstatus($host,$user) != "correct"} {
            set passwd($host,$user) [get_passwd $host $user]
            #set passwd($host,$user) [get_passwd $host $user "" "Enter Password:"]
            if {$passwd($host,$user) == 1} {
               set pwstatus($host,$user) unset
               set out "Cancelled ssh command to $host"
               win_output $win "\n" 2
               win_output $win $out
               close
               wait
               return $out
            }
            set pwstatus($host,$user) set
         }
         exp_send "$passwd($host,$user)\r"
         exp_continue
      } "assword: " {
         if {$ppstatus == "set"} {
            set ppstatus incorrect
         }
         regexp -line {^(.*)@(.*)'s password:} $expect_out(buffer) match user host
         if {! [info exist pwstatus($host,$user)]} {
            set pwstatus($host,$user) unset
         }
         if {$pwstatus($host,$user) != "correct"} {
            set passwd($host,$user) [get_passwd $host $user]
            if {$passwd($host,$user) == 1} {
               set pwstatus($host,$user) unset
               set out "Cancelled ssh command to $host"
               win_output $win "\n" 2
               win_output $win $out
               close
               wait
               return $out
            }
            set pwstatus($host,$user) set
         }
         exp_send "$passwd($host,$user)\r"
         exp_continue
      } "assphrase for key*: " {
         if {$ppstatus != "correct"} {
            #set passph [get_passwd $host $user "Enter Passphrase"]
            set passph [get_passwd $host $user "Enter Passphrase" $expect_out(buffer)]
            if {$passph == 1} {
               set ppstatus unset
               set out "Cancelled ssh command to $host"
               win_output $win "\n" 2
               win_output $win $out
               close
               wait
               return $out
            }
            set ppstatus set
         }
         exp_send "$passph\r"
         exp_continue
      } "ASSCODE:" {
         set passcode [get_passwd $host $user "Enter PASSCODE"]
         if {$passcode == 1} {
            set out "Cancelled ssh command to $host"
            win_output $win "\n" 2
            win_output $win $out
            close
            wait
            return $out
         }
         exp_send "$passcode\r"
         exp_continue
      } "okencode :" {
         set passcode [get_passwd $host $user "Enter the next tokencode" \
	    "Wait for the tokencode to change, then enter the new tokencode"]
         if {$passcode == 1} {
            set out "Cancelled ssh command to $host"
            win_output $win "\n" 2
            win_output $win $out
            close
            wait
            return $out
         }
         exp_send "$passcode\r"
         exp_continue
      } "onnection closed" {
         set err "Connection closed by $host"
         win_output $win $err
         close
      } "service* not known" {
         set err "$host: node name or service name not known"
         win_output $win $err
         close
      } timeout {
         set err "Timed out, $host not responding"
         win_output $win $err
         close
      } "ermission denied" {
         if {$pwstatus($host,$user) == "set"} {
            set pwstatus($host,$user) incorrect
         }
         if {$ppstatus == "set"} {
            set ppstatus incorrect
         }
         set err "$host: Permission denied"
         win_output $win $err
         close
      } "uthentication failure" {
         if {$pwstatus($host,$user) == "set"} {
            set pwstatus($host,$user) incorrect
         }
         if {$ppstatus == "set"} {
            set ppstatus incorrect
         }
         set err "$host: Too many authentication failures for $user"
         win_output $win $err
         close
      } "lost connection" {
         set err "$host: lost connection"
         win_output $win $err
         close
      } "*he authenticity of host*" {
         regexp -line {^.*host '(.*) \(} $expect_out(buffer) match host
         set answer [get_yesno $expect_out(0,string)]
         exp_send "$answer\r"
         if {$answer == "yes"} {
            win_output $win "Permanently added $host to the list of known hosts"
            exp_continue
         } else {
            set err "$host: Host key verification failed"
            win_output $win $err
            close
         }
      } "arning: Permanently added*" {
         exp_continue
      } "Your password has expired*" {
         set err "Your password has expired for account $user, please ssh to $host and update it"
         $win configure -text $err
         close
      } -re ":-- ETA$" {
         if {$pwstatus($host,$user) == "set"} {
            set pwstatus($host,$user) correct
         }
         if {$ppstatus == "set"} {
            set ppstatus correct
         }
         set out "${out}$expect_out(buffer)"
         exp_continue
      } "\n" {
	 #puts "XX: [string map {\r 0 \n 1} $expect_out(buffer)]"
         if {$expect_out(buffer) != "\r\n"} {
            if {$pwstatus($host,$user) == "set"} {
               set pwstatus($host,$user) correct
            }
            if {$ppstatus == "set"} {
               set ppstatus correct
            }
	 }
         win_output $win $expect_out(buffer) 2
         set out "${out}$expect_out(buffer)"
         exp_continue
      } full_buffer {
         if {$pwstatus($host,$user) == "set"} {
            set pwstatus($host,$user) correct
         }
         if {$ppstatus == "set"} {
            set ppstatus correct
         }
         win_output $win $expect_out(buffer) 2
         set out "${out}$expect_out(buffer)"
         exp_continue
      } eof {
         win_output $win $expect_out(buffer) 2
         set out "${out}$expect_out(buffer)"
      }
   }
   win_output $win "\n" 2
   wait

   if {$err != ""} {
      error $err
   } else {
      return $out
   }
}

proc run_ssh {win host user comm {extraopt ""}} {
   global env

   if {[info exists env(UMUI_SSH_DEBUG_LEVEL)]} {
      set dbg_lev $env(UMUI_SSH_DEBUG_LEVEL)
   } else {
      set dbg_lev 0
   }

   if {$dbg_lev == 0} {
      log_user 0
      set spawn_comm "-noecho ssh -o LogLevel=ERROR $extraopt -l $user $host $comm"
   } elseif {$dbg_lev == 1} {
      log_user 1
      set spawn_comm "ssh -o LogLevel=ERROR $extraopt -l $user $host $comm"
   } elseif {$dbg_lev == 2} {
      log_user 1
      set spawn_comm "ssh $extraopt -l $user $host $comm"
   } elseif {$dbg_lev == 3} {
      log_user 1
      set spawn_comm "ssh -v $extraopt -l $user $host $comm"
   } elseif {$dbg_lev == 4} {
      log_user 1
      set spawn_comm "ssh -vv $extraopt -l $user $host $comm"
   } elseif {$dbg_lev > 4} {
      log_user 1
      set spawn_comm "ssh -vvv $extraopt -l $user $host $comm"
   }

   set ret [run_spawn $win $host $user $spawn_comm]

   return $ret
}

proc run_scp_put {win host user sourcefile targetfile {extraopt ""}} {
   global env

   if {[info exists env(UMUI_SSH_DEBUG_LEVEL)]} {
      set dbg_lev $env(UMUI_SSH_DEBUG_LEVEL)
   } else {
      set dbg_lev 0
   }

   if {$dbg_lev == 0} {
      log_user 0
      set spawn_comm "-noecho scp -q -o LogLevel=ERROR $extraopt $sourcefile $user@$host:$targetfile"
   } elseif {$dbg_lev == 1} {
      log_user 1
      set spawn_comm "scp -q -o LogLevel=ERROR $extraopt $sourcefile $user@$host:$targetfile"
   } elseif {$dbg_lev == 2} {
      log_user 1
      set spawn_comm "scp $extraopt $sourcefile $user@$host:$targetfile"
   } elseif {$dbg_lev == 3} {
      log_user 1
      set spawn_comm "scp -v $extraopt $sourcefile $user@$host:$targetfile"
   } elseif {$dbg_lev == 4} {
      log_user 1
      set spawn_comm "scp -vv $extraopt $sourcefile $user@$host:$targetfile"
   } elseif {$dbg_lev > 4} {
      log_user 1
      set spawn_comm "scp -vvv $extraopt $sourcefile $user@$host:$targetfile"
   }

   set ret [run_spawn $win $host $user $spawn_comm]

   return $ret
}

proc win_output {win text {output_type 1}} {

#  output_type = 1 - Output to Message widget if exists else to Text widget
#  output_type = 2 - Output to Text widget only

   global win_exists
   
   if {! $win_exists} return

   set class [winfo class $win]

   if {$class == "Text"} {
      if {$output_type == 2} {
         regsub -all "\r" $text "" text1
         $win insert end $text1
      } else {
         $win insert end $text
      }
      if {$output_type == 1} {$win insert end "\n"}
      $win see end
   } elseif {$class == "Message"} {
      if {$output_type == 2} return
      $win configure -text $text
   }
}
