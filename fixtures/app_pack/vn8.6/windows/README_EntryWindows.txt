UMUI and GHUI documentation.

README for Entry Windows Syntax.
11th April 1996. 
Mick Carter
Steve Mullerworth

Entry Window Files.
~~~~~~~~~~~~~~~~~~~
Each file defines the contents of one window. All interactive components in 
the contents of one file should be related in some way, and the window should
not be too large. Larger sets of related information should either be split 
into sub-categories, or a series of "follow-on" windows can
be defined. Interactive components can appear in more than one window, but
each database item should have one defined "home window". For components
relating to items not on their home window, it is good practice to make this
clear by using wording such as
"Elsewhere, you have defined." 


File Naming Convention.
~~~~~~~~~~~~~~~~~~~~~~~
Entry windows are always called something.pan.
The "something" should describe both the contents of the window and its
position in the navigation tree, as with the following example:
  atmos_Control_Output_Writes_MaxMin.pan
The last "level" (MaxMin) defines the window contents and the other "levels"
define the primary position in the navigation tree. You will remember that it
is possible for a window appear once in the navigation tree, but there should
only be one primary position (see the header or the nav.spec file).

Large subjects may need to spread across two windows (using a next button). In
this case, the second window would be called 
  atmos_Control_Output_Writes_MaxMin2.pan
etc

Two General Comments on syntax
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. The first character of all window commands is a full-stop (period) eg 
.text, .basrad, .case. Many components have one or more pieces of associated 
text in quotes, the first of which is followed by L or R to specify left 
or right justification. 

2. A useful property is that tcl expressions can be incorporated into
text enabling, for example, text output of application variables:

 These examples show the use of the GHUI get_variable_value command for
 obtaining values of scalar variables (as opposed to arrays):
  .text "You can only set [get_variable_value N_RECS]." L
  .check "Status of Stream Number [get_variable_value SN]" L STAT(SN) 1 0
  .entry "No of half-levels (max [expr [get_variable_value LEV]+1])" L ...
 The last example also uses the tcl expr command to evaluate a sum.

Note that this option should be used with a little caution since the evaluated
text will not change once the window has been opened even if the value
of the variable changes (eg when a user opens the window in which the variable
is set while the original window is still open).


Entry Window Framework.
~~~~~~~~~~~~~~~~~~~~~~~
Window framework is partly defined by the particular window skeleton specified
in the file (see the README in the skeleton directory). For example the 
skeleton would probably define a "Close Window" button common to most windows.
Additionally, each window should contain certain window specific information.
Hence, a window takes the form below:

My comments are in {}
<snip>
.winid "atmos_Assim_Obs"       {This should agree with the file-name. No .pan}
.title "Observation Choices"   {Title, keep it short}
.wintype entry		       {Defines the type of skeleton to use}

.panel
 {The panel body information goes in here. Please indent.}
.panend
</snip>
It is a good idea to repeat the title in the body of the window because:
	1. It is easier to read.
	2. It will not get truncated.
See the .text construct to see how to do this.	
See the README in the skeleton library for description on skeleton use.

Tcl commands to be executed when the window is opened, closed or abandoned
may be defined in this part of the window using the .procs command:

.procs [tcl_entry] [tcl_abandon] [tcl_close]
     [tcl_entry]   Optional. Tcl code or procedure to execute on entry to the
                   window.
     [tcl_abandon] Optional. Tcl code or procedure to execute if abandon is 
                   pressed. Rarely used.
     [tcl_close]   Optional. Tcl code or procedure to execute if close is pressed.

 The .procs command should be placed after the .wintype command and before the
.panel command.

If such procedures are used to alter the values of variables, these
variables should be listed in the window with the .set_on_closure
construct. This ensures that procedures such as the difference
function know the location of such variables.

Examples:

If only a tcl_close command is required, then specify null open and
abandon commands using {}:

 .procs {} {} {set_extra_variables}

The procedure set_extra_variables will be executed if the close button
is selected.

 .procs {} {} {set_variable_value CHEM 4}
Calls GHUI procedure to set application variable CHEM to 4 on closure.

An example from the UMUI is a set of windows with no contents:
 .title "atmos_STASH_tcl"
 .wintype dummy
 .procs {stash 1}

On selecting this item, no GHUI window is created but the entry
procedure "stash" is called which creates its own window. This is a
useful method for incorporating other applications within the GHUI
application - the GHUI commands "set_variable_value",
"set_array_value" etc can be used to save results in the job basis
database. 

You are advised to use indentation inside any constructs such as 
.panel, .panend.
	
Body Language.
~~~~~~~~~~~~~~
The body part of the window definition contains the following language
elements:
	1. Button components to allow links to other entry windows.
	2. Interactive components to allow the user to "edit" the database
	items.
	3. Text, gap and comment components to allow non-interactive 
	definition of window layout.
	4. Start-End type syntax to allow portions of the window to conform to
	rules.
These will be described below. You are advised to look at examples on the
windows as well, but it should not take long to pick this up.


Button Components.
~~~~~~~~~~~~~~~~~~

There are a number of types of button component for use at the end of the panel
block. The skeleton file should include the .pushhelp, .pushquit and .pushclose
components since almost all windows require them:

.pushhelp "Help"

Creates a button labelled Help. When pressed, the help file called after the name
of the window is displayed. ie personal_gen.pan and personal_gen.help are linked.
If the help file does not exist in the help directory, the button is displayed 
greyed-out and inactive.

.pushclose "Close"
.pushquit "Abandon changes

Used for exiting the window, with or without saving changes.

.pushbutton "[button text]" command [arg1 [arg2 ...]]

Creates a button labelled with the button text. Pushing it calls the command
with an optional list of arguments.

There are also standard pushbuttons used to link from one window to
another. These constructs should be used sparingly. They should be
placed at the end of the panel block.

Pushnext/pushsequence component.
  The pushnext components provide a method of:
    1. Linking two windows with related information, typically far apart in
    the navigation system.
    2. Providing a method of retracing steps in a follow-on sequence.
  The pushsequence component is used instead of pushnext to
    1. Provide a method of access to follow-on windows when a subject is too
    large to fit onto one window.
  The pushsequence command is identical to the pushnext command when 
  creating windows but not when creating jobsheets. The pushsequence
  command tells the jobsheet function that the two windows are related
  and should be output one after another. Therefore the follow-on window
  should be listed in the nav.spec as a ..> file and not as a ..p file.

  When either of these constructs are used a labelled button is provided 
  at the bottom of the window.  On pressing the button, the current 
  window is closed and the new window opened. The position 
  in the navigation tree is not effected.
  You can have several pushnext commands in a window and they can be mixed 
  with pushand and pushsequence components. However, each window should 
  contain only one pushsequence command.

  Syntax:  
    Syntax is identical for pushnext and pushsequence commands
    .pushnext "Text"
    .pushsequence "Text"
    Text	is the name put on the button
    window_name is the name of the window (without the .pan).

    Examples
      .pushnext "HYDROL" atmos_Science_Section_Hydrol
        Go to window  atmos_Science_Section_Hydrol when HYDROL button pushed.

    You should add text just above the definition of the pushnext component
    that more fully describes the button.
  Example 2:
   .panel
      .....
      .....
      .text "Push HYDROL to go to the Soil Hydrology options window." L
      .pushnext "HYDROL" atmos_Science_Section_Hydrol
   .panend  
        
  Example 3:
   Avoiding pitfalls when using pushsequence:
   Consider a section which is divided into three different windows eg
   example_win1.pan,example_win2.pan and example_win3.pan, where 
   all three windows require buttons to jump to any of the other two.
   The windows should be listed in nav.spec in the following form.

   ..p example_win1  "Title"
   ...> example_win2  "Follow on window"
   ...> example_win3  "Follow on window"
  
   example_win1.pan would contain:
    .pushsequence "Window 2" example_win2
    .pushnext "Window 3" example_win3

   example_win2.pan would contain:
    .pushnext "Window 1" example_win1
    .pushsequence "Window 3" example_win3

   example_win3.pan would contain:
    .pushnext "Window 1" example_win1
    .pushnext "Window 2" example_win2
    
  When the jobsheet executes, the three windows will be output in 
  order. Note the lack of pushsequence in the third window. If
  this file included:
    .pushseqence "Window 1" example_win1
  then the jobsheet function would enter an endless loop outputting
  win1,win2,win3 followed by win1 again and so on.

Pushand component.
  The pushand component is very similar to the pushnext component. The only
  difference is that the "from" window is not closed before the "to" window is
  opened. This component should be used very sparingly, when it would be
  useful for a user to check the setting in another window when trying to
  answer a complex question in the current window.
  Hence it usually provides a method of linking two windows with related 
  information, typically far apart in the navigaion system.
  A button is provided at the bottom of the window.  On pressing the button,
  the new window opens but the current window also remains open. The 
  position in the navigation tree is not affected.
  You can have several of these in a window and they can be mixed with
  pushnext constructs.
  Syntax:  
    .pushand "Text" window_name
    Text	is the name put on the button
    window_name is the name of the window (without the .pan).

  Example:
      .pushand "HYDROL" atmos_Science_Section_Hydrol
        Open window  atmos_Science_Section_Hydrol when HYDROL button pushed.

  You should add text just above the definition of the pushand component
  that more fully describes the button.
  Example:
     .panel
        .....
        .....
       .text "Push HYDROL to view your settings in the soil hydrol window" L
       .pushand "HYDROL" atmos_Science_Section_Hydrol
     .panend   
        
  
Data-base Interaction Components.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

These are components that allow the user to "edit" the database items
by various methods. On entry to an entry window, the values in the
database required on this window are extracted and used to define the
settings of these components. On close, the variables are verified (as
defined in the "var.register" file in the "variables" directory). If
"Abandon changes" is pressed, the variables remain as they were on
entry.

When adding these components, the designer should bear in mind that the 
text associated with these components is also output by functions such as
the verification and job difference functions, but that here, it is used 
out of context. For example, if the following construct was used:
   .text "Do you want to include tracers"
   .check "Yes or No" ...
then, the help text picked up by these functions would be "Yes or No".

There are four interaction components. Namely, Check boxes (.check),
radio buttons (.basrad), entry boxes (.entry) and table columns (.element).
Additionally, some variables may be set indirectly by routines called on
opening or closing panels (see the nav.spec file). To incorporate this
in a window a special comment type .set_on_closure should be used.

The use of these components is described below. 

Check Boxes

  These allow the user to set a data-base item (or "variable") to one of two
  settings. Text is displayed with a box beside it. Clicking on the text or
  the box toggles between the ON_VAL and the OFF_VAL. Visually, the box 
  is coloured (lit up) or uncoloured (the same colour as the background.
  When a new job is created, all variables have blank values and therefore
  the variables related to check boxes are neither on nor off but unset.
  Since an unset check box that looked like a check box set to off would 
  cause confusion, unset check boxes and their associated text are 
  highlighted by the GHUI. Note, the highlighting does not show up when the
  check box is greyed out (see case statements).
  Syntax:
    .check "Text" L DB_ITEM ON_VAL OFF_VAL
    Text 	is the text displayed.
    L 		is required to ensure the data is packed left.
    DB_ITEM 	Is the data-base item that the component interacts with, 
                must be registered in a variable register in the "variables" 
                directory, normally the "var.register file". Check type will
                normally be a list (eg LIST Y N). Must be reduced to scalar.
    ON_VAL	The value set when the box is lit.
    OFF_VAL     The value set when the box is lit.       
  Example:  
    .check "Mesoscale Model" L MESO Y N
    .check "Define type" L COMPONENT(6) X Y

Radio Buttons 
  These allow the user to set a database item (or "variable") to one of
  several settings. Text is displayed introducing the option. Further text,
  one for each setting, is also displayed. Each option related text is 
  prefixed with a diamond shape that will light up when the option is chosen.
  Only one option can be chosen at once, and only one item can be lit.
  Unset variables are reasonably obvious as none of the diamonds are lit.
  Syntax
    <snip>
    .basrad "Intro_Text" L N_OPTS OR DB_ITEM 
            "Option_Text1" VAL_1 
            ["Option_TextN" VAL_N]
    </snip>
    Intro_text	Is the introductory text.
    L 		Is required to ensure the data is packed left.
    N_OPTS	Defines the number of options the item can take.
    OR		Defines the orientation of the options. It takes the value
                "v" for vertical or "h" for horizontal
    DB_ITEM 	Is the data-base item that the component interacts with, 
                must be registered in a variable register in the "variables" 
                directory, normally the "var.register file". Check type will
                normally be LIST. Must be reduced to scalar.
    Option_Text1 Text associated with the first option.
    VAL1 	 The value that defines the first option.
  Examples 
    .basrad "Select Area Option" L 3 v OCAAA 
            "Global Model       " 1 
            "Limited Area       " 2 
            "Single Column Model" 3
    .basrad "Choose section version." L 4 v SR(15) 
            "1A Simple       " 1A 
            "2A New improved " 2A 
            "3A Experimental " 3A
            "4A Rubbish " 4A
            
Entry Boxes.
  These allow the user to type in a value to define a data-base item 
  (or "variable"). On exit, it will be verified against the rules defined in
  the var.register file. Text is displayed defining the item along with a box 
  that will accept keystrokes.
  Unset variables are reasonably obvious, as the box is empty.
  There is a standard entry box .entry and an active entry box
  .entry_active
  Syntax of standard entry box
    .entry "Text" L DB_ITEM [width]
    Text	Is the defining text.
    L 		Is required to ensure the data is packed left.
    DB_ITEM 	Is the data-base item with which the component interacts. 
                Must be registered in a variable register in the "variables" 
                directory, normally the "var.register file". Must be reduced 
                to scalar.
    width       Optional width. Default is 40.
  Examples 
    .entry "Number of Columns ( X - Direction )" L NCOLSAG 
    .entry "Ratio for 5th component of thingy" L THINGY_RAT(5) 
    .entry "Full path and file name" L FNAME 80 

  Active entry boxes are displayed with a label widget to the right of
  the entry box. The label widget contents are a function of the entry
  input. The conversion is defined by an application specific function
  given as one of the .entry_active arguments.
    The jobsheet will display both results if they differ but only one 
  if the conversion does not alter the input.
   Syntax of active entry box:
    .entry_active "Text" L DB_ITEM command [width]
    Text	Is the defining text.
    L 		Is required to ensure the data is packed left.
    DB_ITEM 	Is the data-base item with which the component interacts. 
                Must be registered in a variable register in the "variables" 
                directory, normally the "var.register file". Must be reduced 
                to scalar.
    command     Application specific command whose input is the
                current text entry and whose output is some conversion
                of that text which is then displayed in the label widget.
    width       Optional width. Default is 40.
  Examples
      .entry_active "Range starting at " L convertInput LEVB_A

    One example use has been where an input could be chosen that was a 
  function of other inputs. A list of identities was set up so that a
  user might specify for example LEVEL-1 to request a value that was 1
  less than some other input identified by LEVEL. The conversion
  command did the calculations and displayed the result real time so
  that the user could be confident about what was being input. Note
  that the conversion function should not throw an error in any
  circumstances. In the above example, while the user is part way
  through typing in the name of an identity, the conversion would
  return what was typed until the name was complete. ie as typing
  proceeds one might see:
           LEV      Converts to LEV
           LEVE     Converts to LEVE
           LEVEL    Converts to 19
           LEVEL-   Converts to 19-
           LEVEL-1  Converts to 18
    
Tables.
  Tables are lists of entry boxes with scroll bars. They allow a user to 
  interact with an array of data-base items or several arrays. On exit, 
  the contents of the table will be verified against the rules defined 
  in the var.register file. A table is displayed with several items 
  of text defining the array(s). Unset variables are reasonably obvious, 
  as the boxes are empty.
  Syntax for a simple table: 
   .table Name "Header_Text" top h LEN SHOW ORDER 
     .element "Column_Text1" DB_ITEM1 LEN COL_WIDTH1 IN_OUT1
     .element "Column_Text2" DB_ITEM2 LEN COL_WIDTH2 IN_OUT2
   .tableend 
   Header_Text	Is the text that goes at the top of the table
   top		Fixed param. To allow positioning in future.
   h		Fixed param. To define orientation of "columns" in future.
   LEN		Number of rows, will often agree with the array length.
   		This can be interactive with an entry box on this, or another
   		window. Some calculation is possible.
   SHOW		The number of rows to display at one time. The rest are
   		reached by scrolling.
   ORDER	NONE, DESC, INCR or TIDY. If you choose  DESC or INCR	
                you will get an order button that will sort the list 
                into descending or increasing order. Additionally lines
                whose first input column is blank will be deleted. TIDY 
                will remove all wholly blank lines without changing the 
                order of other lines.
   Column_Text	Defines the text at the head of the column.
   DB_ARRAY	Is the array that is being interfaced with. Must have been
   		reduced	to a 1-D array (if 2D, by syntax eg DB_ARRAY(*,1) )
   COL_WIDTH	Defines the width of the column. This should also match the
   		width of text Column_Text.
   IN_OUT	Takes the value "in" or "out" to define if the column can be 
                edited (in) or is for display (out).
  Example:	
    .table levels "ETA table" top h NLEVSA[+1] 10 DESC
        .element "Values must be in ascending order" ETA 10 35 in
    .tableend      	
  Syntax for a simple table with numbered rows: 
    .table Name "Header_Text" top h LEN SHOW ORDER 
      .elementautonum "Column_Text1" START LEN COL_WIDTH1
      .element "Column_Text2" DB_ITEM LEN COL_WIDTH2 IN_OUT
    .tableend 
    START	Defines the first count value, normally set to 1.
  Example: 
    .table levels "ETA table" top h 12 10 DESC 
      .elementautonum "Eta Half Level" 1 12 10
      .element "Values must be in ascending order" ETA 10 35 in
    .tableend      
  Syntax for a simple table with nested headings: 
    .table Name "Header_Text" top h LEN SHOW ORDER 
      .super "Super_Heading1"
        .element "Column_Text1" DB_ITEM LEN COL_WIDTH1 IN_OUT
        .element "Column_Text2" DB_ITEM LEN COL_WIDTH2 IN_OUT
      .superend
      .super "Super_Heading2"
        .element "Column_Text3" DB_ITEM LEN COL_WIDTH3 IN_OUT
        .element "Column_Text4" DB_ITEM LEN COL_WIDTH4 IN_OUT
      .superend
    .tableend 					
    Super_Heading1	Sits above column headings. The text width should add
    			up to the individual widths within the text.
  Example: 
   .table Some "Define Obs options" top h NITEMS 10 DESC 
     .super "Obs name and type"
       .element "Name    " ONAME 10 8 out
       .element "Type     " OTYPE 10 9 out
     .superend
     .super "Define"
       .element "Use" OUSE 10 3 in
       .element "Coefficient " OCOEF 10 12 in
     .superend
   .tableend 
  Syntax for indexed tables: 
    .table Name "Header_Text" top h LEN SHOW ORDER 
        .index OUTVAR1 OUTVAR_INDEX
        .index OUTVAR2 OUTVAR_INDEX
        .index INVAR1 INVAR_INDEX
        .index INVAR2 INVAR_INDEX
        .element "TEXT1" OUTVAR1 SHOW WIDTH1 out
        .element "TEXT2" OUTVAR2 SHOW WIDTH2 out
        .element "TEXT3" INVAR1 SHOW WIDTH3 in
        .element "TEXT4" INVAR2 SHOW WIDTH4 in
    .tableend 
    OUTVAR	  Is a variable to be displayed
    OUTVAR_INDEX  Is the system register copy of the index
    INVAR	  Is an interactive variable
    INVAR_INDEX   Is the variable register copy of the index
    Indexed tables are used to allow arrays to have rows inserted/deleted  into 
    them at later releases. One copy of the index (that is used to define the 
    rows) is kept in the system register and another copy is kept in the 
    variable register. The indexes are compared and new rows are added if the 
    system register has new items in, etc. 
    For example, perhaps we have a list of possible obs types {101, 201, 301} 
    and new ones are added at a new release to make a new list 
    {101, 102, 201, 301}. The system register copy of the list would be
    amended, but the variable register copy would be unchanged on moving up to
    the new release. The user may be asked to make responses against these
    types {101 Y, 201 N, 301 Y}. If these are just treated as arrays, the
    responses would be out of order with the types (or the types would not be
    in the natural order). This system solves this problem, and should be
    used for all arrays of this type, which would otherwise be very sparse.
  Example:
    .table OBS "OBS CHOICES" top h LEN SHOW ORDER 
        .index OBS_NO OBS_NO
        .index OBS_NAME OBS_NO
        .index OBS_USE OBS_INDEX
        .index OBS_COEFF OBS_INDEX
        .element "Type     " OBS_NO 10 9 out
        .element "Name    " OBS_NAME 10 8 out
        .element "Use" OBS_USE 10 3 in
        .element "Coefficient " OBS_COEF 10 12 in
    .tableend 
     
Hidden variables
  Some variables are set by procedures attached to windows rather than by
  using the above interactive components. To define help text for these 
  variables, use the .set_on_closure construct. This is essentially an
  alternative sort of comment component since it has no effect on the
  window layout.
  Syntax
    .set_on_closure "Text" VARIABLE
  
  In the following example, ACON(42) is set by a close procedure to a 
  value dependent on the setting of another variable in the window.
   .set_on_closure "Depends on setting of row 25 of table TCA" ACON(42)
  If the Difference function should find a difference with this 
  variable, the text "Depends on..." will be output.

Text, Gap and Comment Components.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
These components provide methods of enhancing the readability of a window to
either the user or the developer.
They allow extra text, not associated with data-base items, and spacing.

Gap component.
  The gap construct provides a method of putting a blank line into a window.
  Syntax:
       .gap

Text components.
  The text components provide a method for putting non-interacting text into a 
  window. There are four different text components: .text .textw .textj and 
  .textd. All components have identical syntax. 
  Syntax:
    .text "Text" L
    Text      The required text to be shown on the window.
    L (or R)  Justify left or right. (NB using R is unusual - it looks untidy)
  
  The different types of text component are concerned with the different
  requirements of producing windows and job sheets (hard copies of job 
  definition whose contents are based on the .pan files). As far as 
  windows are concerned, .text, .textw (w for window) and textd (d for
  description) are identical. However, .textj (j for jobsheet) is ignored 
  when creating windows and only output to job sheets. Conversely, when 
  creating job sheet output, .textw components are ignored while 
  .textj and .text are output. The .textd option is used for long 
  questions which need to be broken into two lines. The .textd text 
  is only output if the question or table that follows it is output.

  Examples 
  1. Text is output both to window and to jobsheet.
   .text "Specify the following parameters:" L  
  2. Different text for window and jobsheet; friendly for the former,
     simply informative for the latter.
   .textw "Fill in column 1 of table with 1 for yes and 0 for no" L
   .textj "Column 1: 1 means yes 0 means no" L
  3. Very long question.
   .textd "Do you want to include the contents of the post processing and" L
   .check "data file windows in your jobsheet" L JS_PP Y N
  In this example, if this question were included on a window other than
  the home window of the JS_PP variable then neither the text nor the 
  question would be output. If .text had been used instead of .textd
  then the first line of text would be output but the .check line might 
  be ignored.    

Comment component.
  The comment component allows you to add in-line comments in a window
  definition file. They are not displayed on the window. Windows are normally
  self explanatory. However, comments should always be added to windows that
  contain data-base items that require special action or may require changes
  to application specific code if amended.
  Syntax:
    .comment TEXT
    TEXT is any text.
  Example:
    .comment=================================================================
    .comment  When adding/removing profile variables, remember to change the
    .comment  list in stash.tcl that perform functions to copy/remove 
    .comment  profiles.
    .comment=================================================================


Start-End Constructs
~~~~~~~~~~~~~~~~~~~~
Start-End constructs further enhance the visual signals on a
window. They make the windows more obvious.

The block construct.
     The block construct provides a method of showing that a
     set of variables are connected. The construct aligns the
     start columns within the construct. Further, for entry
     boxes, the box part of the component is aligned for all
     elements in the block construct and for horizontally-arrayed
     radio buttons, the first button will be aligned for all
     components in the box. This indicates, visually, that the 
     components are related and, if indented, subsidiary to other 
     components.
     Blocks can be nested in a similar way to other constructs.
     Syntax:
       .block N
          COMPONENTS
       .blockend 
       N            Define the indentation required. 0 denotes
                    no indentation.
       COMPONENTS   A series of components. These should be
                    indented in the window file to aid
                    clarity.
     Example:
     .text "Specify coefficients relating to gases"
     .block 1
       .entry "Carbon Dioxide" L CO2_COEFF
       .entry "Sulphur Dioxide" L SO2_COEFF
     .blockend
     In this example, the two entry-box components will be
     slightly indented and the entry boxes will be aligned to
     the right of the widest text.

The case construct.
     The case construct provides a method of showing that
     elements are made redundant by other elements. For
     example, a particular option on a radio button may demand
     that extra questions be answered that are otherwise not
     required. The case construct gives visual clues to this
     by greying out those items that do not need to be
     answered. As well as being greyed out, the items do not
     interact with the keyboard or mouse. The logic for case
     constructs should always agree (in reverse) with the logic 
     that defines an item to be inactive in the variable register
     otherwise a user will receive a consistency check warning
     on closing the window.

     The case construct can be used anywhere within a panel including
     within a table; but as with other constructs, do not overlap 
     nesting of .case with nesting of .super or .table constructs.

     Syntax:
       .case LOGIC
          COMPONENTS
       .caseend 
       LOGIC   Case logic expressions have the same syntax as
               expressions in the inactive column of the variable
               register except that expressions may include spaces. 
                 .case AASMODE==0||AASMODE==1
                 .case VAR_A!=1 && ( VAR_B==1 || VAR_C==2 || VAR_D==6 )
               Therefore, the logic in the case statement ought to be
               the reverse of the logic in the variable register
               relating to the status of enclosed items:
                 inactive status of VAR_X is
                    A==1||B==2
                 in the window use
                    .case !(A==1||B==2)
               There is, however, a function that will automatically
               grab the appropriate logic from the variable register
               and reverse the logic:
                    .case active VAR_NAME
               will return the inactive expression of VAR_NAME with
               a !(...) around it to reverse the logic.
               
               In expressions, strings should be in quotes. Numbers
               may or may not be in quotes.
                   .case VAR_A==1 || STRING_A=="N"

     Example:
       .basrad "Choose radiation type" L 3 v RAD_TYPE
               "Simple" 1
               "With gases" 2
       .case RAD_TYPE==2
         .text "Specify coefficients relating to gases"
         .block 1
           .entry "Carbon Dioxide" L CO2_COEFF
           .entry "Sulphur Dioxide" L SO2_COEFF
         .blockend
       .caseend 
     Here, the case construct is used to good effect with text
     components and block constructs to show that the second
     question is dependent on the first. The items in a case 
     statement do not need to be on the same window. However,
     bear in mind the order in which a typical user goes about
     setting up a job; the questions relating to the variables
     in a case statement ideally will be above the case statement
     in the same window. If they are not on the same window,
     then they should perhaps be on a window that logically 
     precedes it, and information should be provided to the 
     user, for example to explain why a section is greyed out.

     Additionally, case statements will not interact with entry
     boxes. In the following example
       .entry "Specify number of files (0 to 10)" L NFILES
       .case NFILES!=0
         .comment table not in use if NFILES=0
         .text "File names ?"
         .table
           ...
         .tableend
       .caseend
     if a user changed NFILES from 5 to 0, the case would not 
     come into effect until the window was closed and reopened.
     A neater method to use would be 
       .check "Use File table ?" L USE_TABLE Y N
       .case USE_TABLE=="Y"
         .entry "Specify number of files (1 to 10)" L NFILES
         .comment table not in use if USE_TABLE!="Y"
         .text "File names ?"
         .table
           ...
         .tableend
       .caseend
     Here, if the check box is set to off, the case statement
     immediately greys out the rest of the window.

     Another example using the "active" function.
        .case active VAR_A
           .check "Use this option ?" L VAR_A Y N
        .caseend
     This will greyout automatically when VAR_A is inactive
     as defined in the variable register.

The invisible construct.
     The invisible construct is like the case construct. It
     provides a method of showing that elements are made
     redundant by other elements. For example, a particular
     option on a radio button may demand that extra questions
     be answered that are otherwise not required. The
     invisible construct gives visual clues to this by
     removing those items that do not need to be answered. As
     well as being invisible, the items do not interact with
     the keyboard or mouse. The logic for invisible constructs
     should agree (in reverse) with the logic that defines an
     item to be inactive in the variable register otherwise,
     as with case logic, consistency warnings will be output. The
     construct can be used to good effect with text constructs
     to put variable dependent comments on windows.
     Syntax:
       .invisible LOGIC
          COMPONENTS
       .invisend 
       LOGIC   Invisible logic syntax is the same as case logic
               syntax.

     Example:
       .basrad "Choose radiation type" L 3 v RAD_TYPE
               "Simple" 1
               "With gases" 2
       .invisible RAD_TYPE==2
         .text "You need define the appropriate ancillary
     file."
       .caseend
     Here, the case construct is used to provide tailored help. 
     For invisible constructs to work with logic using items 
     in the same window, the items must be defined by radio 
     button or check-box constructs. Invisible constructs 
     should be used sparingly as they obscure user choices.
     Example invisible logic:
          ATMOS_SR(5)!=3A True if element (5) of array
          ATMOS_SR does not take the value 3A.
          (VAR1==5  VAR2==7)&&VAR3==2

The .colour construct.
     The colour construct allows items in panels to be given
     a colour other than black. A conditional expression is 
     also supplied and the colour is applied when the condition
     is satisfied. Note that if an item is greyed out it will
     be shown in the normal grey colour rather than the optional
     colour.
       The .colour construct works in a similar way to .case and
     .invisible except that a colour has to be specified. 
     Syntax:
       .colour COLOUR LOGIC
         components
       .colourend

       COLOUR : Any colour allowed by the system. Typically use
                red, blue, green etc.
       LOGIC  : Logic statement of the same format as .case

     Note that colour constructs cannot be nested - there is no 
     single logical way of doing so. It is a simple enough matter
     to have numerous constructs rather than nested constructs.

     Colouring may simply be used to highlight certain questions
     or labels. Alternatively, it may be used in a more elaborate 
     manner in conjunction with appropriate variable checking 
     functions. The .colour construct was originally added to the
     GHUI to cope with a situation similar to the following example.

     Example:
      .check "Optionally reading data from external file ?" L OPT Y N
      .invisible OPT=="Y"
         .textw "If blue questions are left blank then values" L
         .textw "will be read in from external file" L
      .invisend
      .invisible OPT!="Y"
         .textw "No external file being used" L
         .textw "All questions must be answered" L
      .invisend
      .colour blue OPT==Y
         .entry "Initial value" L I_VAL
      .colourend

     The above example envisages a system where input comes either from
     the user interface or from an external file. If an external
     file is not being used, the user must answer all questions 
     (and none are coloured blue). If, however, an external file
     is being used then certain questions are coloured blue. Those
     questions that are blue either can optionally be left blank. 
     Whether or not a question is allowed to be left blank is 
     determined by a non-GHUI variable checking function listed
     in the variable register.

Including other files within windows
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Windows may include other files. Thus a commonly used set of constructs
can be set up in more than one window. String substitution is possible
in the included files for flexibility.

Include files should have a suffix .inc and take the form:

 .include_begin no_of_args
   ...normal windows commands
 .include_end

where no_of_args is the number of substitution strings required

To include a file, use the command
 .include filePrefix arg1 arg2...arg

 filePrefix: prefix of include file which should have a .inc suffix
 arg1 etc: Either a string, or a user interface variable prefixed with %

eg.

  .include inc_file ATMOS %VALUE

will include the file inc_file.inc and substitute instances of %1 in
the include file with the string "ATMOS" and %2 with the value of the
user interface variable VALUE.  Care should be taken when using
user-interface variables - if the variable changes while the panel is
opened it will not affect the include file.

Suppose there is an array ARRAY whose different elements are set on
different windows but with the same radiobutton question. An include
file can be written:

File array_question.inc

  .include_begin 2
     .basrad "Choose mode" L 3 %2 ARRAY(%1)
             "Single Tasked" S
             "Perf Trace" P
             "Multi Tasked" M
  .include_end

The strings %1 and %2 will be substituted with strings specified in
the appropriate windows file. So one window will contain: 
   .include array_question 1 h
and the question will set ARRAY(1) and the radiobutton will appear
horizontally arrayed. Another window may contain
   .include array_question 13 v
The question will set ARRAY(13) and the radiobutton will appear
vertically arrayed.

A more complicated example is when not all options apply to all
windows. Then we can have

  .include_begin 5
     .basrad "Choose mode" L %2 v ARRAY(%1)
        %3     "Single Tasked" S
        %4     "Perf Trace" P
        %5     "Multi Tasked" M
  .include_end

If all options apply, use:
   .include 13 3 {} {} {}
if only options 1 and 3 apply, use:
   .include 13 2 {} .comment {}
(The second argument provides the number of buttons.)


Jobsheet related commands for non-standard or complex windows
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Additional commands are available to support the printing of job sheets (hard
copies of job definitions). These two examples are somewhat advanced and 
may be worth passing over until some experience of writing windows is obtained
since reasonably simple windows do not require such commands:

 1. The .function declaration.
For some windows, the jobsheet will not produce a suitable output. Instead
the jobsheet generation is passed to an application specific function.
The function needs to be declared in the .pan file before the .panel 
command.

 .function js_complex_window1

When the jobsheet function reaches this window, jobsheet output will be 
passed to the named procedure. The procedure will be called with two
arguments: the id of the output file and the maximum width in characters.
The function should output suitable text to the file keeping within the
width specification.

 2. The .loop construct.
More than one instance of some windows may exist. The variables in such a
window would be declared with another variable as an index. The second 
variable would be set by another window before opening this one.
 Syntax:
  .loop VARNAME TO FROM
 VARNAME is the name of the index variable. TO and FROM specify the range
of VARNAME to use. TO and FROM can be integers, application variables
or sums involving integers and variables.

Here is an example from the UMUI:

.winid "atmos_Control_OutputData_LBC2"
.title "Specification of LBC generation"
.wintype entry
.loop OCBMLA 1 4
.panel
   .check "Stream [get_variable_value OCBMLA] active" L OCBILA(OCBMLA) 1 0 
   .case OCBILA(OCBMLA)==1
     .gap
<snip>
     .block 1
       .entry "Re-initialise every (hours)" L ILMARH(OCBMLA)
       .check "With automatic archiving" L ILMARA(OCBMLA) Y N 
     .blockend
   .caseend
   .textw "push NEXT to define the vertical grid" L
   .pushsequence "NEXT" atmos_Control_OutputData_LBC3
.panend

When the jobsheet function finds the .loop command, it will output the window
four times first setting OCBMLA to different values 1 to 4.
     
See the jobsheet information for further examples.
    
