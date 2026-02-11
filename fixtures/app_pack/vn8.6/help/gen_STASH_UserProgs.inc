This window allows users to define how any user-prognostic variables
are to be initialised. User prognostics are registered in the
user-STASHmaster files defined in window "Specification of user
STASHmaster files" in this section.

These files can contain a mixture of Prognostic and Diagnostic
items.

Do not use repeated item numbers in any of the files.

The prognostics (Section zero items with a space code of 2 or 3)
that exists in your listed files are tabulated on this window.

You can change the list of prognostics in the file, but do this when
you are  out of the UMUI to avoid problems with mixing up the
indices of items already  listed.

Make sure that you have the reconfiguration switched on for this
sub-model.

If choosing option 2, make sure that you are using one of the
special unit  numbers for user-ancillary fields:
  This is a special feature to allow users to define new
  "prognostic" fields  and use them as ancillary fields. There are
  special STASH items numbers  reserved for such prognostics:
	301-320 Single-Level Atmospheric items.
	321-324 Multi-Level Atmospheric items.
	331-340 Single-Level Oceanic items
	351-354 Multi-Level Oceanic items.
This file must hold all the items of the type specified that are
required. These should be time-variant and updated. Simple
configuring can be done through  the windows in STASH that allow
specification of fields on files in a more  flexible way. 

Option 7 is a simpler method of doing this for any item number.
However, you cannot update the diagnostic or interpolate it in time.
The file (in ancillary file format) must only contain the field at a
single "time-level".
