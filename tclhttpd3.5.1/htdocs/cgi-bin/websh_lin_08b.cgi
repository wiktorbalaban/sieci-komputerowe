#!/usr/bin/tclsh
#
# websh - obsluga sesji...
#

## Sposob: 
# - id sesji przechowywany w ciasteczku po stronie klienta
# - dane sesji przechowywane w kont. plikowym na serwerze  

## Uwagi:
# - websh obsluguje sesje "niskopoziomowo"
#   ale za to mamy kontrole nad wszystkim...
# - w tym przykladzie nie uzywa sie metody przekazywania danych
#   przez url
# - id sesji powinien byc numerkiem ktorego trudno zgadnac ...
#   (obecnie to sa kolejne liczby...)

# -----------------------------------------------------

if [catch { # dbg - poczatek

load /home/mhanckow/tcl/websh/8.4/libwebsh3.6.0b4.so


## obsluga sesji ...
# - kontekst kli: id -to jest id sesji
# - kontekst ser: dane -dowolne dane; np tablica tcl
# - "sesja utworz" tworzy nowa sesje jesli w ciasteczku nie ma "id"

web::cookiecontext kli

set katalog /home/mhanckow/tcl/httpd/cgi-bin
set nazwaprogramu "aplikacjawebsh"
  # czy tego nie mozna pobrac automatycznie ???

web::filecontext ser -path $::katalog/$::nazwaprogramu%d.dat

proc sesja args {
  kli::init $::nazwaprogramu
  if {[kli::cexists id]} {
    ser::init [kli::cget id]
  } else {
    if {$args=="utworz"} {
      web::filecounter liczsesji -filename $::katalog/liczsesji.dat
      kli::cset id [liczsesji nextval]
      kli::commit
      ser::new [kli::cget id] 
    } else {
      error "musisz rozpoczac sesje poprzez glowna strone ..."
    }
  } 
}

# ---

web::command default {
  sesja utworz
  
  ser::cset dane 1000
  set dane2(imie) "Michal"
  set dane2(nazwisko) "Hanckowiak"
  ser::cset dane2 [array get dane2]
  ser::commit

  web::put "<p>A ku ku !!!</p>"
  web::put "<p><a href=[web::cmdurl komenda_a]>komenda_a</a></p>"
  web::put "<p>kli: [kli::cnames]</p>"
  web::put "<p>ser: [ser::cnames]</p>"
}

web::command komenda_a {
  sesja
  
  set dane [ser::cget dane]
  ser::cset dane [expr {$dane+1}]
  ser::commit
    # to musi byc przed put JEDYNIE dla cookiecontext!!!

  web::put "<p>to ja komenda_a</p>"
  web::put "<p>dane= $dane</p>"

  web::put "<p><a href=\"[web::cmdurl komenda_b]\">link do komenda_b</a></p>"

  web::put "<p>kli: [kli::cnames]</p>"
  web::put "<p>ser: [ser::cnames]</p>"
}

web::command komenda_b {
  sesja

  set dane [ser::cget dane]
  array set dane2 [ser::cget dane2]

  web::put "<p>to ja komenda_b</p>"
  web::put "<p>dane= $dane</p>"
  web::put "<p>dane2= [array get dane2]</p>"
  web::put "<p>kli: [kli::cnames]</p>"
  web::put "<p>ser: [ser::cnames]</p>"
}

web::dispatch

}] {web::put "<pre>errorInfo: $errorInfo</pre>"}; # dbg - koniec


