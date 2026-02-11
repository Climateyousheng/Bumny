--------------------------------------------------------------------

A note on dump packing

The packing option allows you to specify if primary (prognostic and
ancillary) fields get packed to 32-bits or not. 

Dumps are comprised of two parts. The prognostic fields and  diagnostic
storage areas. The latter being used for holding partial result fields
(often partial-sums) for STASH time processed data.

Using packed dumps can significantly improve the performance of a model.
IO time implies wasted CPU resources. Hence packing often improves the
both speed of a run and the total throughput of the machine.

Separately, for both prognostics and diagnostics, the user can choose to
have the data unpacked, or packed if so indicated by the STASHmaster
file. Most fields are marked as packable.

It is possible to override the packing settings in the STASHmaster file
by use of a user-STASHmaster file. Typically, this would be to change a
setting to force a field to remain unpacked to gain extra precision or
number range.

The down side of using packed fields:

  Packed prognostics can cause problems with restarting in
  a bit comparable way when you are force to restart with an NRUN.
  This is because ancillary fields do not get packed until the
  first dump is written and the sequence is different in NRUNS
  and CRUNS.

  Packed data is less accurate and has a smaller range of values.
  Prognostic fields should be marked through the STASHmaster file
  if they are unsuitable for packing. However, diagnostic fields
  will depend on the time processing in use and so the standard
  marking may be inappropriate.

  Given that most people will be viewing data on workstations with
  32-bit IEEE numbers, this should not be a big problem, but
  remember that if you do means over long periods  (particularly
  STASH means rather than climate means where intermediate means
  are used), the partial-sums will require more accuracy and
  range than the final result. However, long period STASH meaning
  should be avoided as it is ill-conditioned.

However, the savings to be gained may be considerable.

-----------------------------------------------------------------------------
