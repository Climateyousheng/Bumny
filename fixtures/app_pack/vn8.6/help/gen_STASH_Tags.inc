
Sets of diagnostics can be grouped together into packages by labelling
all of them with the same package identity. A package of diagnostics
can then be included or excluded as a group by setting the package
flag to Y or N in the "Set Package Switches" panel accessed from the
diagnostic menu. The panel also allows each package to be given a
short description.

Package identities can be any capital letter, and are set by entering
the appropriate box in the Package column and pressing a capital letter
key. Note that capital letters are required because lower case letters
have other uses within the STASH panel.

The Package column displays both the include status and the package
identity. The include status is "+" for "included" or just the package
name for "excluded". If no label is set, the diagnostic is included. If
the status of the label is not set to "Y" or "N", the assumed status is
excluded.

The package description is printed in the status line of the STASH
panel whenever a new package is attached to a diagnostic or whenever a
box in the Package column is selected with the mouse.

If a diagnostic is excluded, it is ignored by the verification
procedure and it is not output to the STASHC file on processing.

USEFUL TIP:

It is possible to divide the diagnostics into included and excluded
diagnostics by using the "Change Sort Order" option under the
diagnostics. Enter the number of both the Include column and the
Package column into the sort option box and sort. The diagnostics will
then be displayed with the excluded ones first then the included ones.
