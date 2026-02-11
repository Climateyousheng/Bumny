UMUI and GHUI documentation.

README for the Skeleton Directory.
12 January 1995. 
Mick Carter.

This directory contains skeletons that define the look and feel of standard
entry windows that are interpreted by the GHUI system. This has only one used
entry at present as well as a dummy entry for linking in non-generic windows
from the navigation system. However, other window formats could be defined
here.

entry.skel
  This file defines the outline for standard entry windows that are
  interpreted by the GHUI generic code.
  The file defines the standard buttons available on the window and links
  these to Tcl actions in the generic code. Help, Abandon changes and Close
  are defined in this way.
  All windows in the windows directory that have a wintype of entry will use
  this skeleton.
  
dummy.skel
 This file is used when the "window" entered via the navigation system (or
 by other means) is not a window that is dealt with by generic code. It has no
 effective information in it.
 



