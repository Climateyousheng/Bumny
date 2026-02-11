This window allows you to specify the attributes of a chosen domain
profile. This is one in a sequence of windows. You should look at
the whole sequence.

Use this window to define the diagnostic requirements in term of the
vertical grid. In the wave model, the "vertical" dimension is used
to express direction binned into discrete bins of dimension (as
defined in  spectral domain definition)

Each STASH item is on a defined "vertical" grid. The definition is set
in the STASHmaster file. You can choose to look at a sub-set of the
vertical domain of the diagnostic. You must use domain profile that
agrees in vertical domain type with that of the diagnostic.
Verification will stop you doing otherwise.

For items on integer levels (such as model full levels),
specification of a range larger than the domain of the diagnostic
will be adjusted to the range of the diagnostic without
notification.


Because the system checks that the level values that you have specified
are within the ranges implied by the codes in the STASHmaster file, some
account is taken of the requirement to use new limits.

The system relates to special user settings in the user-STASHmaster files
and the help for that window is repeated here:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%I gen_STASH_UserDiags
