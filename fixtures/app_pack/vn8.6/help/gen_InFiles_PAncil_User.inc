
The UM functionality relating to this panel is not yet available. So
please do not use without further advice.

It is the intention that metadata describing available ancillary
fields and files will be kept in record files similar to STASHmaster
record files. The UMUI already maintains such record files but the UM
is not set up to read them. The following help is therefore not yet
relevant.

----

This panel allows records in the standard ancillary record files to be
overwritten by records in user-supplied files.

What is an ancillary record file?
---------------------------------

There are two types of record file relating to ancillary files. One
type stores details about the ancillary files, the other stores
details about the fields within the ancillary files. The master record
files exist within the UMUI in vn?/variables in files called
AncilFiles_A and AncilFields_A for the atmosphere and similar for the
ocean etc.

Each ancillary file can hold more than one ancillary field and each
field must have a single ancillary file relating to it. For example,
the orography ancillary file (file 10) holds five fields describing
orography, orography variance and orography gradient (the gradient
comprises 3 fields). This converts to one record in the AncilFiles_A
record file:

1|   10 |   1 |OROG    |Orography                                |

and five records in the AncilFields_A record file. 

1|    2 |    1 |   33 |Orography                           |
2|   10 |
#===============================================================================
1|    3 |    1 |   34 |Orography Variance                  |
2|   10 |
#===============================================================================
1|    4 |    1 |   35 |Orography Gradient XX               |
2|   10 |
#===============================================================================
1|    5 |    1 |   36 |Orography Gradient XY               |
2|   10 |
#===============================================================================
1|    6 |    1 |   37 |Orography Gradient YY               |
2|   10 |


The records in the AncilFields record file include a pointer to a
particular file (the first item on the second line).

User records
------------

Records can be replaced or additional records can be included by
listing files containing records in the tables of this panel. This
method is similar to that used for user STASHmaster files. 

The files should have the same format as the centrally held
files. Namely:

 - The header items (the lines at the top starting with "H") should be
   identical.

 - The format of each record should be the same as those in the main
   files: the initial character on each line of the record should be
   the same, and the position of the "|" characters should be the
   same.

 - The last record should be the same as the last record in the master
   files to indicate an end-of-file record.

Having supplied new records, additional information will be required
for each record. To supply this, select the "Next" button to go to the
follow on window. On selecting the "Next" button, the contents of the
user files will be read. Warnings will be issued to indicate any
records that replace records in the master file; overwriting records
is allowed. Errors will be issued for incorrectly formatted files. You
probably need to address these errors before continuing to fill in the
follow-on panel.

User files are read or reread when a UMUI job is opened and when the
"Next" button is pressed. If a file is modified it needs to be reread
before the job is processed so revisit this and the follow-on panel
first.
