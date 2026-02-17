# proc navigation
#
# Creates a instance of the navigation system

proc navigation {} {

    #+
    # TREE: experiment_instance navigation
    #-

    global c d nav_icons tree item c_width job_title
    global job_id exp_id
    global pos fonts application

    # If re-entering, remove tree before re-reading file

    if {[info exists tree]} {unset tree}
    set item 0 

    # Width of a cell for this font.
    set c_width 20

    # Set up path to nav spec file and icons
    set nav_file [navspec_file]
    set nav_icons [ghui_version_path]/icons
    wm title . "$application application. Navigation of $job_title"
    wm iconname . "$exp_id$job_id \n$application"
    wm iconbitmap . "@$nav_icons/icon.xbm"

    # Hierarchy of Navigation panel:
    # Main part of window which contains navigation tree and panel lists
    set fTop .fTop
    frame .fTop

    # fTop is split down the middle, navigation tree to the left, list 
    # of panels to the right
    set fTree $fTop.left
    set fPanel $fTop.right
    # Set up main window
    frame $fTree -relief raised -bd 2
    frame $fPanel -relief raised -bd 2
    # Secondary frames hold the canvas. These are required to add a border
    # to the canvas which changes appearance depending on where the focus
    # is. You can't do the appearance change with $fTree and $fPanel
    # as it would affect the appearance of the scrollbar as well
    frame $fTree.c 
    frame $fPanel.c 

    # The canvases - these are global variables (yuk!)
    set c $fTree.c.c
    set d $fPanel.c.c
    set vScrollTree $fTree.vscroll
    set vScrollPanel $fPanel.vscroll

    # Secondary part of window which is below main part and contains 
    # buttons
    set fBottom .fBottom
    frame $fBottom
    make_buttons $fBottom

    # Finally there is a status line at the very bottom
    create_status_line "" $fonts(lines)

    # Generate canvas and scrollbars
    # Must define y coord of canvases in terms of pixels because values 
    # are used by scrolling routines for testing whether edge of canvas 
    # has been reached
    canvas $c -scrollregion {0 0 15 1500}  -height 14c -width 10c \
	    -yscrollcommand "$vScrollTree set" \
	    -yscrollincrement $c_width \
	    ;# -xscrollcommand "$fTree.hscroll set"
    canvas $d -scrollregion {0 0 15 1500}   -height 14c -width 10c \
            -yscrollcommand "$vScrollPanel set" \
	    -yscrollincrement $c_width \
	    ;# -xscrollcommand "$fPanel.hscroll set" -yscrollincrement $c_width
    scrollbar $vScrollTree  -relief sunken -command "$c yview"
    scrollbar $vScrollPanel  -relief sunken -command "$d yview"

    # Horizontal scrollbars not in use
    #scrollbar $fTree.hscroll  -orient horiz -relief sunken \
	    -command "$c xview"
    #scrollbar $fPanel.hscroll  -orient horiz -relief sunken \
	    -command "$d xview"
    #pack $fTree.hscroll -side bottom -fill x
    #pack $fPanel.hscroll -side bottom -fill x


    # Pack everything. Pack buttons first so they stay on screen if window
    # size is reduced
    pack $fBottom -side bottom -fill x
    pack $fTop -fill both -expand yes 
    pack $vScrollTree -side right -fill y
    pack $vScrollPanel -side right -fill y
    pack $c -in $fTree.c -fill both -expand yes -padx 5 -pady 5 
    pack $d -in $fPanel.c -fill both -expand yes -padx 5 -pady 5 
    pack $fTree.c -in $fTree -fill both -expand yes -after $vScrollTree
    pack $fPanel.c -in $fPanel -fill both -expand yes -after $vScrollPanel
    pack $fTree -side left -fill both -expand yes
    pack $fPanel -side left -fill both -expand yes


    bind $c <FocusIn> "$fTree.c configure -background grey60"
    bind $c <FocusOut> "$fTree.c configure -background grey80"
    bind $c <1> "focus $c"
    bind $d <FocusIn> "$fPanel.c configure -background grey60"
    bind $d <FocusOut> "$fPanel.c configure -background grey80"
    bind $d <1> "focus $d"

    # Set up event bindings for canvases:

    bind $c <1> "+mouse_next_level $c"
    bind $c <2> "$c scan mark %x %y"
    bind $c <B2-Motion> "$c scan dragto %x %y"
    bind $d <1> "+mouse_next_level $d"
    bind $d <2> "$d scan mark %x %y"
    bind $d <B2-Motion> "$d scan dragto %x %y"
#    bind . <Any-Enter> "if \{%w==\".\"\} \{clear_focus $c\}"
    bind . <Any-Enter> {if {"%w" == "."} {clear_focus $c}}

    bind $c <space> "key_next_level $c"
    bind $c <Up>  "key_up $c"
    bind $c <Down>  "key_down $c"
    bind $c <Right>  "key_right $c"
    bind $c <Configure> [list $c configure -height %h]

    bind $d <space> "key_next_panel $c"
    bind $d <Up>  "key_panel_up $d"
    bind $d <Down>  "key_panel_down $d"
    bind $d <Left>  "key_left $d"
    bind $d <Configure> [list $d configure -height %h]

    #bind $c <l> "puts \[$c configure\]"

    # Tcl8 bodge - commented out next 2 lines
    # bind $c <Configure> "puts %h;$c config -height %h"
    # bind $d <Configure> "$d config -height %h"
    #bind $c <k> "$c yview \[expr %y+1\];puts %y"
    #bind $c <j> "$c yview \[expr %y-1\];puts %y"

    # Open the file, read in the tree and set up internal tree.

    set f [open $nav_file r]

    # The main database for the nav system is an associative array called
    # 'tree'. It is 2 dimensional, one index is the name of the panel / node
    # and the other is an attribute of the node, such as 'parent' 'x_position'
    # etc. The array also has some single dimension elements which are used
    # as global variables, but refer only to that tree.

    # Initialise the tree

    set nodots 0
    set levels(0) root
    set tree(root,y_pos) 1
    set tree(root,x_pos) 1
    set tree(root,expand) 0
    set tree(highlight) root
    set tree(entered) root
    set tree(lines) 1

    while {[gets $f line] >= 0} {
        
	# Count the number of dots and decide if we've gone up/down a level
	set n 0 
	while {[string index $line $n] == "."} { incr n }

	set type [string index $line $n]
        set first_char [string index $line 0]
	if { ($first_char != "#" ) && ($type != ">") } {
	    # not a follow-on window  or a comment line (these are ignored).
	    set name [lindex [split $line " "] 1]

	    if {$type=="t"} {
		# Duplicated node so add unique prefix to start
		set prefix [get_next_id $name]
		set name "$prefix\_$name"
	    } elseif {$type=="s"} {
		# Duplicate panel so designate as such with _ character
		set name "_$name"
	    } elseif [regexp {[1-9_]} [string index $name 0]] {
		# Numbers and understrokes are special characters - disallow from nav.spec
		error "Reading nav.spec - do not start names with an integer or understroke (name $name)"
	    } elseif [info exists tree($name,title)] {
		#puts "Duplicate panel $name"
	    }
	    set title [lindex [split $line "\""] 1]
	    set tree($name,title) $title 

	    # 'levels' is a array of the immediate hierachy, 'n' is an 
	    # index indicating the current level.

	    if {$n > $nodots} {
		set nodots $n 
		set levels($n) $name 
	    }
	    if {$n < $nodots} { 
		set nodots $n 
		if {($type == "n") || ($type == "t")} { 
		    set levels($n) $name 
		}
	    } 
	    set above $levels([expr $n -1])
	    set tree($name,above) $above
	    if {[info exists tree($above,below)]} { 
		lappend tree($above,below)  $name 
	    } else { 
		set tree($above,below) [list $name]
	    }
	    set tree($name,type) $type
	    set tree($name,expand) 0
	    if {($type == "n") || ($type == "t")} { 
		set levels($n) $name 
	    }
	} 
	#  end of if { $type != ">" } 
    } 
    #  end of while loop on lines 

    # Render first level of tree onto Canvas
    # and highlight the first node
    insert_focus_stack $c
    highlight_node [expand_node root] $c

    # Include logo - currently not set up fully
    #set image [image create photo -file ~hadsm/temp/top.gif]
    #set imSize 60
    #update idletasks
    #bind $d <Configure> [list +displayLogo $d %w %h $image $imSize $imSize]
}

##########################################################################
# proc get_next_id                                                       #
# get a new unique identity number for a duplicated node                 #
##########################################################################

proc get_next_id {name} {
    global tree
    set i 1
    while {[info exists tree($i\_$name,type)]} {incr i}
    return $i
}

# scroll_canvasy
#   Calculates new position if canvas $c is scrolled one point 
#   in direction $direction.
# Arguments
#   c: canvas to scroll
#   direction: 1 for up and -1 for down
# Result
#   Return new position in pixels or -1 if position should
#   remain the same.

proc scroll_canvasy {c direction} {

    # y_pos is position in pixels
    set y_pos [$c canvasy 0]

    # increment is also in pixels
    set increment [lindex [$c config -yscrollincrement] 4]

    # Scroll region
    set scrollreg [lindex [lindex [$c config -scrollregion] 4] 3]

    # Get current height of canvas display area in pixels
    set height [lindex [$c config -height] 4]

    # Point where further scrolling not needed
    set max_y_pos [max 0 [expr $scrollreg-$height]]

    # Do not change position if at the top and going up or if
    # at the bottom and going downwards.
    if {($y_pos != 0 || $direction != -1) && ($y_pos != $max_y_pos || $direction != 1)} {
	set new_pos [expr ($y_pos + $direction * $increment)/$scrollreg]
	if {$new_pos < 0} {
	    set new_pos 0
	} elseif {$new_pos > $max_y_pos} {
	    set new_pos $max_y_pos
	}
	return $new_pos
    }
    return -1
	
}

##########################################################################
# proc scroll_canvasx                                                    #
# Scroll canvas $c one point left or right in direction $direction       #
##########################################################################
proc scroll_canvasx {c direction} {

    # x_pos is position in pixels
    set x_pos [$c canvasx 0]

    # increment is also in pixels
    set increment [lindex [$c config -xscrollincrement] 4]

    # Scroll region
    set scrollreg [lindex [lindex [$c config -scrollregion] 4] 2]

    # Get current height of canvas display area in pixels
    set width [lindex [$c config -width] 4]

    set max_x_pos [max 0 [expr $scrollreg-$width]]

    set new_pos [expr ($x_pos + $direction * $increment)/$scrollreg]
    if {$new_pos<0} {
	set new_pos 0
    } elseif {$new_pos>$max_x_pos} {
	set new_pos $max_x_pos
    }
    return $new_pos
}

##########################################################################
# proc reposition_canvas                                                 #
# Called with canvas id and tag of item                                  # 
# Scrolls canvas till tag within clear view                              #
##########################################################################
proc reposition_canvas {c tag} {

    set c_pos [lindex [$c coords $tag] 1]
    while {[move_within_view $c $c_pos]==1} {}
}

# scrollregionBorder
#   Defines a border at the top and the bottom of the scrollregion
#   to ensure that the selected node is not partly off the screen
# Comments
#   Central procedure used as it has to be consistent when moving 
#   canvas and when calculating scrollregion otherwise an endless 
#   loop can ensue.
#    Choice of 40 related to the fact that position of top node is 40.
#   The value of 40 must be duplicated in the recalcTreeScrollregion
#   procedure to prevent endless loop

proc scrollRegionBorder {} {
    return 40
}

# move_within_view
#   If $pos is not within view then scroll one step in appropriate 
#   direction. Returns 1 if scrolling was needed and 0 otherwise

proc move_within_view {c pos} {

    set border [scrollRegionBorder]

    # top is position in pixels of screen top
    set top [$c canvasy 0]

    # Get current height of canvas display area
    set height [lindex [$c config -height] 4]

    set new_pos -1
    if { $pos <= [expr $top+$border] } {
	# pos is too high so scroll up
	set new_pos [scroll_canvasy $c -1]
    } elseif { $pos > [expr $top+$height-$border]} {
	# pos is too low so scroll down
	set new_pos [scroll_canvasy $c 1]
    }

    if {$new_pos >=0 } {
	# A new position has been set so move to it and return 1
	$c yview moveto $new_pos
	return 1
    }
    return 0
    
}
# recalcTreeScrollregion
#   Recalculates the scrollregion of the canvas so that the scrollbar
#   is appropriately sized and positioned for the tree

proc recalcTreeScrollregion {c} {

    set border [scrollRegionBorder]
    # Get the name of the last node
    set lastNode [last_leaf_of "root"]
    set nodePos [lindex [$c coords $lastNode] 1]
    $c configure -scrollregion [list 0 0 0 [expr $nodePos+$border]]
}




##########################################################################
# proc mouse_next_level                                                  #
# Obtain name of item that mouse clicked onto and then call next_level   #
##########################################################################

proc mouse_next_level {c} {

    #+
    # TREE: experiment_instance navigation next_level
    #-

    set item [$c gettags current]
    next_level $c $item
}

##########################################################################
# proc key_next_level                                                    #
# get name of highlit item and then call next_level                      #
##########################################################################

proc key_next_level {c} {

    #+
    # TREE: experiment_instance navigation next_level
    #-
    global tree
    set item $tree(highlight).t
    next_level $c $item
}
##########################################################################
# proc key_next_panel                                                    #
# get name of highlit item and then call next_level to open panel        #
##########################################################################

proc key_next_panel {c} {

    #+
    # TREE: experiment_instance navigation next_level
    #-
    global tree
    set item $tree(entered).t
    next_level $c $item
}


#############################################################################
# proc create_duplicate_node                                                #
# ..t nodes are recreated from original with a different numerical prefix   #
# for each instance of the repeated node                                    #
#############################################################################

proc create_duplicate_node {name} {

    global tree

    if [info exists tree($name,below)] {
	# Node previously been recreated so return
	return
    }
    # name is in form $number_window_name
    # Get name of original node oname, and prefix id
    set oname [string range $name [expr [string first "_" $name]+1] end]
    set id [string range $name 0 [expr [string first "_" $name]-1]]

    if [info exists tree($oname,below)] {
	# Recreate the tree variables for this instance of the node
	set tree($name,below) ""
	foreach item $tree($oname,below) {
	    if {[string index $item 0]=="_"} {
		# This is a ...s duplicate panel - do not want two understrokes 
		# so remove one before creating nitem below
		set item [string range $item 1 end]
	    } elseif [regexp {[1-9]} [string index $item 0]] {
		error "Cannot have ..t nodes within ..t nodes"
	    } 
	    set nitem "$id\_$item"
	    lappend tree($name,below) $nitem
	    set tree($nitem,above) $name
	    set tree($nitem,title) $tree($item,title)
	    set tree($nitem,expand) 0

	    if {($tree($item,type)=="p")||($tree($item,type)=="s")} {
		# All panels are duplicate
		set tree($nitem,type) "s"
	    } else {
		# all nodes are duplicate
		set tree($nitem,type) "t"
		# Create duplicate subnode by recursive call
		create_duplicate_node $nitem
	    }
	}
    }
}


##########################################################################
# proc next_level                                                        #
# Called with name of item which may be visible node or panel            #
# If it is a node, expand it. If a panel, open it                        #
##########################################################################

proc next_level {c item} {
    #+
    # TREE: experiment_instance navigation mouse_next_level next_level
    #     : experiment_instance navigation key_next_level next_level
    #-
    global tree d

    set ilist [split [lindex $item 0] .] 

    # Check that an item is actually selected

    if {[llength $ilist] != 0} {

	set name [lindex $ilist 0]

	# If it's a node, expand it down one level
	if {($tree($name,type) == "n") || ($tree($name,type) == "t")} { 

	    expand_node [lindex $ilist 0]

	} else {

	    # Otherwise it's a panel, so enter it.

	    # highlight the panel.

	    $d itemconfig $tree(entered).t -fill black

	    set tree(entered) $name


	    $d itemconfig $name.t -fill white
	    $d configure -cursor watch
	    status_message "" "Building window..."
	    update idletasks

	    if {([string index $name 0]=="_")||([regexp {[1-9]} [string index $name 0]])} {
		# A ...s panel. Remove initial _ to form window name
		set win [string range $name [expr [string first "_" $name]+1] end]
	    } else {
		set win $name
	    }

	    create_window $win  
	    $d configure -cursor arrow
	    clear_message ""
	    update
	}
    }
}			

##########################################################################
# proc key_up                                                            #
# Up key pressed. Set current node to visible node above current node    #
##########################################################################

proc key_up {c} {
    global tree

    # Get current node
    set node $tree(highlight)
    if {$node=="root"} {return}

    # Get node from which current node hangs
    set parent_node $tree($node,above)

    # Get list of panels and nodes hanging from parent 
    set pan_list $tree($parent_node,below)
    # Current node will be among the list so get its position 
    set position [lsearch $pan_list $node]

    if {$position==0} {
	# Current node is first in list so new node is its parent
	set node $parent_node
    } else {
	# Get item which precedes current node
	set prev_item [lindex $pan_list [expr $position-1]]
	if {($tree($prev_item,type)=="p")||($tree($prev_item,type)=="s")} {
	    # Previous item is a panel. Therefore current node is first node
	    set node $parent_node
	} else {
	    # Previous item is a node but it may be expanded
	    # If it is, need to go to bottom node of expanded bit
	    set node [last_leaf_of $prev_item]
	}
    }
    if {$node=="root"} {return}
    highlight_node $node $c
}

##########################################################################
# proc last_leaf_of                                                      #
# Return name of lowest node (position-wise) hanging from $node          #
##########################################################################

proc last_leaf_of {node} {
    # Returns name of most extreme expanded node hanging from $node

    global tree

    # $node not expanded so return itself
    if {$tree($node,expand)==0} {return $node}

    set last_node [lindex $tree($node,below) [expr [llength $tree($node,below)]-1]]

    # Does node contain only panels below - if so return $node
    if {($tree($last_node,type)=="p")||($tree($last_node,type)=="s")} {return $node}

    # Return name of most extreme expanded node hanging from $last_node
    return [last_leaf_of $last_node]
}

##########################################################################
# proc key_down                                                          #
# Down key pressed. Set current node to visible node below current node  #
##########################################################################

proc key_down {c} {
    global tree

    set after 0
    set node $tree(highlight)
    set expand $tree($node,expand)

    if {$tree($node,expand)} {
	# Node is expanded so start search at start of this node
	set new_node [down_node $node -1]
    } else {
	# node is not expanded so look for panel below this in parent node.
	# $parent_node is the node from which $tree(highlight) hangs
	set parent_node $tree($node,above)

	# $after is position of current $node in list
	set after [lsearch $tree($parent_node,below) $node]

	set new_node [down_node $parent_node $after]
    }
    if {$new_node!=0} {
	highlight_node $new_node $c
    }
}

##########################################################################
# proc down_node                                                         #
# called with a node name and a position $after. Returns name of node    #
# which follows position $after in list of nodes below $node             #
# Calls itself recursively when moving beyond lowest child node or when  #
# next node in list is actually a panel                                  #
##########################################################################

proc down_node {parent_node after} {
    # Returns name of next visible node after a child node 
    # The child node is listed in position $after of $tree($parent_node,below)
    # down or 0 if already at very bottom
    global tree

    # List of nodes below $parent_node
    set below $tree($parent_node,below)
    
    if {$after==[expr [llength $below]-1]} {
	# Already at last child node - need to find auntie node: parent's younger sister :-)

	# $parent_node is the node from which $node hangs

	if {[info exists tree($parent_node,above)]==0} {
	    # At root of the tree - cannot go further. Original node must be at very bottom 
	    return 0
	}

	# Get node from which parent hangs
	set grandparent_node $tree($parent_node,above)

	# $after is position of parent in $grandparent_node list
	set after [lsearch $tree($grandparent_node,below) $parent_node]

	# Recursive call to get next node to parent
	return [down_node $grandparent_node $after]
    } else {
	incr after
	# $new node is child node's younger sister
	set new_node [lindex $below $after]
	if { ($tree($new_node,type)=="n") || ($tree($new_node,type)=="t") } {
	    # It is a node rather than a panel so return it
	    return $new_node
	} else {
	    # It is a panel so make recursive call to find next node
	    return [down_node $parent_node $after]
	}
    }
}
	
#######################################################################################
# proc key_right                                                                      #
# Focus moved to righthand side of navigation window                                  #
# Point to either top panel or to previous selection if still showing                 #
#######################################################################################
proc key_right {c} {
    global tree d

    # Current node on left side
    set node $tree(highlight)


    # If not expanded cannot go to panels
    if {$tree($node,expand)==0} {return}

    # Set pan to name of last selection or initialise if this is first
    if [info exists tree(entered)] {
	set pan $tree(entered)
    } else {
	set pan ""
    }

    if { [lsearch $tree($node,below) $pan]==-1} {
	# Last selection is no longer displayed so set to first panel of new selection
	if {[set pan [first_pan $node]]==0} {return}
    }
    clear_focus $d
    set tree(entered) $pan
    $d itemconfig $pan.t -fill white
}

#######################################################################################
# proc first_pan                                                                      #
# Return name of first panel hanging from $node or 0 if there aren't any              #
#######################################################################################
proc first_pan {node} {
    global tree

    set below $tree($node,below)

    set i 0
    while { ($i<[llength $below]) } {
	set node [lindex $below $i]
	if {($tree($node,type)=="p")||($tree($node,type)=="s")} {
	    return $node
	}
	incr i
    }
    return 0
}


#######################################################################################
# proc key_left                                                                       #
# Moving back to lefthand side of navigation. Unhighlight current panel and set focus #
#######################################################################################
proc key_left {d} {
    global tree c

    clear_focus $c
    $d itemconfig $tree(entered).t -fill black
}

#######################################################################################
# proc key_panel_down and key_panel_up                                                #
# Moving up and down righthand side of navigation. Stop if at top                     #
#######################################################################################
proc key_panel_down {d} {
    global tree

    if {[set pan [next_panel 1]]==0} {return}
    highlight_panel $pan $d
}

proc key_panel_up {d} {
    global tree

    if {[set pan [next_panel -1]]==0} {return}
    highlight_panel $pan $d
}

#######################################################################################
# proc next_panel                                                                     #
# Return name of next panel either up or down dependent on $direction set to -1 or 1  #
#######################################################################################
proc next_panel {direction} {
    global tree

    set node $tree(highlight)

    set list $tree($node,below)
    set current_pan $tree(entered)

    set pos [expr [lsearch $list $current_pan]+$direction]

    if { ($pos<0) || ($pos>=[llength $list]) } {return 0}

    set new_pan [lindex $list $pos]

    if {($tree($new_pan,type)!="p")&&($tree($new_pan,type)!="s")} {return 0}
    return $new_pan
}


##########################################################################
# proc highlight_node                                                    #
# Unhighlight old node and highlight new node. Scroll canvas if required #
##########################################################################

proc highlight_node {node c} {
    global tree

    $c itemconfig $tree(highlight).t -fill black
    
    set tree(highlight) $node

    $c itemconfig $node.t -fill white

    reposition_canvas $c $node

}


##########################################################################
# proc highlight_panel                                                   #
# Unhighlight old panel and highlight new panel. Scroll canvas if required
##########################################################################

proc highlight_panel {panel d} {
    global tree

    $d itemconfig $tree(entered).t -fill black

    set tree(entered) $panel

    $d itemconfig $panel.t -fill white    

    reposition_canvas $d $panel

}


#***********************************************************************
#
# proc collapse_rec
# -----------------
#
# Recursively collapse a tree.
#
# Calls itself to descend down the tree, killing all nodes along the way
#
#***********************************************************************

proc collapse_rec {node} {

    #+
    # TREE: experiment_instance navigation expand_node collapse_node collapse_rec
    # TREE: experiment_instance navigation expand_node collapse_node collapse_rec collapse_rec
    # TREE: experiment_instance navigation next_level expand_node collapse_node collapse_rec
    # TREE: experiment_instance navigation next_level expand_node collapse_node collapse_rec collapse_rec
    #-

    global c tree

    # y_tot is a counter to keep track of how many windows I've killed.
    # referenced up the tree.

    upvar 1 y_tot y_tot

    # if it's a node, kill it.

    if {($tree($node,type) == "n") || ($tree($node,type) == "t")} { 

	$c delete $node.t
	$c delete $node.l1
	$c delete $node.l2
	if {[$c find withtag $node] != ""} {set y_tot [expr $y_tot + 1]}
	$c delete $node

	set tree($node,expand) 0

	# Now call myself to kill the rest of it.

	if {[info exists tree($node,below)]} { 

	    foreach name $tree($node,below) { collapse_rec $name } 
	}

    }
}




#**********************************************************************
# 
# proc collapse_node
# ------------------
#
# The non-recursive bit that does the calling.
#
#**********************************************************************

proc collapse_node {name} { 

    #+
    # TREE: experiment_instance navigation expand_node collapse_node
    # TREE: experiment_instance navigation next_level expand_node collapse_node
    #-

    global tree 

    set y_tot 0

    set tree($name,expand) 0

    # If there's nothing to kill...

    if {![info exists tree($name,below)]} {return}

    # call the recursive murderer for all 'name's children.

    foreach name2 $tree($name,below) {

	collapse_rec $name2 
    }

    # Move the list up by the number of windows killed recursively.

    shift_node $name -$y_tot

}




#*********************************************************************
#
# proc shift_rec
# --------------
#
# Recursively shift up all the panels on the canvas.
#
# Arguments : node - the node we're shifting.
#	    : y_pos - the position where the shift was started
#	    : y_tot - the amount to shift, can be + or -
#
#*********************************************************************

proc shift_rec {node y_pos y_tot} {

    global c tree c_width

    if {($tree($node,type) == "n") || ($tree($node,type) == "t")} {

	if {$tree($node,y_pos) > $y_pos} {


	    set y_mov [expr {$y_tot * $c_width}]

	    $c move $node.t 0 $y_mov
	    $c move $node.l1 0 $y_mov
	    $c move $node.l2 0 $y_mov
	    $c move $node 0 $y_mov
	    set tree($node,y_pos) [expr {$tree($node,y_pos) + $y_tot}]
	}

	# If the node's been expanded, call myself to contract the rest.

	if {$tree($node,expand) != 0} {

	    if {($tree($node,type) == "n") || ($tree($node,type) == "t")} { 

		foreach name $tree($node,below) { shift_rec $name $y_pos $y_tot }

	    } 

	}
	
    }
}




#**********************************************************************
#
# proc shift_node
# ---------------
#
# shift_node - the non-recursive bit of the shift process.
#
# Arguments : name - the node to start shifting from.
# 	    : y_tot - the no. of cells to shift by, can be + or -
#
#**********************************************************************


proc shift_node {name y_tot} { 

    #+
    # TREE: experiment_instance navigation expand_node shift_node
    # TREE: experiment_instance navigation next_level expand_node shift_node
    #-

    global tree c_width c
 
    set x_pos $tree($name,x_pos)
    set y_pos $tree($name,y_pos)

    foreach name2 $tree(root,below) {

	shift_rec $name2 $y_pos $y_tot
    }

    # If we're shifting down the canvas - expanding a node.
    
    if {$y_tot > 0} {

	# Some horribly messy stuff to get the lines in the right places.


	    # This is a hack to handle the lines that we draw on the canvas.
	    # We increment tree(lines) everytime we draw a new line, and index
	    # that new line as tree(line_start_y,tree(lines)) etc
	    # When we delete a line, we simply unset tree(line_start_y,num),
	    # so the loop has to loop round from 0 to tree(lines) testing if
	    # the line still exists or not.

	    if {[info exists tree(lines)]} { 

		incr tree(lines) 

	    } else { set tree(lines) 1 }

	    # set the line array element for the new line

	    set tree(line_start_y,$tree(lines)) $y_pos
	    set tree(line_x,$tree(lines)) [expr $x_pos -1 ]
	    # Is this node the last one in the sub-tree.
	    if {![info exists tree($name,last)]}  {
		set tree(line_end_y,$tree(lines)) [expr $y_pos + $y_tot]
		# draw the new line
		$c create line [expr {($x_pos -1) * $c_width}] [expr {\
		    ($y_pos ) * $c_width}] [expr { ($x_pos -1) * $c_width}] \
		    [expr { ($y_pos + $y_tot) * $c_width}] -width 1 -tag l.$tree(lines)
	    } else {
		set tree(line_end_y,$tree(lines)) $y_pos
	    }

	# Now loop through all the old lines expanding them.

	for {set x 1} {$x < $tree(lines)} {incr x} {

	    if {[info exists tree(line_end_y,$x)]} {
		
		if {$tree(line_start_y,$tree(lines)) < $tree(line_start_y,$x)} {
		    set tree(line_start_y,$x) [expr $tree(line_start_y,$x)+$y_tot]
		}

		if {$tree(line_end_y,$x) >= $tree($name,y_pos)} {

		    # Delete the old line.

		    $c delete l.$x				

		    set tree(line_end_y,$x) [expr $tree(line_end_y,$x) + $y_tot]

		    # And create the new.

		    $c create line [expr {$tree(line_x,$x) * $c_width}] [expr {\
			    $tree(line_start_y,$x) * $c_width}] [expr { $tree(line_x,$x) * $c_width}] \
			    [expr {$tree(line_end_y,$x) * $c_width}] -width 1 -tag l.$x
		}
	    }
	}


	# else ( y_tot is negative and we're collapsing the tree instead.) 

    }

    if {$y_tot < 0} {

	# loop through all the old lines contracting them

	for {set x 1} {$x <= $tree(lines)} {incr x} {

	    if [info exists tree(line_end_y,$x)] {

		$c delete l.$x

		# Need to know the original y_start in order to know which lines to
		# delete.

		set original_y_start $tree(line_start_y,$x)
		
		if {$tree(line_end_y,$x) > $tree($name,y_pos)} {
		    set tree(line_end_y,$x) [expr $tree(line_end_y,$x) + $y_tot]
		}

		if {$tree(line_start_y,$x) > $tree($name,y_pos)} {
		    set tree(line_start_y,$x) [expr $tree(line_start_y,$x) + $y_tot]
		}
		
		# Work out which lines to delete....

		if {($tree(line_end_y,$x) <= $original_y_start) && \

		($tree(line_start_y,$x) <= $y_pos)} {

		    unset tree(line_end_y,$x)
		    unset tree(line_start_y,$x)
		    unset tree(line_x,$x)
		} else {

		    # Otherwise just contract them.

		    $c create line [expr {$tree(line_x,$x) * $c_width}] [expr {\
			    $tree(line_start_y,$x) * $c_width}] [expr { $tree(line_x,$x) * $c_width}] \
			    [expr {$tree(line_end_y,$x) * $c_width}] -width 1 -tag l.$x

		}

	    }
	}

    }

    

}




# expand_node
#  Called when an item in the tree is selected. It will expand it if
#  it is closed and collapse it if it is already expanded.
# Argument 
#  topname: the node to expand

proc expand_node {topname} {

    #+
    # TREE: experiment_instance navigation expand_node
    # TREE: experiment_instance navigation next_level expand_node
    #-

    global c d tree nav_icons c_width fonts
    #puts "expand_node - expanding $topname"
    set name ""
    # clear out all the panels.
    $d delete all

    if [regexp {[1-9]} [string index $topname 0]] {
	# A ...t node. Highlight the ..t node but use the variables stored under the ...n version
	create_duplicate_node $topname
    }

    highlight_node $topname $c

    # if no nodes to expand, return.
    
    if {![info exists tree($topname,below)]} { 
	return 
    } 

    # If already expanded, un-highlight current and last name.
    # but if `expand == 2' , then the sub-tree contains only
    # panels, so don't collapse it.

    if {$tree($topname,expand) == 1} {

	catch {collapse_node $topname}

    } else {

	set do_expand 0
	# If we're not in the top node, shift the rest of the tree down.

	if {$topname != "root"} {
	    if {$tree($topname,above) != "root"} {
		set y_tot 0
		foreach name $tree($topname,below) {

		    if {($tree($name,type) == "n") \
			    || ($tree($name,type) == "t")} { 

			set y_tot [ expr $y_tot + 1 ] 
			set do_expand 1		
		    }
		}
		shift_node $topname $y_tot
	    } else {
		set do_expand 1
	    }
	}

	# if do_expand == 1 , we have nodes in the sub-tree, so we want 
	# 'expand = 1' , otherwise we want 'expand = 2'

	if {$do_expand == 1} { 
	    set tree($topname,expand) 1 
	} else {
	    set tree($topname,expand) 2 
	}

	# set the fonts and colours for panel titles.

	# Tcl8 bodge
	set blue DeepSkyBlue3
	set red red
	set purple purple
	set green SeaGreen3

	set font1 $fonts(navigation)
	# p_pos is the same as y_pos , but for the panels in the other canvas.

	set p_pos 1

	# y and x_pos are where we start drawing.

	set y_pos [expr {$tree($topname,y_pos) + 1 }]
	set x_pos [expr {$tree($topname,x_pos) + 1 }]

	# first_draw is a flag to make the little line which joins up to 
	# the node icon not draw over the icon itself.

	set first_draw 1

	# highlight the node.
	#$c itemconfig $tree(highlight).t -fill black
	#set tree(highlight) $topname
	#$c itemconfig $topname.t -fill white

	# expand the node.
	foreach name $tree($topname,below) {

	    set above $tree($name,above)

	    if {($tree($name,type) == "n") || ($tree($name,type) == "t")} {
		set node_name $name
		set tree($name,y_pos) $y_pos
		set tree($name,x_pos) $x_pos

		if {$tree($name,above) != "root"} {

		    $c create line [expr ($x_pos - 0.4) * $c_width] [expr \
			    ($y_pos ) * $c_width] [expr  ($x_pos -1) * $c_width] \
			    [expr  ($y_pos) * $c_width] -width 1 -tag $name.l1

		    if {$first_draw != 1} {

			$c create line [expr {($x_pos -1) * $c_width}] [expr {\
				($y_pos ) * $c_width}] [expr { ($x_pos -1) * $c_width}] \
				[expr { ($y_pos -1) * $c_width}] -width 1 -tag $name.l2

		    } else { 

			set first_draw 0

			$c create line [expr {($x_pos -1) * $c_width}] [expr {\
				($y_pos ) * $c_width}] [expr { ($x_pos -1) * $c_width}] \
				[expr { ($y_pos -0.5) * $c_width}] -width 1 -tag $name.l2

		    }

		}
		$c create text [expr {($x_pos+1) *$c_width}] [expr {\
			$y_pos * $c_width} ] -font $font1 -text $tree($name,title) \
			-anchor w -tag $name.t 
	    } else {
		# draw a panel.

		$d create text [expr {2 *$c_width}] [expr {\
			$p_pos * $c_width} ] -font $font1 -text $tree($name,title) \
			-anchor w -tag $name.t 
	    }
	    switch $tree($name,type) {
		
		"n" { $c create bitmap [expr $x_pos *$c_width] \
			[expr $y_pos*$c_width] -bitmap @$nav_icons/node.xbm \
			-tags $name -foreground $red}

		"p" { $d create bitmap $c_width \
			[expr $p_pos*$c_width] -bitmap @$nav_icons/panel.xbm \
			-tags $name -foreground $green }

		"s" { $d create bitmap $c_width \
			[expr $p_pos*$c_width] -bitmap @$nav_icons/screen.xbm \
			-tags $name -foreground $purple }

		"t" { $c create bitmap [expr $x_pos*$c_width] \
			[expr $y_pos*$c_width] -bitmap @$nav_icons/tree.xbm \
			-tags $name -foreground $blue }
	    }

	    # set the bindings for the icons.

	    if {($tree($name,type) == "n") || ($tree($name,type) == "t")} {
		$c bind $name <Any-Enter> "itemEnter $c"
		$c bind $name <Any-Leave> "itemLeave $c"
		$c bind $name.t <Any-Enter> "itemEnter $c"
		$c bind $name.t <Any-Leave> "itemLeave $c"
		set y_pos [expr {$y_pos + 1}]

	    } else {

		$d bind $name <Any-Enter> "itemEnter $d"
		$d bind $name <Any-Leave> "itemLeave $d"
		$d bind $name.t <Any-Enter> "itemEnter $d"
		$d bind $name.t <Any-Leave> "itemLeave $d"
		set p_pos [expr $p_pos + 1]
	    }
	}
    }

    # last is a flag to indicate that node is the last one drawn, and
    # hence a line shouldn't be drawn to it when the tree is later
    # expanded.

    if {[info exists node_name]} {set tree($node_name,last) 1}

    # Recalculate the scrollregion of the canvas
    recalcTreeScrollregion $c

    # On first call, this will return name of top node
    return $name
}

# Utility procedures for highlighting the item under the pointer:

#*********************************************************************
#
# proc itemEnter
# --------------
#
# Callback procedure called when an item is entered by the pointer on
# the canvas.
#
#*********************************************************************

proc itemEnter {e} {

    #+
    # TREE: experiment_instance navigation expand_node itemEnter
    # TREE: experiment_instance navigation next_level expand_node itemEnter
    #-

    # restoreCmd is a line of tcl to be executed when the item is left

    global restoreCmd item
#    #if {[tk colormodel $e] != "color"} {
#	set restoreCmd {}
#	return
#    }
    set type [$e type current]
    if {$type == "window"} {
	set restoreCmd {}
	return
    }
    if {$type == "bitmap"} {
	set bg [lindex [$e itemconf current -background] 4]
	set restoreCmd [list $e itemconfig current -background $bg]
	$e itemconfig current -background white
    } elseif {$type == "text"} {
	set item [lindex [split [lindex [$e gettags current] 0 ] . ] 0 ]
	set bg [lindex [$e itemconf $item -background] 4]
	set restoreCmd [list $e itemconfig $item -background $bg]
	$e itemconfig $item -background white
    }
}




#*********************************************************************
#
# proc itemLeave
# --------------
#
# Callback procedure called when an item is left by the pointer on
# the canvas.
#
#*********************************************************************

proc itemLeave {c} {
    #+
    # TREE: experiment_instance navigation expand_node itemLeave
    # TREE: experiment_instance navigation next_level expand_node itemLeave
    #-

    global restoreCmd item

    eval $restoreCmd
}

proc read_buttons {file} {
    
    global idx navbuttons

    if {[file readable $file]==0} {
	dialog .error "File unreadable" "The file \"$file\" does not exist or is unreadable. Please report to GHUI Admin Team" {} 0 {OK}
	return 1
    }
    
    set f [open $file r]
    
    set i 0
    
    while {[eof $f]==0} {
	set idx 0
	if {[gets $f line]==-1} {break}
	if {[regexp "^#.*" $line]==0} {
	    if {[regexp "^>.*" $line]!=0} {
		set navbuttons($i,type)      "menu"
		set navbuttons($i,name)      [next_element $line]
		set navbuttons($i,txt)       [next_element $line]
		set navbuttons($i,command)   [next_element $line]
		set navbuttons($i,args)      [next_element $line]
		set accelerator              [next_element $line]
		if {$accelerator=="NONE"} {
		    set navbuttons($i,accel) -1
		} else {
		    set navbuttons($i,accel) [string first $accelerator $navbuttons($i,txt)]
		}
	    } else {
		set navbuttons($i,type)      "button"
		set navbuttons($i,name)      [next_element $line]
		set navbuttons($i,txt)       [next_element $line]
		set navbuttons($i,show)      [next_element $line]
		set navbuttons($i,disabled)  [next_element $line]
		set navbuttons($i,command)   [next_element $line]
		set navbuttons($i,args)      [next_element $line]
		set accelerator              [next_element $line]
		if {$accelerator=="NONE"} {
		    set navbuttons($i,accel) -1
		} else {
		    set navbuttons($i,accel) [string first $accelerator $navbuttons($i,txt)]
		}
	    }
	    incr i
	}
    }
    return $i
}


proc next_element {line} {
    
    global idx

    set list [split $line]
    for {set i $idx} {$i < [llength $list]} {incr i} {
	set offset 0
	set element [lindex $list $i]
	if {$element != {}} {
	    if {[string range $element 0 0]=="%"} {
		set len [expr [string length $element] - 1]
		set str [string range $element $len $len]
		if {$str=="%"} {break}
		incr offset
		while {$offset<10} {
		    set next  [lindex $list [expr $offset + $i]]
		    if {$next!= {}} {
			set element "$element $next"
			set len [expr [string length $element] - 1]
			set str [string range $element $len $len]
			if {$str=="%"} {break}
			incr offset
		    }
		}
	    }
	    break
	}
    }
    regsub "^%" $element {} element
    regsub "%$" $element {} element
    set idx [expr $i + $offset + 1]
    #puts "returning ---$element---"
    return $element
}


proc menulevel {string} {
    set char ">"
    set level 0
    while {$char == ">"} {
	incr level
	set char [string index $string $level]
    }
    return $level
}



proc make_buttons {b} {

    global navbuttons read_write c

    set butcount [read_buttons [navbuttons_file]]

    set level 0

    for {set i 0} {$i < $butcount} {incr i} {
	if {$navbuttons($i,type)=="menu"} { 
	    set this_level [menulevel $navbuttons($i,name)]
	    regsub -all ">" $navbuttons($i,name) {} name
	    if {$this_level == 1} {
		# new top level menubutton: create and pack button
		set window $b.m_$name
		menubutton $window -underline $navbuttons($i,accel) -text $navbuttons($i,txt) \
			-menu $window.m -relief raised
		pack $window  -pady 2m -side left -ipadx 2m -expand yes

		# This is the menu that goes with above menu button
		menu $window.m

		if {$navbuttons($i,accel)!=-1} {
		    # Bind key which posts the menu
		    set accel [string tolower [string index $navbuttons($i,txt) $navbuttons($i,accel)]]
		    bind . <Meta_R><$accel> "menu_post $window.m"
		    bind . <Meta_L><$accel> "menu_post $window.m"
		    bind . <Alt_R><$accel> "menu_post $window.m"
		    bind . <Alt_L><$accel> "menu_post $window.m"
		}
		bind $window.m <Button-2> "menu_unpost $window.m"
		
		# Once menu is posted, focus will be set to menu so when key is pressed traverse_menu is called
		bind $window.m <KeyPress> "traverse_menu $window.m %K"


		incr level
	    } elseif {$this_level == $level} {
		set window_sp [split $window "."]
		set window [join [lrange $window_sp 0 [llength $window_sp]] "."]
		incr level -1

		# Add item with appropriate letter underlined
		$window.m add command -label "$navbuttons($i,txt)" \
			-command "$navbuttons($i,command) $navbuttons($i,args)" -underline $navbuttons($i,accel)
	    } elseif {$this_level == [expr $level + 1] } {
		# Add item with appropriate letter underlined
		$window.m add command -label "$navbuttons($i,txt)" \
			-command "$navbuttons($i,command) $navbuttons($i,args)" -underline $navbuttons($i,accel)
	    }		
	} elseif {$navbuttons($i,type)=="button"} {
	    set show "no"
	    set disable "no"

	    # Parse command to be executed on selection of button
	    if {$navbuttons($i,args)!="NONE"} {
		set command2 "$navbuttons($i,command) $navbuttons($i,args)"
	    } else {
		set command2 "$navbuttons($i,command)"
	    }

	    # Determine active status of button and whether it should be shown
	    if {$navbuttons($i,show)=="ALWAYS"} {
		set show "yes"
		if  {$navbuttons($i,disabled)=="ALWAYS"} {
		    set disable "yes"
		} elseif {$navbuttons($i,disabled)!="NEVER"} {
		    set command "if {$navbuttons($i,disabled)} {set disable \"yes\"}"
		    #puts $command
		    #puts $navbuttons($i,disabled)
		    eval $command
		    #puts $disable
		}   
	    } elseif {$navbuttons($i,show)!="NEVER"} {
		set command1 "if {$navbuttons($i,show)} {
		    set show \"yes\"
		    if {\"$navbuttons($i,disabled)\"!=\"NEVER\"} {
			if {$navbuttons($i,disabled)} {set disable \"yes\"}
		    } elseif {$navbuttons($i,disabled)!=\"ALWAYS\"} {
			set disable \"yes\"
		    }
		}"
		eval $command1
		}
		if {$show=="yes"} {
		    set button $b.$navbuttons($i,name)
		    menubutton $button -underline $navbuttons($i,accel) -text $navbuttons($i,txt) -relief raised

		    if {$disable=="yes"} {
			$button configure -state disabled
		    } else {
			# Button is active
			# Make bindings for its appearance when selected by mouse
			bind $button <Button-1> "$button configure -relief sunken"
			bind $button <ButtonRelease-1> "$command2; $button configure -relief raised"

			if {$navbuttons($i,accel)!=-1} {
			    # Make keyboard bindings which cause button to depress for a moment
			    set accel [string tolower [string index $navbuttons($i,txt) $navbuttons($i,accel)]]
			    bind . <Meta_L><$accel> \
				    "$button configure -relief sunken;update; $command2; $button configure -relief raised"
			    bind . <Meta_R><$accel> \
				    "$button configure -relief sunken;update; $command2; $button configure -relief raised"
			    bind . <Alt_L><$accel> \
				    "$button configure -relief sunken;update; $command2; $button configure -relief raised"
			    bind . <Alt_R><$accel> \
				    "$button configure -relief sunken;update; $command2; $button configure -relief raised"
			}
		    }
		    pack $button -pady 2m -side left -ipadx 2m -expand yes
		}
	    } else {
		puts "ERROR in nav.spec. Report to UMUI admin at once"
	    }
	}
    }

# This posts a menu on screen, sets focus and saves preceding focus
proc menu_post {w} {
    $w post 1 1
    push_focus $w
}

# This unposts a menu and resets focus
proc menu_unpost {w} {
    $w unpost
    focus_remove $w
}

# The procedure below is used to implement keyboard traversal within
# the posted menu.  It takes two arguments:  the name of the menu to
# be traversed within, and an ASCII character.  It searches for an
# entry in the menu that has that character underlined.  If such an
# entry is found, it is invoked and the menu is unposted.
# Routine adapted from tk_traverseWithinMenu


proc traverse_menu {w char} {
    if {$char == ""} {
	return
    }
    set char [string tolower $char]
    set last [$w index last]
    if {$last == "none"} {
	return
    }
    for {set i 0} {$i <= $last} {incr i} {
	if [catch {set char2 [string index \
		[lindex [$w entryconfig $i -label] 4] \
		[lindex [$w entryconfig $i -underline] 4]]}] {
	    continue
	}
	if {[string compare $char [string tolower $char2]] == 0} {
	    menu_unpost $w
	    $w invoke $i
	    return
	}
    }
}


