This directory hold the help text that can be viewed from the entry system.

Just edit the text of the files to improve or change the help.

Here are the rules for adding more help items to the menu.
  
1) create help file in ~umui/development/help contain standard UMUI help text

        eg a file ~umui/development/help/entry_pizza.help might contain:

        "Contact Mick Carter on X4003 with your order. Please have your
        PIN ready. Be very courteous and remember to tip heavily. :-)"

2) edit ~umui/development/tcl/entr_appearance.tcl

        The relevent code is at (approx.) line 105
        eg. If you wanted to add a help window about the entry system
        pizza ordering facility: You would add a line:

                set menus(text-Help-help_pizza) {Pizza ordering}
                                    ^^^^^^^^^^   ^^^^^^^^^^^^^^
                                    Procedure      Menu Text
                                      Name
        and add the item to the list just above defining the menu.                              

3) edit ~umui/development/tcl/entry_menu.tcl

        The relevent code is at the end of the file (approx.) line 448
        eg. above example would require the addition of the following
        code:

                proc menu_help_general {} {
                    show_help .entry_pizza
                }

The routine that shows the help (show_help) is functionally identical
to the job edit version, but has one or two code changes (eg help path
and font global variables). Subsequent changes to the help routine (eg
push HTML doc to Web Browser, include help, etc) will need to be added
seperately.
