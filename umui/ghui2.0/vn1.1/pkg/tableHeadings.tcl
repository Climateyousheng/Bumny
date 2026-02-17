package provide GHUITable 1.0

# Table heading data objects
# foreach type [list entry heading super title]
#  TVals($c,$type,Number)   : Number of columns of type $type
#  TVals($c,$type,Width,$i) : Width of column $i
# foreach type [list heading super title]
#  TVals($c,$type,$i)       : Text in column $i
#
#  TVals($c,super,lastCol,$i) : Last header column over which super $i sits


# FrameHeadings 
#    Create frames for each row and heading. Calculate minimum
#    width required for each heading in entrybox units.
# Method
#    Headings are packed as labels into frames and the frame size is 
#    obtained. Labels are then unpacked as they need to be place'd
#    into frames otherwise frame collapses in size.

proc FrameHeadings {c} {
    global TVals

    set f $TVals($c,OuterFrame)

    if {$TVals($c,super,Number) > 0} {
	# Also have superheadings
	set titleTypes [list title super heading]
    } else {
	set titleTypes [list title heading]
    }
    
    # Create frames for each row and heading
    foreach type $titleTypes {
	pack [frame $f.$type] -before $c -anchor w
	for {set i 0} {$i < $TVals($c,$type,Number)} {incr i} {
	    pack [frame $f.$type.f$i] -side left
	    pack [label $f.$type.f$i.l -text $TVals($c,$type,$i)]
	    set TVals($c,$type,label,$i) $f.$type.f$i.l
	    if {$TVals($c,$type,Font) != ""} {
		$f.$type.f$i.l configure -font $TVals($c,$type,Font)
	    }
	}
    }

    # Calculate width of each heading then remove packed label
    update idletasks
    foreach type $titleTypes {
	for {set i 0} {$i < $TVals($c,$type,Number)} {incr i} {
	    set TVals($c,$type,Width,$i) [PixelToChar $c [winfo reqwidth $f.$type.f$i]]
	    set TVals($c,$type,Height,$i) [winfo reqheight $f.$type.f$i]
	    #puts "Width of $type is $TVals($c,$type,Width,$i) ([winfo reqwidth $f.$type.f$i] pixels)"
	    pack forget $f.$type.f$i.l
	}
    }
    set TVals($c,TitleTypes) $titleTypes
}

# PlaceHeadings
#    Sets the sizes of the heading frames and places text within

proc PlaceHeadings {c} {
    global TVals
 
    set border 2

    set f $TVals($c,OuterFrame)
    foreach type $TVals($c,TitleTypes) {
	for {set i 0} {$i < $TVals($c,$type,Number)} {incr i} {
	    $f.$type.f$i configure -width $TVals($c,$type,Width,$i) \
		    -height [expr $TVals($c,$type,Height,$i)+2*$border] \
		    -relief sunken -bd $border
	    place $f.$type.f$i.l -x 0
	}
    }
}

# ScaleTitles
#    Ensures heading width matches column width, super heading width
#    matches heading and title width matches all.

proc ScaleAllTitles {c} {

    # Match up heading and column widths
    ScaleHeadings $c

    # Match up super and heading widths.
    ScaleColumn $c super

    # Match up title and super widths
    if [ScaleColumn $c title] {
	# Super widths were changed so rematch heading widths
	ScaleColumn $c super
    }

    # Convert all widths to pixel units once scaling complete
    ConvertToPixelUnits $c
}

# ConvertToPixelUnits
#    Converts widths of all headings and titles from character units to pixel units

proc ConvertToPixelUnits {c} {
    global TVals

    # First convert the headings
    for {set i 0} {$i < $TVals($c,heading,Number)} {incr i} {
	set TVals($c,heading,Width,$i) [CharToPixel $c $TVals($c,heading,Width,$i)]
    }
    # Then match pixel widths of supers and title to heading widths
    MatchOtherWidths $c
}

# MatchOtherWidths
#    Sets widths of title and super headings to match subheadings below.
#    This saves on calling CharToPixel for each item.

proc MatchOtherWidths {c} {
    global TVals

    # Each superheading should be total width of subheadings below
    set firstCol 0
    for {set i 0} {$i<$TVals($c,super,Number)} {incr i} {
	set TVals($c,super,Width,$i) 0
	for {set j $firstCol} {$j<=$TVals($c,super,lastCol,$i)} {incr j} {
	    incr TVals($c,super,Width,$i) $TVals($c,heading,Width,$j)
	}
	set firstCol $j
    }

    # Title should be total width of all headings
    set TVals($c,title,Width,0) 0
    for {set i 0} {$i<$TVals($c,heading,Number)} {incr i} {
	incr TVals($c,title,Width,0) $TVals($c,heading,Width,$i)
    }
    
}

# ScaleColumn
#    Ensures superheading or title widths match up with headings below.
#    If not, the smaller is resized to match the larger.
# Result
#    Returns 1 if heading widths were altered. Returns 0 for no alteration
#    or if there are no super headings.
# Comments
#    Total width is calculated in pixels and then converted back to
#    character units to ensure ExtraWidth is accounted for.

proc ScaleColumn {c type} {
    global TVals
    
    if {$TVals($c,$type,Number) > 0} {
	set rescaled 0
	set startCol 0
	for {set i 0} {$i < $TVals($c,$type,Number)} {incr i} {
	    # If the headings below this title or super heading are narrower
	    # Then RescaleRange expands them and returns 0
	    set newWidth [RescaleRange $c $TVals($c,$type,Width,$i) $startCol $TVals($c,$type,lastCol,$i)]
	    if {$newWidth != 0} {
		# Otherwise, the headings are wider so need to increase 
		# width of superheading or title to match headings below
		set TVals($c,$type,Width,$i) $newWidth
		set rescaled 1
	    }
	    # Start column for next range of headings
	    set startCol [expr $TVals($c,$type,lastCol,$i)+1]
	}
    } else {
	# There are no headings of this $type
	set rescaled 0
    }
    return $rescaled
}

# RescaleRange
#   Calculates width of a range of columns. If smaller than $width,
#   call RescaleColumns to increase them, otherwise, return width.
# Arguments
#   c : Canvas name and table id
#   width : Required minimum width of the range of headings
#   start,end : The range of entry boxes whose widths have to match up with $width

proc RescaleRange {c width start end} {
    global TVals
    set totalWidth 0
    set newWidth 0

    # Current width of the range of columns in pixel units
    for {set j $start} {$j <= $end} {incr j} {
	incr totalWidth [CharToPixel $c $TVals($c,entry,Width,$j)]
    }
    set totalWidth [PixelToChar $c $totalWidth]
    set difference [expr $width - $totalWidth]
    if {$difference < 0} {
	# Columns are wider
	set newWidth $totalWidth
    } elseif {$difference > 0} {
	# Columns are narrower, so increase their size by given amount
	RescaleColumns $c $start $end $difference
    }
    # else: Same width so return 0 anyway

    return $newWidth
}

# RescaleColumns
#    Increases a range of heading widths so that their total width
#    matches width of the super heading above

proc RescaleColumns {c start end change} {
    global TVals
    # BODGE
    set col $start
    for {set i 0} {$i < $change} {incr i} {
	incr TVals($c,heading,Width,$col)
	incr TVals($c,entry,Width,$col)
	incr col
	if {$col > $end} {set col $start}
    }
}

# ScaleHeadings
#    Matches heading widths and entry box widths

proc ScaleHeadings {c} {
    global TVals

    set nCols $TVals($c,heading,Number)
 
    for {set i 0} {$i < $nCols} {incr i} {
	if {$TVals($c,heading,Width,$i) > $TVals($c,entry,Width,$i)} {
	    set TVals($c,entry,Width,$i) $TVals($c,heading,Width,$i)
	} else {
	    set TVals($c,heading,Width,$i) $TVals($c,entry,Width,$i)
	}
    }
}

# PixelToChar
#    Converts a size in pixels to a size in entrybox units.
proc PixelToChar {c w} {
    global TVals
    
    set width [expr $w-$TVals($c,ExtraWidth)]
    set sCharUnits [expr $width/$TVals($c,CharWidth)]

    # Round up
    if {[expr $width % $TVals($c,CharWidth)] > 0} {
	incr sCharUnits
    }
    return $sCharUnits
}

# CharToPixel 
#    Converts an entry box width into a pixel width

proc CharToPixel {c w} {
    global TVals
    
    set sPixUnits [expr $TVals($c,ExtraWidth) + $w * $TVals($c,CharWidth)]
    return $sPixUnits
}

proc test_PixelToChar {c} {
    global TVals
    set TVals($c,ExtraWidth) 8
    set TVals($c,CharWidth) 9
    for {set i 1} {$i < 30} {incr i} {
	puts "$i [PixelToChar $c $i]"
    }
}
proc test_CharToPixel {c} {
    global TVals
    #set TVals($c,ExtraWidth) 8
    #set TVals($c,CharWidth) 9
    for {set i 1} {$i < 30} {incr i} {
	puts "$i [CharToPixel $c $i]"
    }
}

proc test_ScaleAllTitles {} {
    global TVals eWidths hWidths sWidths tWidth
    
    set eWidths [list 1 23 20 10 10]
    set hWidths [list 9  21 19 11 10]
    set sWidths [list    21 90 10]
    set sLast   [list 1   3  4]
    set tWidth 10

    set TVals(c,heading,Number) [llength $eWidths]
    set TVals(c,super,Number) [llength $sWidths]
    set TVals(c,title,Number) [llength $tWidth]

    for {set i 0} {$i < [llength $eWidths]} {incr i} {
	set TVals(c,entry,Width,$i) [lindex $eWidths $i]
	set TVals(c,heading,Width,$i) [lindex $hWidths $i]
    }

    for {set i 0} {$i < [llength $sWidths]} {incr i} {
	set TVals(c,super,Width,$i) [lindex $sWidths $i]
	set TVals(c,super,lastCol,$i) [lindex $sLast $i]
    }

    set TVals(c,title,Width,0) $tWidth
    set TVals(c,title,lastCol,0) 4

    #set TVals(c,ExtraWidth) 8
    #set TVals(c,CharWidth) 9

    puts "At Start"
    output_ScaleAllTitles
    ScaleAllTitles c
    puts "At End"
    output_ScaleAllTitles
}

proc output_ScaleAllTitles {} {
    global TVals eWidths hWidths sWidths tWidth

    for {set i 0} {$i < [llength $eWidths]} {incr i} {
	puts -nonewline "   $TVals(c,entry,Width,$i)"
    }
    puts ""
    for {set i 0} {$i < [llength $hWidths]} {incr i} {
	puts -nonewline "   $TVals(c,heading,Width,$i)"
    }
    puts ""
    for {set i 0} {$i < [llength $sWidths]} {incr i} {
	puts -nonewline "   $TVals(c,super,Width,$i)"
    }
    puts ""
    for {set i 0} {$i < [llength $tWidth]} {incr i} {
	puts -nonewline "   $TVals(c,title,Width,$i)"
    }
    puts ""
}

#test_ScaleAllTitles
    
