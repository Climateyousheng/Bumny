# atpp
#   Verifies the ATPP variable which is the number of timesteps per
#   period in the atmosphere (normally a period is a day).
# Comments
#   The maximum is 86400 for a 1 second timestep in a 1 day period.
#   The timestep must also divide into an hour

proc atpp {atpp variable index} {

    set maxTimesteps 86400

    if { $atpp < 1 || $atpp > $maxTimesteps } {
	error_message .d {Range} \
		"Number of timesteps per period is outside range 1,\
		$maxTimesteps" warning 0 {OK}
	return 1
    } 
    set ahpp [get_variable_value AHPP]
    if { [ expr $atpp % ($ahpp *24 )  ] != 0 } { 
	error_message .d {Bad Timestep} \
		"Timesteps must divide into hours" warning 0 {OK}
	return 1
    }
    return 0
}
