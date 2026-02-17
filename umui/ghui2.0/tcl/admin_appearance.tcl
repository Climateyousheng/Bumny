
# admin_appearance
#   Define default colours and fonts. Set up arrays for menus. Define help
#   files for the help menu.

proc admin_appearance {} {
    
    global menus fonts

    set colours(title_bg_normal) pink
    set colours(title_bg_filter) orange
    set colours(select_bg) lightblue
    set colours(unselect_bg) gray80
    set colours(enabled_fg) black
    set colours(disabled_fg) gray60
    option add *foreground $colours(enabled_fg)
    option add *background $colours(unselect_bg)
    option add *disabledForeground $colours(disabled_fg)
    option add *Scrollbar.foreground gray80
    option add *Scrollbar.background gray70

    # fonts
    option add *font          "lucidatypewriter 12"
    set fonts(lines)          "lucidatypewriter 10"
    set fonts(medium_lines)   "courier 12"
    set fonts(menus)          "helvetica 11 bold"
    set fonts(help)           "courier 11"
    set fonts(buttons)        "times 14"

    # menu titles
    set menus(titles) {File Window Clients Help}

    # File menu

    set menus(items-File) {quit_admin}

    set menus(text-File-quit_admin)   {Quit}

    # Window menu

    set menus(items-Window) {redraw}

    set menus(text-Window-redraw)    {Re-draw}

    # Clients menu

    set menus(items-Clients) {show_clients conf_clients}

    set menus(text-Clients-show_clients) {Show configuration}
    set menus(text-Clients-conf_clients) {Re-configure}

    # Define help menu
    # File name prefix for help files and location of gaps in menu
    set menus(items-Help) [list \
	    admin_intro \
	    admin_trouble \
	    admin_automation \
	    GAP \
	    admin_open_jobs \
	    admin_primary_server \
	    admin_backup_server \
	    GAP \
	    admin_file_menu \
	    admin_window_menu \
	    admin_clients_menu \
	    ]

    # Title of menu items with the same gaps as above
    set titles [list \
	    Introduction \
	    Trouble-shooting \
	    Automation \
	    GAP \
	    "Open Jobs" \
	    "Primary Server" \
	    "Backup Server" \
	    GAP \
	    "File Menu" \
	    "Window Menu" \
	    "Clients Menu" \
	    ]

    # Define the procedure to execute for each of the menu options.
    # Basically the procedure calls "show_help" with the appropriate
    # file prefix and title.
    foreach item $menus(items-Help) title $titles {
	if {$item != "GAP"} {
	    set menus(text-Help-$item) $title
	    eval [list proc menu_$item {} [list \
		    show_help $item "Help for $title"
	    ]]
	}
    }
}
