This window allows you to specify the attributes of a chosen domain
profile.
This is one in a sequence of windows. You should look at the whole
sequence.

Use this window to define the diagnostic requirements in term of the
pseudo-levels. Each STASH item is defined as being:
1. Not having a pseudo-level dimension.
2. Having one of the listed pseudo-level dimensions.
This is another (variable use) dimension that a diagnostic can have
(akin to the levels dimension). E.G. some radiation diagnostics are
available on each model level and each LW radiation band.
Most diagnostics do not have a pseudo-level dimension.


The definition of type is set in the STASHmaster file. You can choose to
look at a sub-set of the domain in this dimension. You must use domain
profile that agree in pseudo-level type with that of the diagnostic.
Verification will stop you doing otherwise.

Because the system checks that the type that you have specified agrees
with the type in the STASHmaster file, some account is taken of the 
requirement to use new pseudo-level types.

The system relates to special user settings in the user-STASHmaster files
and the help for that window is repeated here:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%I gen_STASH_UserDiags
