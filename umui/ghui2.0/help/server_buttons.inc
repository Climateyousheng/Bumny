                Server Buttons
                --------------

When the Admin Interface is started for the first time, before the
servers have been started, two buttons will be displayed: "Start
Primary Server" and "Start Backup Server". For instructions on how
to start the servers see the "Introduction" help.

Once the either server has been started, and the window updated (by
selecting the "Re-draw" item from the "Window" menu), a row of buttons
will be displayed below a window that lists the last ten lines of the
server log.

Reload Log 
  The server log display does not update itself automatically. Press 
  "Reload Log" to carry out this operation.

Clear Log
  "Clear Log" deletes the server log file situated in the directory
  that contains the application database.

"Status" Button
  The Status button displays the state of the server. It should be in
  one of the four states EMPTY, RELOAD, PAUSED, ACTIVE. 
  
  EMPTY:  The server has just been started and the database has not been 
          read yet.
  RELOAD: The server is in the process of reading the database.
  PAUSED: The server is running, but users are prevented from accessing 
          it.
  ACTIVE: The server is fully active.

"Type" Button
  The Type button displays the type of the server. It should be PRIMARY
  or BACKUP. For Single Server Mode the server should be of type PRIMARY,
  for Dual Server Mode there should be one of each type. When the servers
  are in the PAUSED state, their type can be toggled by pressing the Type
  button. If you change the server types you need to select Re-configure 
  from the "Clients" menu for the change to take effect. However, you
  will not be allowed to reconfigure the servers with an illegal combination
  of server types.

Read Database
  "Read Database" reads information about all jobs and experiments from the
  database into memory.

Copy
  "Copy" copies the database from the server on which the button was pressed
  to the other server. Only relevant when running in Dual Server Mode. TAKE
  GREAT CARE WITH THIS COMMAND AS YOU MAY OVERWRITE YOUR DATABASE.

Kill
  Stops the server - the window will change so that only the Start Server 
  button will be displayed.
