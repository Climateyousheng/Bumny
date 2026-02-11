AMIP II SST and ice updating
=============================
Setting the updating of SST and ice to use the AMIP II method
implies that your ice ancillary file contains only ice concentrations.
The ice depths are worked out from the ice concentration by the ancillary
updating subroutine. You should still ask for updating of ice depth.
This method does not allow the ice concentration
seen by the model to fall below 0.3. This limit is applied because in the
present version of the model if any ice is present however small the value
of the SST seen by the physics (boundary layer and radiation) is -1.8C
irrespective of the value of the SST coming from the ancillary file.

This method is designed to be used with the specially prepared SST and ice
boundary data supplied by PCMDI. This data is valid for a real calendar
year and when using daily updating it will reproduce correctly
monthly mean SST and ice.

If a different updating period is used the monthly means will not be
correctly reproduced.

Note the normal style SST and ice ancillary files contain correct monthly
means but once the model takes the data and interpolates, the resulting
monthly means output by the model do not agree with the original values.

