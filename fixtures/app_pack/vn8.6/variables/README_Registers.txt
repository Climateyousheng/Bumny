UMUI and GHUI documentation.

README_Registers for the Variables Directory.
Variable Register Files
16th January 1996
Steve Mullerworth              

This file contains a description of the fields required in the variable 
registers. Each line requires at least twelve fields and the last field is
usually followed by some extra information. There is some error checking
to ensure that the correct number of fields are present and that the 
entries in some of the fields, namely columns 6 and 12, are valid.

As mentioned on other pages, these are not variables in the normal sense.
Their values are stored in a database and obtained using the C routines
get_variable_value or get_variable_array. Additionally, these registers 
are read when a job is opened, so within the body of the program 
information about each variable is obtained using the C routine 
get_variable_info rather than by rereading the registers.

Fields are delimited by one or more spaces, so do not use spaces within 
fields and do not use tab characters. The variable registers can be 
commented; start comment lines with a # character in the first column.

Each line has a maximum length of 320 characters, but in addition, some 
fields also have a maximum length.

 Column    Maximum Length
 1         48
 2         160
 8         10
 9         48
 10        48
 11        160
 13        160

Furthermore, there is a maximum length of string that can be stored
(column 7) of 127 characters. There is no error catch for items
which exceed these limits.

The following is a description of each of the fields in the registers.

Col      Description
    
1     Variable name
2     Value which designates blank value when stored in database
3     Start index of array variables
4     Maximum length of an array
5     For 2D arrays designates second dimension
6     Type : either STRING, INT, REAL or LOGIC
7     Maximum length of STRING variables - up to 127 only. Exceeding 127
      results in the corruption of basis databases.
8     Format of REAL variables: eg 10.6f for 10 significant figures and 6 
      decimal places
9     Name of window - or most important window if variable is on more than 
      one. This column is used when locating errors during Check Setup. 
      Window name should have the form prefix_rest_of_window_name where the 
      prefix is that listed in the partition.database for this partition 
      (see column 10). For cross partition variables whose different elements
      should exist on window panels whose names differ only by this prefix, 
      the prefix is substituted for the appropriate prefix obtained from the 
      partition.database. For array variables which have different elements 
      on different windows functions can be declared in the form 
      FN:function_name. The function will be called without arguments since 
      it uses the global variables fv_variable_name and fv_index defined in 
      full_verify to determine which window name to return. The 
      system.database is a useful place for storing lists of window names. 
      This column is allowed a maximum of 48 characters
10    Contains a partition identifier used for grouping together sets of 
      variables. The first character of the identifier is the most 
      significant; the partition.database contains information which is used
      to determine whether or not the variables in a partition with a given 
      initial identifier are 'active'. Inactive partitions are not checked
      during Check Setup.
11    This column provides information as to which variables and which 
      elements of arrays are 'inactive'. Status of a variable can be 
      determined either by logical expressions or functions. It is 
      important that there is always a match between the logic in the 
      variable register and the logic in all window panels within which
      the variable is set. That is, if the variable is 'greyed out' on the 
      window then it should be inactive, and if it is not greyed out it 
      should be checked. 

      This column may also contain qualifications to the above in terms of
      array length expressions and GT1 logic. See below.

                        Logical Expressions
      Probably the most common form would be a logical expression checking 
      values of other variables eg 
                  variable name                  Column 11
                  ANY_VARIABLE1                  VAR==1 
                  ANY_VARIABLE2                  VAR2(2)!="Y" 
                  ANY_VARIABLE3                  !(VAR2(2)!="Y"||VAR2(3)!="Y") 
                  ARRAY                          (VAR3(N)==2)
      If the statement is TRUE, the variable is inactive and is not checked.
      While the first two examples could refer to any type of variable, the 
      last example would be applicable to a 1D array where some elements may 
      be active and some inactive, or a 2D array where some lists may be 
      active and others inactive. Assume VAR3=1 2 1. If ARRAY is 1D then
      ARRAY(1) and ARRAY(3) are active and ARRAY(2) is inactive. If ARRAY is
      2D then the arrays ARRAY(*,1) and ARRAY(*,3) are active and ARRAY(*,2) 
      is inactive. There is no contingency for applying logic to single 
      elements within 2D arrays. 

      Rules for writing statements are similar to most programming languages:
       --  Multiple logic statements can be used:
                 VAR==1&&VAR(2)!="N"
                 (VAR3(N)==1)||(VAR4(N)!="N")
		 VAR=1||(VAR==2&&VAR2==VAR3)
       -- Parenthesis is optional
       -- && is evaluated before || if no parenthesis
       -- The .NOT. operator ! applies only to expressions, not to variables.
          Therefore it would always be followed by a "(".
       -- strings must be within double quotes
       -- integers may or may not be within double quotes
      There are some minor limitations:
       -- Only == and != can be used
       -- A variable must be used to the left of == or !=
       -- You cannot have:
                  (VAR+1)==VAR1
		  (VAR==VAR1)==(VAR2==VAR3)
       -- Real numbers must be treated as strings

      Additionally, NEVER and ALWAYS count as logical statements. NEVER
      means never inactive, ALWAYS means always inactive. If a variable is
      ALWAYS inactive then its value is never checked. Therefore ALWAYS
      should be rarely, if ever, used in a variable register.
 
                           Functions
      Some variables may require tests that are too complicated to express
      as a logical expression. Instead, a function can be used.
                    FN:vi_testvar
      the vi prefix stands for 'variable inactive ?'. The document "Adding 
      variables to a GHUI application" gives details on writing these functions.

                           Length Expressions
      All arrays are stored with a fixed maximum length which cannot sensibly
      be changed. However, arrays are also allowed to have a variable 
      'active' length which is specified by an expression and must be less
      than the maximum length. Even if the variable is active, only the 
      indices up to this length are checked. These expressions must come
      before the logic expression or function.
               variable name                    Column 11
               ARRAYX_1_DIMENSION                LENGTH:NEVER
               ARRAYY_1_DIMENSION                LENGTH+1:FN:vi_check_array
               ARRAYX_2_DIMENSIONS               LEN(N):USE_ARRAYX(N)!="Y"
     the third example concerns a 2D array. The length of each of the lists
     ARRAYX_2_DIMENSIONS(N) is LEN(N). If a variable in the length expression
     is unset, the array will not be checked.

                           GT1 option
     This option is applicable to arrays whose requirement is that, if they 
     are active they must contain at least one element. Thus in the following
               ARRAY                           GT1:USE_ARRAY!="Y"
     if USE_ARRAY is 'Y' then the first element must contain a valid value,
     but elements with indices greater than 1 (hence GT1) are allowed to be
     blank.

12  This column contains information used to check the values of active 
    variables. Check types can be one of the following
      LIST:     followed by a list of allowed values
      RANGE:    followed by lower and upper ranges which can be functions of
                other variables
      FILE:     Checks file and path entries. Options which can be listed in
                any order include:

                   FILE or PATH : limited checking that input is valid file
                                  or path name.
                   LOCAL : For FILE, must be local and readable. 
                           For PATH, must be local.
                   OPT : input is optional.

                eg  FILE OPT LOCAL PATH : optional input of local path
      NONE :    Limited checking. Options are:
                OPT: any input including blank input is allowed
                NOTOPT: any input, but blank is not allowed.
      FUNCTION  followed by the name of a function plus zero or more
                arguments. The function is called with three arguments
                plus the optional arguments
                 value: Variable value, or list if an array
                 name : Name of variable.
                 index: Index to be checked which takes account of
                        start index (column 3), or -1 if scalar.
                 [arg1, [arg2]]...

                If called following window closure, name is as it appears in 
                the window file. It will nearly always be one of the following 
                forms: NAME for a scalar or an array, NAME(2) for a single 
                element of an array, NAME(INDEX) (where index is an INT) also 
                a single element of an array, or NAME(*,2) and NAME(*,INDEX)
                for a single array of a 2D variable. If called during Check 
                Setup then name will depend on the type of variable. 
                For single partition variables:
                   Scalars  :  NAME      index=-1
                   1D arrays:  NAME      index loops from start index.
                   2D arrays:  NAME(*,2) index loops from start index.
                Cross-partition variables are stored as normal arrays with n
                elements where n is the number of partitions. Calls are not
                made to check elements in inactive partitions.
                   1D arrays:  calls made for each active partition with 
                               NAME(i) where i goes from 1 to n. and index=-1  
                   2D arrays:  A set of calls made for each active partition 
                               with NAME(*,i) where i goes from 1 to n. For 
                               each set of calls, index loops from start index  











