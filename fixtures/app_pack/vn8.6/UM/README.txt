GHUI and UMUI Documentation

The /tcl/UM directory
Application Specific Functions
SD Mullerworth
19.1.96

This directory holds functions specific to the application. These fall into a 
three categories all of which are likely to be required in most reasonably 
large applications:

  * Navigation functions - Routines executed on selection of the buttons in
    the application's entry window.
        Look at the examples included in the UMUI.        

  * Standard variable checking functions.
        Read the document "Adding variables to a GHUI application" for examples
        of how variable checking functions are written.

  * Routines which are called on entering, exiting or abandoning windows. 
        See the nav.spec file for help in using these.

To write these routines, an understanding of the way variables are stored and
a knowledge of some of the basic variable handling C routines will be needed. 
See the README files for the /variables and /bin directories.


A summary of each class of routine follows. Read these carefully, but also
look at the examples in other documents.

Navigation Functions.

Navigation functions are those functions which are called when the buttons
on the navigation window of an application are selected. The functions are
called without arguments. The nav.buttons file in /windows provides a simple 
method for adding additional buttons.

Currently, nearly all the navigation buttons written for the UMUI are 
application specific and reside in this directory. Only one, full_verify
(Check Setup), is generic and is included in the /tcl directory. However, 
many of the UMUI navigation functions, including those such as Save, Quit 
and Process, can easily be rewritten to be suitable for other applications.
Descriptions of each of the navigation buttons can be found in the help 
provided for the navigation window.

Standard Variable Checking Functions

These functions are called when the variables to which they are attached are
checked. The functions are attached to the variables by listing them in the 
appropriate place in variable registers. See README_Registers in /variables.
These functions are divided into three categories.

1. 'Inactive' Functions: These are listed in the inactive column. They 
are used when a logic expression is not suitable. They are called with 
three arguments: variable, call type and index. Preliminary calls are made 
to functions with  call type set to PRELIM. On this call, functions return 
0 if the variable is active, 1 if it is inactive or 2 if the variable is
a list which could be partly active and partly inactive. 

When a variable is checked following a window closure and the return from a 
preliminary call is 0 or 1, this logic must ideally match the greying out or 
invisible status on the window panel. A consistency check included in the GHUI
is designed to produce a system warning message if the logic does not match.
To use this check, a variable called CONSISTENCY_CHECK should be added to
the system register and set to 'ON' in the system database.

2. Verification functions: These are listed in the final column of the variable
register. They are required to check variables when the LIST, FILE and RANGE
check options are not suitable. They are called with three arguments, variable 
name, variable value (or list of values if an array) and index to be checked. 
For scalar variables, index is set to -1. Verification functions should
return 0 for valid values or output suitable error messages using the 
error_message function and return 1 for an error.

3. Window name functions: These are listed in the window name column of the
variable register. They are required when an array variable has different
elements set on different window panels. Currently, they are executed only 
during the Check Setup procedure but they will eventually be used when 
producing job sheets and when comparing two jobs. 

These functions are called without arguments, but they do require two
global variables, fv_variable_name and fv_index which will be set to
the variable name and index by the calling function. For 2D lists,
fv_index will be set to the second index.  They should return a list
containing two strings. The first string is used in generating the
Check Setup error message which is of the form:-
     {Error type} in {location text} (variable {variable name})
The second string should be the window name which is listed somewhere in 
nav.spec. The nav.spec file is searched during Check Setup to provide
informative directions to problem windows.


Functions attached to Windows

As described in the nav.spec file in the windows directory, up to three 
functions can be attached to window panels which are executed when the 
window is opened, abandoned or closed. These functions can take any format
and hold any arguments. For example, they may be used to set various variables
which do not need to be set by the user. They may also be used to incorporate
non standard windows into the interface. The UMUI contains one such example
called stash.

Note that the function executed on closure of the window is run *after* the 
variables have been checked and the window panel closed.

-------------------------------------------------------------------------------

