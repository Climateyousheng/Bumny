# Returns path to an application directory - eg umui/updates
# where $name is updates
proc appdir_path {name} {
    return [application_path]/$name
}

# Returns path to the base of an application or the GHUI itself
proc application_path {} {
    global directories application version
	
    return $directories($application)
}

# Returns path of a GHUI directory
proc ghuidir_path {name} {

    return [ghui_path]/$name
}

# Base directory of the GHUI
proc ghui_path {} {
    global directories

    return $directories(ghui)
}

# Base directory of a version of the GHUI job-edit code
proc ghui_version_base {version} {
    global directories application
    if {[info exists directories($application,$version)]==0} {
	error "Version $version is not registered in the $application.def file"
    } else {
	return $directories($application,$version)
    }
}

# Path to a directory in the GHUI job edit code
proc ghui_version_path {version dir} {
    return [ghui_version_base $version]/$dir
}

# Path of a help file
proc ghui_help_file {name} {
    set file [ghuidir_path help]/$name.help
    if {[file readable $file] == 0} {
	error "Help file $file does not exist or is not readable"
    } else {
    return $file
    }
}

proc help_include_file {name path} {
    
    return $path/$name.inc
}


proc serverdef_file {} {

    return [appdir_path etc]/servers.def
}
