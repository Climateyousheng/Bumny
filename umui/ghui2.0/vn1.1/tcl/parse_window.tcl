# Read a window definiton and convert it into a tcl script.

proc parse_window {file_name window_name} {

    global parser_line parser_line_preread
    global parser_fpanel parser_fskeleton parser_fin parser_script
    global parser_winid parser_title
    global parser_inskeleton parser_skeleton_open parser_include_open parser_subs

    # reset globals
    set parser_winid ""
    set parser_title ""
    set parser_inskeleton 0
    set parser_skeleton_open 0
    set parser_script ""
    set parser_include_open 0
    set parser_subs {}

    # open files
    set parser_fpanel [open $file_name r]

    # read a line at a time, starting with main panel file
    set parser_fin $parser_fpanel
    set parser_line_preread 0

    while {(! [eof $parser_fin]) || $parser_line_preread} {
	if {! $parser_line_preread} {
	    #gets $parser_fin parser_line
	    set parser_line [get_a_line $parser_fin]
	}
	set parser_line_preread 0
	#if $parser_include_open {
	    # Reading a .include file - make substitutions if required
	 #   set parser_line [make_substitutions $parser_line]
	#}
	parse_line $window_name
    }

    # close file
    close $parser_fpanel
}

# Read a line and make substitutions if required
proc get_a_line {file} {
    global parser_include_open parser_subs errorInfo
    gets $file line
    if $parser_include_open {
	# Reading a .include file - make substitutions if required
	set line [make_substitutions $line $parser_subs]
    }

    # Tcl8.0 does not like lists such as [list aa bb "cc".] - a list
    # element in quotes must be followed by a space. The following 
    # checks for errors which are more than likely to be caused by
    # fullstops at the end of .comment lines.
    if [catch {lindex $line 0}] {
	error "$errorInfo \nfound while parsing line \n$line\n"
    }

    return $line
}

proc make_substitutions {line subs} {
    set i 0
    # Replace any %[number] with the appropriate number .include argument
    while {$i<[llength $subs]} {
	set sub [lindex $subs $i]
	regsub -all %[incr i] $line $sub line
    }
    return $line
}

proc parse_line {window_name} {

    global parser_line parser_winid parser_title

    # Tcl8.0 does not like lists such as [list aa bb "cc".] - a list
    # element in quotes must be followed by a space. The following 
    # line prevents errors which are more than likely to be caused by
    # quote-fullstops at the end of .comment eg 
    #    .comment input "a" or "b".

    regsub -all \" $parser_line ' p

    switch -exact [lindex $p 0] {
        .comment {}
	.function {}
        .set_on_closure {}
	.loop {}
	.winid {set parser_winid [lindex $parser_line 1]}
	.title {set parser_title [lindex $parser_line 1]}
	.procs {parse_procs}
	.wintype {parse_wintype [lindex $parser_line 1]}
	.openwin {open_window $window_name}
        .closewin {close_window}
	.include {parse_include}
	.include_begin {parse_incbegin [lindex $parser_line 1]}
	.include_end {parse_incend}
	.skeleton {parse_skeleton}
	.skelend {parse_skelend}
	.top {}
	.topend {}
	.mid {}
	.midend {}
	.bottom {}
	.bottomend {}
	.panel {parse_panel}
	.panend {parse_panend}
	.text {parse_single_line text_component}
	.textw {parse_single_line text_component}
	.textj {}
	.textd {parse_single_line text_component}
	.gap {parse_single_line gap_component}
	.basrad {parse_basrad}
	.case {parse_case case_start}
	.caseend {parse_single_line case_end}
	.colour {parse_colour colour_start}
	.colourend {parse_single_line colour_end}
	.invisible {parse_case invisible_start}
	.invisend {parse_single_line invisible_end}
	.pushquit {parse_single_line pushquit_component}
	.pushclose {parse_single_line pushclose_component}
	.pushnext {parse_single_line pushnext_component}
	.pushsequence {parse_single_line pushnext_component}
	.pushand {parse_single_line pushand_component}
	.pushhelp {parse_single_line pushhelp_component}
        .pushbutton {parse_single_line pushbutton_component}
	.block {parse_block}
	.blockend {parse_single_line block_end}
	.entry {parse_single_line entry_component}
	.file_entry {parse_single_line file_entry_component}
	.file_table {parse_file_table}
	.check {parse_single_line check_component}
	.table {parse_table}
	.tableend {parse_single_line tableEnd}
	.super {parse_single_line tableSuper}
	.superend {parse_single_line tableSuperend}
	.element {parse_single_line tableElement}
	.elementautonum {parse_single_line tableElementautonum}
	.index {parse_single_line tableIndexed}
	.help {parse_single_line set_help}
	.init {parse_single_line init_var}
	"" {}
	default {
	    error "Parse error: expected component, got:\n  $parser_line"
	}
    }
}

proc parse_wintype {name} {

    global parser_inskeleton parser_fin parser_fskeleton parser_skeleton_open

    if $parser_inskeleton {
	error "Parse error: can't have .wintype in skeleton"
    }
    set skel [skeletons_file $name]
    set parser_fskeleton [open $skel r]
    set parser_skeleton_open 1
    set parser_fin $parser_fskeleton
}

proc open_window {window_name} {
    global parser_script parser_winid parser_title

    append parser_script "new_window $parser_winid \"$parser_title\" \{\n"

    # Incorporate variables into parser_script

    append parser_script "global window_name\n"
    append parser_script "set window_name $window_name\n"
}

proc close_window {} {
    global parser_script
    append parser_script {end_of_window}
    append parser_script \n\}\n

}

# Include file requested. Open file, set flag and point parser at top of file

proc parse_include {} {
    global parser_finclude parser_include_open parser_line parser_subs parser_fin
    if {$parser_include_open==1} {
	error "Cannot have .include commands within include files"
    }
    set name [lindex $parser_line 1]
    set inc_file [window_include_file $name]
    set parser_finclude [open $inc_file r]
    set parser_subs [lrange $parser_line 2 end]
    set parser_subs [convertVariables $parser_subs]
    set parser_fin $parser_finclude
}

# convertVariables
#   Takes a list of args and substitutes items beginning with % with its
#   user-interface value (using get_variable_value)

proc convertVariables {list} {

    set newList ""
    foreach item $list {
	if {[string index $item 0] == "%"} {
	    set var [string range $item 1 end]
	    set val [get_variable_value $var]
	} else {
	    set val $item
	}
	lappend newList $val
    }
    return $newList
}
	    
# dontConvertVariables
#   Takes a list of args and substitutes items beginning with % with 
#   just the name (ie removes the percent). Used when we don't want
#   to make the substitution just yet

proc dontConvertVariables {list} {

    set newList ""
    foreach item $list {
	if {[string index $item 0] == "%"} {
	    set val [string range $item 1 end]
	} else {
	    set val $item
	}
	lappend newList $val
    }
    return $newList
}
	    

# Top of include file - just set flag to tell parser to make substitutions

proc parse_incbegin {n_args} {
    global parser_include_open parser_subs parser_line
    if { $n_args<[llength $parser_subs] } {
	error "Too many arguments while parsing .include file"
    } elseif { $n_args>[llength $parser_subs] } {
	error "Too few arguments while parsing .include file"
    }
    set parser_include_open 1
}

# End of include file. Close file, unset flag and point parser back to original file

proc parse_incend {} {
    global parser_fpanel parser_fin parser_finclude parser_include_open
    if {$parser_include_open!=1} {
	error ".incude_end without .include"
    }
    set parser_include_open 0
    close $parser_finclude
    set parser_fin $parser_fpanel
}

proc parse_skeleton {} {

    global parser_inskeleton parser_script parser_winid parser_title

    if $parser_inskeleton {
	error "Parse error: can't nest .skeleton .skelend structures"
    }
    set parser_inskeleton 1
    if {$parser_winid == ""} {
	error "Parse error: missing .winid statement, must appear before .wintype"
    }
    if {$parser_title == ""} {
	error "Parse error: missing .title statement, must appear before .wintype"
    }
#    append parser_script "new_window $parser_winid \"$parser_title\" \{\n"
}


proc parse_skelend {} {

    global parser_inskeleton parser_fskeleton parser_fpanel parser_fin

    if {! $parser_inskeleton} {
	error "Parse error: can't have .skelend outside skeleton"
    }
    set parser_inskeleton 0
    close $parser_fskeleton
    set parser_fin $parser_fpanel
}


proc parse_panel {} {

    global parser_inskeleton parser_fpanel parser_fin

    if $parser_inskeleton {
	set parser_inskeleton 0
	set parser_fin $parser_fpanel
    }
}


proc parse_panend {} {

    global parser_inskeleton parser_fskeleton parser_fin parser_skeleton_open

    if $parser_inskeleton {
	error "Parse error: can't have .panend inside skeleton"
    }
    set parser_inskeleton 1
    set parser_fin $parser_fskeleton
    if {! $parser_skeleton_open} {
	error "Parse error: .panel not specified in skeleton"
    }
}


proc parse_single_line {proc_name} {

    global parser_script parser_line
    append parser_script "$proc_name [lrange $parser_line 1 end]\n"
}


proc parse_case {start_call} {

    global parser_script parser_line

    append parser_script "$start_call \{[lrange $parser_line 1 end]\}\n"
}

proc parse_colour {start_call} {

    global parser_script parser_line

    append parser_script "$start_call [lindex $parser_line 1] \{[lrange $parser_line 2 end]\}\n"
}


proc parse_table {} {

    global parser_script parser_line

    append parser_script "addToWindowList Table [lindex $parser_line 1]\n"
    append parser_script "tableStart [lrange $parser_line 1 4]"
    append parser_script " \{[lindex $parser_line 5]\} "
    append parser_script "[lrange $parser_line 6 end]\n"
}


proc parse_block {} {

    global parser_script parser_line

    append parser_script "block_start 1 [lrange $parser_line 1 end]\n"
}

###########################################################################
# parse_procs                                                             #
# List of up to 3 procedures to execute when opening or closing panels    #
# Include command after .wintype and usually before .panel                #
###########################################################################

proc parse_procs {} {
  
  global parser_script parser_line parser_skeleton_open save_done processing_done

  if {$parser_skeleton_open==0} {
    error ".procs command must follow .wintype command"
  }

  set init_proc [lindex $parser_line 1]
  set quit_proc [lindex $parser_line 2]
  set close_proc [lindex $parser_line 3]

  # Evaluate any init_proc immediately
  if {$init_proc != ""} {
      set save_done 0
      set processing_done 0
      eval $init_proc
  }

  if {$close_proc == ""} {set close_proc "NONE"}
  if {$quit_proc  == ""} {set quit_proc  "NONE"}

  # add procedure names to parser scripts. Needs to be global because
  # all widgets have bindings to execute them
  append parser_script "global quit_proc close_proc\n"
  append parser_script "set quit_proc \{$quit_proc\}\n"
  append parser_script "set close_proc \{$close_proc\}\n"
}

proc parse_basrad {} {

    global parser_fin parser_script parser_line parser_line_preread

    append parser_script "basrad_component [lrange $parser_line 1 end] \{\n"
    while {! [eof $parser_fin]} {
	set parser_line [get_a_line $parser_fin]
	#gets $parser_fin parser_line
	set first_token [lindex $parser_line 0]
	if {$first_token == "" || [string index $first_token 0] == "."} {
	    append parser_script \}\n
	    set parser_line_preread 1
	    return
	}
	for {set i 0} {$i < [llength $parser_line]} {incr i 2} {
	    append parser_script \{[lrange $parser_line $i [expr $i + 1]]\}\n
	}
    }
    error "Parser error: premature end of file"
}

