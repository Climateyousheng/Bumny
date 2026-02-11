~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Primary Items.
~~~~~~~~~~~~~~
A primary item is an item that is required as part of an integration. It
could be a prognostic item, an ancillary item or some other boundary item
(such as lateral boundary tendancies).
They live in D1 and the Dump and are primarily referenced to STASH
in section zero.

It is possible to obtain available primary fields from section 0 (at
the end of a timestep) or after other sections that later their values.

Such items may not be available as diagnostics for one of two reasons:

   They may not be required for the configuration you have chosen
   (as defined by the option code, see UMDP C4)

   They may not be on a suitable grid to be input to STASH as a 
   diagnostic (as defined by the space code in UMDP C4). Some such
   items (eg LBCs) cannot ever be obtained as diagnostics. Others
   (eg fields compressed to land-only points) can be decompressed
   in scientific sections and passed to STASH.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

