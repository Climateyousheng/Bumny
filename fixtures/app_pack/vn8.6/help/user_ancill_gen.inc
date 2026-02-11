
Most users will not need user-ancillaries. It would only be required
when developing new science that requires a new ancillary file with
periodic updating. Once developed the ancillary files should be made
"permanent".

This is a special feature to allow users to define new "prognostic" fields
and use them as updatable-ancillary fields. There are special STASH items
numbers reserved for such prognostics divided into the following types:
  301-320 Single-Level Atmospheric items.
  321-324 Multi-Level Atmospheric items.
  331-340 Single-Level Oceanic items
  351-354 Multi-Level Oceanic items.
These map onto Ancillary Reference Numbers:
  301-320 48-67
  321-324 68-71
  331-340 24-33
  351-354 34-37
  
Note that single-level atmospheric items are assumed to be ON LAND
POINTS ONLY in the ATMOSPHERIC model. If this is not the case, a
modification is required near the end of REPLANCA.

One ancillary file must hold all the items required for a particular
type in the list above. These should be time-variant and updated.

A new STASHmaster record is also required, to be added by including a
user-STASHmaster file. Set the appropriate initialisation code in the
STASH user prognostic initialisation window.

This system is not for use when you are trying to "configure" a new
primary field. Simple configuring can be done through the windows in
STASH that allow specification of fields on files in a more flexible
way. For example, you can have different fields in different files and
are not restricted to these special item numbers.

Between the user-prognostic and user-ancillary system, most things are
possible.
Limitations are:

  If you are updating, you must put all the files of one type into
  one file and use the same updating intervals for all fields.

  There is no easy way of "configuring" from a climatology by
  temporal interpolation.
