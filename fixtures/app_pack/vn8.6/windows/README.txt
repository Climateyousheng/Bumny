UMUI and GHUI documentation.

README for the Windows Directory.
5 January 1995. 
Mick Carter.


In Brief:	
This directory holds control files that define the look and feel of the entry
windows, the navigation windows etc.   See also the skeletons directory.


Entry Windows.
Most files in this directory relate to entry windows. They are named
something.pan and are mostly control files that act as skeletons to define
what is seen on a window and how it interacts with the GHUI system.
A few of these files are dummy window files that link to application specific
Tcl code to define the actions, rather than the generic action.
To help you find these, the last level of there name (before the .pan) should
be "tcl" (eg atmos_STASH_tcl.pan). These windoes use the dummy window skeleton
(dummy.skel in skeletons) by using the type definition line:
<snip>
.wintype dummy
</snip>
Standard windows are defined by a language described in the
README_EntryWindows file.


Other files.
Apart from the README files and the COPYRIGHT file, this directory contains two
other files that should not be removed by someone setting up a new GHUI
application.
They are the "nav.spec" file and the "nav.buttons" file. These files are
internally documented


