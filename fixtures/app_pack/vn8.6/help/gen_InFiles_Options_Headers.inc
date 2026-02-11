This window allows users to specify values used in dynamic
allocation of space to hold headers for ancillary files and lateral
boundary tendency files.

The values can be an over-specification.

The numbers required depend on the number of fields in all files of
each type.

Ancillary files
This depends on the number of field types, number of levels and the
time dimension of all ancillary files used in the model (not the
reconfiguration. i.e. updated not configured).

Lateral Boundary Tendency files.
The number needs to be at least as large as the length of the time
dimension in the file (if it is being used). That is LBTs into, not
out of the run.

See also the basic user guide on ancillary files.

