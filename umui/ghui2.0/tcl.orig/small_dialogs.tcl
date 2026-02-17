# small dialogs used by the entry system
#


# find a free window id
#
proc free_winid name {

    set i 0
    while {[info commands .$name$i] == ".$name$i"} {
	incr i
    }
    return .$name$i
}


# enter description text
#
proc get_description {prompt {old_name ""}} {

    global titles

    # find next free window name
    set winid [free_winid descr]

    global descr_text_$winid descr_ok_$winid
    if {$old_name!=""} {set descr_text_$winid $old_name}

    # create window
    toplevel $winid
    wm geometry $winid +10+200
    wm title $winid "Description"

    label $winid.l -text $prompt
    entry $winid.t -width 40 -textvariable descr_text_$winid \
	    -relief sunken
    button $winid.ok -text OK -command "
    global descr_ok_$winid

    set descr_ok_$winid 1
    destroy $winid
    "
    button $winid.cancel -text Cancel -command "destroy $winid"

    pack $winid.l -padx 2m -pady 1m -anchor w
    pack $winid.t -padx 2m -pady 1m -anchor w
    pack $winid.ok -side left -padx 2m -pady 2m -ipadx 1m -expand yes
    pack $winid.cancel -side left -padx 2m -pady 2m -ipadx 1m -expand yes
    focus $winid.t

    # return contents of entry box if OK pressed
    set descr_ok_$winid 0
    tkwait window $winid
    if [set descr_ok_$winid] {
	# Apostrophes not allowed - they interfere with apostrophes used in data files
	set name [set descr_text_$winid]
	regsub ' $name ` name
	return $name
    } else {
	return -code return
    }
}


# Returns a list of job ids in use in exp_id
proc job_id_list {exp_id} {
    set job_ids ""
    # Need list returned without job filters
    set job_list [OnPrimaryServer send_job_list [concat $exp_id [blank_filter_list job_filters] ]]
    foreach spec $job_list {
	lappend job_ids [lindex $spec 0]
    }
    return $job_ids
}

# getIdButtonCommand
#   This proc is bound to buttons in get ID dialog. It sets the global
#   variable appropriately when one of the ID buttons is chosen, and
#   destroys the dialog.
# Arguments
#   w: Dialog window
#   variable: Name of global
#   buttonVal: Value of selected button

proc getIdButtonCommand {w variable buttonVal} {
    global $variable
    set $variable $buttonVal
    destroy $w
}

# getId
#   Allows user to select a letter ID for jobs or experiments. A list of
#   disallowed values can be passed in. These will be greyed out.
# Arguments
#   title: Title of dialog
#   prompt: Appropriate question to ask user
#   usedList: List of letters that cannot be used

proc getId {title prompt usedList} {

    set w [free_winid getid]
    
    global id_letter_$w

    toplevel $w
    wm geometry $w +10+200
    wm title $w $title
    wm withdraw $w
    
    set i 1
    foreach line $prompt {
	label $w.t$i -text $line
	pack $w.t$i -padx 2m -anchor w
	incr i
    }
    frame $w.letters
    pack $w.letters -padx 2m -pady 2m
    set b $w.letters
    set i 0
    # Display letters in two rows
    foreach list [list [list a b c d e f g h i j k l m] [list n o p q r s t u v w x y z]] {
	incr i
	set f $b.f$i
	pack [frame $f]
	foreach letter $list {
	    button $f.$letter -text $letter -command \
		    "getIdButtonCommand $w id_letter_$w $letter"
	    if {[lsearch $usedList $letter]!=-1} {
		# Greyout and deactivate disallowed letters
		$f.$letter configure -state disabled -foreground grey60
	    }
	    pack $f.$letter -side left -ipadx 1m
	}
    }
    button $w.cancel -text Cancel -command \
	    "getIdButtonCommand $w id_letter_$w NONE"
    pack $w.cancel -pady 2m -ipadx 1m
    set id_letter_$w "NONE"
    wm deiconify $w
    # Await for window to be destroyed
    tkwait window $w
    return [set id_letter_$w]
}


# get_jobid
#   Allow user to select a new job id when creating a job in a
#   particular experiment.
# Arguments
#   prompt: A relevant question to be displayed in the dialog
#   exp_id: Target experiment ID - so user can be given a list 
#           of unused IDs

proc get_jobid {prompt exp_id} {

    # Get list of currently used letters
    set usedList [job_id_list $exp_id]
    if {[llength $usedList] == 26} {
	tk_messageBox -message \
		"Sorry. There is no more space in this experiment" \
		-type ok -icon error
	return -code return
    }

    set idLetter [getId "Job ID" [list $prompt] $usedList]
    if {$idLetter == "NONE"} {
	# This causes the calling program also to return
	return -code return
    } else {
	return $idLetter
    }
}


# information window
#
proc info_box text {

    # find next free window name
    set winid [free_winid info]

    # create window
    toplevel $winid
    wm geometry $winid +10+200
    wm title $winid "Information"

    label $winid.l -text $text
    button $winid.ok -text OK -command "destroy $winid"

    pack $winid.l -padx 2m -pady 2m
    pack $winid.ok -padx 2m -pady 2m -ipadx 1m
}


# are you sure window
#
proc are_you_sure text {

    # find next free window name
    set winid [free_winid sure]

    global sure_$winid

    # create window
    toplevel $winid
    wm geometry $winid +10+200
    wm title $winid "Are you sure?"

    label $winid.l -text $text
    button $winid.y -text Yes -command "
    global sure_$winid

    set sure_$winid 1
    destroy $winid
    "
    button $winid.n -text No -command "destroy $winid"

    pack $winid.l -padx 2m -pady 2m
    pack $winid.y -padx 2m -pady 2m -ipadx 1m -side left -expand yes
    pack $winid.n -padx 2m -pady 2m -ipadx 1m -side left -expand yes

    set sure_$winid 0
    tkwait window $winid
    return [set sure_$winid]
}


# view and/or change an access list for an experiment
#
proc edit_access_list {exp_id old_list} {

    # find next free window name
    set winid [free_winid access]

    global change_$winid change_al_$winid

    # create window
    toplevel $winid
    wm geometry $winid +10+200
    wm title $winid "Access list for experiment $exp_id"

    frame $winid.list
    listbox $winid.list.box -relief sunken -yscrollcommand "$winid.list.sbar set" -selectmode single
    scrollbar $winid.list.sbar -relief sunken -command "$winid.list.box yview"
    button $winid.del -text "Delete selected name" -command "al_delete $winid"
    frame $winid.add
    button $winid.add.do -text "Add name..." -command "al_add $winid"
    entry $winid.add.text -relief sunken
    bind $winid.add.text <Return> "al_add $winid"
    button $winid.change -text Change -command "al_change $winid"
    button $winid.cancel -text Cancel -command "destroy $winid"

    pack $winid.list -padx 2m -pady 2m -anchor w
    pack $winid.list.box -side left
    pack $winid.list.sbar -side left -fill y
    pack $winid.del -padx 2m -pady 1m -ipadx 1m -anchor w
    pack $winid.add -padx 2m -pady 1m
    pack $winid.add.do -side left -ipadx 1m
    pack $winid.add.text -side left -padx 2m
    pack $winid.change -side left -pady 4m -ipadx 1m -expand yes
    pack $winid.cancel -side left -pady 4m -ipadx 1m -expand yes
    focus $winid.add.text

    # fill in access list
    foreach user $old_list {
	$winid.list.box insert end $user
    }

    set change_$winid 0
    tkwait window $winid
    if [set change_$winid] {
	# return new list of users
	return [set change_al_$winid]
    } else {
	# force calling procudure to ignore this access list
	return -code continue
    }
}

# access list item deletion
proc al_delete winid {
    set index [$winid.list.box curselection]
    if {$index != ""} {
	$winid.list.box delete $index
    }
}

# access list item addition
proc al_add winid {
    set user [$winid.add.text get]
    if {$user != ""} {
	$winid.list.box insert end $user
    }
    $winid.add.text delete 0 end
}

# access list update
proc al_change winid {

    global change_$winid change_al_$winid

    set change_al_$winid {}
    for {set i 0} {$i < [$winid.list.box size]} {incr i} {
	lappend change_al_$winid [$winid.list.box get $i]
    }

    set change_$winid 1
    destroy $winid
}


# select a new version for an update
#
proc select_version {exp_id job_id} {

    global all_lines

    # get old and possible new versions
    set old_version $all_lines($exp_id$job_id-version)
    set new_versions [OnPrimaryServer updates_available $old_version]

    if {[llength $new_versions] == 0} {
	error "There is no version upgrade package available for version\
		$old_version (job $exp_id$job_id)."
    }

    # find next free window name
    set winid [free_winid version]

    global version_$winid

    # create window
    toplevel $winid
    wm geometry $winid +10+200
    wm title $winid "New version"

    label $winid.t -text "Select a new version for job $exp_id$job_id."
    frame $winid.versions
    pack $winid.t -padx 2m -pady 2m
    pack $winid.versions -padx 2m -pady 2m
    set i 0
    foreach version $new_versions {
	button $winid.versions.v$i -text $version -command "
	global version_$winid
	set version_$winid $version
	destroy $winid
	"
	pack $winid.versions.v$i -side left -ipadx 1m
	incr i
    }
    button $winid.cancel -text Cancel -command "destroy $winid"
    pack $winid.cancel -pady 2m -ipadx 1m

    set version_$winid NONE
    tkwait window $winid
    if {[set version_$winid] == "NONE"} {
	return -code return
    } else {
	return [set version_$winid]
    }
}

# get_version
#   Generate dialog to allow user to choose from the possible versions 
#   for a new job

proc get_version {} {

    # find possible versions by looking for the directories holding the
    # edit software.
    set base_dir [application_path]
    set versions {}
    foreach dir [glob -nocomplain $base_dir/vn*] {
	# extract the version number part of the directory name
	lappend versions [string range $dir \
		[expr [string length $base_dir] + 3] \
		end]
    }

    if {$versions == ""} {
	error "Bizarre! There are no possible versions of the job edit software!"
    }

    set versions [lsort $versions]

    # find next free window name
    set winid [free_winid version]

    global version_$winid

    # create window
    toplevel $winid
    wm geometry $winid +10+200
    wm title $winid "New job version"

    label $winid.t -text "Select a version for the new job."
    pack $winid.t -padx 2m -pady 2m

    frame $winid.versions
    pack $winid.versions -padx 2m -pady 2m
    set i 0
    for {set i 0} {$i < [llength $versions]} {incr i} {
	set version [lindex $versions $i]
	button $winid.versions.v$i -width 8 -text $version -command "
	global version_$winid
	set version_$winid $version
	destroy $winid
	"
	lappend buttonList $winid.versions.v$i
	# Display buttons in rows of 5
	if {([expr (($i+1)/5) * 5] == [expr $i + 1]) || \
		([expr $i + 1] == [llength $versions])} {
	    eval "grid $buttonList"
	    set buttonList ""
	}
    }
    button $winid.cancel -text Cancel -command "destroy $winid"
    pack $winid.cancel -pady 2m -ipadx 1m

    set version_$winid NONE

    # Return with the selection once the window is destroyed
    tkwait window $winid
    if {[set version_$winid] == "NONE"} {
	return -code return
    } else {
	return [set version_$winid]
    }
}

# error dialog
proc bgerror message {
    global serverProgram

    if [info exists serverProgram] {
	# Server, so send to server log
	server_log "Error $err $errorInfo"
    } else {
	# Not the server, so send to window

	# create dialog, or bring to top.
	if {[info commands .error] == ".error"} {
	    wm withdraw .error
	    wm deiconify .error
	} else {
	    toplevel .error
	    wm geometry .error +10+200
	    wm title .error "GHUI errors and warnings"
	    frame .error.f
	    text .error.f.msg -relief raised -bd 2 -yscrollcommand {.error.f.sbar set} \
		    -width 80 -height 25
	    scrollbar .error.f.sbar -relief sunken -command {.error.f.msg yview}
	    button .error.ok -text OK -command {destroy .error}
	    button .error.st -text "s.t." -command {
		global errorInfo
		.error.f.msg insert end "STACK-TRACE:\n$errorInfo\n"
	    }
	    pack .error.f
	    pack .error.f.msg -side left
	    pack .error.f.sbar -side left -fill y
	    pack .error.ok -side left -expand yes -pady 2m -ipadx 1m
	    pack .error.st -side left -expand yes -pady 2m -ipadx 1m
	}
	.error.f.msg insert end $message\n
    } 

}

# Called from upgrade procedures upgrading options depend
# on user selection

proc upgrade_options {text help args} {
    global run_id
    set i 0
    while {[info commands .upgrade_$i]==".upgrade_$i"} {incr i}
    set w ".upgrade_$i"
    set title "Upgrading $run_id"
    # Format ensures that title etc. each remain as one argument but args
    # remains as a list of arguments regardless of positioning of spaces
    eval [list dialog_with_help $w "$title" "$text" "$help"] $args
}
