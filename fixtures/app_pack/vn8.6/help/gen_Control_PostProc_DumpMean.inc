This panel allows the specification of model dumping (and potentially
meaning) for a particular sub-model. It is part of a 2 window
sequence. Gregorian-calendar meaning should only be chosen when not
using the 360-day calendar.

Model dumps contain much of the information required to re-start a
run.

Frequency of dumping depends on the balance between:

1. Costs of writing out dumps more or less frequently.
2. The amount of repetition required should a run fail between dumping
periods or should a section of a run need to be repeated.

To choose a dumping interval consider
1. the frequency of events that cause a model to stop on your system.
2. the amount of disk-space available (if you are not deleting superseded
   re-start dumps).
3. the archive requirements of the job.
4. the climate meaning sequence required (if any).

At UM version 4.0 and above, you do not normally need to worry about
restartability when choosing the archive interval for restart dumps.
The last safe restart dump is kept on-line for you automatically and
the risk of losing data on disks is small.

Dumping Frequency
-----------------

1. Short runs (low CPU cost) often do not need to dump at all if there
are no climate mean requirements.

2. Periodic dumping is normal on longer period runs to reduce the
amount of rerunning in case there is a computer crash or model
failure.

Periodic dumping is also required if the climate mean system is to be
used.

The climate meaning system allows long period means to be calculated,
such as monthly, seasonal, annual and decadal means. Theoretically,
STASH is capable of calculating such means, but limits in numerical
precision of the computer reduces the accuracy of STASH meaning; when
there are too many samples (eg. if you were to sample a quantity every
timestep for a decade), then there is an increased loss of precision
as the accumulated sum becomes much greater than the samples towards
the end of the period. The climate mean works by calculating, for
example, monthly means, then calculating seasonal means from three
monthly means and annual means from four seasonal means and so on. See
the Basic User Guide for a more complete discussion of climate
meaning.

Climate mean intervals need to be input in units of dump
period. Therefore:

 - so if the dumping period is changed, the settings in the follow-on panel
   should be reviewed.

 - The basic dumping frequency should divide into the first climate
   mean interval exactly. 

3. Irregular dumping is used operationally because delays in the early
part of the run are more serious that those later on.
   
3. Gregorian-calendar climate means require a dumping frequency that is
no less frequent than once per day.

Archiving Restart Dumps
-----------------------

Restart dumps can be archived to cater for the need to rerun a part of
the run at a later date if there is a loss of data or if further date
needs to be calculated from a run. 

In normal circumstances those doing climate integrations should
archive restart dumps at a frequency equivalent to 1-day's (wall
clock) integration or longer. Gregorian-calendar meaning restricts the
archiving interval to 1, 3 or 12 months of model time, starting at the
same period after the start of the run.

%I dump_pack

Selecting Climate Meaning
-------------------------

The climate meaning system will only work fully for users who have
specified automatic post processing and climate model archiving. These
systems will not be available in most non-Met Office platforms.

The reference date/time is used as a basis time for the meaning
sequence. For example, set the date to 1st December if you just need
to be sure that your seasonal means align on December-January-February
(DJF), March-April-May (MAM) etc. If you started the run in, say,
January, then calculation of seasonal means will not start till the
beginning of March and the annual mean will not start till next
December.

Set to all zeroes to use the start date/time. "True date" settings
allow comparison between runs starting at different times and are
recommended. When using Gregorian-calendar meaning, the day must be 1
and the hour must be 0.

Zonal mean printouts only work for the atmospheric model as other
models do not include suitable code sections.

%I gen_Arch

 

