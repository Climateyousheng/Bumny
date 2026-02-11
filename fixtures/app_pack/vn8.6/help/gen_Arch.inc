________________________________________________________________________________
A note on automatic archiving:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Automatic archiving of the various file types can only be requested
if the master switches are set to include an automatic archiving
system.
You need both automatic post processing and an archiving system selected.

The archiving options associated with particular files ensure that
the model sends archive requests down the "pipe" to the archive
server at appropriate times. These options are on various windows in
the UMUI, eg:
   Atmos --> Control --> Post Proc --> Dumping and Meaning
   Post Processing --> Init & proc of mean & standard PP.
Here you specify exactly what you want archiving for dumps, PP-files etc.

However it is possible that, through the script release system, you
have provided your own "local" archiving system for files. Such a
system is unlikely to use the messages coming down the pipe. Hence,
as far as the questions on the windows associated with archiving a
file type are concerned, no archiving is required. In the main window
containing the master switches, you would need automatic post processing 
to ensure that your scripts are released. However, you do not need to 
choose an archiving system.
________________________________________________________________________________
