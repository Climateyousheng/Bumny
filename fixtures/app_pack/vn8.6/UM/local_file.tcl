proc local_file {value variable index} {
    #  this procedure tests to see if a file is readable.
    #  it is used as a verification function to test on local files that need to
    #  be read, eg preSTASHmaster files.
    #  Accepts file list with an index, or single file
    if {$index!=-1} {
	set value [get_variable_value $variable\($index\)]
    }
    if { !([file readable $value]) } {
	error_message .d {File Not Readable} "Named file <$value> should be local and readable." warning 0 {OK}
	return 1
    } 
    return 0
}
