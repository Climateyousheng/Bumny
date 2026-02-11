Sub-model independent Sections.
see below for a description of sections.

This window allows the user to specify which version of various
sections, independent of sub-model, are required.
 
Most sections are always required and the windows contain infomation
about suitability for your platform. See in here for information on those
sections that can be set to "0A, not used".
See the window for advice on standard settings.

This help window covers all the windows in this sequence.

-----------------------

Section 95: This section allows the choice of IO routines which were 
created to aid porting of the UM. The 2A version is the stable version 
of the IO routines which have been tested on many platforms. The 2B 
version is a developmental version to try and increase functionality 
and improve coding structure but may have some issues on untested 
platforms. C95_2B requires some of the C99 standard and can use some 
Fortran 2003. 

Section 96:
This section allows a choice of the underlying MPP communications
methods used by the UM - you will almost always need one of these.
The current code is optimised for machines that use MPI as their primary
communications. This option is appropriate for most current HPC
machines. The GCOM collectives limit specifies the upper limit for when
GCOM all-to-all routines are used for collective gather/scatters. Beyond
this value MPI gathers and scatters are used. The optimal value of this
limit may value by both machine architecture and job configuration.

There is a choice of methods for summing distributed arrays held 
across multiple processors. The Old Reproducible method gives the 
same answers irrespective of processor decomposition. It does not 
scale well however. The Double-Double Precision Reproducible method
 also gives the same answers irrespective of processor 
decomposition but scales much better. The Fast Non-Reproducible 
method can give different results when run on different processor 
configurations. None of the methods will reproduce with each other 
as they perform summations in different orders.

Section 97:
This section contains different versions of a routine giving information about
time spent in various parts of the code during a model run.
Version 1A is the standard UM timer, but cannot be used on MPP machines.
Version 3A is an upgraded version of the standard timer. It can be used all
types of machines, and will give useful timing information on MPP machines.
It is computationally more expensive than version 1A. As well as giving timing
information for individual routines (as version 1A does), version 3A also
gives timing information for larger model components - for example the total
time spent in the dynamics or physics.

Section 98:
This section contains routines and functions that REQUIRE OpenMP libraries 
to run successfully (code containing only optional !$OMP directives, e.g. 
!$OMP DO, do not need OpenMP libraries as such statements will be ignored 
by a standard Fortran compiler). Version 1A includes any code that requires 
OpenMP to run and must be selected when compiling code with OpenMP. 
Version 0A ignores such code and must be used when compiling without OpenMP. 
Section 98 is set automatically when selecting/de-selecting OpenMP elsewhere 
in the UMUI and should not be adjusted manually. Doing so may cause compile 
failures.

%I timer

Section 72:
You MUST only use the coupling section (72) if you are coupling.
Otherwise you job will fail, either trying to find an unmade object
library if BUILDSECT is false, or because you have empty .f files
if BUILDSECT is true.


-----------------------
%I compile_modes
