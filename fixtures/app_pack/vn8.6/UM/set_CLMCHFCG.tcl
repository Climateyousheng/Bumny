proc set_CLMCHFCG {} {
  # Complex text for a logical "L_CLMCHFCG" in cntlatm.
  # This is also used in cross-cheking for section 70.
  set co2opt [get_variable_value CO2OPT ]
  set esr [get_variable_value ES_RAD ]
  set lw2meth [get_variable_value LW2METHABS]
  set lw2nox [get_variable_value LW2NOXABS]
  set lw2c11 [get_variable_value LW2CFC11ABS]
  set lw2c12 [get_variable_value LW2CFC12ABS]
  set lw2c113 [get_variable_value LW2CFC113ABS]
  set lw2c114 [get_variable_value LW2CFC114ABS]  
  set lw2hc22 [get_variable_value LW2HCFC22ABS]
  set lw2hfc125 [get_variable_value LW2HFC125ABS]
  set lw2hfc134 [get_variable_value LW2HFC134AABS]
  if { ($co2opt==2) || \
        ( ( $esr==2 || $esr==3 ) && \
          ($lw2meth=="C" || $lw2nox =="C" || $lw2c11=="C" || \
           $lw2c12=="C"  || $lw2c113=="C" || $lw2c114=="C" || \
           $lw2hc22=="C" || $lw2hfc125=="C" || $lw2hfc134=="C") ) } {
     return 1
  } else {
     return 0
  }

}
