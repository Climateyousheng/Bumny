ghui2.0/Install directory
-------------------------

It is important to note the distinction between the GHUI and the 
	GHUI-based applications such as the UMUI, VARUI etc. On a given
	system, there can be one GHUI installation that is used by more 
	than one application. Therefore a two stage installation process 
	is required. 

This directory contains the main script and some of the files required
	to install the GHUI. The installation of the GHUI also creates some
	template files that are subsequently used in the installation of
	GHUI-based applications.

	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
		Content of Install direcrory berofe running Configure
	
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	README.txt:This file.

	Configure: Run this script to configure the installation of the 
		GHUI.  This script manufacture Makefiles and other files 
		required for building and installing the GHUI and GHUI-based
    	applications.

	Config.in: A file that contains example answers to the questions 
		asked by the Configure script. 


	Makefile:  The main Configure and Makefile files used to exist in 
		the directory above this one. The Configure file was moved 
		into the Install directory but the Makefile was not. The 
		Makefile in this directory is just a simple Makefile that calls
		the main makefile.

 	template.in, 

	_admintemplate.in, 

	_startservertemplate.in, 

	_haltservertemplate.in

    	GHUI based applications require up to four startup scripts. 
		One starts the administration client; the program that sets 
		up and administers the server, one is needed by users to start
		up the application, and the third is an optional script that 
		automatically starts the server rather than needing to go 
		through the administration client. These scripts are created 
		in a two stage process:

           1. The GHUI Configure script in this directory converts the
           _admintemplate.in and template.in files into _admintemplate
           and template files by inserting, eg, the names of the Tcl/Tk 
           executables - items that are generic to all GHUI based 
           applications.

           2. In the configuration of the GHUI-based application, the
           _admintemplate and template files are converted into - eg.
           in the case of the UMUI - a umui_admin, a umui and a
           umui_autoserver script which are placed in the bin
           directory of the UMUI installation.
		   

	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
		Files created in Install direcrory after running Configure
	
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	 template,
	_admintemplate
	_startservertemplate
	_haltservertemplate 		   
		 As described above, these are used in the installation of 
    	applications that use the GHUI.

	Config.cache:     Contains the answers most recently input into 
		the Configure script. If the configure script is rerun, the 
		answers in Config.cache are offered as default responses, 
		rather than using the answers in Config.in
          
