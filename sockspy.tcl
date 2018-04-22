package re Tk; lappend auto_path D:/Studia/SieciKomputerowe/tcllib
  # sciezke do tcllib trzba prawd. zmienic !!! (MH)

# sockspy: copyright tom poindexter 1998
# sockspy: copyright Keith Vetter 2002
#	    tpoindex@nyx.net
# version 1.0 - december 10, 1998
# version 2.0 - January, 2002 by Keith Vetter
# KPV Nov 01, 2002 - added proxy mode
# KPV Dec 21, 2002 - added extract window
# version 2.5 - February, 2003 by Don Libes
# DL Jan/Feb, 2003 - added date support, state save/restore, cmdline display
# 
# spy on conversation between a tcp client and server
#
# usage: sockspy clientPort serverHost serverPort
#  -or-	 sockspy -proxy proxyPort
#	   clientPort - port to which clients connect
#	   serverHost - machine where real server runs
#	   serverPort - port on which real server listens
#
#  e.g. to snoop on http connections to a web server:
#	sockspy 8080 www.some.com 80
#  then client web browser should use a url like:
#	 http://localhost:8080/index.html
#	 (or set your browser's proxy to use 8080 on the sockspy machine)

catch {package require uri}			;# Error handled below

array set state {
    version 2.5
    extract 0
    bbar 1
    ascii 1
    autoscroll 1
    autowrap 1
    capture 1
    msg ""
    fixed {}
    fixedbold {}
    fontSize 9
    playback ""
    gui 0
    listen ""
    title "not connected"
    proxy 0
    fname ""
    time 1
    timeFormat ""
    timeFormatDefault "%H:%M:%S "
}

# variables to save across runs
set saveList {
    state(extract)
    state(bbar)
    state(ascii)
    state(autoscroll)
    state(autowrap)
    state(proxy)
    state(fname)
    state(time)
    state(timeFormat)
    state(fontSize)
    extract(client)
    extract(server)
    extract(meta2)
    SP(proxyPort)
    SP(clntPort)
    SP(servPort)
    SP(servHost)
}

array set colors {client green server cyan meta red meta2 yellow}
array set SP {proxyPort 8080 clntPort 8080 servHost "" servPort 80}

set extract(client) {^(GET |POST |HEAD )}
set extract(server) {^(HTTP/|Location: |Content-)}
set extract(meta2) {.}
#set extract(meta) {.}

##+##########################################################################
# 
# createMain -- Creates the display
# 
proc createMain {} {
    global state colors tcl_platform
    
    wm withdraw .

    set state(fixed) [font create -family courier -size $state(fontSize)]
    set state(fixedbold) [font create -family courier -size $state(fontSize) \
		  -weight bold]

    wm title . "SockSpy -- $state(title)"
    wm resizable .  1 1
    wm protocol . WM_DELETE_WINDOW Shutdown	;# So we shut down cleanly

    #
    # Set up the menus
    #
    menu .m -tearoff 0
    . configure -menu .m
    .m add cascade -menu .m.file -label "File" -underline 0
    .m add cascade -menu .m.view -label "View" -underline 0
    .m add cascade -menu .m.help -label "Help" -underline 0
    
    menu .m.file
    .m.file add command -label "Save ..." -underline 0 -command saveOutput
    .m.file add command -label "Reconnect ..." -underline 0 -command GetSetup
    .m.file add separator
    .m.file add command -label "Exit" -underline 1 -command Shutdown
    
    menu .m.view
    .m.view add command -label " Clear" -underline 1 -command clearOutput
    .m.view add separator
    .m.view add checkbutton -label " ButtonBar" -variable state(bbar) \
	    -underline 1 -command ButtonBar
    .m.view add checkbutton -label " Extract Window" -variable state(extract) \
	    -underline 1 -command ToggleExtract
    .m.view add separator
    .m.view add command -label " + Font" -command [list doFont 1]
    .m.view add command -label " - Font" -command [list doFont -1]
    .m.view add separator
    .m.view add radiobutton -label " Hex" -underline 1 \
	    -variable state(ascii) -value 0 -command redraw
    .m.view add radiobutton -label " ASCII" -underline 1 \
	    -variable state(ascii) -value 1 -command redraw
    .m.view add separator
    .m.view add checkbutton -label " Autoscroll" -underline 5 \
	    -variable state(autoscroll)
    .m.view add checkbutton -label " Autowrap" -underline 5 \
	    -variable state(autowrap) -command ToggleWrap
    .m.view add checkbutton -label " Capture" -underline 5 \
	    -variable state(capture) -command ToggleCapture
    .m.view add separator
    .m.view add checkbutton -label " Time" \
	-variable state(time) -command redraw
    .m.view add command -label " Time Format ..." -command timestampWindow

    menu .m.help -tearoff 0
    .m.help add command -label Help -underline 1 -command Help
    .m.help add separator
    .m.help add command -label About -command About
    #
    # Title and status window
    #
    frame .bbar
    frame .cmd -relief sunken -bd 2
    radiobutton .cmd.hex -text Hex -variable state(ascii) \
	    -value 0 -command redraw
    radiobutton .cmd.ascii -text ASCII -variable state(ascii) \
	    -value 1 -command redraw
    checkbutton .cmd.autos -text Autoscroll -variable state(autoscroll)
    checkbutton .cmd.autow -text Autowrap -variable state(autowrap) \
	 -command ToggleWrap
    checkbutton .cmd.capture -text Capture -variable state(capture) \
	 -command ToggleCapture
    checkbutton .cmd.time -text Time -variable state(time) \
     -command redraw
    button .cmd.clear -text Clear -command clearOutput
    #button .cmd.incr -text "+ Font" -command [list doFont 1]
    #button .cmd.decr -text "- Font" -command [list doFont -1]
    button .cmd.save -text Save -command saveOutput
    button .cmd.kill -text Exit -command Shutdown
    pack .cmd -side top -fill x -pady 5 -in .bbar
    pack .cmd.kill .cmd.save .cmd.clear .cmd.autow .cmd.autos .cmd.capture \
    .cmd.time \
	-side right -padx 3 -pady 3
    #label .title -relief ridge -textvariable state(title)
    #.title config -font "[.title cget -font] bold"
    label .stat -textvariable state(msg) -relief ridge -anchor w

    #
    # Now for the output area of the display
    #
    scrollbar .yscroll -orient vertical -command {.out yview}
    scrollbar .xscroll -orient horizontal -command {.out xview}
    text .out -width 80 -height 50 -font $state(fixed) -bg white -setgrid 1 \
	    -yscrollcommand ".yscroll set" -xscrollcommand ".xscroll set"
    foreach t [array names colors] {
	.out tag configure $t -background $colors($t) -borderwidth 2 \
	    -relief raised -lmargin1 5 -lmargin2 5
	.out tag configure time_$t -background $colors($t) -borderwidth 2 \
	    -relief raised -lmargin1 5 -lmargin2 5 -font $state(fixedbold)
    }
    .out tag configure client2 -font $state(fixedbold)
    .out tag raise sel				;# Selection is most prominent

    grid .bbar -       -row 0 -sticky ew
    grid .out .yscroll -row 1 -sticky news
    grid .xscroll      -row 2 -sticky ew
    grid .stat -       -row 3 -sticky ew
    grid rowconfigure	 . 1 -weight 1
    grid columnconfigure . 0 -weight 1

    bind .out <Control-l> clearOutput
    bind all <Alt-c> {console show}
    focus .out
    wm geometry . +10+10
}
##+##########################################################################
# 
# createExtract -- Creates the extract toplevel window.
# 
proc createExtract {} {
    global state colors
    
    if {[winfo exists .extract]} {
	wm deiconify .extract
	return
    }
    set top ".extract"
    toplevel $top
    wm title $top "SockSpy Extract"
    wm protocol $top WM_DELETE_WINDOW [list ToggleExtract -1]
    if {[regexp {(\+[0-9]+)(\+[0-9]+)$} [wm geom .] => wx wy]} {
	wm geom $top "+[expr {$wx+35+[winfo width .]}]+[expr {$wy+15}]"
    }

    frame $top.top -bd 2 -relief ridge
    label $top.top.c  -text "Client Filter" -anchor e
    entry $top.top.ce -textvariable extract(client) -bg $colors(client)
    label $top.top.s  -text "Server Filter" -anchor e
    entry $top.top.se -textvariable extract(server) -bg $colors(server)
    label $top.top.m  -text "Metadata Filter" -anchor e
    entry $top.top.me -textvariable extract(meta2) -bg $colors(meta2)
    
    text $top.out -width 80 -height 20 -font $state(fixed) -bg beige \
	-setgrid 1 -wrap none -yscrollcommand [list $top.yscroll set] \
	-xscrollcommand [list $top.xscroll set]
    foreach t [array names colors] {
	$top.out tag configure $t -background $colors($t) -borderwidth 2 \
	    -relief raised -lmargin1 5 -lmargin2 5
	$top.out tag configure time_$t -background $colors($t) -borderwidth 2 \
	    -relief raised -lmargin1 5 -lmargin2 5 -font $state(fixedbold)
    }
    $top.out tag raise sel			;# Selection is most prominent

    scrollbar $top.yscroll -orient vertical -command [list $top.out yview]
    scrollbar $top.xscroll -orient horizontal -command [list $top.out xview]
    grid $top.top - -row 0     -sticky ew -ipady 10
    grid $top.out $top.yscroll -sticky news
    grid $top.xscroll	       -sticky ew

    grid rowconfigure	 $top 1 -weight 1
    grid columnconfigure $top 0 -weight 1

    grid $top.top.c $top.top.ce -row 0 -sticky ew
    grid $top.top.s $top.top.se	       -sticky ew
    grid $top.top.m $top.top.me	       -sticky ew
    grid columnconfigure $top.top 1 -weight 1
    grid columnconfigure $top.top 2 -minsize 10
}
##+##########################################################################
# 
# doFont -- Changes the size of the font used for the display text
# 
proc doFont {delta} {
    global state

    incr state(fontSize) $delta
    font configure $state(fixed) -size $state(fontSize)
    font configure $state(fixedbold) -size $state(fontSize)
}
##+##########################################################################
# 
# clearOutput -- Erases the content of the output window
# 
proc clearOutput {} {
    global state
    if {$state(gui)} {
	.out delete 0.0 end
	catch {.extract.out delete 0.0 end}
    }
    set state(playback) ""
}
##+##########################################################################
# 
# redraw -- Redraws the contents of the output window.
#
# It does this by replaying the input stream.
# 
proc redraw {} {
    global state 

    set save_as $state(autoscroll)		;# Disable autoscrolling
    set state(autoscroll) 0

    set p $state(playback)			;# Save what gets displayed
    clearOutput					;# Erase current screen
    foreach {who data time} $p {		;# Replay the input stream
	insertData $who $data $time 1
    }
    set state(autoscroll) $save_as
}
##+##########################################################################
# 
# saveOutput -- Saves the content of the output window. 
# 
# It uses the playback stream as its data source.
# 
proc saveOutput {} {
    global state but

    set but -1
    set but [tk_dialog .what "SockSpy Save" "Save which window?" \
	    questhead 2 server client both cancel]

    if {$but == -1 || $but == 3} {
	return
    }
    set file [tk_getSaveFile -parent . -initialfile $state(fname)]
    if {$file == ""} return

    set state(fname) $file
    if {[catch {open $file w} fd]} {
	tk_messageBox -message "file $file cannot be opened" -icon error \
		-type ok
	return
    }
    fconfigure $fd -translation binary
    foreach {who data time} $state(playback) {
	if {$who == "meta" || $who == "meta2"} continue
	if {$but == 2 || ($but == 0 && $who == "server") || \
		($but == 1 && $who == "client")} {
	    if {$state(time)} {
		puts $fd [timestamp $time]
	    }
	    puts $fd $data
	}
    }
    close $fd
    bell
}
##+##########################################################################
# 
# printable -- Replaces all unprintable characters into dots.
# 
proc printable {s {spaces 0}} {
    regsub -all {[^\x09\x20-\x7e]} $s "." n
    if {$spaces} {
	regsub -all { } $n "_" n
    }
    return $n;
}
##+##########################################################################
# 
# insertData -- Inserts data into the output window. WHO tells us if it is
# from the client, server or meta.
# 
proc insertData {who data {time {}} {force 0}} {
    global state
    array set prefix {meta = meta2 = client > server <}

    if {$time == ""} {				;# If not set, then set to now
	set time [clock seconds]
    }
    set timestamp [timestamp $time]

    DoExtract $who $data $timestamp		;# Display any extracted data
    if {! $force && ! $state(capture)} return	;# No display w/o capture on
    lappend state(playback) $who $data $time	;# Save for redraw and saving
    
    if {$state(ascii) || [regexp {^meta2?$} $who] } {
	regsub -all \r $data "" data
	foreach line [split $data \n] {
	    set line [printable $line]
	    set tag $who
	    if {$tag == "client" && [regexp -nocase {^get |^post } $line]} {
		lappend tag client2
	    }
	    if {$state(gui)} {
		.out insert end "$timestamp" time_$tag "$line\n" $tag
	    } else {
		puts "$timestamp$prefix($who)$line"
	    }
	}
    } else {					;# Hex output
	while {[string length $data]} {
	    set line [string range $data 0 15]
	    set data [string range $data [string length $line] end]
	    binary scan $line H* hex
	    regsub -all {([0-9a-f][0-9a-f])} $hex {\1 } hex
	    set line [format "%-48.48s	%-16.16s\n" $hex [printable $line 1]] 
	    if {$state(gui)} {
		.out insert end "$timestamp" time_$who "$line" $who
	    } else {
		puts "$timestamp$prefix(who)$line"
	    }
	}
    }
    if {$state(autoscroll) && $state(gui)} {
	.out see end
    }
}
##+##########################################################################
#
# timestampInit -- Initialize timestamp support
#
proc timestampInit {} {
    global state

    set state(timeFormat) $state(timeFormatDefault)
}
##+##########################################################################
#
# timestamp -- Produce printable timestamps
#
# Note that it is the user's responsibility to make sure the
# user-supplied format ends with a delimiter or separator such as a
# space or colon. The timestamp code itself checks whether or not it
# should do anything to simplify the many different places in the code
# from which can be called.

proc timestamp {time} {
    global state
    
    if {! $state(time)} { return "" }
    return [clock format $time -format $state(timeFormat)]
}
##+###########################################################################
#
# timestampWindow -- Dialog for the user to configure the timestamp format.
#
proc timestampWindow {} {
    global state

    set state(oldTimeFormat) $state(timeFormat)

    set w .tf2
    destroy .tf
    toplevel .tf
    wm title .tf "SockSpy Time Format"

    set txt "Edit the format used for timestamps. "
    append txt "See Tcl's clock command documentation for a complete "
    append txt "description of acceptable formats."
    
    frame .tf.top -bd 2 -relief raised -padx 5
    
    message .tf.t -aspect 500 -text $txt
    label .tf.l -text "Format: "
    entry .tf.e -textvariable state(timeFormat)
    button .tf.default -text Default -width 10 -command {tfButton default}
    button .tf.ok -text OK -width 10 -command {tfButton ok}
    button .tf.cancel -text Cancel -width 10 -command {tfButton cancel}
    
    grid .tf.top -row 0 -column 0 -columnspan 4 -sticky ew -padx 10 -pady 10
    grid columnconfigure .tf 0 -weight 1
    grid x .tf.default .tf.ok .tf.cancel -padx 5 -sticky ew
    grid rowconfigure .tf 2 -minsize 8

    grid .tf.t - -in .tf.top -row 0
    grid .tf.l .tf.e -in .tf.top -row 1 -pady 10 -sticky ew
    grid columnconfigure .tf.top 1 -weight 1
    grid columnconfigure .tf.top 2 -minsize 10

    focus .tf.e
    .tf.e icursor end
    .tf.e select range 0 end
}
##+##########################################################################
# 
# tfButton -- handles button clicks on the timestamp dialog
# 
proc tfButton {who} {
    if {$who == "defaut"} {
	set ::state(timeFormat) $::state(timeFormatDefault)
    } elseif {$who == "ok"} {
	destroy .tf
	redraw
    } elseif {$who == "cancel"} {
	set ::state(timeFormat) $::state(oldTimeFormat)
	destroy .tf
    }
}
##+##########################################################################
# 
# INFO
# 
# Puts up an informational message both in the output window and
# in the status window.
# 
proc INFO {msg {who meta} {time {}} {display 0}} {
    global state
    set state(msg) $msg
    insertData $who $msg $time $display
}
proc ERROR {emsg} {
    if {$::state(gui)} {
	tk_messageBox -title "SockSpy Error" -message $emsg -icon error
    } else {
	puts $emsg
    }
}
##+##########################################################################
# 
# sockReadable -- Called when there is data available on the fromSocket
# 
proc sockReadable {fromSock toSock who} {
    global state
    set data [read $fromSock]
    if {[string length $data] == 0} {
	close $fromSock
	catch { close $toSock }
	insertData meta "----- closed connection -----"
	INFO "waiting for new connection..." 
	return
    }
    if {$toSock == ""} {			;# Not connected yet
	ProxyConnect $fromSock $data		;# Do proxy forwarding
    } else {
	catch { puts -nonewline $toSock $data } ;# Forward if we have a socket
    }
    insertData $who $data
    update
}
##+##########################################################################
# 
# ProxyConnect
# 
# Called from a new socket connection when we have to determing who
# to forward to.
# 
proc ProxyConnect {fromSock data} {
    set line1 [lindex [split $data \r] 0]
    set bad [regexp -nocase {(http:[^ ]+)} $line1 => uri]
    if {$bad == 0} {
	INFO "ERROR: cannot extract URI from '$line1'"
	close $fromSock
	insertData meta "----- closed connection -----"
	insertData meta "waiting for new connection..." 
    }
    set state(uri) $uri				;# For debugging
    array set URI [::uri::split $uri]
    if {$URI(port) == ""} { set URI(port) 80 }
    set bad [catch {set sockServ [socket $URI(host) $URI(port)]} reason]
    if {$bad} {
	set msg "cannot connect to $URI(host):$URI(port) => $reason"
	INFO $msg
	close $fromSock
	ERROR $msg
	insertData meta "----- closed connection -----"
	insertData meta "waiting for new connection..." 
	return
    }
    INFO "fowarding to $URI(host):$URI(port)" meta2
    fileevent $fromSock readable \
	[list sockReadable $fromSock $sockServ client]
    fconfigure $sockServ -blocking 0 -buffering none -translation binary
    fileevent $sockServ readable \
	[list sockReadable $sockServ $fromSock server]
    puts -nonewline $sockServ $data
}
##+##########################################################################
# 
# clntConnect -- Called when we get a new client connection
# 
proc clntConnect {sockClnt ip port} {
    global state SP

    set state(sockClnt) $sockClnt
    set state(meta) ""
    
    INFO "connect from [fconfigure $sockClnt -sockname] $port" meta2
    if {$state(proxy) || $SP(servHost) == {} || $SP(servHost) == "none"} {
	set sockServ ""
    } else {
	set n [catch {set sockServ [socket $SP(servHost) $SP(servPort)]} reason]
	if {$n} {
	    INFO "cannot connect: $reason"
	    close $sockClnt
	    ERROR "cannot connect to $SP(servHost) $SP(servPort): $reason"
	    insertData meta "----- closed connection -----"
	    insertData meta "waiting for new connection..." 
	    
	}
	INFO "connecting to $SP(servHost):$SP(servPort)" meta2
    }

    ;# Configure connection to the client
    fconfigure $sockClnt -blocking 0 -buffering none -translation binary
    fileevent $sockClnt readable \
	    [list sockReadable $sockClnt $sockServ client]

    ;# Configure connection to the server
    if {[string length $sockServ]} {
	fconfigure $sockServ -blocking 0 -buffering none -translation binary
	fileevent $sockServ readable \
		[list sockReadable $sockServ $sockClnt server]
    }
}
##+##########################################################################
# 
# DoListen
# 
# Opens the socket server to listen for connections. It first closes it if
# it is already open.
# 
proc DoListen {} {
    global state SP

    set rval 1
    catch {close $state(sockClnt)}		;# Only the last open connection
    
    ;# Close old listener if it exists
    if {$state(listen) != ""} {
	set n [catch {close $state(listen)} emsg]
	if {$n} { INFO "socket close error: $emsg"}
	set state(listen) ""
	update					;# Need else socket below fails
    }

    # Listen on clntPort or proxyPort for incoming connections
    set port $SP(clntPort)
    if {$state(proxy)} {set port $SP(proxyPort)}
    set n [catch {set state(listen) [socket -server clntConnect $port]} emsg]
    
    if {$n} {
	INFO "socket open error: $emsg"
	set state(title) "not connected"
	set rval 0
    } else {
	if {$state(proxy)} {
	    set state(title) "proxy localhost:$SP(proxyPort)"
	} else {
	    set state(title) "localhost:$SP(clntPort) <--> "
	    append state(title) "$SP(servHost):$SP(servPort)"
	}
	INFO $state(title)
	INFO "waiting for new connection..."
    }
    wm title . "SockSpy -- $state(title)"
    return $rval
}
##+##########################################################################
# 
# GetSetup -- Prompts the user for client port, server host and server port
# 
proc GetSetup {} {
    global state SP ok
    array set save [array get SP]
    set ok 0					;# Assume cancelling

    ;# Put in some default values
    if {![string length $SP(proxyPort)]} {set SP(proxyPort) 8080}
    if {![string length $SP(clntPort)]}	 {set SP(clntPort) 8080}
    if {![string length $SP(servPort)]}	 {set SP(servPort) 80}
    
    if {! $state(gui)} {
	catch {close $state(listen)}

	set d "no" ; if {$state(proxy)} { set d yes }
	set p [Prompt "Proxy mode" $d]
	if {[regexp -nocase {^y$|^yes$} $p]} {
	    set state(proxy) 1
	    set SP(proxyPort) [Prompt "proxy port" $SP(proxyPort)]
	} else {
	    set state(proxy) 0
	    set SP(clntPort) [Prompt "Client port" $SP(clntPort)]
	    set SP(servHost) [Prompt "Server host" $SP(servHost)]
	    set SP(servPort) [Prompt "Server port" $SP(servPort)]
	}
	DoListen
	return
    } 

    destroy .dlg
    toplevel .dlg
    wm title .dlg "SockSpy Setup"
    wm geom .dlg +176+176
    #wm transient .dlg .
    
    label .dlg.top -bd 2 -relief raised
    set msg    "You can configure SockSpy to either forward data\n"
    append msg "a fixed server and port or to use the HTTP Proxy\n"
    append msg "protocol to dynamically determine the server and\n"
    append msg "port to forward data to."

    frame .dlg.fforward
    frame .dlg.fproxy
    frame .dlg.fcmdline

    label .dlg.msg -text $msg -justify left
    radiobutton .dlg.forward -text "Use fixed server forwarding" \
	-variable state(proxy)	-value 0 -anchor w -command GetSetup2
    label .dlg.fl1 -text "Client Port:" -anchor e
    entry .dlg.fe1 -textvariable SP(clntPort)

    label .dlg.fl2 -text "Server Host:" -anchor e
    entry .dlg.fe2 -textvariable SP(servHost)
    label .dlg.fl3 -text "Server Port:" -anchor e
    entry .dlg.fe3 -textvariable SP(servPort)
    
    radiobutton .dlg.proxy -text "Use HTTP Proxying" \
	-variable state(proxy)	-value 1 -anchor w -command GetSetup2
    label .dlg.pl1 -text "Proxy Port:" -anchor e
    entry .dlg.pe1 -textvariable SP(proxyPort)

    label .dlg.cllabel -text "Command Line Equivalent"
    entry .dlg.clvar -textvariable SP(cmdLine) \
    -borderwidth 2 -relief sunken
    # -state readonly doesn't seem to work, sigh

    button .dlg.ok -text OK -width 10 -command ValidForm
    button .dlg.cancel -text Cancel -width 10 -command [list destroy .dlg]
    
    grid .dlg.top -row 0 -column 0 -columnspan 3 -sticky ew -padx 10 -pady 10
    grid columnconfigure .dlg 0 -weight 1
    grid x .dlg.ok .dlg.cancel -padx 10
    grid configure .dlg.ok -padx 0
    grid rowconfigure .dlg 2 -minsize 8
    
    pack .dlg.msg -in .dlg.top -side top -fill x -padx 10 -pady 5
    pack .dlg.fforward .dlg.fproxy .dlg.fcmdline -in .dlg.top \
	-side top -fill x -padx 10 -pady 10
    
    grid .dlg.cllabel -in .dlg.fcmdline -row 0 -column 0 -sticky w 
    grid .dlg.clvar -in .dlg.fcmdline -row 1 -column 0 -sticky ew
    grid columnconfigure .dlg.fcmdline 0 -weight 1
    # no need for row/col configure

    grid .dlg.proxy - - -in .dlg.fproxy -sticky w
    grid x .dlg.pl1 .dlg.pe1 -in .dlg.fproxy -sticky ew
    grid columnconfigure .dlg.fproxy 0 -minsize .2i
    grid columnconfigure .dlg.fproxy 2 -weight 1
    grid columnconfigure .dlg.fproxy 3 -minsize 10
    grid rowconfigure .dlg.fproxy 2 -minsize 10

    grid .dlg.forward - - -in .dlg.fforward -sticky w
    grid x .dlg.fl1 .dlg.fe1 -in .dlg.fforward -sticky ew
    grid x .dlg.fl2 .dlg.fe2 -in .dlg.fforward -sticky ew
    grid x .dlg.fl3 .dlg.fe3 -in .dlg.fforward -sticky ew
    grid columnconfigure .dlg.fforward 0 -minsize .2i
    grid columnconfigure .dlg.fforward 2 -weight 1
    grid columnconfigure .dlg.fforward 3 -minsize 10
    grid rowconfigure .dlg.fforward 4 -minsize 10
    raise .dlg

    bind .dlg.forward <Return>	[bind all <Key-Tab>]
    bind .dlg.proxy <Return>  [bind all <Key-Tab>]
    bind .dlg.fe1 <Return> [bind all <Key-Tab>]
    bind .dlg.fe2 <Return> [bind all <Key-Tab>]
    bind .dlg.fe3 <Return> [list .dlg.ok invoke]
    bind .dlg.pe1 <Return> [list .dlg.ok invoke]

    GetSetup2
    .dlg.pe1 icursor end
    .dlg.fe2 icursor end

    # trace all variables involved in the Setup window 
    trace variable state(proxy) w cmdlineUpdate
    trace variable SP w cmdlineUpdate
    cmdlineUpdate SP servHost w

    if {$state(proxy)} { focus -force .dlg.pe1 } { focus -force .dlg.fe2 }

    raise .dlg
    tkwait window .dlg
    wm deiconify .  

    if {$ok} {
	DoListen
    } else {
	array set SP [array get save]
    }
}
##+##########################################################################
# 
# GetSetup2 -- toggles between forwarding and proxying modes in the dialog
# 
proc GetSetup2 {} {
    global state
    array set s {1 normal 0 disabled}
    if {! $state(proxy)} { array set s {0 normal 1 disabled} }
    
    .dlg.pl1 config -state $s(1)
    .dlg.pe1 config -state $s(1)
    foreach w {1 2 3} {
	.dlg.fl$w config -state $s(0)
	.dlg.fe$w config -state $s(0)
    }
}
##+##########################################################################
# 
# ValidForm -- if setup dialog has valid entries then kill the dialog
# 
proc ValidForm {} {
    global state SP ok
    set ok 0
    if {$state(proxy)} {
	if {$SP(proxyPort) != ""} {set ok 1}
    } elseif {$SP(clntPort) !="" && $SP(servHost) !="" && $SP(servPort) !=""} {
	set ok 1
    }
    if {$ok} {destroy .dlg}
    return $ok
}
##+#########################################################################
#
# cmdlineUpdate
#
# cmdlineUpdate watches the connection variables and updates the command-line
# equivalent.
#
proc cmdlineUpdate {X elt X} {
    global SP

    # Check that port values are integers and that server host is not empty.
    if {$::state(proxy)} {
	set SP(cmdLine) "sockspy -proxy $SP(proxyPort)"
	if {! [string is integer -strict $SP(proxyPort)]} {
	    set SP(cmdLine) "none (invalid proxy port above)"
	}
	return
    }
    
    if {$SP(servHost) == ""} {
	set SP(cmdLine) "none (invalid server host above)"
	return
    }
    foreach elt {clntPort servPort} lbl {"client port" "server port"} {
	if {! [string is integer -strict $SP($elt)]} {
	    set SP(cmdLine) "none (invalid $lbl above)"
	    return
	}
    }
    set SP(cmdLine) "sockspy $SP(clntPort) $SP(servHost) $SP(servPort)"
}
##+##########################################################################
# 
# Prompt -- Non-gui way to get input from the user.
# 
proc Prompt {prompt {default ""}} {
    if {$default != ""} {
	puts -nonewline "$prompt ($default): "
    } else {
	puts -nonewline "$prompt: "
    }
    flush stdout
    set n [gets stdin line]

    if {$n == 0 && $default != ""} {
	set line $default
    }
    return $line
}
##+##########################################################################
# 
# Shutdown -- Closes the listen port before exiting
# 
proc Shutdown {} {
    global state

    catch {close $state(listen)}
    stateSaveReal				;# save all state info NOW!
    exit
}
##+##########################################################################
# 
# ButtonBar -- Toggles the visibility of the button bar
# 
proc ButtonBar {} {
    global state

    if {$state(bbar)} {				;# Need to add button bar
	pack .cmd -side top -fill x -pady 5 -in .bbar
    } else {
	pack forget .cmd
	.bbar config -height 1			;# Need this to give remove gap
    }
}
##+##########################################################################
# 
# ToggleExtract -- Toggles the visibility of the extract window
# 
proc ToggleExtract {{how 0}} {
    global state

    if {$how == -1} {				;# Hard kill
	destroy .extract
	set state(extract) 0
	return
    }
    if {$state(extract)} {
	createExtract
    } else {
	catch {wm withdraw .extract}
    }
}
##+##########################################################################
# 
# ToggleWrap -- turns on or off wrap in the text window
# 
proc ToggleWrap {} {
    global state
    array set x {0 none 1 char}
    .out configure -wrap $x($state(autowrap))
}
##+##########################################################################
# 
# ToggleCapture -- puts up a help message
# 
proc ToggleCapture {} {
    global state
    if {$state(capture)} {
	INFO "Data capture display enabled" meta
	.out config -bg white
    } else {
	INFO "Data capture display disabled" meta 1
	.out config -bg grey88
    }
}
##+##########################################################################
# 
# Help -- a simple help system
# 
proc Help {} {
    destroy .help
    toplevel .help
    wm title .help "SockSpy Help"
    wm geom .help "+[expr {[winfo x .] + 50}]+[expr {[winfo y .] + 50}]"

    text .help.t -relief raised -wrap word -width 70 -height 25 \
    -padx 10 -pady 10 -cursor {} -yscrollcommand {.help.sb set}
    scrollbar .help.sb -orient vertical -command {.help.t yview}
    button .help.dismiss -text Dismiss -command {destroy .help}
    pack .help.dismiss -side bottom -pady 10
    pack .help.sb -side right -fill y
    pack .help.t -side top -expand 1 -fill both

    set bold "[font actual [.help.t cget -font]] -weight bold"
    set fixed "[font actual [.help.t cget -font]] -family courier"
    .help.t tag config title -justify center -foregr red -font "Times 20 bold"
    .help.t tag configure title2 -justify center -font "Times 12 bold"
    .help.t tag configure header -font $bold
    .help.t tag configure n -lmargin1 15 -lmargin2 15
    .help.t tag configure fixed -font $fixed -lmargin1 25 -lmargin2 55

    .help.t insert end "SockSpy\n" title
    .help.t insert end "Authors: Tom Poindexter and Keith Vetter\n\n" title2

    set m "SockSpy lets you watch the conversation of a tcp client and server. "
    append m "SockSpy acts much like a gateway: it waits for a tcp connection, "
    append m "then connects to the real server. Data from the client is passed "
    append m "on to the server, and data from the server is passed onto the "
    append m "client.\n\n"

    append m "Along the way, the data streams are also displayed in text "
    append m "widget with data sent from the client displayed in green, data "
    append m "from the server in blue and connection metadata in red. The data "
    append m "can be displayed as printable ASCII or both hex and "
    append m "printables.\n\n"
    .help.t insert end "What is SockSpy?\n" header $m n

    set m "Why might you want to use SockSpy? Debugging tcp client/server "
    append m "programs, examining protocols and diagnosing network problems "
    append m "are top candidates. Perhaps you just want to figure out how "
    append m "something works. I've used it to bypass firewalls, to rediscover "
    append m "my lost smtp password, to access a news server on a remote "
    append m "network, etc.\n\nIt's not a replacement for heavy-duty tools "
    append m "such as 'tcpdump' and other passive packet sniffers. On the "
    append m "other hand, SockSpy doesn't require any special privileges to "
    append m "run (unless of course, you try to listen on a Unix reserved tcp "
    append m "port less than 1024.)\n\n"
    .help.t insert end "Why Use SockSpy?\n" header $m n

    set m "Just double click on SockSpy to start it. You will be prompted for "
    append m "various connection parameters described below.\n\n"
    append m "Alternatively, you can specify the connection parameters on the "
    append m "command line. This is also how you can run SockSpy in text mode "
    append m "without a GUI.\n\n"
    append m "To start SockSpy from the command line:\n"
    .help.t insert end "How to Use SockSpy\n" header $m n
    
    set m "$ sockspy <listen-port> <server-host> <server-port>\n  or\n"
    append m "$ sockspy -proxy <proxy-port>\n\n"
    .help.t insert end $m fixed

    set m "To start SockSpy in text mode without a GUI:\n"
    .help.t insert end $m n
    set m "$ tclsh sockspy <listen-port> <server-host> <server-port>\n	or\n"
    append m "$ tclsh sockspy -proxy <proxy-port>\n\n"
    .help.t insert end $m fixed

    set m    "<listen-port>: the tcp port on which to listen. Clients should "
    append m "connect to this port.\n"
    append m "<server-host>:  the host where the real server runs.\n"
    append m "<server-port>:  the tcp port on which the real server listens.\n"
    append m "<proxy-port>:  the tcp port on which to listen in proxy-mode.\n\n"
    .help.t insert end $m n

    set m "In proxy mode SockSpy works like a simple HTTP proxy server. "
    append m "Instead of forwarding to a fixed server and port, it follows the "
    append m "HTTP proxy protocol and reads the server information from the "
    append m "first line of HTTP request.\n\n"
    append m "You can turn on proxy mode by selecting it in the SockSpy Setup "
    append m "dialog, or by specifying -proxy on the command line.\n\n"
    .help.t insert end "Proxy Mode\n" header $m n

    set m "The extract window lets you extract specific parts of the "
    append m "data stream. As data arrives from the client, server, or as "
    append m "metadata, it gets matched against the appropriate regular "
    append m "expression filter. If it matches, the data gets displayed "
    append m "in the extract window. (Malformed regular expression are "
    append m "silently ignored.)\n\n"
    .help.t insert end "Extract Window\n" header $m n

    set m "To spy on HTTP connections to a server, type:\n"
    .help.t insert end "Example\n" header $m n
    .help.t insert end "  sockspy 8080 www.some.com 80\n" fixed
    .help.t insert end "and point your browser to\n" n
    .help.t insert end "  http://localhost:8080/index.html\n\n" fixed
    .help.t insert end "Alternatively, you could configure your browser to " n
    .help.t insert end "use localhost and port 8000 as its proxy, and then " n
    .help.t insert end "type:\n" n
    .help.t insert end "  sockspy -proxy 8000\n" fixed
    .help.t insert end "and user your browser normally.\n" n
    
    .help.t config -state disabled
}
##+##########################################################################
# 
# About -- simple about box
# 
proc About {} {
    set m "SockSpy  version $::state(version)\n"
    append m "by Tom Poindexter and Keith Vetter\n"
    append m "Copyright 1998-[clock format [clock seconds] -format %Y]\n\n"
    append m "A program to eavesdrop on a tcp client server conversation."
    tk_messageBox -icon info -title "About SockSpy" -message $m -parent .
}
##+##########################################################################
# 
# DoExtract -- Displays any data matching the RE in the extract window
# 
proc DoExtract {who data timestamp} {
    global state extract

    if {! $state(gui)} return
    if {! [info exists extract($who)]} return
    if {! [winfo exists .extract]} return
    
    regsub -all \r $data "" data
    foreach line [split $data \n] {
	if {$extract($who) == ""} continue
	catch {
	    if {[regexp -nocase $extract($who) $line]} {
		.extract.out insert end "$timestamp" time_$who
		.extract.out insert end "$line\n" $who
	    }
	}
    }
    if {$state(autoscroll)} {
	.extract.out see end
    }
}
##+##########################################################################
# 
# stateRestore - Initialize save/restore package and do restore.
# 
proc stateRestore {} {
    global env state SP extract

    switch $::tcl_platform(platform) "macintosh" {
	set stateFile [file join $env(PREF_FOLDER) "SockSpy Preferences"]
    } "windows" {
	set stateFile [file join $env(HOME) "sockspy.cfg"]
    } "unix" {
	if {[info exists env(DOTDIR)]} {
	    set stateFile [file join $env(DOTDIR) .sockspy]
	} else {
	    set stateFile [file join $env(HOME) .sockspy]
	}
    }
    
    # complain only if it exists and we fail to read it successsfully
    if {[file exists $stateFile]} {
	uplevel #0 source $stateFile
    }
    
    set state(stateFile) $stateFile
    
    foreach v $::saveList {
	trace variable $v w stateSave
    }
}
##+#########################################################################
#
# stateSave and stateSaveReal - Save program state.
#
# Two procs are used to do this.  stateSave is called to schedule the save.
# stateSaveReal is called to actually do the save.
#
# stateSave schedules the save a short time in the future to avoid interfering
# with the UI.	This is especially a problem with the "extract" variables which
# aren't edited from a modal dialogue and thus have no associated "OK" button
# to tell us when to save them.	 (The alternative would be to save them after
# every keystroke - yuk.)
#
proc stateSave {a b c} {
    catch {after cancel $::state(saveId)}
    set ::state(saveId) [after 5000 stateSaveReal]
}

proc stateSaveReal {} {
    global state SP extract

    # silently ignore open failure
    if {[catch {open $state(stateFile) w} sf]} return

    set now [clock format [clock seconds] -format %c]
    puts $sf "# SockSpy Initialization File"
    puts $sf "# Written by SockSpy $state(version) on $now."
    puts $sf "#"
    puts $sf "# Warning: If you edit this file while SockSpy is running, "
    puts $sf "# edits will be lost! Also, only edit the lines already here. "
    puts $sf "# If you add procs or more variables, they will not be saved."
    
    puts $sf ""
    foreach v $::saveList {
	puts $sf "set $v \"[string map {[ \\[ \\ \\\\} [set $v]]\""
    }
    close $sf
}

################################################################
################################################################
################################################################

set state(gui) [info exists tk_version]
if {[catch {package present uri}]} {
    ERROR "ERROR: SockSpy requires the uri package from tcllib."
    exit 1
}
    
timestampInit
stateRestore

if {$state(gui)} createMain

if {[lindex $argv 0] == "-local"} {
    set argv [list 8080 localhost 80]
    set argc 3
}

if {[lindex $argv 0] == "-proxy"} {
    set state(proxy) 1
    if {$argc == 2} {
	set SP(proxyPort) [lindex $argv 1]
	DoListen
    } else {
	GetSetup
    }
} else {
    if {$argc >= 1} { set SP(clntPort) [lindex $argv 0] }
    if {$argc >= 2} { set SP(servHost) [lindex $argv 1] }
    if {$argc >= 3} { set SP(servPort) [lindex $argv 2] }
    if {$argc >= 3} {
	DoListen
    } else {
	GetSetup
    }
}

if {$state(extract)} createExtract

if {! $state(gui)} {
    vwait forever				;# tclsh needs this
} else {
    wm deiconify .
}
