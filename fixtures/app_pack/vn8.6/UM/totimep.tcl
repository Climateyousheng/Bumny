# totimep.tcl 
#
# Convert times from units of $unit to units of timestep for that
# submodel.
#

# totimep
#   Time $time in units of $unit and must be converted to units of
#   timestep for model $model.
# Arguments
#   time : An integer time
#   unit : Units of time. Can be T for timesteps, H for hours, DA for
#          days or DU for dump periods.

#   model : Letter indicating submodel. Required because different 
#           submodels can have different timesteps and can dump with 
#           different units.
# Example
#   time = 24, units = H, model = A, and the atmosphere has 48
#   timesteps per period (ATPP = 48) in a period of 1 day (days
#   per period AHPP = 1). Then ATPP/(AHPP*24)=2 timesteps per hour.
#   Multiply by time in hours to get 48 timesteps.

proc totimep { time unit model } {
  
  set adump_opt [get_variable_value ADUMP(1)]


  if {$model == "A" } {
      if { $unit == "T" } {
          return $time
      } elseif { $unit == "H" } {
          return [ expr $time * [get_variable_value ATPP] / ( [get_variable_value AHPP] * 24 ) ]
      } elseif { $unit == "DA" } {
          return [ expr $time * [get_variable_value ATPP] / [get_variable_value AHPP] ]
      } elseif { $unit == "RM" } {
          return [ expr 31 * $time * [get_variable_value ATPP] / [get_variable_value AHPP] ]
      } elseif { $unit == "DU" } {
	  # Units of dump period - typically used for climate meaned diagnostics.

      if {$adump_opt == "3"} {
         # ILP for Gregorian Calendar
         set adump [ get_variable_value ADUMPPRM(1)]
         return [ expr $time * $adump * [get_variable_value ATPP] / ( [get_variable_value AHPP] * 24 ) ]
         
      } elseif {$adump_opt == "1"} {
	  # ADUMPP is dump period in units of ADUMPU (T for timesteps, DA for days etc)
          set adump [ get_variable_value ADUMPP(1) ] 
          set adumpu [ get_variable_value ADUMPU(1) ]
          if { $adumpu == "T" } {
             return [ expr $time * $adump ]
          } elseif { $adumpu == "H" } { 
             return [ expr $time * $adump * [get_variable_value ATPP] / ( [get_variable_value AHPP] * 24 ) ]
          } elseif { $adumpu == "DA" } {
             return [ expr $time * $adump * [get_variable_value ATPP] / [get_variable_value AHPP] ]
          } elseif { $adumpu == "RM" } {
             return [ expr 31 * $time * $adump * [get_variable_value ATPP] / [get_variable_value AHPP] ]
          } else  { error "unknown secondary unit in totimep ($adumpu)" }
      } else {
          # No dumping period defined
          error "Time profile Error:
  To use a meaning period of DUMP PERIOD regular frequency dumping is required.  
Please correct either Dumping and Meaning Panel or STASH TimeProfile panel." 
      }        
      } else { error "unknown unit in totimep ($unit)" }
  } else { error "unknown model in totimep ($model)" }
}
