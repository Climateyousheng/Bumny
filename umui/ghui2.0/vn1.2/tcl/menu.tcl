#==============================================================================
# RCS Header:
#   File         [$Source: /home/hc0300/umui/srce_code/GHUI_archive/ghui2.0/vn1.2/tcl/menu.tcl,v $]
#   Revision     [$Revision: 1.1 $]     Named [$Name: head#main $]
#   Last checkin [$Date: 2000/08/15 11:46:22 $]
#   Author       [$Author: umui $]
#==============================================================================

#
# menu.tcl
#
#   Provides package for generating menubars.

namespace eval menuBar {
    namespace export mbMenuSetup
    namespace export mbMenu
    namespace export mbMenuSeparator
    namespace export mbMenuCommand
    namespace export mbMenuCascade
    namespace export mbMenuRadio
    namespace export mbMenuCheck
    namespace export mbMenuBind
}

# MenuSetup
#  Associate a menubar with a toplevel window name
# Argument
#  menubar : Menubar widget name

proc ::menuBar::mbMenuSetup {m} {
    variable menu
    menu $m
    bind $m <Destroy> [namespace code "MBDestroyMenubar $m"]
    # Associate menu with its main window
    set top [winfo parent $m]
    $top configure -menu $m
    set menu($m,menuName) $m
    set menu($m,uid) 0
    return $m
}

# mbMenu
#   Adds a new cascade menu to menubar
# Arguments
#   m : Identity of menubar
#   label : Label to display, and also identity of menu
#   underline : If 1, underline unique letter as accelerator

proc ::menuBar::mbMenu {m label {underline "yes"}} {
    variable menu
    if [info exists menu($m,menu,$label)] {
	error "menuBar: Menu $label already defined"
    }
    # Create the cascade menu
    set menuName $m.mb$menu($m,uid)
    incr menu($m,uid)
    menu $menuName -tearoff 1
    if {$underline == "no"} {
	$m add cascade -label $label -menu $menuName
    } else {
	$m add cascade -label $label -menu $menuName \
		-underline [MBUnderlineLetter $m $label $underline]
    }
    # Remember the name to menu mapping
    set menu($m,menu,$label) $menuName
}

# MBUnderlineLetter
#   Determines unique letter to underline
# Arguments
#   m : Identity of menubar
#   label : Name of label
#   underline : Underline option. Either chosen letter, or 1 which 
#               results in unique letter being chosen

proc ::menuBar::MBUnderlineLetter {m label underline} {
    variable menu

    set l [string tolower $label]

    if {$underline != "yes"} {
	set letter [string tolower $underline]
	if {[info exists menu($m,underlineList)] != 0} {
	    if {[lsearch $menu($m,underlineList) $letter] != -1} {
		error "menuBar: Menu accelerator letter $underline for item $label already used"
	    }
	}
    } else {
	if {[info exists menu($m,underlineList)] == 0} {
	    set letter [string index $l 0]
	} else {
	    set letter ""
	    for {set i 0} {$i < [string length $l]} {incr i} {
		set pl [string index $l $i]
		if {[regexp {[a-z]} $pl] == 1 && [lsearch $menu($m,underlineList) $pl] == -1} {
		    set letter $pl
		    break
		}
	    }
	    if {$letter == ""} {
		error "menuBar: No unique accelerator letter could be found for menu item $label"
	    }
	}
    }
    lappend menu($m,underlineList) $letter
    set index [string first $letter $l]
    if {$index == -1} {
	error "menuBar: Accelerator letter $letter not found in $label"
    }
    if {[regexp {[a-z]} $letter] == 0} {
	error "menuBar: Accelerator key should be a letter"
    }
    return $index
}


# mbMenuCommand
#   Add standard menu option that calls a command
# Arguments
#   menuName : Name of cascade menu
#   label : Name of new label
#   command : Command to call when selected

proc ::menuBar::mbMenuCommand {m menuName label command} {
    set mb [MBMenuGet $m $menuName]
    $mb add command -label $label -command $command
}

# mbMenuCheck
#   Add a checkbutton item to a cascade menu
# Arguments
#   menuName : Name of cascade menu
#   label : Name of new label
#   var : Name of global variable
#   command : Optional command to implement when button toggled

proc ::menuBar::mbMenuCheck {m menuName label var {command {} } } {
    set mb [MBMenuGet $m $menuName]
    $mb add check -label $label -command $command \
	    -variable $var
}

# mbMenuRadio
#   Add a radiobutton item to a cascade menu
# Arguments
#   menuName : Name of cascade menu
#   label : Name of new label
#   var : Name of global variable
#   val : Default value to set
#   command : Optional command to implement when button toggled

proc ::menuBar::mbMenuRadio {m menuName label var {val {}} {command {}} } {   
    set mb [MBMenuGet $m $menuName]
    if {[string length $val] == 0} {
	set val $label
    }
    $mb add radio -label $label -command $command \
	    -valu $val -variable $var
}

# mbMenuSeparator
#   Add a separator line to a cascade menu
# Arguments
#   menuName : Name of cascade menu

proc ::menuBar::mbMenuSeparator {m menuName} {
        [MBMenuGet $m $menuName] add separator
}

# mbMenuCascade
#   Add a submenu to an item in an existing cascade menu
# Arguments
#   menuName : Name of cascade menu
#   label : Name of new label to which submenu is attached

proc ::menuBar::mbMenuCascade {m menuName label} {
    variable menu
    set mb [MBMenuGet $m $menuName]
    if [info exists menu($m,menu,$label)] {
	error "menuBar: Menu $label already defined"
    }
    set sub $mb.sub$menu($m,uid)
    incr menu($m,uid)
    menu $sub -tearoff 0
    $mb add cascade -label $label -menu $sub
    set menu($m,menu,$label) $sub
}

# mbMenuBind
#   Bind a key sequence to a menu item
# Arguments
#   what : Name of widget with focus when key event happens
#   sequence : Key event
#   menuName : Name of cascade menu
#   label : Name of item in menu

proc ::menuBar::mbMenuBind {m what sequence menuName label} {
    variable menu
    set mb [MBMenuGet $m $menuName]
    if [catch {$mb index $label} index] {
	error "menuBar: $label not in menu $menuName"
    }
    set command [$mb entrycget $index -command]
    bind $what $sequence $command
    $mb entryconfigure $index -accelerator $sequence
}

# mbMenuDestroy
#   Destroy instance of menu and clear array
# Arguments
#   m : Menu bar

proc ::menuBar::MBDestroyMenubar {m} {
    variable menu

    if {[info commands $m] == "$m"} {destroy $m}

    # Clear out array
    foreach index [array names menu $m,*] {
	unset menu($index)
    }
}

# MBMenuGet
#   Private procedure to return name of menubar holding particular menu
# Arguments
#   menuName : Name of cascade menu

proc ::menuBar::MBMenuGet {m menuName} {
    variable menu
    if [catch {set menu($m,menu,$menuName)} m] {
	return -code error "menuBar: No such menu: $menuName"
    }
    return $m
}

proc menuBarTestProc {} {
    namespace import menuBar::*
    set m [mbMenuSetup .menubar]
    mbMenu $m Sampler 
    mbMenu $m Simpler 
    mbMenu $m Sumpler 
    mbMenu $m Suei 
    mbMenuCommand $m Sampler Hello! {puts "Hello World!"}
    mbMenuCheck $m Sampler Boolean foo {puts "foo = $foo"}
    mbMenuSeparator $m Sampler
    mbMenuCascade $m Sampler Fruit
    mbMenuRadio $m Fruit apple fruit
    mbMenuRadio $m Fruit orange fruit
    mbMenuRadio $m Fruit kiwi fruit
    mbMenuCascade $m Sampler Options
    mbMenuCommand $m Options Opt1 {puts "Option 1"}
    mbMenuCommand $m Options Opt2 {puts "Option 2"}
    mbMenuCommand $m Options Opt3 {puts "Option 3"}
    
    pack [frame .f -width 300 -height 50]
    focus .f
    mbMenuBind $m .f <space> Sampler Options
}
