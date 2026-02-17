############################################################################
#         Moving focus from window to window when using the keyboard       #
############################################################################
# Moving the focus is based on a stacking system. When a new window is 
# created, a call to push_focus sets the focus to this window and appends
# the focus to the stack. The procedure destroy_window destroys the window
# removes it from the stack and sets the focus to the window at the top of
# the stack. Some widgets such as menus may be hidden but should not be destroyed;
# a call to focus_remove removes the item from the stack and sets the new focus 
# without destroying the window.
#
# If the mouse is used, the order of windows may be upset. The routine clear_focus
# clears the stack and sets focus to the named window - in the GHUI, this is
# called with the name of one or other of the main canvases when the focus
# enters these canvases.
#
# The procedure insert_focus inserts an item at the bottom of the stack.
# This is used in the GHUI when a job is opened read-only. The readonly
# warning window is created before the navigation window so the readonly
# window is pushed onto the stack and then the main canvas is inserted 
# before this window. This means that when the readonly window is destroyed,
# the focus will be set to the main canvas.
#
# If a new dialog box is to be created then:
# If it uses the procedures dialog or multioption_dialog you do not 
# need to do anything.
#
# If it uses the procedure 
# bind_button_list arg1 arg2 [arg3]... do the following
#   - bind_button_list automatically calls push_focus for arg1.
# for each of the button args that result in the window being destroyed 
# add the command 
#   destroy_window arg1 
# in addition to any command that destroys the toplevel window. This ensures
# that the focus is passed to the next item on the stack.
#
# If it uses the procedure 
#  bind_ok [toplevel window name] [button name]
# then the toplevel window is added to the stack (cf bind button list where 
# the button name is added to the stack) and the button destroys the window 
# then bind the button to the command
#  destroy_window (toplevel window name)
# 
# Otherwise:
# On creating or posting a window $win call 
#  push_focus $win
# On destroying the window (including by a button binding) call
#  destroy_window $win
# If the window is to be hidden without being destroyed (eg menus)
# call
#  remove_focus $win


###################################################################
# proc push_focus                                                 #
# pushes window $f onto the focus stack                           #
###################################################################
proc push_focus {f} {
    global focus_stack
    #puts "push_focus called with $f"
    if {[info exists focus_stack]==0} {
	clear_focus $f
	return
    }
    set c [focus]
    #puts "Current focus $c"
    if {$c!=[lindex $focus_stack [expr [llength $focus_stack] -1]] && $c != ""} {
	lappend focus_stack $c
    }
    if {$f==[lindex $focus_stack [expr [llength $focus_stack] -1]]} {
	focus $f
	return
    }
    lappend focus_stack $f
    focus $f
    #puts "focus $f"
    #puts "push_focus added $focus_stack"
}

#########################################################################
# proc destroy_window                                                   #
# Destroys window, removes it from the stack and sets new focus         #
#########################################################################
proc destroy_window {win} {

    # Destroy the toplevel window that holds panel canvas
    catch {destroy $win}
    focus_remove $win
}
##########################################################################
# proc focus_remove                                                      #
# removes $win from the stack and sets new focus without destroying $win #
########################################################################## 
proc focus_remove {win} {
    global focus_stack
    set new_stack ""
    #puts "focus_remove $win from $focus_stack"
    foreach item $focus_stack {
	if {$item!=$win} {lappend new_stack $item}
    }
    set focus_stack $new_stack
    pop_focus
    #puts "New stack is $focus_stack"
}

##########################################################################
# proc clear_focus                                                       #
# clears stack and sets it to $f                                         #
##########################################################################
proc clear_focus {f} {
    global focus_stack
    #puts "Clear focus $f"
    set focus_stack $f
    focus $f
}

##########################################################################
# proc insert_focus_stack                                                #
# Adds $f to bottom of focus stack                                       #
##########################################################################
proc insert_focus_stack {f} {
    global focus_stack
    #puts "Clear focus stack $f"
    if {[info exists focus_stack]==0} {set focus_stack {} }
    set focus_stack [concat $f $focus_stack]
    #puts "focus_stack $focus_stack"
    pop_focus
}

##########################################################################
# proc pop_focus                                                         #
# Sets focus to uppermost existing item on stack and removes items above #
##########################################################################
proc pop_focus {} {
    global focus_stack

    #puts "pop_focus called"
    if {[set l [llength $focus_stack]] == 0} {
	#puts "Error: run out of stack $focus_stack"
	return
    }
    

    for {} {$l>=1} {} {
	incr l -1
	set new_focus [lindex $focus_stack $l]
	if {[catch {focus $new_focus} ]!=1} {
	    #puts "Setting focus to $new_focus"
	    break
	}
    }
    set focus_stack [lrange $focus_stack 0 $l]
    #puts "pop_focus $focus_stack"
}


