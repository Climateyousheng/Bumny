proc job_descr {} {
    # Verification of JOBDESC
    # Removes new line, replaces apostroph simbols, cuts up to 80 chars 

    set value [get_variable_value JOBDESC]

	# Replace apostrophes and new line characters
    set name $value    
	regsub -all ' $name ` name    
    regsub -all "\n" $name "" name
 
    # If job description name has been changed, the variable has to be reset
    if {[string compare $value $name] != 0} {
       set_variable_value JOBDESC $name  
    }
 
    return 0
}
