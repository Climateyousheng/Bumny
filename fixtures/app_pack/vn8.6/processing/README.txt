UMUI and GHUI documentation.

README for the Processing Directory.
5 January 1995. 
Mick Carter.

In brief:
This directory holds skeleton files that are converted into application
control files by the navigation action "processing". Essentially, this action
performs variable substitution to create files whose format is defined by the
contents of this directory.

Processing is a "Navigation Action" and so may not be used in some GHUI
applications, but this is unlikely to be the case.

Normally, a GHUI application uses the GHUI windows system to allow users to
assign values to variables and to further change those values at a later date.

Processing is a method of converting this information into formatted control
files that can be used to run the application associated with this GHUI, eg
the UM.

The navigation action "Process" can create a number of files, each of which
is defined by one or more "processing" files. These are the files in this
directory.

The only file that needs to be here to allow this to happen is "top". 
The name of this file is hard-wired in the processing code.

The contents of the file are parsed into tcl code and then executed.
The contents are themselves a mixture of tcl and our own shorthand.

Those developing new GHUI applications would do well to look at the files in
the UMUI application to see examples of how this can be used.

It is best if the file "top" is kept for controlling the creation of other
files and to source tcl functions that are required by processing. Such
functions also live in this directory.

For example, "top" can instigate the generation of a control file call XYZ as
follows:

<snip>
%OUTPUTFILE XYZ
%I xyz
</snip>

In this case, any previous control file being written would be closed and a
file called XYZ opened in the user's job directory.
The processing function would then look for a file "xyz" in the procesing
directory and "include" it (%I). More than one file can be "included". The act
of inclusion implies parsing of the file into a piece of tcl. At the end of
this process the whole piece of tcl is executed.

The file xyz may need to call a tcl procedure to perform some tasks. Say the
function is call find_maximum. This can achieved by creating a file in this
directory holding the tcl procedure. The file in this case should be named
proc_find_maximum to denote the fact that it is a tcl proceedure and not a
processing skeleton. Procedure names should not conflict with any names used
elsewhere in the GHUI tcl code.

All procedures should be sourced at the top of the "top" file as follows:
%I proc_find_maximum
be sourced by creating a file

Below is a description of how the parsing works, as supplied by the designer
Chris Paulson-Ellis:

This piece of text will get passed through unchanged, as will
any text that does not have percentages in it.

All the constructs in this mechanism will be started with a
percentage.

A double percentage, %%, is used to output a single percentage.
If you want two percentages, then use 4 percentages in a row
like this, %%%%.

If a percentage is followed by a variable name, then this is
substituted from the basis database, ie %ETA(4), or %NLEVSA.
This substitution is done without any sort of padding.
If there is some ambiguity at the end of the variable name
then you can use curly brackets to clarify. For example:

%{NLEVSA}(10) 
  may yield
19(10)
  whereas
%NLEVSA(10)
  would give an error, since NLEVS is not an array.

Without curly brackets, a variable reference is ended by the
first character that is not alphabetic, unless there is a
parethesised expression. eg:

/users/string02/%USERNAME/umui/%FILENAMES(4).ui
  may yield:
/users/string02/frcp/umui/fourthfile.ui

A comment is specified in one of two ways. Percent C starts
a comment that ends at the end of the line. eg:

This is not in the comment, %C but this is in the comment.
Again, this is not in the comment.

For multiple line comments COMM and ENDCOMM are used. eg:

This is not in the comment. %COMM
This is in the comment.
  This is also in the comment.
%ENDCOMM This is not in the comment.

This yields (note the two spaces between the sentences):

This is not in the comment.  This is not in the comment.

The curly bracket construct can be used to remove the spaces without
making things ambiguous. eg:

This is not in the comment.%COMM No problem at the start
This is in the comment.
  This is also in the comment.
Need curly brackets at the end... %{ENDCOMM}This is not in the comment.

  would yield:

This is not in the comment.This is not in the comment.

%COMM
   This comment will just be ignored in the skeleton.
   You can use other constructs in the comment (here is a
   percentage: %%); They will be recognised, but not interpreted.
   You can nest comments to any depth:
      This is in the comment. %C This is a comment within a comment.
      %COMM
         This is a multiple line
            comment within a comment!
      %ENDCOMM
   This allows you to comment out complex pieces of code.
%ENDCOMM

To include a skeleton within a skeleton, just use one of
the following constructs:

%I filename1

or

%INCLUDE
   filename1
   filename2
%ENDINCLUDE

This includes any number of skeletons at the current
position. I expect we will have a search path in which the
filenames can be found.

As for comments, the short form terminates the include at the
end of the line.

The other constructs will be implemented in tcl. The tcl code
will be straight tcl except for the percentage substitutions.
All the special facilities needed will be implemented with new
tcl commands (procedures).

By the way, the reason that percentages are used is because
they have no special meaning to a shell or to tcl and are
little used in tcl or shell scripts. This means that they
can be given a new special meaning without conflicting with
other shell or tcl constructs.

This example shows how a tcl construct is introduced:

%T putl {This text gets printed.}
  which yields:
This text gets printed.

or

%TCL
  putl {This text
        gets printed.}
%ENDTCL
  which yields:
This text
        gets printed.

The new tcl command putl puts its argument with a newline into
the output file. There is another new tcl command, put, which
does not use a newline in the output. eg:

This is equivalent...
%T put {This is equivalent...}
%TCL put {This is equivalent} %ENDTCL...

There is nothing to stop you using tcl variables, arithmetic,
logic, flow control, etc. This example prints the numbers 0
to 9:

%TCL
  for {set i 0} {i < 10} {incr i} {
    putl $i
  }
%ENDTCL

You can continue to use other constructs within the tcl
construct. This prints a line of increasing numbers from
START to END, from the basis database, separated by
percentage signs.

%%%TCL
  for {set i %START} {i <= %END} {incr i} {
    put " $i %%"
  }
%ENDTCL

Note that in this example, a single percentage is printed before the tcl
starts and a single percentage is printed after every number.

The new tcl command "pad" will extract strings and pad them with the
appropriate number of spaces as defined in the variable register.
The result is returned as the result of the tcl command (it is not
printed). eg:

SOIL="%TCL put [pad FILE(56)] %ENDTCL"
  may yield:
SOIL="$DATAR/qrclim       "

Note that we had to use the long TCL ENDTCL form here in order to surround
the value with quotes without any newlines getting in. The square brackets
are a tcl construct that use the result of the "pad" command as the
argument to "put".

This is a common construct, but it is annoying to have to type the
put part, so we will create a further tcl command, padp, that
prints the result rather than returning it. eg:

SOIL="%TCL padp FILE(56) %ENDTCL"
  may yield:
SOIL="$DATAR/qrclim       "

This is still rather long, because of the long TCL TCLEND construct. A
further variation of pad, padpq, will print the padded string surrounded
with double quotes. We can then use the short form of tcl inclusion. eg:

SOIL=%T padpq FILE(56)
  may yield:
SOIL="$DATAR/qrclim       "

One can add any number of these handy abbreviations very easily. It
depends on what constructs come up most. For example, if we want lots
of lines like the above, but with commas at the end (for namelists),
then we could create a new tcl command, padpqc, which prints that too. eg:

SOIL=%T padpqc FILE(56)
  may yield:
SOIL="$DATAR/qrclim       ",

If the variable does not need padding then simple substitution can be used:

SOIL=%FILE(56)
  may yield:
SOIL=$DATAR/qrclim

If the variable is a REAL, then it is formatted according to the format in
the variable register. For example, if the format for VALUE in the variable
register is .2f, then with a value of 3.4:

NUMBER=%VALUE
  will yield:
NUMBER=3.40

If the format had been 10.2f, the you would get:

NUMBER=      3.40

If some arithmetic is needed, then use tcl:

NUMBER=%T put [expr %VALUE * %MULTIPLIER]
  may yield:
NUMBER=6.8

If you need to reformat this result, then use the tcl format command. eg:

NUMBER=%T put [format %%10.2f [expr %VALUE * %MULTIPLIER]]
  may yield:
NUMBER=      6.80

Note that this is a rare case when we need a real percentage in the
tcl, because the tcl format command uses it. The percentage was inserted
with the double percentage construct. In both these cases, we have been
using the standard tcl commands expr and format. These are not new commands
and illustrate the use of arbitrary tcl.

We could use format to re-format a variable which needs to be output with
a different format to that which appears in the variable register. eg:

NUMBER=%T put [format %%.5f %VALUE]
  will yield:
NUMBER=3.40000

Since we are on the subject of maths, here is an example of using tcl
variables, maths and logic:

STRATOSPHERE=%TCL
  %C This is a comment in the tcl
  # Since we are in tcl, we can also use tcl comments.
  # Use the set and eval commands to set the tcl variable tropopause_height
  #  to the value of the variable SURFACE_PRESSURE divided by 10. Ha, ha.
  set tropopause_pressure [eval %SURFACE_PRESSURE / 10]
  # Use a tcl if test to compare this with the value of the variable TOPLEVEL.
  if {%TOPLEVEL < $tropopause_pressure} {
    put Y
  } else {
    put N
  }
%ENDTCL
  will yield either:
STRATOSPHERE=Y
  or:
STRATOSPHERE=N

This could be compressed to:

STRATOSPHERE=%T if {%TOPLEVEL < [eval %SURFACE_PRESSURE / 10]} {put Y} else {put N}

To to array substitution, we need a routine to print a list with
delimiters:

ETA_HALF=%T delimit %ETAH {,} { }
  may yield:
ETA_HALF= 1.00 , 0.75 , 0.50 , 0.25 
                                   ^
                       There is a space here.

The new tcl command delimit takes three arguments. The first is a
list of values. We have used simple substitution to get the value of
an array as a tcl list. The second argument is the separator put
between each value. The third argument is the string used to surround
each value; in this case, a space. The curly brackets are used in tcl
to protect a string from being evaluated. They are superfluous around
the comma, but needed around the space.

We may not have wanted those spaces:

ETA_HALF=%T delimit %ETAH {,} {}
  may yield:
ETA_HALF=1.00,0.75,0.50,0.25

Maybe we want quotation marks:

CODES=%T delimit %CODE_STRINGS {,} {"}
  may yield:
CODES="a3","b3","c3","d3","e3"

We can use pad, defined above to pad string arrays before
they are "delimited":

CODES=%T delimit [pad CODE_STRINGS(*,3)] {,} {"}
  may yield:
CODES="a3  ","b3  ","c3  ","d3  ","e3  "

Note that we have used an array slice. Here are the possible ways of
returning a value:

  scalars:
    %VAR        - scalar variable
    %VAR(5)     - array element
    %VAR(3,4)   - 2D array element
  lists:
    %VAR        - whole array
    %VAR(*,3)   - column array slice
    %VAR(2,*)   - row array slice

This is just the same as in the window definition files. Note that
when an array is used, a list is returned which is the current
length of the array, not the maximum possible length padded with null
values.

Variable substitution will use the new tcl command replace:

GLOBAL=%T put [replace GLOB Y .TRUE. N .FALSE.]
  may yield
GLOBAL=.FALSE.
  or
GLOBAL=.TRUE.

The first argument to replace is a variable name. The variable value
is then compared with the 2nd, 4th, 6th,... arguments and the
corresponding 3rd, 5th, 7th... argument is returned. If the variable is
an array or array slice, then this is done for each element of the array
and a list is returned.

If there are no matches a tcl error is generated with the following
text. The message will be displayed in a window.

  GLOB is only allowed the values Y or N, but was WHATEVER.

To avoid having to type the put statement, there can be a
short form called replacep (like pad and padp). eg:

GLOBAL=%T replacep GLOB Y .TRUE. N .FALSE.

If you do not want a match failure to cause an error, then use the
pattern * to match any other value. eg:

GLOBAL=%T replacep GLOB Y .TRUE. N .FALSE. * .FUZZY.
  will yield:
GLOBAL=.FUZZY.
  if GLOB is neither Y or N.

An array substitution would work like this:

GLOBALS=%T replacep GLOBS Y Yes N No
  may yield:
GLOBALS=YesNoYes

To delimit the result using the delimit command described above, we
need to use the form of replace that returns its result rather than
printing it. eg:

GLOBALS=%T delimit [replace GLOBS Y Yes N No] {,} {"}
  may yield:
GLOBALS="Yes","No","Yes"

Case statements will use normal tcl statements and logic:

%T if {%ATMOS == Y} {
  SOIL=%T padpqc FILE(56)
  # This is a shell comment, not a tcl comment
%T }

 may yield:

  SOIL="$DATAR/qrclim       ",
  # This is a shell comment, not a tcl comment

The above example shows the tcl command split into more than one line. The
start of the if statement is in one percent T bracket and the end is in
another. This allows you to treat the body of the if as arbitrary
skeleton constructs. It could have been written, less elegantly as:

%TCL
 if {%ATMOS == Y} {
   put {  SOIL=}
   padpqc FILE(56)
   put {\n  # This is a shell comment, not a tcl comment}
 }
%ENDTCL

It also reveals how the skeleton is going to be evaluated. The whole thing
will be parsed, turning it into a tcl script. This tcl script will then
be run. This is the same mechanism used for parsing window definition files.

The DO loop example could be coded as:

%T for {i = 1} {i <= %ILEVSA} {incr i} {putl K($i)=%DIFF($i),}
  which may yield:
K(1)=1.2E-5,
K(2)=1.2E-5,
K(3)=1.2E-5,
K(4)=1.2E-5,
K(5)=1.2E-5,

This uses the tcl variable i to index the array. Note one can
use the DIFF reference here as it will be re-evaluated
on each execution of the loop, with a different index value. Again, this
is a feature of the parse/execute mechanism.

No facility for creating new variables in the basis database has been included. 
The use of tcl variables (using the $var construct) should suffice.


Advantages of this approach:

  Very easy to write.

  Easily extensible by adding further tcl commands for any
  complex processing that might be needed.

  Full flexibility of tcl available. We can use all the logic and control
  structures of tcl as well as additional commands written in tcl.

Summary of constructs:

  %%
    Produce a single percentage sign

  %varname
  %{varname}
    Substitute with variable value or array list

  %COMM ...any text or constructs... %ENDCOMM
  %C ...any text or constructs...
    Comment. Short form ended by newline

  %INCLUDE ...file names... %ENDINCLUDE
  %I ...file names...
    Include other skeleton files. Short form ended by newline

  %TCL ...any tcl and constructs other than %INCLUDE and $TCL... %ENDTCL
  %T ...any tcl and constructs other than %INCLUDE and $TCL...
    Evaluate tcl. Short form ended by newline

Summary of new tcl commands:

  putl arg
    Equivalent of "puts output_file arg"

  put arg
    Equivalent of "puts -nonewline output_file arg".

  pad varname
    Return variable value with strings padded to full length with spaces.

  padp varname
    As pad, but prints result.

  padpq varname
    As padp, but surrounds with double quote marks.

  padpqc varname
    As padpq, but followed by a comma.

  delimit list separator surrounder
    Prints list of values surrounded by the surrounder argument and
    separated by the separator argument.

  replace varname pattern1 string1 pattern2 string2 ...
    Return a list of strings, one for each element in array specified by
    varname (or a single string if the variable is a scalar). The string
    returned corresponds to the pattern matching that element. An error
    is produced if there are no matches unless the pattern * is used to
    match any other string.

  replacep varname pattern1 string1 pattern2 string2 ...
    As replace, but the result is printed.





 






