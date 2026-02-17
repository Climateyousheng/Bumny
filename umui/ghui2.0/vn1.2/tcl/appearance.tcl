# Appearance and style of the GHUI.
proc set_appearances {app} {

    #+
    # TREE: experiment_instance set_appearances
    #-

    global tk_strictMotif
    global fonts font font_labels font_radchk font_tables
    global font_tabhed font_butons font_help
    global component_height gap_height indent_width
    global col_text_normal col_text_grayed col_bg_normal col_checkbutton_hilit 
    global col_tab_element col_tab_heading col_tab_selected

    # Motif like behaviour
    set tk_strictMotif 1

    # Fonts

    # Status line font: Normal value "helvetica 9"
    set fonts(lines)   "helvetica 9"
    # GHUI Main navigation window font. Normal value "helvetica 9"
    set fonts(navigation) "helvetica 9"
    # GHUI panel fonts (text, checkbutton widgets etc) Normal value "helvetica 11"
    set fonts(normal) "helvetica 11"
    set fonts(menus) "helvetica 11 bold"
    # GHUI table fonts. Normal values "helvetica 11 bold" and "courier 10"
    set fonts(tables,headings) "helvetica 11 bold"
    set fonts(tables,entries)  "courier 10"
    # Large buttons and menubuttons. Normal value "times 14"
    set fonts(buttons) "times 14"
    # Small dialog boxes. Normal value "times 14"
    set fonts(message) "times 14"
    # Used when outputting chunks of text. Normal values "courier 11"
    set fonts(textOutput) "courier 11"

    ###########################################################
    #The following few are only required to support UMUI STASH code
    # STASH buttons
    set font_butons "helvetica 11 bold"         ; # Normally "helvetica 11 bold"  
    # Size of Profile name boxes
    set font_tables "courier 10"        ; # Normally "courier 10"
    # Size of profile headings
    set font_tabhed "helvetica 11 bold" ; # Normally "helvetica 11 bold"
    ###########################################################

    # Colours
    set col_checkbutton_hilit lightBlue
    set col_text_normal black
    set col_text_grayed gray60
    set col_bg_normal gray80

    set col_tab_element gray80
    set col_tab_heading gray70
    set col_tab_selected lightblue

    # Height of components (in pixels due to bug in frame!)
    set component_height 25
    set gap_height 25

    # Width of indentation of blocks in pixels
    set indent_width 25

    # clear keyboard focus when clicking outside an entry box.
    bind all <Any-ButtonPress> {focus ""}
    
    # All components except buttons should have zero highlightthickness
    option add *highlightThickness 0
    option add *Button*highlightThickness 1
    option add *foreground $col_text_normal
    option add *background $col_bg_normal
    option add *Scrollbar.foreground gray80
    option add *Scrollbar.background gray70
    option add *disabledForeground $col_text_grayed

    # Run the application specific appearance procedure if one exists
    if {[info procs "applicationAppearance"] == "applicationAppearance"} {
	applicationAppearance
    }

    # Read in over-rides from user's file in home director call
    # .{application name}_appearance.
    set test [ file readable "~/.$app\_appearance" ]
    if { $test == 1 } {
      # appearance file exists. Open file.
      set file_id [ open "~/.$app\_appearance" r ]
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

    # Set standard fonts for various widgets
    option add *Button*font      $fonts(buttons)
    option add *Menubutton*font  $fonts(buttons)
    option add *Menu*font        $fonts(menus)
    option add *Radiobutton*font $fonts(normal)
    option add *Checkbutton*font $fonts(normal)
    option add *Label*font       $fonts(normal)
    option add *Message*font     $fonts(message)
    option add *Entry*font       $fonts(normal)
    option add *Listbox*font     $fonts(normal)
    option add *Dialog*Message*font $fonts(normal)

}
