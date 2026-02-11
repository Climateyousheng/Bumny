This window allows you to set the attributes for a given time profile. 

This Help Panel covers:
 - The basic components of the panel
 - An example setup
 - Differences relating to diagnostics that may not available every
   timestep such as some radiation and convection diagnostics
 - How to set up Climate Means to calculate monthly, seasonal,
   annual etc means.

Remember that time profiles also interact with usage profiles  (for
things like climate means) and domain profiles (for time series). 
When doing these things, read all the help windows fully to ensure 
you have a consistent set.

Time profiles have three sets of parameters:

1. The type of time processing, if any, that is required.

2. If time processing is selected, the period over which to process
data, and the sampling period.

3. The output times for data.

The first question in the panel defines time processing choices. 

Single time fields:
	Are snap-shots of a field output at the timesteps implied by the second 
	part of the window, i.e. no time processing.
Accumulations and Means:
        Need to be accumulated over an interval, known as the period.
        Values that make up the mean/accumulation do not need to be taken from 
        each timestep but most often are, in which case set the sampling
        frequency to 1 timestep.
Time series:
        Are best used in conjunction with time series domain profiles. A series 
        of data points is appended at the frequency specified into STASH 
        reserved space in dump. The data in dump is overwritten every 
        re-cycling period. see below:
Special day-mean time series:
        Are best used in conjunction with time series domain profiles. A series 
        of data points is appended at the frequency specified into STASH 
        reserved space in dump. The data in dump is overwritten every 
        re-cycling period. The data is based on daily sampling of timestep 
        means over the day. Hence, sampling period must be 1 day and 
        sampling offset must be zero.
Maximum/minimum:
        Settings should be similar to accumulations. The period defines the
        period over which the extremum is calculated and the sampling frequency
        defines the timesteps at which the checks of current values against
        current extrema are made (most often 1 timestep). 
        
If one of the time processing options is selected, an area in the dump
is used to hold a working copy of the diagnostic. 

The sampling frequency and period mentioned in the above description
are input into the second part of the panel. In STASH document
parlance these numbers are the FREQUENCY and PERIOD. An offset may
also be specified if the sampling frequency is greater than 1 unit.

The final part of the window defines the output times for the
diagnostic. The diagnostic is copied to output at the times specified.
Single Time Fields are simply copied directly from input to STASH.
Accumulations, Means and Time Series are copied from the time
processing area in the dump.

Some more detailed description and examples follow:

The first timestep used for the processing of a time processed
diagnostic is:
     (FIRST OUTPUT TIME)-(PERIOD)+(OFFSET) + (1 TIMESTEP)
I.E. this is the first timestep at which the field is added into the
     partial accumulation (or appended to the record) in dump store.
This formula is used because many key radiation diagnostics are 
only available on radiation timesteps. Timestep 1 is a radiation
timestep (hence +1 timestep).


A complex example would be:
Suppose we are running with a 20 min timestep, and have:

 Sampling frequency: 1 hour
 Period:             3 hours
 Sampling offset     0 hours

 Output times: regular intervals - starting:  5 hours
                                   ending:    -1 (for ever)
                                   frequency: every 6 hours

This would imply that the first mean (from T+2hrs to T+5hrs) is
calculated by averaging the fields taken at the following timesteps:

HOUR:      0        1        2        3        4        5
TIMESTEP:  0  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15
                                ^        ^        ^   
USE THIS:                       |        |        | 

Sampling offsets were a new feature at vn4.4. Previously, the first
sampling period always had to be timestep 1 regardless of sampling
frequency. Now, if sampling frequency is 2 or more timesteps, an
offset can be specified. This feature is used in some ocean runs that
use "dual-timestep" diagnostics; two copies of each diagnostic are
maintained, both with a sampling frequency of 2 timesteps. One copy of
the diagnostic has a 0 offset and is processed on odd timesteps.  The
other has an offset of one and hence is processed on even timesteps

Time profiles and fields not available every timestep
-----------------------------------------------------

Some fields are not available every timestep. For example, this
applies to some diagnostics in the radiation and convection section.
Such diagnostics are indicated by a particular time code in the
STASHmaster file. The model makes some effort to modify requests to
ensure that the time profile is appropriately set up for such
diagnostics. eg. for a radiation diagnostic the following occurs,
though the system is much the same for other similar diagnostics:

When requesting sampling of a radiation diagnostic every timestep
(such as when doing a time mean) the model will change the sampling
period to match the radiation timestep.

When calculating the first output time, the model will change the time
to an appropriate radiation timestep. eg for a 6-timestep radiation
timestep, an initial output time of timestep 0 to 5 is changed to
timestep 1, timesteps 6-11 to timestep 7 and so on.

NOTE: There is no matching modification of the end timestep. Therefore
if, say, running 1 day + 1 timestep in order to include the first
radiation timestep on the second day, ensure that the end timestep is
equal to or greater than, say 49 when running 48 timesteps per day.

The model will not:

 - modify the sampling frequency of a processed diagnostic if the
frequency is not a radiation timestep unless it is set to 1 timestep.

 - modify the output frequency at all for unprocessed diagnostics
(sometimes called instantaneous fields) even if the output frequency
is one timestep.

Time processing and climate meaning
-----------------------------------

Climate means are means over very long periods; typically months,
years or decades. STASH cannot sensibly do means for such long
periods. Most often, a climate mean is a mean of a time-processed
diagnostic. For example, STASH generates a mean over a whole dumping
period, sampling every timestep and the climate mean is calculated
from the mean of a series of these. 

The climate meaning system is called only at the end of a dump period;
therefore it usually makes sense that the STASH output time matches
the dumping period exactly - a warning will be given if a climate
meaned diagnostic is attached to a time profile that does not match
the dumping period.

Time series:
~~~~~~~~~~~~
STASH time series are defined by both domain and time profiles.

The facility allows you to specify a number of "boxes", these get collapsed down
to point values by meaning (using any weighting defined in the domain profile).

This list of point values is written to an area of memory at intervals defined
by the sampling frequency in the time profile.

The time profile also defines an over-writing period to stop the list becoming
too long. It is normal to output the result at the same frequency as the
over-writing period.

eg.
days                  	 	0           1           2           3   
timesteps			.............................................
sampling freq 12hrs    		      |     |     |     |     |     |
over-writing freq 24hrs		            x           x           x       
output freq 24hrs                           +           +           +

would result in a "PP-fields" each with 2 time levels and as many points as are
defined in the domain profile. The "fields" would be produced each day.
If 3 "points" were defined, the file would contain "fields" vis:

Field 1.  VAL(point=1,time=12), VAL(point=2,time=12), VAL(point=3,time=12), 
          VAL(point=1,time=24), VAL(point=2,time=24), VAL(point=3,time=24)  
Field 2.  VAL(point=1,time=36), VAL(point=2,time=36), VAL(point=3,time=36), 
          VAL(point=1,time=48), VAL(point=2,time=48), VAL(point=3,time=48) 
etc.       



Daily mean timeseries.
-----------------------
Time profiles for daily mean timeseries should be setup as for timeseries
but the sampling period is must be set at 1 day .

eg
  recycling period as usual say 30 days

  sampling frequency   - should be set to 1 Day.

 output times - regular
         starting   30 days
         ending     - 1
         frequency  every 30 days.

Note - the daily mean timeseries are daily means formed from values every
       timestep. The user has no control over this.

In principle the sampling frequency could be set to a different value eg
5 days to get 5 day mean timeseries. Nothing like this has been tested.
This option was added with the aim of providing daily mean timeseries of
global means required for AMIP II runs.
