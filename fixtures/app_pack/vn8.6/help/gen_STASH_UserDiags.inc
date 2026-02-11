This "specification of user-STASHmaster files" window allows users to 
define a list of files that hold user STASHmaster records for this 
internal model. This is to allow:
        1. New diagnostics to be obtained.
        2. New prognostics to be included.
        3. New ancillary fields to be included.
        4. Existing STASHmaster records to be corrected or modified.

The files should exist on your local network and you must have read
permission for them.

There can be any number of user STASH files. The entries do not need
to be in order. Take care not to have multiple identical entries, as
they are not allowed.

Give full pathnames and do not use environment variables - but you can
use <~>. You are advised to use ~ followed by your user-id rather than
than just ~ as others may wish to look at your job.

If the files belong to someone else, it is often advisable to take
your own copies.

If files are to be shared, it may be advisable to have them put into
a special directory and to ensure that all users are informed of any
changes.

Changes made to the contents of the files after jobs are processed
will be ignored. Do not edit the contents when you are in the UMUI.

Unless correcting existing STASHmaster records, you should ensure that
all files contain unique records for the correct sub-model.

Considerable care must be used when constructing the files as small
format differences can cause serious problems. These problems will
sometimes be picked up when closing this panel and sometimes when
entering the main STASH panel after the user STASH files have been
loaded into memory. See the end of this section for details of some of
these checks.

Each file may relate to a modification set which makes the necessary
control changes to the UM code to interface the diagnostic to
STASH. Some corrections to existing STASHmaster records will not
require modification sets.

If any file contains user prognostics, you MUST specify initialisation
choices in the "Initialisation of User Prognostics" window that
follows this one.

Refer to the Basic Users Guide on STASH, and ancillary files as well
as UMDP C4.


The format of the file is similar to the following. It would be best
to start from a template taken directly from the main STASHmaster file
as this help file may not be correctly updated at each version change.

<snip>
H1| SUBMODEL_NUMBER=1
H2| SUBMODEL_NAME=ATMOS
#
#|Model |Sectn | Item |Name                                |
#|Space |Point | Time | Grid |LevelT|LevelF|LevelL|PseudT|PseudF|PseudL|LevCom|
#| Option Codes         | Version Mask         | Halo |
#|DataT |DumpP | PC1  PC2  PC3  PC4  PC5  PC6  PC7  PC8  PC9  PCA |
#|Rotate| PPFC | USER | LBVC | BLEV | TLEV |RBLEVV| CFLL | CFFF |
#
#=============================================================================
#
1|    1 |   16 |  245 |USER DIAGNOSTIC XXXX                |
2|    0 |    0 |    1 |    1 |    3 |   10 |   11 |    0 |    0 |    0 |   1 |
3| 00000000000000000028 | 00000000000000000001 |
4|    1 |    2 | -99  -99  -99  -99  -99  -99  -99  -99  -99  -99 |
5|    0 |  528 |    0 |    8 |    0 |    0 |    0 |    0 |    0 |
#
1|    1 |   16 |  246 |USER DIAGNOSTIC YYYY                |
2|    0 |    0 |    1 |    1 |    3 |   10 |   11 |    0 |    0 |    0 |   1 |
3| 00000000000000000029 | 00000000000000000001 |    1 |
4|    1 |    2 | -99  -99  -99  -99  -99  -99  -99  -99  -99  -99 |
5|    0 |  529 |    0 |    8 |    0 |    0 |    0 |    0 |    0 |
#
#=============================================================================
#
1|    1 |   18 |    1 |USER DIAGNOSTIC ZZZZ                |
2|    7 |    1 |    1 |    1 |    5 |   -1 |   -1 |    0 |    0 |    0 |   0 |
3| 00000000000000000000 | 00000000000000000001 |    1 |
4|    1 |    2 |  -3   -3   -3   -3   -3  -99  -99  -99  -99  -99 |
5|    0 |    8 |    0 |  129 |    0 |    0 |    0 | 9999 |   12 |
#
#=============================================================================
#
1|   -1 |   -1 |   -1 |END OF FILE MARK                    |
2|    0 |    0 |    0 |    0 |    0 |    0 |    0 |    0 |    0 |    0 |   0 |
3| 00000000000000000000 | 00000000000000000000 |    0 |
4|    0 |    0 | -99  -99  -99  -99  -30  -99  -99  -99  -99  -99 |
5|    0 |    0 |    0 |    0 |    0 |    0 |    0 |    0 |    0 |
#
</snip>

The header section (H1,H2) is optional in user STASHmaster files and
defines the internal model.  In this example, there is an optional
format record that can be used to help recognise the elements in a
real record.  This, and any other line starting with a "#" is ignored
in the UMUI and the UM.

Note:
1. The end of file record.
2. That most integers do NOT have leading zeros. The option code and
version mask are strings of single integers and DO need the leading
zeros.
3. The exact spacing of the elements is important.

Copy a template record from the UMUI directories on your system
 eg ~umui/umui2.0/vn5.2/variables/STASHmaster_A

 or $UMDIR/vn5.2/ctldata/STASHmaster/STASHmaster_A
             
The number following "vn" depends on the UM/UMUI version and model in
use. The final letter of the file name indicates the relevant
submodel.

Ask your local UMUI team where the basic UMUI directories are on
your system.               

One of the weaknesses of the STASH system is that it works from codes
that need to be interpreted both by the UM and the UMUI. This all
works fine until you want to add a new diagnostic that requires a new
code because it is on a new grid, or because its level range is new
etc.

It is possible for the user, by modification, to put code in the UM to
deal with new codes. However, there is no way of modifying the UMUI.

The most likely problems that a user is likely to encounter are with
levels and pseudo levels, where ranges are checked in the UMUI and
used for addressing in the UM.

The UMUI now allows new codes to be defined along with their
decoded values for the job in question. You will need to include
modifications to the UM at this release to use this facility.

Defined are new first/last level codes for users:
(LevelF or LevelL)
101, 102, 103 for the atmos model.
201, 202, 203 for the ocean.
etc.

Also new PseudT as well as PseudF and PseudL
101, 102, 103 for the atmos model.
201, 202, 203 for the ocean.
etc.

The user can define values that relate to the following codes:
  Level codes (LevelF or LevelL),   PseudF  or PseudL
You do this on  window atmos(etc) --> STASH --> Spec of user-STASHmaster files.

Set to 0 if not used, as zero would not make sense as a return for any
such field.

You can only specify a fixed number and not relate them to any other
UMUI question. So if the number is (Number of atmos levels +3) then you
would need to put 19+3=22 and remember to change it when the number of
levels changes. This is only for testing between releases!

You can now ask for new pseudo-level types in the STASH domain window
101, 102, 103 for the atmos etc.
These must agree with the types in the user-STASHmaster file.

A new type may be tiles for example.

When verifying the diagnostics, the levels and pseudo levels in the list
are checked to be in the bounds of the settings relating to the new codes
as set in the window.

On processing, the UMUI writes information like:

 USER_LEVEL_CODES(1,1)=0,12,0,  
 USER_PSEUDO_FIRST_CODES(1,1)=0,0,0, 
 USER_PSEUDO_LAST_CODES(1,1)=15,0,0, 

In the STSHCOMP NAMELIST in SIZES etc.

As the user will need mods. This info is only written for the
sub-models for which the user has asked to be able to extend the codes.
See the window.

The arrays are dimensioned (3,Number of sub models).
Three is the number of codes allowed for each sub-model 
  atmos:  101, 102, 103 etc.
So in the example above, the user wants to use a LevelB or LevelT code
of 102 and this should generate 12 as a response. This could be the 
number of levels in a locust model, for example.
They have also asked to use a PseudL code of 101 that returns the
value of 15. It may be the 15 different types of locust that they are 
modelling.
They may have also used a PseudT of 103 (or 101 or 102) to define
that the dimension is locust-types. This would be defined through the
pre-STASHmaster file.

Nothing would be written for any sub-model that the user has said they
do not want to extend the level/pseudo-level codes for at all.

Because of this, I think that the arrays (USER_LEVEL_CODES etc) should
be initialised to 0, to indicate unset. This is in line with the window,
where 0 means the user is not using the code. 

Also the modified code should check that a return of zero in the UM
generates an error as it means that the UM is trying to use an unset
code.

This system is only for testing new diagnostics requiring new codes.
When introduced properly, non-users codes need to be assigned and 
questions added to the UMUI and passed to the UM as with other
such parameters.

Errors and Warnings
-------------------

On closing the user STASH panel, basic checks are made on the contents of
user STASHmaster files. The more confusing ones are detailed here.

