# Trivial application-direct URL for "/hello"
# The URLs under /hello are implemented by procedures that begin with "::hello::"

Direct_Url /hello	::hello::

namespace eval ::hello {
    variable x "[clock format [clock seconds]]"
}

# ::hello::/ --
#
#	This implements /hello/

proc ::hello::/ {args} {
    return "Hello, World!"
}

# ::hello::/there --
#
#	This implements /hello/there

proc ::hello::/there {args} {
    variable x
    return "Hello, World!<br>\nThe server started at $x"
}

#Direct_Url /mh ::mh::
Direct_Url /mh ::mh:: 1
 # MH staram sie uruchamiac to w watku (parametr "1")
 # czy to dziala ??? TAK!!!
 # Uwaga: jest problem z pakietem md5 (patrz poprawka w lib/thread.tcl)

namespace eval ::mh {
    variable x "[clock format [clock seconds]] i tralala !!!"
    variable licznik 0
}

proc ::mh:: {args} {
    variable licznik
    incr licznik
    for {set i 0} {$i<20} {incr i} {
      puts "mh: i=$i; thread::id=[thread::id]"
      after 1000
    }
    return "\
	Hello, World! to ja MH<br>
	(to jest $licznik wejscie na strone ...)<br>
	thread::id=[thread::id]<br>
	$args"
}

proc ::mh::/2 {args} {
    variable licznik
    incr licznik
    for {set i 0} {$i<20} {incr i} {
      puts "mh/2: i=$i; thread::id=[thread::id]"
      after 1000
    }
    return "\
	Hello, World! to ja MH<br>
	(to jest $licznik wejscie na strone ...)<br>
	thread::id=[thread::id]<br>
	$args"
}

proc ::mh::/3 {args} {
    variable licznik
    incr licznik
    for {set i 0} {$i<20} {incr i} {
      puts "mh/3: i=$i; thread::id=[thread::id]"
      after 1000
    }
    return "\
	Hello, World! to ja MH<br>
	(to jest $licznik wejscie na strone ...)<br>
	thread::id=[thread::id]<br>
	$args"
}


proc ::mh::/tutaj {args} {
    variable x
    return "Hello, World! to ja MH<br>\nThe server started at $x"
}


# kod do obslugi sesji; uruchamiac eval-em na poczatku strony .tml
# tworzy zmienne: id (id sesji) i nowy_id
#
set ::mh::obsluga_sesji {
  set cookie_id ""
  catch { set cookie_id [Cookie_Get session] }
  if {$cookie_id!=""} {
    set id [Session_Match "session $cookie_id"]
  } else {
    set id ""
  }
  set nowy_id 0
  if {$id==""} {
    set nowy_id 1
    set id [Session_Create session]
    Cookie_Set -name session -value $id
    Cookie_Save [Httpd_CurrentSocket]
  }
}

return ""
