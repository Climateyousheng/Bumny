proc check_rp {WIN} {
# Procedure for ensuring default values in Stochastic RP tables 
# are mirrored elsewhere as necessary.
# Function is called ON OPEN and ON CLOSE of RP panel - not needed on
# other panels as mirrored RP variables are not used in processing

   # Mirror Timescale (seconds) for CAPE closure (CONV)
   set caperp [get_variable_value RPCV_DEFS(1)]
   set cape [get_variable_value CAPETSCALE]
   if { $caperp != $cape } {
      set_variable_value RPCV_DEFS(1) $cape
   }   

   # Mirror Critical Humidity on Level 3 (ONLEV)
   set rhc3rp [get_variable_value RPLSP_DEFS(1)]
   set rhcend [get_variable_array ENDLEV_RHC]
   set rhc3 0
   set i 0
   foreach lev $rhcend {
      if {$lev>=3} {
          set rhc3 [lindex [get_variable_array RHC] $i]
          break
      }
      incr i
   }

   if { $rhc3rp != $rhc3 } {
       if { $WIN=="OUT" } {
           incr i
	   set_variable_value RHC($i) $rhc3rp
       } else {
          set_variable_value RPLSP_DEFS(1) $rhc3
       }
   }

   # Mirror Charnock parameter (SSURF)
   set charnrp [get_variable_value RPBL_DEFS(3)]
   set charn [get_variable_value CHARNOCK]
   if { $charnrp != $charn } {
       if { $WIN=="OUT" } {
          set_variable_value CHARNOCK $charnrp
       } else {
          set_variable_value RPBL_DEFS(3) $charn
       }
   }  
 
   # Mirror Critical Froude number default value (GWD)
   set crfrrp [get_variable_value RPGWD_DEFS(1)]
   set crfr [get_variable_value CFNUM]
   if { $crfrrp != $crfr } {
      set_variable_value RPGWD_DEFS(1) $crfr
   }  

   set gwdprp [get_variable_value RPGWD_DEFS(2)]
   set gwdp [get_variable_value SGWCON]
   if { $gwdprp != $gwdp } {
      set_variable_value RPGWD_DEFS(2) $gwdp
   }  

   return 0
}
