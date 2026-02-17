#################################################################
# proc set_help                                                 #
# Called by new_window script to set name of window's help file #
#################################################################

proc set_help {panel_name} {

    global help_names win

    set help_names($win) $panel_name
}

#################################################################
# proc toplev_name                                              #
# Takes a window name and returns name of toplevel parent       #
# Used where toplevel relates to a file name                    #
#################################################################

proc toplev_name {child} {
    for {set i 1} {$i<[string length $child]&&[string index $child $i]!="."} {incr i} {}
    return [string range $child 0 [expr $i-1]]
}
    
#################################################################
# Routines to couple to the display_help procedure              #
# window_help is called when window help buttons pressed        #
# nav_help can be used in nav.buttons file                      #
#################################################################

proc window_help {window_file} {
    set file_name $window_file
    set title "Help for window : $file_name"
    show_help $file_name $title
}

proc window_help_active_status {window_file} {
    # Returns 0 if help file does not exist
    set help_file [help_file $window_file]
    if {! [file readable $help_file]} {
	return 0
    }
    return 1
}    

proc nav_help {file_name} {
    set title "Help for Navigation Buttons"
    show_help $file_name $title
}

proc ghui_nav_help {file_name} {
    set title "Help for Navigation Buttons"
    set path [ghui_version_dir help]
    application_help $file_name $title $path
}
    
proc application_help {file_name title {path ""}} {
    
    if {$path==""} {set path [directory_path help]}
    if {[string range $file_name [expr [string length $file_name]-5] end]!=".help"} {
	set file_name $file_name.help
    }
    # Prevent "." characters in filename getting into window name
    regsub -all {\.} $file_name _ winname
    set win .$winname\_help
    display_help $path/$file_name $win $title $path
}    
    

#################################################################
# proc show_help                                                #
# Called with filename and title for a help window              #
#################################################################

proc show_help {file_name title} {
    set help_file [help_file $file_name]
    set path [directory_path help]

    # Prevent "." characters in filename getting into window name
    regsub -all {\.} $file_name _ winname
    set win .$winname\_help
    display_help $help_file $win $title $path
}

#########################################################################
# proc display_help                                                     #
# Displays help in a top-level window with scroll bars and close button #
# On closing, returns focus to original point                           #
#########################################################################

proc display_help {help_file win title path} {

    global font_help font_butons
    
    if {! [file readable $help_file]} {
	dialog .warning "Help file does not exist" "The help file \"$help_file\" does not exist. You should contact the GHUI administration team." {} 0 {OK}
	return
    }

    if {[info commands $win] == $win} {
	# Help has already been opened - bring to top
	wm iconify $win
	wm deiconify $win
	return
    }

    # Get help text and remove blank lines from end
    set hf [open $help_file r]
    set text [split [read $hf] \n]
    set text [remove_blank_lines $text]
    close $hf

    # Include any .inc help text files
    set text [include_help_text $text $path]

    # Make any text substitutions if required
    set text [text_substitutes $text]

    set text [join $text \n]
    textToWindow $win $text $title

}

#####################################################################################
# proc include_help_text                                                            #
# Called with list of help text - inserts any include file text                     #
#####################################################################################

proc include_help_text {text path} {

    set include 1
    set output {}
    set count 1
    while {$include==1} {
	# Do repeatedly to include .inc files within .inc files
	set include 0
	set output {}
	foreach line $text {
            if {[string range $line 0 1]=="\%I"} {
		set inc_file [help_include_file [lindex $line 1] $path]
		set hf [open $inc_file r]
		set inc_text [split [read $hf] \n]
		set inc_text [remove_blank_lines $inc_text]
		close $hf
		set output [concat $output $inc_text]
		set include 1
	    } else {
		lappend output $line
	    }
	}
	set text $output
	if {[llength $text]>500} {
	    dialog .help {Too much help} "More than 500 lines of help is not allowed. Possible recursion of include files? Please check and reduce" {} 0 {OK}
	    set include 0
	}
    }
    return $text
}

#########################################################################
# proc text_substitutes                                                 #
# Looks for substitutions in text and makes them                        #
#########################################################################     

proc text_substitutes {text} {
    
    foreach line $text {
	if {[string range $line 0 1]=="\%S"} {
	    # Add a new substitution to the list
	    set var [lindex $line 1]
	    set val [lindex $line 2]
	    set sub($var) $val
	} else {
	    if {[regexp % $line] && [info exists sub]} {
		# Make substitutions if required
		foreach name [array names sub] {
		    set string "\%$name\[^A-Za-z0-9_\]"
		    if [regexp $string $line] {
			set line [text_replace "$line" $name $sub($name)]
		    }
		}
	    }
	    lappend output $line
	}
    }
    return $output
}

####################################################################
# proc text_replace                                                #
# Does a regsub -all but does not replace if the %name is followed #
# by a letter or number. Could not think of a way for testing      #
# before substitution just using regsub and regexp                 #
####################################################################

proc text_replace {line name sub} {

    set new_line ""
    while {[set p [string first \%$name $line]]!=-1} {
	set end [expr $p+[string length $name]+1]
	set ch [string index $line $end]

	append new_line [string range $line 0 [expr $p - 1]]
	if {[regexp {[^A-Za-z0-9_]} $ch]||$ch==""} {
	    # Make substitution
	    append new_line $sub
	    if {$ch=="\\"} {
		# a \ has been used to protect a following character - ignore it
		incr end
	    }
	} else {
	    # name is followed by a letter or number - this is part of another name
	    append new_line [string range $line $p [expr $end-1]]
	}
	set line [string range $line $end end]
    }
    append new_line $line
    return $new_line
}

################################################################################
# proc remove_blank_lines                                                      #
# Removes blank lines from end of text                                         #
################################################################################

proc remove_blank_lines {text} {
    
    
    set i [llength $text]
    
    
    while { ([lindex $text [expr $i-1] ]=="") && ($i>0) } {
	incr i -1
    }

    return [lrange $text 0 $i]
}

