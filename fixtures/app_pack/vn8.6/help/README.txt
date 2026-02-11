UMUI and GHUI documentation.

README for the Help Directory.

5 January 1995. 
Mick Carter.



This directory contains files that relate to the version specific help
windows. 

The help relating to the entry system is NOT version specific, and so is not
in this directory. Move up to non-version specific directories to find this
help.

This directory includes:

  1. Files with help text relating to the help options available from the
  Navigation Window.
  
  2. Files with help text relating to each window that is reached from the
  navigation window (job set-up windows):
  
  3. Include files (file_name.inc) which may be included in other .help or 
     .inc files using:
        %I file_name 
     with the %I as the first two characters of a line.

For standard job set-up windows, the GHUI system looks for a file with a name
based on the window name. If it finds such a file, the text on the help button
is not greyed out, otherwise it is.
For example. A window with name "subindep_Control_Gen.pan" would need a file
in this directory called  "subindep_Control_Gen.help".
Hence the naming convention is set by the naming convention for windows.

Text substitutions can be specified in files which apply to all text below
the declaration including .inc files. Specify the substitution in the form

%S old_text new_text

and this will replace any succeeding instances of %old_text with new_text.
For example:

%S partition ATMOS
%I general_file

will replace instances of %partition in general_file.inc with the string ATMOS.

Non standard windows, such as STASH, may call the help windows directly, from
a drop-down menu. There may be no window associated directly with such help.
See the tcl code stash.tcl.
Here a menu is built as follows
<snip>
    menubutton $w.pbut.b6 -text "Help" \
	    -menu $w.pbut.b6.m -relief raised -font $font_butons
    pack $w.pbut.b6 -side left -expand yes -padx 20
    menu $w.pbut.b6.m 
    $w.pbut.b6.m add command -label "stash...." \
	    -command "show_help .stash"
    $w.pbut.b6.m add command -label "profiles...." \
	    -command "show_help .stash_profiles"
    $w.pbut.b6.m add command -label "diagnostics...." \
	    -command "show_help .stash_diagnostics"
</snip>
New help categories can be added easily by adding lines such as
    $w.pbut.b6.m add command -label "more help...." \
	    -command "show_help .stash_MoreHelp"
In which case, a file would be required in this directory called
"stash_MoreHelp.help"
Here the naming of the file should follow this convention:
	Text separated by the Under-score character, followed by .help.
	The first level (before the first underscore character) should denote
	the special window type (such as stash_).
	Other levels, separated by underscores, should not normally be needed
	unless you have nested drop-down menus.
	
Similarly, this directory holds the help files relating to the navigation
system. It is possible that this will change from one release to another.
Here, changing or adding new help categories is done through the file that
defines the navigation buttons and assocaited actions.
See nav.buttons in the windows directory for this facility/release.
Here, the button displayed is called "Help" and a menu is created below it
that offers he
>help       Help                                     NONE               NONE   
>>help      Help..                                   show_help          .navigation_Help
>>about     Navigation..                             show_help          .navigation_Nav 
>>verify    %Check Setup..%                          show_help          .navigation_CheckSetup
>>save      Save..                                   show_help          .navigation_Save 
etc	
Here, the button displayed is called "Help" and a menu is created below it
showing help categories "Help..", "Navigation..", etc. The action show_help
will display the contents of the files   "navigation_Help" etc.

  
All help windows are displayed using the tcl code show_help.tcl. This code
simply displays the contents of the file named in the call to show_help.
The calling of show_help is done automatically by the standard window display
tcl code and called indirectly by the navigation system by use of the
nav.buttons file.
Other facilities will need hard-wired code, as is done in the STASH windows.

Those setting up new facilities using the GHUI system should delete _ONLY_ the
help files relating to set-up windows and other special windows.
The will leave this README, the COPYRIGHT notice and the help-files that are
displayed from the navigation window. These are named navigation_*
You will need to consider the navigation help. Some files will not be needed
if they relate to navigation actions that are not used by your system. Others
may need to be added if you have new navigation actions.

See README in the windows and tcl directories for a description of the
navigation actions process.


