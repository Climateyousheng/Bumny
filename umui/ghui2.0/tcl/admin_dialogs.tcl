proc  server_none_dialog {server} {

  global fonts gonone

  toplevel .sure
  wm geometry .sure +600+200
  message .sure.msg -width 200 -text \
      "Do you want $server configured as \"NONE\"" \
      -font $fonts(help)
  button .sure.q -text "Abandon" \
      -command "set gonone 0
  catch {destroy .sure}" 
  button .sure.a -text "Yes" \
      -command "set gonone 1
  catch {destroy .sure}"
  pack .sure.msg -padx 2m -pady 2m
  pack .sure.q -ipadx 1m -ipady 1m -pady 2m
  pack .sure.a -ipadx 1m -ipady 1m -pady 2m
  tkwait window .sure
  if {$gonone==0} {
    return 0
  } else {
    return 1
  }
}

proc server_reloading_dialog {} {

  dialog .error_srd {ERROR} \
      "This server is currently reloading the database. You \
      cannot do this while the server is reloading. Please try again later" \
      {} 0 {OK}
}


proc no_primary_dialog {server} {
  
  dialog .error_npd {ERROR} \
      "You cannot configure the clients with one dead server  \
      and one backup server. You should always have one primary \
      server. You may want to set $server as \"PRIMARY\". Please rectify." \
      {} 0 {OK}
}

  
proc server_running_dialog {} {

  dialog .error_srd2 {ERROR} \
      "The server is already running. You should use \"Re-draw\" under the \
      \"Window\" menu to redraw the admin interface." \
      {} 0 {OK}
}


proc conf_clients_error {errmsg} {

  dialog .error_cce {ERROR} \
      "Failed to copy configuration to one of the clients defined in \
      the client.def file. Check that the file entries are correct. \
      If they are ok, then there may be a network error or the client \
      may be down. Pressing \"OK\" will continue distibuting to other \
      clients. ERROR: attempting to rcp to $errmsg" \
      {} 0 {OK}
  tkwait window .error_cce
}

proc conf_clients_error2 {errmsg} {

  dialog .error_cce2 {ERROR} \
      "Failed to copy configuration to one of the clients defined in \
      the client.def file. This is either because there has been a \
      problem with the ghui_hostup script, there is a problem with \
      host lookup on this system or the clients.def file has a bad \
      entry. Pressing \"OK\" will continue distibuting to other \
      clients. THE GHUI SYSTEM IS CURRENTLY MISCONFIGURED. ERROR attempting \
      to rcp to $errmsg, ghui_hostup returned \"unknown\"." \
      {} 0 {OK}
  tkwait window .error_cce2
}

proc conf_clients_error3 {errmsg} {

  dialog .error_cce3 {ERROR} \
      "Failed to copy configuration to one of the clients defined in \
      the client.def file. Check that the file entries are correct. \
      If they are ok, then there may be a network error or the client host \
      may be down. Pressing \"OK\" will continue distibuting to other \
      clients. THE GHUI SYSTEM IS CURRENTLY MISCONFIGURED. ERROR: \
      attempting to rcp to $errmsg, ghui_hostup returned \"no\"." \
      {} 0 {OK}
  tkwait window .error_cce3
}

proc conf_clients_error4 {errmsg} {

  dialog .error_cce4 {ERROR} \
      "Failed to copy configuration to one of the clients defined in \
      the client.def file. There is a serious problem with ghui_hostup. \
      Contact GHUI admin immediately. THE GHUI SYSTEM IS CURRENTLY \
      MISCONFIGURED. Pressing \"OK\" will continue distibuting to other \
      clients. ERROR: attempting to rcp to $errmsg, ghui_hostup failed" \
      {} 0 {OK}
  tkwait window .error_cce4
}

proc check_type_error {} {

  dialog .error_cte {ERROR} \
      "The primary server and backup server are both \
      set to the same type. They cannot be the same. Please rectify." \
      {} 0 {OK}
}

proc check_status_error {} {
  dialog .error_cse {ERROR} \
      "Servers cannot be ACTIVE for this action \
      Please rectify this if you want the action enabled." \
      {} 0 {OK}
}

proc unknown_state_error {} {
  
  dialog .error_use {ERROR} \
      "The server is in an unknown state. \
      This is an error. Please contact the GHUI admin team." \
      {} 0 {OK}
}

proc empty_dbse_error {} {
  
  dialog .error_ede {ERROR} \
      "The server job database is empty. \
      Use the \"Read database\" button to load the job database." \
      {} 0 {OK}
}

proc unknown_type_dialog {} {

  dialog .error_utd {ERROR} \
      "The server is of an unknown type. \
      This is an error. Please report to GHUI development Team" \
      {} 0 {OK}
}

proc file_unreadable_dialog {file} {
  
  dialog .error_fud {ERROR} \
      "The file \"$file\" does not exist or is not readable." \
      {} 0 {OK}
}

proc not_paused_dialog {} {
  
  dialog .error_npd {ERROR} \
      "The server is not in state \"PAUSED\". \
      You must pause the server before you attempt this action." \
      {} 0 {OK}
}

proc quit_admin_dialog {} {
  
  dialog .error_qad {Quit} \
      "You will now need to \"Re-draw\" from the \"Window\" menu, \
      for the configuration to affect the admin interface." \
      {} 0 {OK}
}
