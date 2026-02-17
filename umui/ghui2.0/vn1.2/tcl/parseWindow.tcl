#
# parseWindow.tcl
#   Contains procs required to parse GHUI window files.
#
# Globals
#   parser: Holds details parser status while window script is parsed
#   parser($p[,element])
#    p: Each instance is given a unique value of $p

# parse_window
#   Read a window definiton and convert it into a tcl script.
# Arguments
#   fileName: Full pathname of file holding toplevel window script
#   window_name: Name of window - generally it is the filename prefix.
# Result
#   Returns Tcl script that creates window when eval'd

proc parse_window {fileName window_name} {
    global parser

    # Use first unused element of parser array
    set p 0
    while {[info exists parser($p)] == 1} {incr p}
    set parser($p) 1

    # initialise globals
    set parser($p,winid) ""
    set parser($p,title) ""
    set parser($p,inSkeleton) 0
    set parser($p,skeletonOpen) 0
    set parser($p,script) ""
    set parser($p,includeOpen) 0
    set parser($p,subs) {}

    # open files
    set parser($p,fpanel) [open $fileName r]

    # read a line at a time, starting with main panel file
    set parser($p,fin) $parser($p,fpanel)
    set parser($p,linePreread) 0

    while {(! [eof $parser($p,fin)]) || $parser($p,linePreread)} {
	if {! $parser($p,linePreread)} {
	    set parser($p,line) [get_a_line $p $parser($p,fin)]
	}
	set parser($p,linePreread) 0
	parseLine $p $window_name
    }

    # close file
    close $parser($p,fpanel)

    # Clean up array and return the window script
    set script $parser($p,script)
    foreach index [array names parser $p,*] {
	unset parser($index)
    }
    unset parser($p)
    return $script
}

# get_a_line
#   Read a line and make substitutions if required. Substitutions are
#   currently only applicable to include files in which %n is replaced
#   by argument n.
# Arguments
#   p: Instance of parser global
#   file: Channel id of window file or include file being read
# Result
#   Returns the line read in with any substitutions

proc get_a_line {p file} {
    global parser errorInfo

    gets $file line

    if {$parser($p,includeOpen) == 1} {
	# Reading a .inc file - make substitutions if required
	set line [make_substitutions $line $parser($p,subs)]
    }

    # Tcl8.0 does not like lists such as [list aa bb "cc".] - a list
    # element in quotes must be followed by a space. The following 
    # checks for errors which are more than likely to be caused by
    # fullstops at the end of .comment lines.
    if [catch {lindex $line 0}] {
	error "$errorInfo \nfound while parsing line \n$line\n"
    }
    regsub -all "\t" $line " " line
    return $line
}

# make_substitutions
#  Searches for %[1-9]+ and replaces with appropriate argument.
# Arguments
#  line: Original line
#  subs: List of substitutions

proc make_substitutions {line subs} {
    set i 0
    # Replace any %[number] with the appropriate number .include argument
    while {$i<[llength $subs]} {
	set sub [lindex $subs $i]
	regsub -all %[incr i] $line $sub line
    }
    return $line
}

# parseLine
#   Obtains command from current line and calls appropriate procedure.
# Arguments
#   p: Instance of parser global
#   window_name: Name of window - required to give a title to panel.
# Results
#   None

proc parseLine {p window_name} {

    global parser

    # Tcl8.0 does not like lists such as [list aa bb "cc".] - a list
    # element in quotes must be followed by a space. The following 
    # line prevents errors which are more than likely to be caused by
    # quote-fullstops at the end of .comment eg 
    #    .comment input "a" or "b".

    regsub -all \" $parser($p,line) ' line
    #"
    # Run appropriate procedure depending on the command in the line
    switch -exact [lindex $line 0] {
        .comment {}
	.function {}
        .set_on_closure {}
	.loop {}
	.winid {set parser($p,winid) [lindex $parser($p,line) 1]}
	.title {set parser($p,title) [lindex $parser($p,line) 1]}
	.procs {parse_procs $p}
	.wintype {parse_wintype $p [lindex $parser($p,line) 1]}
	.openwin {open_window $p $window_name}
        .closewin {close_window $p}
	.include {parse_include $p}
	.include_begin {parse_incbegin $p [lindex $parser($p,line) 1]}
	.include_end {parse_incend $p}
	.skeleton {parse_skeleton $p}
	.skelend {parse_skelend $p}
	.top {}
	.topend {}
	.mid {}
	.midend {}
	.bottom {}
	.bottomend {}
	.panel {parse_panel $p}
	.panend {parse_panend $p}
	.text {parse_single_line $p text_component}
	.textw {parse_single_line $p text_component}
	.textj {}
	.textd {parse_single_line $p text_component}
	.gap {parse_single_line $p gap_component}
	.basrad {parse_basrad $p}
	.case {parse_case $p case_start .case}
	.caseend {parse_single_line $p case_end}
	.colour {parse_colour $p colour_start .colour}
	.colourend {parse_single_line $p colour_end}
	.invisible {parse_case $p invisible_start .invisible}
	.invisend {parse_single_line $p invisible_end}
	.pushquit {parse_single_line $p pushquit_component}
	.pushclose {parse_single_line $p pushclose_component}
	.pushnext {parse_single_line $p pushnext_component}
	.pushsequence {parse_single_line $p pushnext_component}
	.pushand {parse_single_line $p pushand_component}
	.pushhelp {parse_single_line $p pushhelp_component}
        .pushbutton {parse_single_line $p pushbutton_component}
	.block {parse_block $p}
	.blockend {parse_single_line $p block_end}
	.entry {parse_single_line $p entry_component}
        .entry_active {parse_single_line $p activeEntryComponent}
	.file_entry {parse_single_line $p file_entry_component}
	.file_table {parse_file_table $p}
	.check {parse_single_line $p check_component}
	.table {parse_table $p}
	.tableend {parse_single_line $p tableEnd}
	.super {parse_single_line $p tableSuper}
	.superend {parse_single_line $p tableSuperend}
	.element {parse_single_line $p tableElement}
	.elementautonum {parse_single_line $p tableElementautonum}
	.index {parse_single_line $p tableIndexed}
	.help {parse_single_line $p set_help}
	.init {parse_single_line $p init_var}
	"" {}
	default {
	    error "Parse error: expected component, got:\n  $parser($p,line)"
	}
    }
}

proc parse_wintype {p name} {

    global parser

    if $parser($p,inSkeleton) {
	error "Parse error: can't have .wintype in skeleton"
    }
    set skel [skeletons_file $name]
    set parser($p,fskeleton) [open $skel r]
    set parser($p,skeletonOpen) 1
    set parser($p,fin) $parser($p,fskeleton)
}

# open_window
#  Called when .openwin command found. Initialises the script to create 
#  the panel. Essentially the script will be a call to the new_window 
#  procedure that passes in the name and title of the panel and also a 
#  tcl script to be eval'ed within new_window.

proc open_window {p window_name} {
    global parser

    append parser($p,script) "new_window $parser($p,winid) \"$parser($p,title)\" \{\n"

    # Incorporate variables into parser($p,script)

    append parser($p,script) "global window_name\n"
    append parser($p,script) "set window_name $window_name\n"
}

proc close_window {p} {
    global parser
    append parser($p,script) {end_of_window}
    append parser($p,script) \n\}\n

}

# Include file requested. Open file, set flag and point parser at top of file

proc parse_include {p} {
    global parser
    if {$parser($p,includeOpen)==1} {
	error "Cannot have .include commands within include files"
    }
    set name [lindex $parser($p,line) 1]
    set inc_file [window_include_file $name]
    set parser($p,finclude) [open $inc_file r]
    set parser($p,subs) [lrange $parser($p,line) 2 end]
    set parser($p,subs) [convertVariables $parser($p,subs)]
    set parser($p,fin) $parser($p,finclude)
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

proc parse_incbegin {p n_args} {
    global parser
    if { $n_args<[llength $parser($p,subs)] } {
	error "Too many arguments while parsing .include file"
    } elseif { $n_args>[llength $parser($p,subs)] } {
	error "Too few arguments while parsing .include file"
    }
    set parser($p,includeOpen) 1
}

# End of include file. Close file, unset flag and point parser back to original file

proc parse_incend {p} {
    global parser
    if {$parser($p,includeOpen)!=1} {
	error ".incude_end without .include"
    }
    set parser($p,includeOpen) 0
    close $parser($p,finclude)
    set parser($p,fin) $parser($p,fpanel)
}

# parse_skeleton
#  Called when .skeleton command found. ie. at top of .skel file.
#  Apart from setting the inSkeleton flag, does  nothing except 
#  check that the skeleton file is not nested and that .winid and 
#  .title commands have already been called to set the window id 
#  and title, and sets the inSkeleton flag

proc parse_skeleton {p} {
    global parser

    if $parser($p,inSkeleton) {
	error "Parse error: can't nest .skeleton .skelend structures"
    }
    set parser($p,inSkeleton) 1
    if {$parser($p,winid) == ""} {
	error "Parse error: missing .winid statement, must appear before .wintype"
    }
    if {$parser($p,title) == ""} {
	error "Parse error: missing .title statement, must appear before .wintype"
    }
}

# parse_skelend
#  Checks that we are in a skeleton file and unsets flag if so. Close
#  skeleton file and return control to the main window control file.

proc parse_skelend {p} {

    global parser

    if {! $parser($p,inSkeleton)} {
	error "Parse error: can't have .skelend outside skeleton"
    }
    set parser($p,inSkeleton) 0
    close $parser($p,fskeleton)
    # Go back to reading the main window control file
    set parser($p,fin) $parser($p,fpanel)
}

# parse_panel
#  Called when .panel command is found. The .panel command can be found
#  in both the skeleton and the window control files but it doesn't serve
#  any purpose in the window control file. In the skeleton file it returns
#  control back to the window control file.

proc parse_panel {p} {
    global parser

    if $parser($p,inSkeleton) {
	set parser($p,inSkeleton) 0
	set parser($p,fin) $parser($p,fpanel)
    }
}


proc parse_panend {p} {

    global parser

    if $parser($p,inSkeleton) {
	error "Parse error: can't have .panend inside skeleton"
    }
    set parser($p,inSkeleton) 1
    set parser($p,fin) $parser($p,fskeleton)
    if {! $parser($p,skeletonOpen)} {
	error "Parse error: .panel not specified in skeleton"
    }
}


proc parse_single_line {p proc_name} {

    global parser
    append parser($p,script) "$proc_name [lrange $parser($p,line) 1 end]\n"
}

# parse_case
#   Implements case and invisible constructs.
#   Add appropriate command plus expression to script.
# Arguments
#   p: Instance of panel
#   start_call: Tcl proc. Either case_start or invisible_start
#   command: Input panel command. Either .case or .invisible

proc parse_case {p start_call command} {

    global parser
    # Remove command from line to leave logical expression
    # Using regsub rather than, say lrange to preserve quoting.
    # Otherwise A == "FRED" gets incorrectly converted to A == FRED
    regsub " *$command *" $parser($p,line) "" expression
    append parser($p,script) "$start_call \{$expression\}\n"
}

# parse_colour
#   Implements colour construct.
#   Add appropriate command plus expression to script.
# Arguments
#   p: Instance of panel
#   start_call: Tcl proc. Either case_start or invisible_start
#   command: Input panel command. Either .case or .invisible

proc parse_colour {p start_call command} {

    global parser

    set colour [lindex $parser($p,line) 1]
    # Remove command and colour from line to leave logical expression
    # Using regsub rather than, say lrange to preserve quoting.
    # Otherwise A == "FRED" gets incorrectly converted to A == FRED
    regsub " *$command *$colour *" $parser($p,line) "" expression
    append parser($p,script) "$start_call $colour \{$expression\}\n"
}


proc parse_table {p} {

    global parser

    append parser($p,script) "addToWindowList Table [lindex $parser($p,line) 1]\n"
    append parser($p,script) "tableStart [lrange $parser($p,line) 1 4]"
    append parser($p,script) " \{[lindex $parser($p,line) 5]\} "
    append parser($p,script) "[lrange $parser($p,line) 6 end]\n"
}


proc parse_block {p} {

    global parser

    append parser($p,script) "block_start 1 [lrange $parser($p,line) 1 end]\n"
}

###########################################################################
# parse_procs                                                             #
# List of up to 3 procedures to execute when opening or closing panels    #
# Include command after .wintype and usually before .panel                #
###########################################################################

proc parse_procs {p} {
  
  global parser

  if {$parser($p,skeletonOpen)==0} {
    error ".procs command must follow .wintype command"
  }

  set init_proc [lindex $parser($p,line) 1]
  set quit_proc [lindex $parser($p,line) 2]
  set close_proc [lindex $parser($p,line) 3]

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
  append parser($p,script) "global quit_proc close_proc\n"
  append parser($p,script) "set quit_proc \{$quit_proc\}\n"
  append parser($p,script) "set close_proc \{$close_proc\}\n"
}

proc parse_basrad {p} {

    global parser

    append parser($p,script) "basrad_component [lrange $parser($p,line) 1 end] \{\n"
    while {! [eof $parser($p,fin)]} {
	set parser($p,line) [get_a_line $p $parser($p,fin)]
	#gets $parser($p,fin) parser($p,line)
	set first_token [lindex $parser($p,line) 0]
	if {$first_token == "" || [string index $first_token 0] == "."} {
	    append parser($p,script) \}\n
	    set parser($p,linePreread) 1
	    return
	}
	for {set i 0} {$i < [llength $parser($p,line)]} {incr i 2} {
	    append parser($p,script) \{[lrange $parser($p,line) $i [expr $i + 1]]\}\n
	}
    }
    error "Parser error: premature end of file"
}

proc parse_file_table {p} {

    global parser

    append parser($p,script) "table_start [lrange $parser($p,line) 1 4]"
    append parser($p,script) " \{[lindex $parser($p,line) 5]\} "
    append parser($p,script) "[lrange $parser($p,line) 6 end]\n"
}

# Need to make changes to proc table_start so it recognises a file_table
# and produces a "filewalk" button and links it to the current focus
#
# This will involve an extra argument to the routine and extra args
# to all the table tags in the windows. It may be easier to copy the
# proc table_start to file_table_start and call it explicetly.
