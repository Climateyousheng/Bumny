#==============================================================================
# RCS Header:
#   File         [$Source: /home/hc0300/umui/srce_code/GHUI_archive/ghui2.0/vn1.4/tcl/displayLogo.tcl,v $]
#   Revision     [$Revision: 1.1 $]     Named [$Name: head#main $]
#   Last checkin [$Date: 2002/11/19 10:20:29 $]
#   Author       [$Author: umui $]
#==============================================================================

# displayLogo
#  Displays logo in one of the corners of widget d.
# Arguments
#  d: Name of widget in which to display logo
#  w,h: width and height of $d
#  image: Image object to display
#  imX,imY: Width and height of image
#  border: Amount of space between logo and edge of $d
#  anchor: Which corner to put logo se, sw, ne or nw
# Usage
#  Do a bind on a configure event to call this routine each time
#  the widget is resized or redisplayed.
#   bind $d <Configure> [list +displayLogo $d %w %h $image $imX $imY]

proc displayLogo {d w h image imX imY {border 10} {anchor se}} {

    # Use anchor and image in name in case we want to display 
    # an image twice or we want to display two images.
    set c $d.gif$anchor$image

    if {[info commands $c] == ""} {
	# First create a new canvas and put image on it
	canvas $c -width $imX -height $imY
	$c create image 0 0 -image $image -anchor nw
    }

    # Calculate position of image
    switch $anchor {
	"ne" {set h $border; incr w -$border}
	"nw" {set h $border; set w $border}
	"sw" {incr h -$border; set w $border}
	"se" {incr h -$border; incr w -$border}
	"n" {set h $border; set w [expr ($w)/2]}
	"e" {set h [expr $h/2]; incr w -$border}
	"s" {incr h -$border; set w [expr ($w)/2]}
	"w" {set h [expr $h/2]; set w $border}
	"center" {set h [expr $h/2]; set w [expr ($w)/2]}
    }

    # Display canvas with image
    place $c -in $d -x $w -y $h -anchor $anchor
}
