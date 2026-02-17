################################################################
# Routines that return paths and filenames required by various #
# functions                                                    #
################################################################

# Path to a particular directory type - the key is in the
# "Directories" section of the apllication definition file.
proc directory_path {name} {
    global directories application version
    if { $name == "etc" } {return [application_path]/$name}
    return [application_path]/vn$version/$directories($application,$name)
}

# Path to base dir for GHUI job edit code for a particular version
proc ghui_version_path {} {
    global directories application version   
    return $directories($application,$version)
}

# Directory which contains windows, variables, help etc. for a
# particular version of the application
proc version_path {} {
    global directories application version

    return [application_path]/vn$version
}

# Base directory of an application
proc application_path {} {
    global directories application

    return $directories($application)
}

# Base directory of the GHUI distribution
proc ghui_path {} {
    global directories

    return $directories(ghui)
}

# Returns path name of version specific GHUI directory
proc ghui_version_dir {type} {
    return [ghui_version_path]/$type
}

##################################################################
# Central definitions of the locations of various types of files #
# required by GHUI-based applications.                           #
##################################################################
proc window_include_file {name} {
    
    return [directory_path windows]/$name.inc
}

proc window_file {name} {
    
    return [directory_path windows]/$name.pan
}

proc help_include_file {name path} {
    
    return $path/$name.inc
}

proc help_file {name} {
    
    return [directory_path help]/$name.help
}

proc skeletons_file {name} {
    
    return [directory_path skeletons]/$name.skel
}

proc navspec_file {} {

    return [directory_path windows]/nav.spec
}

proc navbuttons_file {} {

    return [directory_path windows]/nav.buttons
}

proc partitions_directory {} {

    return [directory_path variables]
}

proc serverdef_file {} {

    return [directory_path etc]/servers.def
}
