This window allows you to specify the attributes of a chosen domain
profile. This is one in a sequence of windows. You should look at
the whole sequence.

Use this window to define the diagnostic requirements in term of the
horizontal grid. Each STASH item is on a defined particular
horizontal grid. The definition is set in the STASHmaster file.
 
Most domain profiles will ask for the diagnostic on the whole grid.
This will work for any diagnostic. Sub-areas are possible and can be
specified in various ways. If this is a limited area models and area
is to be  specified by latitude/longitudes, do this in terms of the
true polar grid, not the rotated  grid.

When specifying a sub area by latitude/longitude remember that all
limits must be specified unambiguously from the meridian/equator.
For example, a Western limit of 30deg West must be specified as 330
or -30. Similarly a Southern limit of 20deg South must be specified
as -20.

When using this option, the actual area provided is the smallest
gridpoint rectangle area covering the specified limits. This can be
quite a different shape for limited area models. It is also possible
that the requested area lies outside the domain for a limted area. In
this case, the intersection of the limited area grid and your request is
covered.

Diagnostics may be masked using the land-sea mask. For example,
specifying "Sea gridpoints only" will cause land points to be set to
missing data values. These values will not be used in subsequent
horizontal meaning calculations within STASH (such as zonal meaning).

For the Ocean model:
If the land-sea mask is applied to 3-dimensional fields, then
the mask used will be that from the top vertical ocean level.
This means that the mask will not necessarily reflect the true
orography at lower levels. Consequently, land-sea masking is not
generally recommended for use with 3-d diagnostic fields.

Specification of spatial averaging will reduce the number of output
dimensions of the diagnostic. This can be done in conjunction with a
weighting option.

If using a Time-Series domain profile, it is normal to ask for the
full horizontal domain in this window. The following window will
allow you to specify sub-domains in all 3 standard dimensions (if it
is not single level). However, you can use the spatial averaging
options with time series. For example, you could ask for weighted
vertical averaging and the following window will ask for
specification on the horizontal limits of sub-domain as the choice
in this window would have collapsed the vertical domain. This would
be done if you wanted the vertical domains of all your time-series
to be the same and averaged over all specified levels.
