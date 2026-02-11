# Expands environment variable $HOME for MACH_NAME 
# if env variable does not exists, returns unexpanded value
# Later on a function could be written which gets value of
# any environment variable. Test function for SCM model

proc expand_homedir {vardir} {

   set lst_path [file split $vardir]
   set first [lindex $lst_path 0]
   set new_p ""
      
   if {[string equal $first "\$HOME"]==1} {
      set ls_host [get_variable_value MACH_NAME]  
      set uid [get_variable_value USERID]
      
      set a [eval [list exec ssh $uid@$ls_host env]]
      foreach item $a {
         if {[string equal -length 5 $item "HOME="]} {
            set homedir [string range $item 5 end]  
            set lst_path [lreplace $lst_path 0 0 $homedir]

            foreach elm $lst_path {
               set new_p [file join $new_p $elm]
            }
            return $new_p
         }
      }
   }
   return $vardir
}
