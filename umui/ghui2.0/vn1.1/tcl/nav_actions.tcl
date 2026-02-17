# save button pressed
#
proc nav_save {} {
    # Keep message bit separate from main save option so
    # do_save can be called from read_rc.tcl

    status_message "" "Saving...Please wait"
    update idletasks
    do_save
    clear_message ""
}

proc do_save {} {
    global save_done exp_id job_id env
    global application titles

    set job_file [unique_jobfile]

    set list {}
    foreach col $titles(all_columns) {
	if [info exists titles(function,$col)] {
	    set fn $titles(function,$col)
	} else {
	    set fn ""
	}
	if { $fn!="" } {
	    if { [info commands $fn]==$fn } {
		lappend list $col
		lappend list [$fn $col]
	    } else {
		error "Function $fn listed in $application application definition file was not found"
	    }
	}
    }

    # write basis file and send back to server
    write_database $job_file
    set fp [open $job_file r]

    OnBothServers save_job [list $exp_id $job_id $env(LOGNAME) $list [read $fp]] 

    close $fp
    exec rm $job_file
    # indicate that a save has been done.
    set save_done 1
}
# quit pressed
#
proc nav_quit {} {

  global save_done read_write exp_id job_id

  # ask for confirmation if necessary
  if {$read_write && ! $save_done} {

      set option [multioption_dialog .quit "Quit" "Do you really want to quit\
	      without saving?" Quit {Save and Quit} Cancel]
      switch -- $option {
	  0  {}
	  1  {nav_save}
	  2  {return}
	  default {return}
      }
  }
  status_message "" "Quitting..."
  update
  do_quit
  destroy .
  exit

}

proc do_quit {} {
  global read_write exp_id job_id env
  # close job if open
  if $read_write {
      # Close with a catch in case job has already been closed
      # by another method
      catch {OnBothServers close_job [list $exp_id $job_id $env(LOGNAME)]}
  }
}

# hand edit pressed
#
proc nav_handedit {} {

  global hand_edit_cancel hand_editor env save_done processing_done 
  global variables exp_id job_id description

  # get editor environment variable
  if {! [info exists hand_editor]} {
    if [info exists env(EDITOR)] {
      set hand_editor $env(EDITOR)
    } else {
      set hand_editor ""
    }
  }

  # ask for editor to use
  if {[info commands .hande] == ".hande"} {
    destroy .hande
  }
  toplevel .hande
  wm geometry .hande +10+100
  wm title .hande "Hand edit basis file"

  message .hande.m -width 800 -text \
   "Hand edit is used to manually change the basis file that describes a job.\
    This action should only be used as a last resort. The GHUI\
    is designed not to require hand edits and you are in danger\
    of damaging your job. Ensure when editing that you leave the basis\
    file in FORTRAN namelist format. Enter the name of the editor you\
    want to use to edit the job below. The default is obtained from\
    the EDITOR environment variable."
  entry .hande.t -relief sunken -width 80
  button .hande.e -text Edit -command {
    global hand_edit_cancel hand_editor
    set hand_editor [.hande.t get]
    destroy .hande
    set hand_edit_cancel 0
  }
  button .hande.c -text Cancel -command {
    global hand_edit_cancel
    destroy .hande
    set hand_edit_cancel 1
  }
  bind .hande.t <Return> {set junk junk}
  focus .hande.t
  .hande.t delete 0 end
  .hande.t insert 0 $hand_editor
  pack .hande.m -padx 2m -pady 2m
  pack .hande.t -padx 2m -pady 2m -anchor w
  pack .hande.e .hande.c -side left -ipadx 1m -pady 2m -expand yes
  tkwait variable hand_edit_cancel
  if $hand_edit_cancel return
 
  # invoke editor
  set download_file [unique_jobfile]
  wm iconify .
  write_database $download_file
  exec xterm -T "Hand Edit" -e /bin/sh -c \
   "echo \"Starting editor...\" ; \
    if $hand_editor $download_file ; then \
    echo \"Uploading...\" ; else sleep 5 ; fi"

  # load basis file
  clear_databases
  load_variables $download_file
  exec rm $download_file

  set_variable_value EXPT_ID $exp_id
  set_variable_value JOB_ID $job_id
  set_variable_value RUN_ID $exp_id$job_id
  set_variable_value JOBDESC $description
  set save_done 0
  set processing_done 0 
  wm deiconify .
}


# download pressed
#
proc nav_download {} {

    global download_cancel download_file env download_path exp_id job_id

    if {![info exists download_path]} {
	if [catch {set dir "/[get_variable_value JOB_OUTPUT]"}] {set dir "/"}
	set download_path(dir) $env(HOME)$dir
	set download_path(file) basis_$exp_id$job_id
    }

    # ask for filename to download as
    if {[info commands .downl] == ".downl"} {
	destroy .downl
    }
    toplevel .downl
    wm geometry .downl +10+100
    wm title .downl "Download basis file"
    
    message .downl.m -width 800 -text \
	    "Download is used to take a personal copy of a job's basis file.\
	    It is not recommended that you store basis files\
	    in this way as it hampers access to your job for other users and\
	    compromises the managed nature of the job storage system. If you\
	    do need this facility (to email a job, for example), then enter a\
	    full pathname for the saved basis file below."
    entry .downl.e -relief sunken -width 80
    .downl.e insert 0 $download_path(dir)/$download_path(file)
    set command "call_filewalk .downl.e"
    button .downl.f -text "Filewalk" -command $command
    button .downl.d -text Download -command {
	global download_cancel download_file
	set download_file [.downl.e get]
	destroy .downl
	set download_cancel 0
    }
    button .downl.c -text Cancel -command {
	global download_cancel
	destroy .downl
	set download_cancel 1
    }
    bind .downl.e <Return> {set junk junk}
    focus .downl.e
    pack .downl.m -padx 2m -pady 2m
    pack .downl.e -padx 2m -pady 2m -anchor w
    pack .downl.d .downl.f .downl.c -side left -ipadx 1m -pady 2m -expand yes
    tkwait variable download_cancel
    if $download_cancel return

    # save job to file specified
    set download_file [get_env $download_file]
    write_database $download_file
    set download_path(dir) [directory_of $download_file]
    set download_path(file) [file_of $download_file]
}

# call_filewalk
#   Interface to filewalk - sets up initial values depending on current
#   contents of entrybox $f
# f : entrybox widget

proc call_filewalk {f} {
    set path [$f get]
    filewalk $f [directory_of $path] [file_of $path]
}

# upload pressed
#
proc nav_upload {} {

    global upload_cancel upload_file save_done processing_done
    global variables exp_id job_id description download_path env

    if {![info exists download_path]} {
	if [catch {set dir "/[get_variable_value JOB_OUTPUT]"}] {set dir "/"}
	set download_path(dir) $env(HOME)$dir
	set download_path(file) basis_$exp_id$job_id
    }

    # ask for filename to upload
    if {[info commands .upl] == ".upl"} {
	destroy .upl
    }
    toplevel .upl
    wm geometry .upl +10+100
    wm title .upl "Upload basis file"

    message .upl.m -width 800 -text \
	    "Upload will overwrite the contents of the current job being edited\
	    and replace it with the contents of the basis file specified. You\
	    may need this function to absorb a pre-existing basis file into\
	    the managed job storage system. Please specify the full pathname\
	    of your basis file."
    entry .upl.e -relief sunken -width 80
    .upl.e insert 0 $download_path(dir)/$download_path(file)
    set command "call_filewalk .upl.e"
    button .upl.f -text "Filewalk" -command $command
    button .upl.d -text Upload -command {
	global upload_cancel upload_file
	set upload_file [.upl.e get]
	destroy .upl
	set upload_cancel 0
    }
    button .upl.c -text Cancel -command {
	global upload_cancel
	destroy .upl
	set upload_cancel 1
    }
    bind .upl.e <Return> {set junk junk}
    focus .upl.e
    pack .upl.m -padx 2m -pady 2m
    pack .upl.e -padx 2m -pady 2m -anchor w
    pack .upl.d .upl.f .upl.c -side left -ipadx 1m -pady 2m -expand yes
    tkwait variable upload_cancel
    if $upload_cancel return
    
    # load basis file
    clear_databases
    set upload_file [get_env $upload_file]
    set download_path(dir) [directory_of $upload_file]
    set download_path(file) [file_of $upload_file]
    load_variables $upload_file

    set_variable_value EXPT_ID $exp_id
    set_variable_value JOB_ID $job_id
    set_variable_value RUN_ID $exp_id$job_id
    set_variable_value JOBDESC $description
    set save_done 0
    set processing_done 0
}


# process pressed
proc nav_process {} {

    global processing_in_progress processing_done read_write save_done
    global proc_cancel job_title job_id exp_id 

    if [info exists processing_in_progress] {
	return
    }

    set path [set_output_dir]
    # make processing output sub-directory
    if {! [file exists $path]} {
	exec mkdir $path
    }
    set processed_dir $path/$exp_id$job_id

    # confim action if there is no save
    if {$read_write && ! $save_done} {
	set continue [multioption_dialog .process "Are you sure ?" "You have not saved your changes.\
		Do you want to process anyway?" {Process} {Save first} {Cancel}]
	if { $continue==-1 || $continue == 2} {
	    # Cancel or return because button pressed a second time
	    return
	} elseif {$continue==1} {
	    nav_save
	}
    }


    set processing_in_progress 1
    # make processing output sub-directory

    if {! [file exists $path]} {
	exec mkdir $path
    }

    if [file exists $processed_dir] {
	exec /bin/sh -c "rm -rf $processed_dir/*"
    } else {
	exec mkdir $processed_dir
    }

    status_message "" "Processing in progress: Input file : top"
    update
    update idletasks

    global ui_dir
    set ui_dir [version_path]

    process_job $processed_dir $job_id

    status_message "" "Processing complete, output in directory: $processed_dir"

    # If an error occurs while processing, c code unsets this variable
    unset processing_in_progress

    set processing_done 1
}


############################################################################
# proc set_output_dir                                                      #
# Returns path of output directory. Called from um_nav_process and _submit #
############################################################################

proc set_output_dir {} {

  global env

  if [catch {set output_dir $env(HOME)/[get_variable_value JOB_OUTPUT]} ] {
    error "APPLICATION ERROR: You are using a navigation procedure which sends output \
	to a user's own account. The output directory name needs to be stored in an \
	application variable called JOB_OUTPUT. You need to add JOB_OUTPUT to one of \
	the variable registers and set it to a pathname, relative to the home \
	directory environment variable \$env(HOME), to which your output should \
	be sent."
  }
  return $output_dir
}  


