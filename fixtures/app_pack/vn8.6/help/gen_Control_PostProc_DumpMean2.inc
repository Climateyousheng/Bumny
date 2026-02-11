This panel allows the specification of model climate meaning.  It is
the second part of a two-window sequence.

See the help for the previous panel before reading this.

The panel will display the information required by the climate meaning
system if it were chosen on the preceding panel. 

For those using a climate meaning sequence:
  The climate mean period lengths are best explained with an example.
1.  For 360-day calendar

a)  Dumping every day,
    If climate means at 10,30 and 90 days are required:
    Set number of climate mean periods to 3, and the period length 
    to be 10,3 and 3 (10x1day, 3x10days and 3x30days).

b)  Dumping every 10 days,
    If climate means at 30 and 90 days, and also annual and decadal 
    required:
    Set number of climate mean periods to 4, and the period length 
    to be 3,3,4,10 (3x10 days, 3x30 days and 4x90 days and 10x360 days).

Also note that diagnostic requests may need to be altered if the
dumping frequency is changed. Climate meaning a STASH daily mean only
makes sense with daily dumping; with 10-day dumping the first 9 daily
means in each dumping period would be ignored. Therefore it is advised
that meaning periods in STASH are specified in terms of dump periods.

Up to four meaning periods can be selected. Note that all individual
STASH requests use the same four periods to calculate means. However,
selection in the STASH request's usage profile can allow a diagnostic
to be output only on some of the climate mean periods. For example,
you might require monthly, seasonal and annual means of some
diagnostics but only annual means of other diagnostics. See the help
for the Usage profile panel in STASH.

2.  For Gregorian-calendar climate means, the only periods available are
    months, seasons and years. It is not compulsory to choose all 3 periods.

Putting N into the "PP Files Required" column only prevents them from
being archived. It does not prevent them from being generated.

For those defining irregular dumping times: Specify a time unit, the
number of times required and a list of times. Press the "SORT TABLE"
button to ensure the data is in order before exiting.

%I gen_Arch


