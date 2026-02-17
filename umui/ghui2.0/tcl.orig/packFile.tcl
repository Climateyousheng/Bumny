#
# packFile.tcl
#   Contains procedures for packing and unpacking files

namespace eval packFiles {
    namespace export pfTestPacking
    namespace export pfUnpackFile
    namespace export pfPackFile
}

# pfTestPacking
#   Test for existence of gzip and gunzip and set flag if they do.

proc ::packFiles::pfTestPacking {} {
    variable packFlag

    set packFlag 1

    # Create a test file to pack
    set fName [unique_jobfile]
    set f [open $fName w]
    puts $f "Test"
    close $f
    if {[catch {exec gzip $fName}]} {
	set packFlag 0
    } elseif {[catch {exec gunzip $fName}]} {
	set packFlag 0
    }
    file delete $fName
}

# pfPackFile
#   Packs file using gzip if packing flag on

proc ::packFiles::pfPackFile {file} {
    variable packFlag

    if {$packFlag == 0} {
	return
    }
    exec gzip $file
}

# pfPackFile
#   Packs file using gzip if packing flag on

proc ::packFiles::pfUnpackFile {file} {
    variable packFlag

    if {[catch {exec gunzip $file}]} {
	error "Basis file $file is packed but unpack command gunzip is unavailable"
    }
}

    
