Application Definition files.

Application definition files should be called app_name.def
where app_name is the name of the command you intend to use
to run the application. Once registered, the server admin
script can be run using the command

ghui_admin app_name

and the application can be run using

ghui app_name

The application definition file contains the following. Apart from
the first two lines, the ordering of sections is not important.

Line 1:  app_name   base directory of application ($ui_dir)
Line 2:  ghui      base directory of ghui distribution

Registration of versions of an application is headed by the string
"Versions"
followed by, for each version:
version number ($vn) (eg 4.1), pathname to base directory of version
relative to the ghui base directory.
This section terminates with the string "END"

Registration of version specific directories is headed by the string
"Directories"
followed by, for each version:
type of directory (eg windows), pathname relative to $ui_dir/vn$vn.
Mostly, the umui directories have the same name as the directory
type. However, they can be called anything.

As a minimum, the GHUI code references directory types "windows",
"skeletons" "variables". Almost essential is "help". the processing
function requires "processing" and if any application functions are 
required, they need a "functions" directory. Additional directories may be 
added. For example, in the UMUI an icons directory is added for use by
the application specific STASH function. Directory names are obtained within
the code using, for example
 set file_name [directory_path icons]/nav.xbm

The "Directories" section ends with "END".

The "Dimensions" section relates to the size of the entry window.
RELATIVE_WIDTH determines the width of the window relative to the
screen size. A LINE_HEIGHT of 32 looks reasonably neat. The
NUMBER_OF_LINES is the number of lines of experiments and jobs shown
initially.

The Server section holds the port number of the server.

The next two sections relate to the information displayed in the columns
of the entry window. Some of this information is from the GHUI and some of
it may be application specific. For example the GHUI columns display 
information about the owner, version, id numbers whereas the application
specific information is set by application specific functions. The information
in these two sections is also read by the experiment filter. Application
specific column definitions start with the string 
"Columns"
GHUI specific column information starts with the string
GHUI_Columns.

The format for the generic columns is the same as for the application
specific columns.

Column 1 is an identity name. Each column must have a unique name and
certain names are reserved for GHUI information; namely, id, owner,
description, version, access_list.

Column 2 relates to the experiment filter. Experiments can be filtered
by a string match in which case this column will contain "string". For
columns which may contain one of only two or three choices this column
may contain "option" and the experiments will be filtered on the
selection of a radio button.

Column 3 contains the title of the column. If spaces are require,
enclose the string in quotes.

Column 4 contains the relative x position of the column. The values should
be between 0 and 1. Setting them is a matter of trial and error. 

Column 5 contains a function name that sets the contents of the 
column. The function should be in the version specific "functions"
directory. When required, the function will be called with the identity
name of the column. For GHUI specific columns a function is optional.

Column 6 specifies which filters should automatically be applied when
the filter window is first opened. Typically this will be set to 0 for
all but "owner".

Column 7 specifies the default value for the filter. For owner, the 
username of the account in which the client is running is automatically
applied. Thus, in combination with setting column 5 of owner to 1 will 
result in the jobs owned by the relevant account being displayed when the job
is first opened.

The contents of Columns 8 upwards depend on whether column 2 says
option or string. For string, a string input is required in the filter
window so a figure is given to specify the width of the entry box.
For option, a list of options is given. One special case applies
in the event that the option is Y/N. In this case, the dafault value
may be Y or N, the option list contains only one string; namely, "YN",
but when the values are displayed in the filter window or the entry window,
the words "Yes" and "No" are used.

None of the GHUI columns have to be used. Any that are excluded will
be invisible to the user but the information will be maintained by the
GHUI system as some of it - such as the version number - is necessary
for the operation of the application. 

Details listed in the application specific columns is maintained
within the database. If new columns are added, or columns removed, the
server must be restarted. New columns will contain "unset" if the job
was created before the column was added - once the job is saved, the
column will be properly set.
