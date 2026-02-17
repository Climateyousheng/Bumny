# This does not work very well. Don't know what reset button is for,
# but what it actually does, is to disable the ability to change
# selection in the right listbox until the left box is clicked again. SDM

# Reset button commented out.

proc filewalk {inw {directory ""} {file ""} } {

    global dirreq selection filter filewin env

    set filewin .filewalker
    set old [split [$inw get] "/"]
    set olddir [join [lrange $old 0 [expr [llength $old] - 2]] "/"]
    set oldfile [lindex $old [expr [llength $old] - 1]]
    set filter .*
    set selection $oldfile
    
    if { $directory=="" } {
	if {![file isdirectory $olddir]} {
	    set dirreq $env(HOME)
	} else {
	    set dirreq $olddir
	}
    } else {
	set dirreq $directory
	set selection $file
    }
	
    catch {destroy $filewin}
    filewalk_setup $filewin $inw
}

proc chdir {dir} {

  global dirreq selection filter filewin

  if {$dir==".."} {
    set old [split $dirreq "/"]
    set dirreq [join [lrange $old 0 [expr [llength $old] - 2]] "/"]
  } elseif {$dir=="."} {
    set dirreq $dirreq
  } elseif {[llength [split $dir "/"]]>1} {
    set dirreq $dir
  } else {
    set dirreq $dirreq/$dir
  }

  if {$dirreq==""} {set dirreq "/"}
  regsub "//" $dirreq "/" dirreq

  destroy $filewin.top.a.list 
  destroy $filewin.top.b.list 
  listbox $filewin.top.a.list -yscrollcommand "$filewin.top.a.scroll set" \
      -relief sunken -selectmode single -height 8 -width 15
  pack $filewin.top.a.list -side left
  listbox $filewin.top.b.list -yscrollcommand "$filewin.top.b.scroll set" \
      -relief sunken -selectmode single -height 8 -width 15
  pack $filewin.top.b.list -side left
  set command "exec ls -a $dirreq"
  foreach i [eval $command] {
    if {[file isdirectory $dirreq/$i]==1} {$filewin.top.a.list insert end $i}
    if {([file isfile $dirreq/$i]==1)&&[regexp $filter $i]} {$filewin.top.b.list insert end $i}
  }
  bind $filewin.top.a.list <Double-ButtonPress-1> {chdir [selection get]}
  bind $filewin.top.b.list <ButtonPress-1> {
#    set index [$filewin.top.b.list nearest %y]
#    $filewin.top.b.list select clear
#    $filewin.top.b.list select adjust $index
#    unset selection
    set selection [$filewin.top.b.list get active]
 }
  unset selection
  set selection [$filewin.top.b.list get 0]
}

proc chfilter {filter} {

  global filewin dirreq

  destroy $filewin.top.b.list
  listbox $filewin.top.b.list -yscrollcommand "$filewin.top.b.scroll set" \
	  -relief sunken -selectmode single -height 8 -width 15
  pack $filewin.top.b.list -side left 

  set command "exec ls -a $dirreq | egrep $filter"

  if {[catch {eval $command}]==0} {
    set files [eval $command]
  } else {
    set files ""
  }

  foreach i $files {
    if {[file isfile $dirreq/$i]} {
      $filewin.top.b.list insert end $i
    }
  }
  bind $filewin.top.a.list <Double-ButtonPress-1> {chdir [selection get]}
}

proc filewalk_setup {filewin entry_window} {

  global dirreq filter

  toplevel $filewin
  wm title $filewin File-walk
  frame $filewin.filter
  pack $filewin.filter -side top -fill both
  label $filewin.filter.lab -text "Regexp file filter : "
  entry $filewin.filter.ent -width 25 -textvariable filter -relief sunken 
  pack $filewin.filter.lab -side left
  pack $filewin.filter.ent -side left -fill both
  frame $filewin.titles
  pack $filewin.titles -side top -fill both
  label $filewin.titles.dir -text "Directories                "
  label $filewin.titles.fil -text "Files"
  pack $filewin.titles.dir $filewin.titles.fil -side left -fill both
  frame $filewin.top
  pack $filewin.top -side top -fill both
  frame $filewin.top.a -relief raised
  pack $filewin.top.a -side left -fill both
  listbox $filewin.top.a.list -yscrollcommand "$filewin.top.a.scroll set" \
	  -relief sunken -selectmode single -height 8 -width 15 
  pack $filewin.top.a.list -side left
  scrollbar $filewin.top.a.scroll -command "$filewin.top.a.list yview"
  pack $filewin.top.a.scroll -side right -fill y
  frame $filewin.top.b -relief raised
  pack $filewin.top.b -side left -fill both
  listbox $filewin.top.b.list -yscrollcommand "$filewin.top.b.scroll set" \
	  -relief sunken -selectmode single -height 8 -width 15
  pack $filewin.top.b.list -side left
  scrollbar $filewin.top.b.scroll -command "$filewin.top.b.list yview"
  pack $filewin.top.b.scroll -side right -fill y
  frame $filewin.bot -relief raised
  pack $filewin.bot -side bottom -fill x
#  button $filewin.bot.rest -text "Reset" -command {
#    set filter ".*"
#    chfilter $filter
#  }
  button $filewin.bot.filt -text "Filter" -command {chfilter $filter}
  button $filewin.bot.canc -text "Cancel" -command {destroy $filewin}
  set command "$entry_window delete 0 end ; $entry_window insert 0 \"\$dirreq/\$selection\" ; destroy $filewin"
  button $filewin.bot.exit -text "Return" -command $command
  pack $filewin.bot.exit -side left -expand 1 -padx 2m -pady 2m -ipadx 1m -ipady 1m -fill both
#  pack $filewin.bot.rest -side left -expand 1 -padx 2m -pady 2m -ipadx 1m -ipady 1m -fill both
  pack $filewin.bot.filt -side left -expand 1 -padx 2m -pady 2m -ipadx 1m -ipady 1m -fill both
  pack $filewin.bot.canc -side left -expand 1 -padx 2m -pady 2m -ipadx 1m -ipady 1m -fill both
  frame $filewin.sel
  pack $filewin.sel -side bottom -fill both
  label $filewin.sel.lab -text "Selection : "
  entry $filewin.sel.ent -width 25 -textvariable selection -relief sunken
  pack $filewin.sel.lab -side left
  pack $filewin.sel.ent -side left -fill both
  frame $filewin.dir 
  pack $filewin.dir -side bottom -fill both
  label $filewin.dir.lab -text "Directory : "
  entry $filewin.dir.ent -width 25 -textvariable dirreq -relief sunken
  pack $filewin.dir.lab -side left
  pack $filewin.dir.ent -side left -fill both 
  bind $filewin.dir.ent <Return> {chdir [$filewin.dir.ent get]}
  bind $filewin.filter.ent <Return> {chfilter $filter}
  bind $filewin.top.a.list <Double-ButtonPress-1> {chdir [selection get]}
  bind $filewin.top.b.list <ButtonPress-1> {
#    set index [$filewin.top.b.list nearest %y]
#    $filewin.top.b.list select clear
#    $filewin.top.b.list select adjust $index
#    unset selection
    set selection [$filewin.top.b.list get active]
  }
  set command "exec ls -a $dirreq"
  foreach i [eval $command] {
    if {[file isdirectory $dirreq/$i]} {$filewin.top.a.list insert end $i}
    if {[file isfile $dirreq/$i]} {$filewin.top.b.list insert end $i}
  }
}
