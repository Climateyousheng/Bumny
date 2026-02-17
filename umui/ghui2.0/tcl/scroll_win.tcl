#####################################################################
# set_scrollframe                                                   #
# Call with proposed name of item $p. $p will be packed as a frame. #
# A canvas called $p.c with scrollbars                              #
# will be created within p and a frame called $p.c.win within this. #
# Name of inner frame "$win" will be returned. All items should be  #
# packed within this frame. Once the frame is filled do a:          #
#    frame_window $p $win maxx maxy                                 #
# where maxx and maxy are the maximum size that the window can have #
# to pack the frame                                                 #
#####################################################################

proc set_scrollframe {p {s_width 15}} {
    global inner outer
    global scrollbar_width

    # Create the frame to hold the canvas
    frame $p
    pack $p -fill both -expand yes
    # Create a canvas with scrollbars
    canvas $p.c  \
	    -yscrollcommand "$p.v.scroll set" \
	    -xscrollcommand "$p.h.scroll set" 

    # Set up the frames for the scrollbar
    set scrollbar_width($p) $s_width

    frame $p.v -width $scrollbar_width($p)
    frame $p.h -height $scrollbar_width($p)

    scrollbar $p.v.scroll -command "$p.c yview" -width $scrollbar_width($p)
    scrollbar $p.h.scroll -orient horiz -command "$p.c xview" -width $scrollbar_width($p)

    pack $p.c -fill both -expand y

    # Create a frame which will be filled by calling routine and which
    # will then be put onto the canvas by calling "proc frame_window"
    set win $p.c.win
    frame $win

    # Initialise global variables
    set inner(x,$p) -1
    set inner(y,$p) -1
    set outer(x,$p) -1
    set outer(y,$p) -1

    # Return name of frame for calling routine to use
    return $win
}

######################################################################
# frame_window                                                       #
# Should be called once the frame $win is fully packed with the      #
# maximum size of the container widget                               #
#  inmaxx and inmaxy are the maximum dimensions of the inner window  #
######################################################################

proc frame_window {p win inmaxx inmaxy} {

    # Update the frame to ensure we get the correct size
    update

    # Put the frame into the canvas
    $p.c create window 0c 0c -tag t$p -anchor nw -window $win

    # Get the size of the frame
    set coords [$p.c bbox t$p]
    set xsize [lindex $coords 2]
    set ysize [lindex $coords 3]

    # Call to set size of the toplevel window
    frame_geometry $p $xsize $ysize $inmaxx $inmaxy

    # Set bindings for when window or frame changes
    bind $win <Configure> "inner_size $p %w %h $inmaxx $inmaxy"
    bind $p.c <Configure> "frame_size $p %w %h"
}

####################################################################
# inner_size                                                       #
# Called when scroll region needs to change due to change in       #
# contents of frame                                                #
####################################################################

proc inner_size {p x y inmaxx inmaxy} {
    global inner

    # Moving a scrollbar requires no action. With my window manager,
    # window does not scroll properly if this condition is not used
    if { $inner(x,$p)!=$x || $inner(y,$p)!=$y} {
	# Call to set size of the canvas and reset scrollbars
	frame_geometry $p $x $y $inmaxx $inmaxy
    }
}

####################################################################
# frame_size                                                       #
# Called when container wigdet changes size                        #
####################################################################

proc frame_size {p x y} {
    global outer

    # Store size of enclosing widget
    set outer(x,$p) $x
    set outer(y,$p) $y
    pack_scrollbars $p
}

####################################################################
# frame_geometry                                                   #
# Set the initial size of the container widget to be the same size #
# as the frame within or to the maximum size                       #
####################################################################

proc frame_geometry {p x y inmaxx inmaxy} {
    global inner scrollbar_width

    set inner(x,$p) $x
    set inner(y,$p) $y

    # Max size is smaller of maximum as requested by user or current size of $win
    set maxx [min_of $inner(x,$p) $inmaxx]
    set maxy [min_of $inner(y,$p) $inmaxy]

    # If only one scrollbar is to be displayed then try to make extra room for it
    # otherwise its presence will take up room and cause other scrollbar to be 
    # displayed as well
    if {$x < $inmaxx && $y > $inmaxy} {
	set maxx [min_of [expr $maxx+$scrollbar_width($p)] $inmaxx]
    } elseif {$y < $inmaxy && $x > $inmaxx} {
	set maxy [min_of [expr $maxy+$scrollbar_width($p)] $inmaxy]
    }

    $p.c configure -height $maxy -width $maxx
    update
    pack_scrollbars $p
}
proc min_of {a b} {
    if {$a<$b} {return $a} {return $b}
}

####################################################################
# pack_scrollbars                                                  #
# Pack or remove scrollbars depending on whether or not frame can  #
# fit within container. A small square is left at bottom right     #
# where bars meet                                                  #
####################################################################

proc pack_scrollbars {p} {

    global inner outer
    global scrollbar_width

    # Dimensions of outer frame
    set w $outer(x,$p)
    set h $outer(y,$p)

    # Dimensions of $win
    set ix $inner(x,$p)
    set iy $inner(y,$p)

    # Compare dimensions. If y scrollbar is packed there will be less room
    set xbar [expr ($w < $ix) || ($w < [expr $ix+$scrollbar_width($p)] && $h < $iy) ]
    set ybar [expr ($h < $iy) || ($h < [expr $iy+$scrollbar_width($p)] && $w < $ix) ]

    # If both bars showing, have a square at bottom right
    set space [expr $scrollbar_width($p)*($xbar==$ybar)]

    if $xbar {
	# pack scrollbar
	place $p.h -y [expr $h-$scrollbar_width($p)] -x 0 -width $w 
	place $p.h.scroll -x 0 -width [expr $w-$space]
	set dh $scrollbar_width($p)
    } else {
	# Width of text smaller than window width so no scrollbar needed
	place forget $p.h 
	place forget $p.h.scroll
	set dh 0
    }
    
    # Ditto
    if $ybar {
	place $p.v -x [expr $w-$scrollbar_width($p)]  -y 0 -height $h
	place $p.v.scroll -y 0 -height [expr $h-$space]
	set dw $scrollbar_width($p)
    } else {
	place forget $p.v
	place forget $p.v.scroll
	set dw 0
    }
    # Scrollbars are placed ON TOP of window so need to
    # reset scrollregion to account for their presence
    $p.c configure -scrollregion "0 0 [expr $ix+$dw] [expr $iy+$dh]"
}
