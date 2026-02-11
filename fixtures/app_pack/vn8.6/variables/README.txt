UMUI and GHUI documentation.

README for the Variables Directory.
10 January 1996. 
Mick Carter.


The variables directory contains three main types of files.

Variable Registers:
  Variable registers (something.register). These files define GHUI data-base
  elements or variables. They are not variables in the Tcl sense and are
  read in from one of several places:
  	The data-base relating to a loaded job.
  	The parameter file for this version of this application.
  	The system file for this version of this application.
  The variable registers define the name of all such variables and other
  information, such as:
   	Variable type.
   	Format, if real.
   	Width if character.
   	Home window.
   	Checking rules.
  The format of the files is documented in README_Registers and each is
  documented by comments in its header.

Standard Variable Files:  
  Standard Variable files (something.database). These hold data-base items that 
  can be access by GHUI-variable access techniques. There are two types of
  file:
  	1. parameter.database 	This holds variables that are used to define
  	array lengths, table lengths and associated processing loops. Elements 
  	must be scalar. The "variables" are loaded first when a job is entered. 
  	Rules are defined in the header of the file. These are similar to
  	fortran parameters when used to dimension arrays.
    	2. system.database 	This holds variables that are common to all
    	jobs in a application-version. For example, they hold:
    		1. Application constants that define "out" variables in tables,
    		such as the available observation types (see windows).
    		2. "Constants" used in cross checking functions, such as the
    		ancillary fields that live in one ancillary file.
    		3. "Constants" that appear in more than one place.
    	These are similar to fortran parameters or data-statements.
    	
Non-Standard Variable Files:
  These are files containing information used by windows that are driven
  outside the GHUI system. They should only be used when system databases are
  inappropriate or difficult to maintain. The values need to be loaded by
  application specific sftware.
  The stash.master file is one such file. It holds a large amount of
  information in the form or records, each record relating to a diagnostic. It
  would be very difficult to maintain this information in GHUI database
  format, and relates to a non-standard application window in any case. The
  loading of the data is done as part of the entry to the non-standard
  application window.  
  	 	
Additionally, the variables directory contains a partition.database. Each
variable in each of the variable registers is assigned a partition identity. 
The first character of this partition id is the most significant since 
information in the partition.database is used to determine which partitions
in a users jobs are in use. See the header of this file for further 
information.





