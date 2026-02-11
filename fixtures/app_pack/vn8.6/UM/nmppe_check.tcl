proc nmppe_check {value variable index} {

    # Checks value of NMPPE (No. of E-W processors)
    # Value should be 1 or an even number up to 144

    set nmppe $value
    set help_text "The number of East-West processors must be \
                   1 or an even number between 2 and 144."
    set halfnmppe [expr $nmppe /2.0]
    set inthalnmppe [expr int($halfnmppe)]
    
    if {($value >= 2) && ($value <= 144) && ($halfnmppe == $inthalnmppe) \
       || ($value == 1)} {
       return 0
    } else {
       error_message .d {Invalid Choice} $help_text warning 0 {OK}
    }
}
