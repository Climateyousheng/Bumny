# binding.tcl
#
#    Functions for setting up standard bindings to various panel 
#    widgets
#

# All routines have the same set of arguments:
# Arguments
#    win : Relates to the name of the window panel.
#    name: Widget name
#
#----------------------------------------------------------------------

# standard_bindings
#    Standard bindings for entry-box, check-box and vertically-aligned
#    radiobutton widgets.

proc standard_bindings {win name} {

    bind $name <Up> "tab_up $win"
    bind $name <Down> "tab $win"
    #bind $name <Tab> "+tab $win"
    bind $name <Return> "+tab $win"

}

# focus_appearance
#    Sets appearance of widgets as focus moves in and out

proc focus_appearance {win name} {
    # Appearance affect of focus

    bind $name <FocusIn> "$name configure -relief groove"
    bind $name <FocusOut> "$name configure -relief flat"
}

# button_bindings
#    Bindings for closing, quitting and help. Keyboard bindings for
#    these functions have been removed due to mainenance problems.

proc button_bindings {win name} {

    #global window_name
    #global close_proc quit_proc
    #if {[info exists close_proc]==0} {set close_proc "NONE"}
    #if {[info exists quit_proc]==0} {set quit_proc "NONE"}
    
    set window_file [string range [toplev_name $win] 1 end]
    bind $name <F1> "window_help $window_file"
    bind $name <Control-h> "window_help $window_file"
    #bind $name <Control-c> "close_pushed $win $window_name \{$close_proc\}"
    #bind $name <Control-q> "quit_pushed $win \{$quit_proc\}"

}


proc entry_binding {win name} {
    # Bindings for entry boxes

    standard_bindings $win $name
    button_bindings $win $name
}

proc check_binding {win name} {
    # Bindings for check boxes

    standard_bindings $win $name
    focus_appearance $win $name
    button_bindings $win $name
}

proc basrad_binding_v {win name} {
    # Bindings for vertically lying radiobuttons

    standard_bindings $win $name
    focus_appearance $win $name
    button_bindings $win $name
}

proc basrad_binding_h {win name} {
    # Bindings for horizontally lying radiobuttons

    bind $name <Left> "tab_lr $win l"
    bind $name <Right> "tab_lr $win r"
    bind $name <Up> "tab_lr $win u"
    bind $name <Down> "tab_lr $win d"
    #bind $name <Tab> "+tab_lr $win d"
    bind $name <Return> "+tab_lr $win d"
    focus_appearance $win $name
    button_bindings $win $name

}

proc binding_of_buttons {win name} {
    # Bindings for horizontally lying radiobuttons

    bind $name <Left> "tab_lr $win l"
    bind $name <Right> "tab_lr $win r"
    bind $name <Up> "tab_lr $win u"
    bind $name <Down> "tab_lr $win d"
    #bind $name <Tab> "+tab_lr $win d"
    bind $name <Return> "+tab_lr $win d"

    bind $name <FocusIn> "$name configure -state active"
    bind $name <FocusOut> "$name configure -state normal"

    button_bindings $win $name
}

