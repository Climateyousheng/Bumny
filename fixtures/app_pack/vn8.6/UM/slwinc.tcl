# slwinc
#    Verifies LWINC and SWINC (long and short wave radiation
#    increments) set in atmos_Science_Tstep.pan
# comments
#    This must be an integer multiple of the number of timesteps per
#    day -
#    if 48 TS/day (30mins), then SWINC of 30,60,90,120... mins are
#    okay, but 10 and 45 would not be okay.

proc slwinc {slwinc variable index} {

    set atpp [get_variable_value ATPP]
    set ahpp [get_variable_value AHPP]
    set tsperday [expr $atpp / $ahpp]
    
    if { $slwinc < 1} {
        error_message .d {Range} \
          "Radiation increments must be greater than zero" warning 0 {OK}
        return 1
    }
    if { [ expr $tsperday % $slwinc ] != 0 } {
      error_message .d {Bad increment number} \
        "Radiation increments must divide into timesteps per day" warning 0 {OK}
      return 1
    }
    return 0
}
