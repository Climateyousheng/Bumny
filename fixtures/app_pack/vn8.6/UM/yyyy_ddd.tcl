proc yyyy_ddd {value variable index} {

    set varinf    [get_variable_info $variable]
    set help_text [lindex $varinf 10]

    if { $value == "" } {
	error_message .d {Blank not allowed} "The entry $help_text should contain a date" warning 0 {OK}
	return 1
    } 
    if { [string index $value 4] != "/" } {
	error_message .d {FORMAT} "Use format YYYY/DDD. Slash not found in place. The entry '$help_text' is set to <$value>" warning 0 {OK}
	return 1
    } 
    set code [ scan $value "%4d/%3d" yyyy ddd]
    if { $code != 2 } {
	error_message .d {FORMAT} "Use format YYYY/DDD. Could not parse. The entry '$help_text' is set to <$value>" warning 0 {OK}
	return 1
    }
    set year [exec date +%Y]
    set day [exec date +%j]
    set then 2500
    if { $yyyy < $year || $yyyy > $then } { 
	error_message .d {Bad year} "Set year in range $year to $then. Year in entry '$help_text' is <$yyyy> " warning 0 {OK}
	return 1
    }
    if { $ddd < 1 || $ddd > 365 } { 
	error_message .d {Bad day} "Set day in range 001 to 365. Day in entry '$help_text' is <$ddd>" warning 0 {OK}
	return 1
    }
    if { $yyyy==$year && $ddd<=$day } {
	error_message .d {Bad date} "Date <$yyyy/$ddd> precedes current date of $year/$day in entry '$help_text'" warning 0 {OK}
	return 1
    }
    return 0
}
