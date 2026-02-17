# 
# scrollWidget.tcl
#
#   Procedures for creating a frame with scrollbars that disappear if 
#   enclosing frame is big enough to fully display its contents.
#   Widget creates a parent frame containing a canvas and scrollbars 
#   within other frames. Initially SWSetFrame creates a further frame
#   whose parent is the canvas and returns its name. Then a call to
#   SWFrameWindow places it on the canvas with "create window" and
#   sets up the bindings to manage the scrollbars etc.
#
#   Call swDestroyFrame to destroy the parent and unset the array.
#

namespace eval scrollWidget {

    namespace export swSetFrame
    namespace export swDestroyFrame

}

# swSetFrame
#   Call with proposed name of parent $p. $p will be packed as a frame.
#   A canvas called $p.c with scrollbars
#   will be created within p and a frame called $p.c.win within this.
#   Name of inner frame "$w" will be returned. All items should be
#   packed within this frame. Once the frame is filled it does a:
#      SWFrameWindow $w maxX maxY
#   where maxX and maxY are the maximum size that the window can have
#   to pack the frame.

proc ::scrollWidget::swSetFrame {p maxX maxY} {
    variable SWidget

    # This is the name of the frame that the calling function will use
    # and also the index used for accessing the SWidget variable
    set w $p.c.win

    # Create the frame to hold the canvas
    frame $p
    pack $p -fill both -expand yes
    # Create a canvas with scrollbars
    canvas $p.c  \
	    -yscrollcommand "$p.v.scroll set" \
	    -xscrollcommand "$p.h.scroll set" 

    # Set up the frames for the scrollbar
    set SWidget($w,scrollbarWidth) 15

    frame $p.v -width $SWidget($w,scrollbarWidth)
    frame $p.h -height $SWidget($w,scrollbarWidth)

    scrollbar $p.v.scroll -command "$p.c yview" 
    scrollbar $p.h.scroll -orient horiz -command "$p.c xview"

    pack $p.c -fill both -expand y

    # Create a frame which will be filled by calling routine and which
    # will then be put onto the canvas by calling "proc frameWindow"
    frame $w

    # Initialise global variables
    set SWidget($w,innerX) -1
    set SWidget($w,innerY) -1
    set SWidget($w,outerX) -1
    set SWidget($w,outerY) -1
    
    # Save name of parent frame
    set SWidget($w,parent) $p
    
    # Put frame onto canvas with scrollbar bindings etc.
    SWFrameWindow $w $maxX $maxY
    # Return name of frame for calling routine to use
    return $w
}

# swDestroyFrame
#   Unset variables and destroy parent frame of scrolling widget
# Arguments
#  w : Frame on canvas inside $p parent frame

proc ::scrollWidget::swDestroyFrame {w} {
    variable SWidget

    # Get name of parent frame
    set p $SWidget($w,parent)

    # Clear out array
    foreach index [array names SWidget $w,*] {
	unset SWidget($index)
    }
    # Destroy parent frame
    destroy $p
}

# SWFrameWindow
#   Should be called once the frame $w is packed, with the
#   maximum size of the container widget
# Arguments
#  w : Frame on canvas inside $p parent frame
#  inMaxX,inMaxY : Maximum dimensions of the inner window

proc ::scrollWidget::SWFrameWindow {w inMaxX inMaxY} {
    variable SWidget

    # Get name of parent frame
    set p $SWidget($w,parent)

    # Update the frame to ensure we get the correct size
    update idletasks

    # Put the frame into the canvas
    $p.c create window 0c 0c -tag t$p -anchor nw -window $w

    # Get the size of the frame
    set coords [$p.c bbox t$p]
    set xSize [lindex $coords 2]
    set ySize [lindex $coords 3]

    # Call to set size of the toplevel window
    SWFrameGeometry $w $xSize $ySize $inMaxX $inMaxY

    # Set bindings for when window or frame changes
    bind $w <Configure> \
	    [namespace code "SWFrameGeometry $w %w %h $inMaxX $inMaxY"]
    bind $p.c <Configure> [namespace code "SWFrameSize $w %w %h"]
}

# SWFrameSize
#   Called when container widget changes size to determine whether 
#   scrollbars need packing or unpacking.
# Arguments
#  w : Frame on canvas inside $p parent frame
#  x,y : Dimensions of $p parent frame - ie the outer container

proc ::scrollWidget::SWFrameSize {w x y} {
    variable SWidget

    # Store size of enclosing parent widget
    set SWidget($w,outerX) $x
    set SWidget($w,outerY) $y
    # Check scrollbars
    SWPackScrollbars $w
}

# SWFrameGeometry
# Set the initial size of the container widget to be the same size
# as the frame within or to the maximum size
# Arguments
#  w : Frame on canvas inside $p parent frame
#  x,y : Dimensions of $w - ie the inner frame
#  inMaxX,inMaxY : Maximum dimensions of $w

proc ::scrollWidget::SWFrameGeometry {w x y inMaxX inMaxY} {
    variable SWidget

    # Get name of parent frame
    set p $SWidget($w,parent)

    set SWidget($w,innerX) $x
    set SWidget($w,innerY) $y

    # Max size is smaller of maximum requested or current size of $w
    set maxX [min $x $inMaxX]
    set maxY [min $y $inMaxY]

    # If only one scrollbar to be displayed, try to make extra room for it
    # otherwise its presence will take up room and cause other scrollbar 
    # to be displayed as well
    if {$x < $inMaxX && $y > $inMaxY} {
	set maxX [min [expr $maxX+$SWidget($w,scrollbarWidth)] $inMaxX]
    } elseif {$y < $inMaxY && $x > $inMaxX} {
	set maxY [min [expr $maxY+$SWidget($w,scrollbarWidth)] $inMaxY]
    }

    # This resizing may be overridden if the window is resized by the user
    $p.c configure -height $maxY -width $maxX
    SWPackScrollbars $w
}

# SWPackScrollbars
#   Pack or remove scrollbars depending on whether or not frame can
#   fit within container. A small square is left at bottom right
#   where bars meet
# Arguments
#  w : Frame on canvas inside $p parent frame

proc ::scrollWidget::SWPackScrollbars {w} {
    variable SWidget

    # Get name of parent frame
    set p $SWidget($w,parent)

    # Dimensions of outer frame
    set ox $SWidget($w,outerX)
    set oy $SWidget($w,outerY)

    # Dimensions of $w
    set ix $SWidget($w,innerX)
    set iy $SWidget($w,innerY)

    # Compare dimensions and pack or remove scrollbars as required.
    # Note that presence of one scrollbar reduces space available
    # in the other direction and therefore affects other scrollbar.
    set sbWidth $SWidget($w,scrollbarWidth)
    if { ($ox < $ix) || ($ox < [expr $ix+$sbWidth] && $oy < $iy)} {
	# place x-scrollbar if container narrower than $w frame OR if
	# y-scrollbar required and container not wide enough for 
	# frame + scrollbar
	place $p.h -y [expr $oy-$sbWidth] -x 0 -width $ox 
	place $p.h.scroll -x 0 -width [expr $ox-$sbWidth]
	set dh $sbWidth
    } else {
	# Width smaller than container width so no scrollbar needed
	place forget $p.h 
	place forget $p.h.scroll
	set dh 0
    }
    
    if { ($oy < $iy) || ($oy < [expr $iy+$sbWidth] && $ox < $ix) } {
	# place y-scrollbar if container shorter than $w frame OR if
	# x-scrollbar required and container not tall enough for 
	# frame + scrollbar
	place $p.v -x [expr $ox-$sbWidth]  \
		-y 0 -height [expr $oy-$sbWidth] 
	place $p.v.scroll -y 0 -height [expr $oy-$sbWidth]
	set dw $sbWidth
    } else {
	# Height less than container height so no scrollbar needed
	place forget $p.v
	place forget $p.v.scroll
	set dw 0
    }
    # Scrollbars are placed ON TOP of window so need to
    # reset scrollregion to account for their presence
    $p.c configure -scrollregion "0 0 [expr $ix+$dw] [expr $iy+$dh]"
}
