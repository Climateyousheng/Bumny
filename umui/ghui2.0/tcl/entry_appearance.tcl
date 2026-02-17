# global variables for the appearance of the entry system
#

proc entry_appearance {} {

    global menus lines titles colours tk_strictMotif fonts icons base_dir
    global col_text_normal col_text_grayed 
    global maxlines line_height init_lines no_cols
    global number_of_lines line_height

    set tk_strictMotif 1

    # colours
    set col_text_normal black
    set col_text_grayed gray60
    set colours(title_bg_normal) pink
    set colours(title_bg_filter) orange
    set colours(select_bg) lightblue
    set colours(unselect_bg) gray80
    set colours(enabled_fg) black
    set colours(disabled_fg) gray60
    option add *foreground $colours(enabled_fg)
    option add *background $colours(unselect_bg)
    option add *disabledForeground $colours(disabled_fg)
    option add *Scrollbar.foreground gray80
    option add *Scrollbar.background gray70

    # fonts
    option add *font   *lucidatypewriter-medium-r-normal-*-*-120-100-100-m*
    set fonts(lines)   *lucidatypewriter-medium-r-normal-*-*-100-100-100-m*
    set fonts(menus)   *helvetica-bold-r-normal-*-*-100-100-100-p*
    set fonts(help)    *-courier-medium-r-normal--*-140-*
    set fonts(buttons) *-times-medium-r-normal--*-180-*

    # Entry box return key binding to do nothing
    bind Entry <Return> {set junk junk}

    # icons
    set icons(blank) @$base_dir/icons/blank.xbm
    set icons(closed) @$base_dir/icons/closed.xbm
    set icons(open) @$base_dir/icons/open.xbm
    set icons(icon) @$base_dir/icons/icon.xbm
    # Ros (March 07)
    # Icons for use with experiment privacy
    set icons(closed_private) @$base_dir/icons/closed_private.xbm
    set icons(open_private) @$base_dir/icons/open_private.xbm

    # menu titles
    set menus(titles) {File Search Experiment Job Help}

    # File menu
    set menus(items-File) {open_r open_rw GAP quit}

    set menus(text-File-open_r) {Open read only}
    set menus(text-File-open_rw) {Open read write}
    set menus(text-File-quit) Quit

    # Find menu
    set menus(items-Search) {filter reload}

    set menus(text-Search-filter) Filter...
    set menus(text-Search-reload) Reload

    # Experiment menu
    set menus(items-Experiment) {exp_new exp_copy exp_delete \
	    exp_download GAP exp_description make_operational \
	    exp_chown change_privacy access_list}

    set menus(text-Experiment-exp_new) New...
    set menus(text-Experiment-exp_copy) Copy...
    set menus(text-Experiment-exp_delete) Delete
    set menus(text-Experiment-exp_download) Download
    set menus(text-Experiment-exp_description) {Change description...}
    set menus(text-Experiment-make_operational) {Make operational}
    set menus(text-Experiment-exp_chown) {Change ownership}
    # Ros (15.03.07)
    # Ability to make experiments private
    set menus(text-Experiment-change_privacy) {Change privacy...}
    set menus(text-Experiment-access_list) {Access list...}

    # Job menu
    set menus(items-Job) {job_new job_copy job_delete job_close GAP \
	    job_description change_identifier \
	    upgrade_version GAP diff}

    set menus(text-Job-job_new) New...
    set menus(text-Job-job_copy) Copy...
    set menus(text-Job-job_delete) Delete...
    set menus(text-Job-job_close) {Force Close...}
    set menus(text-Job-job_description) {Change description...}
    set menus(text-Job-change_identifier) {Change identifier...}
    set menus(text-Job-upgrade_version) {Upgrade version...}
    set menus(text-Job-diff) Difference

    # Help menu
    set menus(items-Help) {help_intro GAP help_general help_file help_find help_exp help_job help_fonts}

    set menus(text-Help-help_intro) Introduction
    set menus(text-Help-help_general) General
    set menus(text-Help-help_file) {File menu}
    set menus(text-Help-help_find) {Search menu}
    set menus(text-Help-help_exp) {Experiment menu}
    set menus(text-Help-help_job) {Job menu}
    set menus(text-Help-help_fonts) {Changing fonts}
    # Read in over-rides from user's file in home director call
    # .{application name}_appearance.
    set test [ file readable "~/.ghui_appearance" ]
    if { $test == 1 } {
	# appearance file exists. Open file.
	set file_id [ open "~/.ghui_appearance" r ]
	set icode 0
	while { $icode != -1 } {
	    # read each line and execute.
	    set icode  [ gets $file_id line ]
	    if { $icode != -1 } {
		eval $line
	    }
	} 
	close $file_id 
    }

    # maximum number of lines for experiments and jobs
    # Do it here so that values can be overwritten by appearance file
    set maxlines 25
    #  set line_height 32

    # number_of_lines is initially obtained from application definition 
    # file. Put it into lines to define max number of experiments and 
    # jobs to display
    set lines $number_of_lines
    set init_lines $lines

}
