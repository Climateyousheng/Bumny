Using timeseries to investigate model behaviour.
-------------------------------------------------

UM timeseries can provide a useful means of looking at the behaviour
of the model at selected locations. This is best done by selecting a
small number of grid points of interest (eg because the behaviour of
the model with two different physics parametrisations changes at these
locations).  The next step is to decide which output fields are of
interest.  In this type of investigation it is usually useful to get
out timeseries with a time profile of every timestep. Fields of
interest would often include top of atmosphere radiation, surface
radiation, surface latent heat, surface sensible heat, precipitation,
surface temperature & or 1.5m temperature, boundary layer depth. In
many studies it will also be useful to get out T, q, qcl, qcf, layer
cloud, convective cloud on all model levels for the selected grid
points. These fields can then be plotted as model level versus time
sections and will show what is happening in the model.  U & V can also
be output but because of the grid on which u and v are held ie offset
by 1/2 grid length from T, q grid they will not be at the same
locations.

In most studies of this type a short run of 1-3 months outputting
timeseries is usually enough. Note that including timeseries increases
the memory requirements of the run. If a lot of points and fields are
requested every timestep the memory required will quickly exceed that
required in normal climate runs. It may be necessary to reinitialise
the timeseries on periods of less than 30 days.

Setting up timeseries requests
------------------------------

STASH time series are defined by both domain and time profiles.

The facility allows you to specify a number of "boxes", these get collapsed 
down to point values by meaning (using any weighting defined in the domain 
profile).

This list of point values is written to an area of memory at intervals defined
by the sampling frequency in the time profile.

The time profile also defines an over-writing period to stop the list becoming
too long. It is normal to output the result at the same frequency as the
over-writing period.

eg.
days                            0           1           2           3   
timesteps                       .............................................
sampling freq 12hrs                   |     |     |     |     |     |
over-writing freq 24hrs                     x           x           x       
output freq 24hrs                           +           +           +

would result in a "PP-fields" each with 2 time levels and as many points as 
are defined in the domain profile. The "fields" would be produced each day.
If 3 "points" were defined, the file would contain "fields" vis:

Field 1.  VAL(point=1,time=12), VAL(point=2,time=12), VAL(point=3,time=12), 
          VAL(point=1,time=24), VAL(point=2,time=24), VAL(point=3,time=24)  
Field 2.  VAL(point=1,time=36), VAL(point=2,time=36), VAL(point=3,time=36), 
          VAL(point=1,time=48), VAL(point=2,time=48), VAL(point=3,time=48) 
etc.       


This panel allows two methods of specifying boxes. In the first
method, a box is specified by giving the range of points it contains
in both horizontal directions and the number of levels it
contains. Thus, each line of the table describes a single box.

The second method is used for specifying boxes of a single grid point
on one level. In this method, a range of levels indicates one box for
each level. This method is quicker to set up when you want to look at
the same point separately on a number of levels.

To compare the methods, if you wanted to look at point 3,5 on levels 4,5 and
6 then in the first method you would have 3 rows:

3  3  5  5  4
3  3  5  5  5
3  3  5  5  6

whereas in the second method you would require one row:

3  5  4  6

When specifying boxes of more than one gridpoint it may be that some
of the dimensions of the boxes may be collapsed out by other
attributes of the domain profile. For example, doing a vertical mean
on the previous window will mean that a timeseries on more than one
level is not relevant. In such cases, the unused columns in the table
are disabled.

Only the atmospheric model allows true boxes at present. Other models can
only deal with points, so specify the "first" and "last" dimensions as 
the same, or use the second method of specifying timeseries.

It is normal to specify the full horizontal domain in the HORIZONTAL window of
a time series profile. Spatial averaging is not normally required.

All dimensions must lie within the box defined by the rest of the profile.

Special PP-package programs are required to access time-series. 
