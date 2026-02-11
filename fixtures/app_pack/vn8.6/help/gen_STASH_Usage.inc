This window allows users to define the attributes of the usage profile
within the STASH windows.

The useage profile defines the output destination of a diagnostic.

Most often, simple diagnostics are written to one of the user-PPfiles on
units 60-69. 
The user can specify these as files to be reinitialised or recycled
(that is, new files are attached periodically to this output stream to
avoid the files becoming too large). In this case, each stream should be
dedicated to a particular sub-model. Several streams can be attached to
one sub-model.  When the streams are defined as not reinitialised, users
can mix output onto these streams as they please.  See
subindep_PostProc_PPInit.

In addition to the standard PP-files, unit 151 can be used.  However
modifying re-initialisation and post-processing options are not available
for this stream. Function "Verify diagnostics will produce a message 
"ERROR: Bad index when getting element: PPM(91)" which could be ignored. 

Alternatively, diagnostics can be written to the D1 area (and the
external dump by implication). Users may wish to do this so that
diagnostics can be passed from one section of code to another. This
method is used by several of the STASHmacros. To allow the code to find
the particular diagnostic it is also Tagged and search routines can find
the STASHlist record that has such TAGs attached. 
See UM routine FINDPTR.
These are the TAGs used by various code sections:
     10   atmosphere to ocean coupling
     11   ocean to atmosphere coupling
     20   atmosphere to slab coupling
     21   slab to atmosphere coupling
     30   atmospheric assimilation dump extension

If the variable is not required in the dump (that is it is not time
processed or you are certain that all time processing occurs within the
dump intervals) you can similarly write tagged diagnostics to secondary
store. These are not written to the dump as they are in an extended area
of D1.

Alternatively, diagnostics can be written to the D1 area (and the
external dump by implication) and tagged to be picked up by the climate
meaning system. Users should attach this sort of profile to diagnostics
from sections other than the climate mean sections (21-24). Users may
wish to perform time processing (such as daily means sampling values
every timestep) and have these further processed by the climate meaning
system. This is the only way to obtain climate means with values
accurate to the nearest timestep. Such diagnostics need to be written to
the climate mean files for each meaning period. Specify the periods
required, the tagging will be added automatically from this information.


Diagnostics from the  climate mean sections (21-24) are either "mean
prognostic variables" or diagnostics calculated from those variables.
They are the result of the climate mean dumps. The sampling frequency
for such meaning is the basic dumping frequency of the run for a given
sub-model. Such diagnostics are written direct to the climate mean
files.
