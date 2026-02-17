# personal_setup
#   Read and apply personal preferences file when job is created or
#   copied from another user. Files are called
#   $HOME/.${app}${version}rc
# Arguments
#   app: Name of application 

proc personal_setup {app version} {
    global env

    set a [open $env(HOME)/.$app${version}rc]

    foreach line [split [read $a] \n] {
	
	set var [lindex $line 0]
	if {[string index $var 0]=="#"} {continue}
	if {$var==""} {continue}

	# Remove the variable name and spaces (note: using lrange 1 end causes
	# {} braces to be added to strings with $'s in them).

	# Protect parenthesis if substituting element of array.
	regsub {\(} $var {\\(} varsub
	regsub {\)} $varsub {\\)} varsub

	regsub $varsub $line "" value
	set value [remove_end_spaces $value]

	regsub ' $value ` value
	if [catch {set_variable_value $var $value} a] {
	    # Error in rc file - return
	    return $a
	}
    }
    return "ok"
}

