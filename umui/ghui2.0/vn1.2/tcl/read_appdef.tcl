# Read info for outputting table and filter


proc read_application_defs {app} {
    global titles base_dir directories o_list
    
    set titles(relpos,icon) 0.0

    set o_list {}



    # Application specific columns
    set a [open $base_dir/apps/$app.def]
    foreach item [list $app ghui] {
	gets $a line
	while {[string index $line 0] == "#"} {gets $a $line}
	if { [lindex $line 0] != $item } {
	    error "Line of $app.def should hold application name \"$item\" optionally followed by its main directory but contains $line"
	}
	set directories($item) [lindex $line 1]
    }

    while {[gets $a line] != -1} {
	switch [lindex $line 0] {
	    GHUI_Columns {
		set_columns $a ghui
	    }
	    Columns {
		set_columns $a app
	    }
	    Directories {
		get_app_dirs $a $app
	    }
	    Versions {
		get_version_dirs $a $app
	    }
	}
    }
    close $a


    # Contains a list of columns in order of position on the table
    set titles(display_columns) $o_list

    # Contains list which includes all required GHUI columns. ie even if they
    # are not listed in the application defn a record of them will be kept
    set titles(all_columns) $o_list
    foreach col {id owner version description access_list opened} {
	if {[lsearch $titles(all_columns) $col]==-1} {
	    lappend titles(all_columns) $col
	}
    }
}


proc set_columns {a type} {
    global titles o_list user

    set titles($type\_columns) ""
    while {[lindex [set line [gets $a]] 0] != "END"} {
	set col [lindex $line 0]
	if { [string index $col 0] == "#" } {continue}
	if {$col==""} {error "No END to $type Columns list"} 
	lappend titles($type\_columns) $col
	set i 1
	foreach item [list type title relpos function filter_switch filter_default] {
	    set titles($item,$col) [lindex $line $i]
	    incr i
	}
	set titles(filter_options,$col) [lrange $line $i end]
	for {set j 0} {$j<[llength $o_list]} {incr j} {
	    if {$titles(relpos,[lindex $o_list $j]) > $titles(relpos,$col)} {
		break
	    }
	}
	set o_list [linsert $o_list $j $col]
    }
}

proc get_app_dirs {a app} {
    global directories

    set app_dir $directories($app)
    set d_list [list windows help functions processing variables bin skeletons icons]
    foreach directory $d_list {
	set directories($app,$directory) $app_dir/$directory
    }

    while {[lindex [set line [gets $a]] 0] != "END"} {
	set dir [lindex $line 0]
	if { [string index $dir 0] == "#" } {continue}
	if {$dir==""} {error "No END to directory list in $app.def file"} 
	if { [lsearch $d_list $dir]==-1 } {
	    error "Directory $dir in $app.def file is not a valid name. Must be one of $d_list"
	}
	set directories($app,$dir) [lindex $line 1]
    }
}

proc get_version_dirs {a app} {
    global directories
    
    while {[lindex [set line [gets $a]] 0] != "END"} {
	set version [lindex $line 0]
	if { [string index $version 0] == "#" } {continue}
	if {$version==""} {error "No END to version list in $app.def file"} 
	set directories($app,$version) [ghui_path]/[lindex $line 1]
    }
}

proc set_global_variables {a app list} {

    while {[lindex [set line [gets $a]] 0] != "END"} {
	set variable [lindex $line 0]
	set value [lrange $line 1 end]
	# puts "$variable $value"
	if { [string index $variable 0] == "#" } {continue}
	if {$variable==""} {error "No END to $list list in $app.def file"} 
	if [catch {expr $value}] {
	    error "Invalid value $value in $list list of $app.def file"
	}
	switch $variable {
	    default {
		error "Invalid variable name $variable in $list list of $app.def file"
	    }
	}
    }
}
