GHUI Documentation

Adding Variables to a GHUI Application.
SD Mullerworth
26.1.96 Incomplete

This document summarises the steps to be taken when adding a variable
to a GHUI application. See other GHUI documentation for more details
of the different types of variable allowed, window design, filling in
variable registers and writing of processing files. The document deals
mainly with the correct method for writing the functions that are
sometimes required for checking variables when the options allowed in
the variable registers are not flexible enough. Examples are included.

The variables being discussed are not conventional Tcl
variables. Rather they are GHUI variables whose values are stored as
strings either in a job or an application database. They need to be
included one of the three variable registers which also contain other
information about the type of variable. The information in these
databases and registers is obtained or altered by using a number of C
commands which are described in the README file of the /bin directory.

The following is a description of the stages to go through when adding
a new variable to an application.

1. If the variable is to be set by a user, add it to a panel control
file as one of the various types of question allowed.  Follow the
instructions held in the README file for the /windows directory. If
any .case, .invisible or .inactive logic is used to deactivate the
variable in certain circumstances, this should be noted.

2. Add the variable to one of the variable registers. See the README
files and the comments within the registers themselves to determine
which is the appropriate register. If the variable is to be set by a
user, it will almost always be included in the var.register file -
these are the variables that are stored in the job database. Other
variables go into the system or parameter registers and have their
values set in the associated database in the /variables directory.

The documentation for these files provides information about filling
in the variable registers. Of particular importance is the "inactive"
column, column 11, of var.register. This column may contain a number of
pieces of information which determine whether the variable is in use
or inactive. It is important that there is a match between this logic
and the .case etc. logic in the window; there is an inbuilt
consistency check which produces warnings if the logic in the variable
register disagrees with the logic in the window panel. See the
examples below. In the case of array variables, a length expression
may be used in this column to determine how many of the elements need
to be checked.

3. Ensure that the variable is incorporated when the job is
processed. Once again, the .case, .invisible etc logic is
important. If the variable is inactive it may be set to a blank value
or to any other value. For integers and strings, no warning will be
given if the value is of the incorrect type when processing accesses
its value (REAL variables will cause an error in processing if they
are wrongly set). Ideally then, logic in the processing should mean
that getting the value of inactive variables should not be attempted.

EXAMPLES

Example 1

An example window panel:

.winid "example_window"
.title "Example"
.wintype entry

.panel
   .text "Specify various options" L
   .basrad "Choose option" L 3 v CHOICE
           "Option 1 " 1
           "Option 2 " 2
           "Option 3 " 3
   .gap
   .case CHOICE[1]
     .check "Specify switch" L SWITCH Y N
     .invisible SWITCH[Y]
       .entry "Define Number of items 1 to 10 "   L LIST_LENGTH
       .table levels "ETA table" top h LIST_LENGTH 10 DESC 
         .elementautonum "Eta Half Level" 1 LIST_LENGTH 10
         .super "Items"
           .element "Values must be in ascending order" ITEMS 10 35 in
         .superend
       .tableend
     .invisend
   .caseend
.panend

This panel contains a radio button for variable CHOICE, a check box
for SWITCH and a table of ITEMS, length LIST_LENGTH. 

var.register:

CHOICE is never inactive on the window. SWITCH is active only when CHOICE
is 1. LIST_LENGTH and ITEMS are active only when CHOICE is 1 and SWITCH
is Y. Additionally, the array ITEMS need have only the elements 1 to
LIST_LENGTH checked. Hence, the logic in the inactive column of the
variable register should return TRUE if the variable is inactive and
FALSE if it is active. 

Variable name			Inactive column
CHOICE				NEVER
SWITCH				CHOICE!=1
LIST_LENGTH			(CHOICE!=1)||(SWITCH=="N")
ITEMS				LIST_LENGTH:(CHOICE!=1)||(SWITCH=="N")

Example 2

Consider a table with two columns which, similar to example 1, depends
on SWITCH being set to Y to be active. Column 1 COL1 is set to Y or
N. Any row of column 2 COL2 needs to be filled in only if the same row
of column 1 is set to Y. The variable register would then be:

variable			Inactive column
SWITCH				NEVER
COL1				SWITCH=="N"
COL2				(SWITCH=="N")||(COL1(N)=="N")

Functions

Determining whether a variable is active or inactive is sometimes too
complicated to express in a simple logic statement. In this case,
functions can be used instead of logic statements. Functions can be
used for arrays or for scalar variables. The general form of
a function is as follows.

proc function_name {variable call_type index} {
   # $variable is set to the name of the variable
   # The function may be called more than once. The first call
   # is made with call_type set to "PRELIM" - a preliminary call 
   # and index is not used.
   # This returns 1 if the whole of $variable is inactive, 0 if fully
   # active, or 2 if the active status is index dependent. In the
   # first two cases the function will not be called again. In the
   # last case, the function is called from a loop for each index of the 
   # variable and returns 1 or 0 for the separate elements of the
   # variable.
 
   if {$call_type=="PRELIM"} {
      # If 1 or 0 is to be returned from this part, the logic *must* 
      # match the .case logic in the window otherwise a built-in
      # consistency check may produce a warning. If the activity
      # status is index dependent, return 2
      ...
   }
   # This bit is executed if the preliminary call returned 2. 
   # $index refers to one of the elements of $variable.
   # return 1 or 0 depending on whether the element is inactive or
   # active
}


If the active status is not index dependent, as will be the case with
scalars and may be the case for arrays, then only one call to the
function is stricly necessary and the call_type can be ignored.
However, because the return from this function on the preliminary call
must match the case logic in the window it will usually still be
necessary to consider call_type. See Example 4.

Example 3

Suppose we have an array variable ITEMS set in a table. Like
Example 2, assume that if SWITCH="N" then ITEMS is totally inactive
and the table will be greyed out or invisible. On the other hand, if
SWITCH="Y" then some elements of ITEMS may be active and others
inactive. However, unlike Example 2, assume that the logic for
determining the index dependent status cannot be expressed in a simple
logic statement.

To deal with this situation, a function is listed in the inactive column:

Variable name			Inactive column
ITEMS				LIST_LENGTH:FN:check_items_list

and the function check_items_list will be in the following form

proc check_items_list {variable call_type index} {
   # Function for checking variable ITEMS

   if {$call_type=="PRELIM"} {
      set switch [get_variable_value SWITCH]
      if { $switch=="N" } {
         # Table is inactive - the whole variable is therefore
         # inactive so return 1.
         return 1 
      } else {
         # Table is active but inactive status of variable is index
         # dependent. return 2 meaning - must be evaluated index by
         # index.
         return 2
      }
   } else {
      # preliminary call returned 2. Function has been called again with 
      # $index set to some value. Determine whether the $index'th
      # element of $variable is active or not and return 0 or 1
      ...
      if {logical check} {
         # element of variable is active
         return 0
      } else {
         # element is inactive
         return 1
      }
   }
}

Example 4

Consider adding a new variable, EXTRA_INFO, to example 2 above. For
the purposes of this example, EXTRA_INFO can be array or scalar.
Suppose EXTRA_INFO is required only if the table is active and if one
or more element of COL1 is set to Y. It is not feasible to include all
this logic in a .case statement on a window; ie in the form:

SWITCH[Y]&&(COL1(1)[Y]||COL1(2)[Y]||COL1(3)[Y]||COL1(4)[Y]||COL1(5)[Y]||...)

nor would it be feasible to have a similar logic statement in the
variable register. Instead, the logic on the window would probably be

.case SWITCH[Y]

and in the variable register, a function would be used.

variable			Inactive column
EXTRA_INFO			FN:extra_info

Although the inactive status can be immediately calculated (ie even if
it is an array, the status does not depend on the index) it is
important that the preliminary call to the function either matches the
.case logic in the window or returns 2 implying - cannot evaluate
yet. An example function to deal with this variable is as follows.

proc extra_info {variable call_type index} {

   # inactive checking for EXTRA_INFO
   # Inactive if SWITCH is N or if COL1 contains no Y
   # function will be called with $variable == EXTRA_INFO

   if {$call_type=="PRELIM"} {
      set switch [get_variable_value SWITCH]

      if { $switch == "N" } {
         # variable is definitely inactive.
         return 1    
      } else {
         # although active status is not index dependent and could be
         # calculated now, the preliminary call return must either
         # match the .case logic in the window or must return 2. Hence:
         return 2
    } else {
         set list [get_variable_array COL1]

         if { [lsearch $list Y] == -1 } {
            return 1  ; # no Y in list. Therefore inactive
         } else {
            return 0 ; # At least one Y. Therefore active
         }
    }
}

The above function will be called once for a preliminary call and, if
it returns 2, once for each index of the array EXTRA_INFO (or only
once if scalar)
