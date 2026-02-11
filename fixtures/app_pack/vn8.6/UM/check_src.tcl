proc check_src {value variable index optional} {
# This procedure ensures that user source code path names end with /src
  if {$index != -1} {set value [get_variable_value $variable\($index\) ] }
  set var_info [get_variable_info $variable]
  set help_text [lindex $var_info 10]

  if {$value=="" && $optional!="OPT" } { 
    error_message .d {No Value Given} "No value for \"$help_text\". \n\
           This is not an optional setting" warning 0 {OK}
    return 1
  }
  
  if {$value!=""} {
        if {$variable=="FCM_USRBRN_VAL" || $variable=="FCM_CMSCR_VAL" } {
	  # Must start with svn: or fcm:um with no spaces
	  if {(([string equal -length 4 $value fcm:]==0)&&([string equal -length 4 $value svn:]==0))||([llength $value]>1)} {
	      error_message .d {Path Name Error} "The entry `$help_text' must begin 'svn:' or 'fcm:' \
	                                        and contain no spaces, but is \"$value\"" warning 0 {OK}
	      return 1
          }	
	} else {
	  # Must start with ~ / or $. Must not contain spaces
	  if {([regexp {[\/\$\~]} [string index $value 0]]==0)||([llength $value]>1)} {
	      error_message .d {Path Name Error} "The entry `$help_text' must contain a valid \
	                                        path, but is \"$value\"" warning 0 {OK}
	      return 1
	  }
	}
	set src "\/src"
	set ind [expr [string length $value] -4]
	if {[string first $src $value $ind]==-1} {
	    error_message .d {Path Name Error} "The entry `$help_text' must end with '\/src'. \
	                                        Please amend before continuing" warning 0 {OK}
	    return 1
        }
  }
  return 0
}
