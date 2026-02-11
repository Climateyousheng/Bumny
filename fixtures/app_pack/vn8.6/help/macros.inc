--------------------------------------------------------------------------------
The STASHmacro is an internal list of STASH requests that are activated with a
minimum number of settings.

The product can be any STASH diagnostics except user diagnostics. The definition
of the diagnostics in the macro are set by those responsible for the
interaction. The macros are defined by control files to the User Interface.

In some cases there are two versions of macros available:
	1. The standard MACRO. This cannot be changed mid-release. 
	2. The development MACRO. This can change and is used to either: 
		a. test a new version of the MACRO    or 
		b. allow changes to operational MACROs mid release. 

Development MACROs can be changed by the UI team at a user's request. However,
this is not encouraged as it is always possible for users to define their own
requirements by use of the standard STASH windows.

Users should only use those MACROs that are required to avoid unnecessary
calculations and output.
