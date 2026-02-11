proc store_A19_L19 { } {
    # Procedure stores incoming values of Atmos (ATMOS_SR(19) and 
    # JULES (JULES_SR(8)) vegetation version selections are the same 
    # to allow correct setting of VEG_TYPE

        set_variable_value ATM19_IN [get_variable_value ATMOS_SR(19)]
        set_variable_value JULES8_IN [get_variable_value JULES_SR(8)]
}
