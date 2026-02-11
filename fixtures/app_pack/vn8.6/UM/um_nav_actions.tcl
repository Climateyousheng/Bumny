# um_nav_process
#   Run processing program to create job library. Does various checks
#   to ensure job saved, jobsheet not running etc.

proc um_nav_process {} {

    global processing_in_progress processing_done read_write save_done
    global proc_cancel job_title job_id exp_id 

    if [info exists processing_in_progress] {
	return
    }

    if {[get_variable_value SUBMIT_METHOD] == 6 && \
        ([get_variable_value MACH_NAME] == "login.hector.ac.uk" || \
         [get_variable_value MACH_NAME] == "phase2a.hector.ac.uk" || \
         [get_variable_value MACH_NAME] == "phase2b.hector.ac.uk")} {
        dialog .hector "Error" "Please enter phase3.hector.ac.uk in the Job submission method panel" \
        {} 0 {OK}
        return
    }

    if {[get_variable_value MACH_NAME] == "xcslc0"} {
        dialog .xcs "Error" "UM 8.6 is NOT installed on Monsoon2." {} 0 {OK}
        return
    }

    set path [set_output_dir]
    # make processing output sub-directory
    if {! [file exists $path]} {
	file mkdir $path
    }
    set processed_dir $path/$exp_id$job_id

    set jobsheet_dir $path
    if [file exists $jobsheet_dir/JOBSHEET_LOCK_$exp_id$job_id] {
	if {[multioption_dialog .js "Jobsheet in progress" "Directory $jobsheet_dir contains lock file due to jobsheet being\
		created. You need to close jobsheet program or delete the file, JOBSHEET_LOCK_$exp_id$job_id, before retrying"\
		Quit Retry]==1} {
	    um_nav_process
	}
	return
    }

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

    # Check that all record files such as STASHmasters and Ancil masters
    # have been read. Otherwise command sets up a callback that recalls 
    # processing once they have been read in
    if {[checkAllFilesRead "global processing_in_progress;unset \
	    processing_in_progress;um_nav_process"] == 0} {return}

    # Overwrite processed directory with new one 
    if [file exists $processed_dir] {
       # Try to delete processed directory
       if {[catch {file delete -force $processed_dir} err] == 1} {
          set answer [multioption_dialog .process "Problem with $processed_dir" \
               "The directory $processed_dir cannot be deleted. This could be  \
                because you are editing one of the files in it. \
                Error: $err" {Close} ]
          unset processing_in_progress
          set processing_done 0
          return
       } 
    }

    file mkdir $processed_dir

    status_message "" "Processing in progress: Input file : top"
    update
    update idletasks

    global ui_dir
    set ui_dir [version_path]

    process_job $processed_dir $job_id
    
    # ILP: make executable scripts 
    foreach item {MOOSE_JOB_SNAP UMSUBMIT COMP_SWITCHES MAIN_SCR EXTR_SCR} {
       if {[file exists $processed_dir/$item] == 1} {
	      file attributes $processed_dir/$item -permissions 00755
       }    
    }

    # ILP: create basis_runid file, zip it and add to the job output dir
    set autopp [get_variable_value AUTOPP]
    set arcsys [get_variable_value SYSTM]
    if { $autopp=="Y" && $arcsys==2 } {
	   append_message "" "...Now creating basis file"
       set download_file $processed_dir/basis_$exp_id$job_id
	   
       if {[catch {write_database $download_file} err] == 1} {
	      error $err
	   }  else {
          status_message "" "Basis file created, doing compression"   
          exec gzip $download_file
          status_message "" "Compression finished"
       }  
    }        

    status_message "" "Processing complete, output in directory: $processed_dir"

    # ILP: create JOBSHEET file
    set jsheet_flag [get_variable_value JSHEET]
    if { $jsheet_flag=="Y" } {
	   status_message "" "...Now creating jobsheet"

	   exec echo "File created to prevent reprocessing while Jobsheet is created.\
		  You need to delete this or quit jobsheet in order to reprocess" > $jobsheet_dir/JOBSHEET_LOCK_$exp_id$job_id
	   start_jobsheet
       status_message "" "Processing complete, output in directory: $processed_dir"
    }
 
    # If an error occurs while processing, c code unsets this variable
    unset processing_in_progress

    set processing_done 1
    
    
}

# um_nav_submit
#  Called when Submit button pressed
# Comments
#  This wrapper prevents effects of SUBMIT being pressed twice in
#  most cases. There is a problem that if a job generates a "not
#  processed" error, then "really_submit_job" can be called directly
#  but this type of event is unlikely to result in a double submission

proc um_nav_submit {} {

    global errorInfo

    if {[get_variable_value SUBMIT_METHOD] == 6 && \
        ([get_variable_value MACH_NAME] == "login.hector.ac.uk" || \
         [get_variable_value MACH_NAME] == "phase2a.hector.ac.uk" || \
         [get_variable_value MACH_NAME] == "phase2b.hector.ac.uk")} {
        dialog .hector "Error" "Please enter phase3.hector.ac.uk in the Job submission method panel" \
	       {} 0 {OK}
	return
    }

    # doingSubmit flag set to 1 during submit process thus preventing
    # a double submission.
    global doingSubmit
    if {[info exists doingSubmit] == 0} {
	set doingSubmit 0
    }
    if {$doingSubmit == 1} {
	# Currently mid-submission so don't do anything
	return
    } else {
	set doingSubmit 1
        set localhost [info hostname]
        if {[string range $localhost 0 3] == "puma"} {
           set checkAndSubmitProc checkAndSubmitPuma
        } else {
           set checkAndSubmitProc checkAndSubmit
        }
	# Catch prevents an error from disabling submit button by
	# leaving doingSubmit set to 1
	if {[catch $checkAndSubmitProc err] == 1} {
	    set doingSubmit 0
	    error $err $errorInfo
	}
	# This update clears out any remaining submit pressings
	# before unsetting flag.
	update
	set doingSubmit 0
    }
}


# checkAndSubmit
#   Checks for anything that the user should be warned of. If there 
#   isn't anything, go ahead and submit. Otherwise require a 
#   confirmation

proc checkAndSubmit {} {

    global processing_done job_title

    if {[info commands .submit] == ".submit"} {
	destroy .submit
    }
    toplevel .submit
    wm geometry .submit +10+200
    wm title .submit "Submission of $job_title to [get_variable_value MACH_NAME]"

    label .submit.rhosts1 -anchor w -text \
	    "If you get a permission denied error, your user name is"
    label .submit.rhosts2 -anchor w -text \
	    "wrong or you need a .rhosts file on the [get_variable_value MACH_NAME] machine."
    message .submit.text -text {} -anchor w -width 500
    frame .submit.buttons
    pack .submit.rhosts1 -anchor w -padx 2m
    pack .submit.rhosts2 -anchor w -padx 2m
    pack .submit.text -anchor w -padx 2m -pady 4m
    pack .submit.buttons

    set message ""
    if {!$processing_done} {
	set message "WARNING: You have not processed the job yet.\n"
    }
    if {$message != ""} {
	.submit.text configure -text "$message"
	button .submit.buttons.continue -text "Submit anyway" -command "
	.submit.text configure -text {}
	destroy_window .submit.buttons.continue 
	destroy .submit.buttons.cancel
	really_submit_job
	"
	button .submit.buttons.cancel -text "Cancel" -command {
	    destroy_window .submit.buttons.continue 
	    destroy .submit
	}
	pack .submit.buttons.continue \
		-pady 2m -padx 2m -ipady 1m -ipadx 2m -side left
	pack .submit.buttons.cancel \
		-pady 2m -padx 2m -ipady 1m -ipadx 2m -side left
	bind_button_list .submit.buttons.continue .submit.buttons.cancel

    } else {
	really_submit_job
    }
}

proc really_submit_job {} {

    global exp_id job_id 
    
    set path [set_output_dir]
    set processed_dir $path/$exp_id$job_id
	set runfile_main "MAIN_SCR"    
	set run_cmd_new "$processed_dir/$runfile_main"

    
	.submit.text configure -text "Calling MAIN_SCR - see console for progress"
	update idletasks
 	eval [list exec $run_cmd_new &]  
#     set submitid [exec date +%j%H%M%S]    
#     eval [list exec $run_cmd_new $submitid &]  

    button .submit.buttons.ok -text "OK" -command {
	destroy_window .submit
    }
    pack .submit.buttons.ok -pady 2m -padx 2m -ipady 1m -ipadx 2m -side left
    
    # Binding for keyboard
    bind_ok .submit .submit.buttons.ok
         
    return       
}

# ======================================
#    ILP Show job history procidures
# ======================================

proc um_job_hist {} {
	global env exp_id job_id job_title

	set path [get_variable_value JOB_OUTPUT]
	set histdir $env(HOME)/$path/job_hist
	set flnm_session $histdir/SESSION_$exp_id$job_id      
	set flnm_history $histdir/HIST_$exp_id$job_id   
    
    set sep " Job ID "
	set wtitle "History of $job_title$sep$exp_id$job_id"
    
    if {[file exists $flnm_history]} {
        # read data from history
        set fileid [open $flnm_history "r"]
        set filedata_h [read $fileid]
        close $fileid
        
        if {[file exists $flnm_session]} {
            # read data from session and add to history
            set fileid [open $flnm_session "r"]
		    set filedata_s [read $fileid]
		    close $fileid
            append filedata_h $filedata_s
        } 
        show_text $filedata_h $wtitle ".jobhist"
    } else {
        if {[file exists $flnm_session]} {
            # read data from session
            set fileid [open $flnm_session "r"]
		    set filedata_s [read $fileid]
		    close $fileid
            show_text $filedata_s $wtitle ".jobhist"
        } else {
            tk_messageBox -message \
            "History file $exp_id$job_id doesn't exist" -type ok
        }
    }
}


proc show_text {textdata wtitle win_name} {

	if {[info commands $win_name] == "$win_name"} {
		destroy $win_name
	}
	
	toplevel $win_name
	set w $win_name
	wm geometry $w +10+300
    wm title $w $wtitle

	text $w.textl \
		-height 30 \
		-xscrollcommand "$w.hscroll set" \
		-yscrollcommand "$w.vscroll set" \
		
	$w.textl insert end $textdata

	scrollbar $w.hscroll -orient horizontal -command "$w.textl xview"
	scrollbar $w.vscroll -command "$w.textl yview"

	button $w.button1 -text "Close" -command "destroy $w"
	frame $w.sepline -width 100 -height 2 -borderwidth 1 -relief sunken

	pack $w.button1 -side bottom
	pack $w.sepline -side bottom -fill x
	pack $w.hscroll -side bottom -fill x
	pack $w.vscroll -side right -fill y
	pack $w.textl -side left	

}

proc um_nav_download {} {

    # call the extended Export proc not the ghui one
    nav_download_new       
}
    

# nav_download_new
#   Creates basis file and (optional) attachment of hand edit and
#   user STASH master files. Call to creation of basis file moved
#   to the UMUI. other GHUI application use up_level GHUI procedure.

proc nav_download_new {} {

    global download_cancel env download_path download_file exp_id job_id

    # If file has not been previously downloaded, compute a default pathname
    if {![info exists download_path]} {
	if [catch {set dir "[get_variable_value JOB_OUTPUT]"}] {set dir ""}
	set download_path(dir) $env(HOME)/$dir
	set download_path(file) basis_$exp_id$job_id
    }

    # ask for filename to download as
    if {[info commands .downl] == ".downl"} {
	destroy .downl
    }
    toplevel .downl
    wm geometry .downl +10+100
    wm title .downl "Export basis file"
    
    message .downl.m -width 800 -text \
	    "Export is used to take a personal copy of a job's basis file,\
	    for example, to email to someone or to save changes when the\
	    server is inaccessible. Optionally, for sending to external\
	    users, the basis file can be saved in a tar file with STASHmaster\
	    and handedit files included."

    entry .downl.e -relief sunken -width 80
    .downl.e insert 0 $download_path(dir)/$download_path(file)

    # Browse command button
    set command "call_filewalk .downl.e"
    button .downl.br -text "Browse" -command $command

    # Cancel command button
    button .downl.ca -text Cancel -command {
	global download_cancel
	destroy .downl
	set download_cancel 1
    }

    # Export command button
    button .downl.ex -text "Export" -command {
	global download_cancel download_path download_file
	set download_file [.downl.e get]
	destroy .downl
	set download_cancel 0
        create_attachment_new $l_attach
    }

    # Check button
    set chck_text "Create attachment from hand edit and user stash master files"
    checkbutton .downl.chkb -text $chck_text -variable l_attach 
    .downl.chkb deselect

    bind .downl.e <Return> {set junk junk}
    focus .downl.e
    pack .downl.m -padx 2m -pady 2m
    pack .downl.e -padx 2m -pady 2m -anchor w
    pack .downl.chkb -padx 2m -pady 2m -anchor w
    pack .downl.ex .downl.br .downl.ca -side left -ipadx 1m -pady 2m -expand yes

    tkwait variable download_cancel
    if $download_cancel return

    # save job to file specified
    set download_file [get_env $download_file]
    write_database $download_file
    set download_path(dir) [directory_of $download_file]
    set download_path(file) [file_of $download_file]
}


# create_attachment_new
#   Creates attachment of all hand edit and user STASH master files.
#   README file shows the state of these files for the job (On/Off).

proc create_attachment_new {l_attach} {
    global download_cancel download_file env download_path exp_id job_id      

    if {$l_attach} {
    # Get requested dir and create temp dir based on its' name
    set w_dir  [directory_of $download_file]
    set w_file [file_of $download_file] 
    set tmp_dir $w_file.attach
    file mkdir $tmp_dir
    set tmp_file $tmp_dir/README.txt
    set fn [open $tmp_file w]
    set total_count 0
    set err_hed_count 0
    set err_table_count 0
    set err_msg ""
    
    # Access hand edit table
    set hed_flnm [get_variable_array HEDFILE]
    set hed_use  [get_variable_array USE_HEDFILE]  
    set hed_count 0  
    
    set tablen [llength $hed_flnm] 
    if {$tablen > 0} {
       # Copy hand edits
       status_message "" "Copying hand edit files..."  
       set hed_dir $tmp_dir/hand_edits
       file mkdir $hed_dir
       puts $fn "Use   Hand edit files\n[string repeat - 55]"
       
       set index 0
       foreach item $hed_flnm {
          set use [lindex $hed_use $index]
          if {[file exists $item]} {
             file copy -force $item $hed_dir   
             incr hed_count      
          } else {
             set use "E"
             incr err_hed_count
          }
          puts $fn [format "%1s %s\n" $use $item]
          incr index
       }
    } else {
       puts $fn "Table with hand edit files is empty\n"
    }
     
    # Access user stash tables. Use list of all models 
    # {A Atmos O Ocean S Slab W Wave} to keep the code
    # compatible with 6.6.x versions
    foreach {var mod_nm} {A Atmos} {
       status_message "" "Copying $mod_nm user stash files..." 
       set use_pre USERPRE_$var 
       set table_nm USERLST_$var
       set use_files [get_variable_value $use_pre]
       set table_rows [get_variable_array $table_nm]    
       set table_count 0
       set stash_dir $tmp_dir/stash_$mod_nm
       set tablen [llength $table_rows] 
       if {$tablen > 0} {
          puts $fn "Use   $mod_nm user stash files\n[string repeat - 55]"
          file mkdir $stash_dir
          foreach item $table_rows {
             if {[file exists $item]} {
                file copy -force $item $stash_dir  
                set use $use_files 
                incr table_count 
             } else {
                set use "E"
                incr err_table_count
             }
             puts $fn [format "%1s %s\n" $use $item]
          
          }
       } else {
          puts $fn "Table with $mod_nm files is empy\n"       
       }                   
       set total_count [expr $hed_count + $table_count]  
    }                  
    close $fn
    
    # Create tar file and inform user about process output
    if {$total_count != 0} {
       status_message "" "Creating tar file..." 
       set current_dir [pwd]
       cd [file dirname $tmp_dir]
       exec tar chf $w_dir/$w_file.attach.tar [file tail $tmp_dir]
       status_message "" "Export Finished" 
       cd $current_dir
       set text "You have requested to create an attachment of hand \
              edit and user stash files. $total_count files were added \
              to the $w_file.attach.tar archive. See README for details."  
       # Add info about failed files    
       if { $err_hed_count!=0 || $err_table_count!=0} {
          set err_msg "\n [expr $err_hed_count + $err_table_count] file(s) \
          were not archived due to error."
          append text $err_msg
       }   
    } else {
       set text "You have requested to create an attachment of hand \
              edit and user stash files. No files were found, so the\
              $w_file.attach.tar archive will not be created. \
              To avoid this message again switch off the option in the \
              Output choices window"
    }              
    dialog .te "Info" $text {} 0 {OK}
    status_message "" ""     
    file delete -force $tmp_dir 
    } 
    
    return 0
}

